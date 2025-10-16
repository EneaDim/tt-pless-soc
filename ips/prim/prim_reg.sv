module prim_reg
  import prim_reg_pkg::*;
#(
  parameter int            DW       = 32,        // Data width
  parameter logic [DW-1:0] RESVAL   = '0,        // Reset value of the register
  parameter sw_access_e    SwAccess = SwAccessRW // Software access type
) (
  input logic clk_i,  // Clock input
  input logic rst_ni, // Asynchronous reset, active low

  // --------------------------------------------------------------------------
  // SW Interface: Used by software/firmware for register accesses
  // --------------------------------------------------------------------------
  input  logic          we, // Write enable (or read pulse if SwAccess is RC)
  input  logic [DW-1:0] wd, // Write data from SW
  output logic [DW-1:0] ds, // Write data that will be written into register
  output logic [DW-1:0] qs, // Readable register value from software view

  // --------------------------------------------------------------------------
  // HW Interface: Used by hardware logic to modify or observe register
  // --------------------------------------------------------------------------
  input  logic          de, // Data enable from HW (when HW wants to update)
  input  logic [DW-1:0] d,  // Data input from HW
  output logic          qe, // Qualified enable output (write occurred)
  output logic [DW-1:0] q   // Internal register value (flop output)
);

  // Internal signals for write arbitration
  logic          wr_en;    // Internal write enable
  logic [DW-1:0] wr_data;  // Internal data to be written

  // --------------------------------------------------------------------------
  // Write arbitration logic based on SW access type
  // --------------------------------------------------------------------------

  // Software RW or WO access: SW has priority over HW
  if (SwAccess inside {SwAccessRW, SwAccessWO}) begin : gen_w
    assign wr_en   = we | de;
    assign wr_data = we ? wd : d;
    logic [DW-1:0] unused_q;
    assign unused_q = q; // Prevent lint warnings

  end else if (SwAccess == SwAccessRO) begin : gen_ro
    assign wr_en   = de;
    assign wr_data = d;
    logic          unused_we;
    logic [DW-1:0] unused_wd, unused_q;
    assign unused_we = we;
    assign unused_wd = wd;
    assign unused_q  = q;

  end else if (SwAccess == SwAccessW1S) begin : gen_w1s
    // Write 1 to set: HW tries to clear; SW sets
    // OR operation allows SW to assert bits
    assign wr_en   = we | de;
    assign wr_data = (de ? d : q) | (we ? wd : '0);

  end else if (SwAccess == SwAccessW1C) begin : gen_w1c
    // Write 1 to clear: HW tries to set; SW clears
    // AND with complement of SW data allows clearing
    assign wr_en   = we | de;
    assign wr_data = (de ? d : q) & (we ? ~wd : '1);

  end else if (SwAccess == SwAccessW0C) begin : gen_w0c
    // Write 0 to clear: HW tries to set; SW clears with zero
    assign wr_en   = we | de;
    assign wr_data = (de ? d : q) & (we ? wd : '1);

  end else if (SwAccess == SwAccessRC) begin : gen_rc
    // Read to clear: SW pulse acts as read+clear trigger
    assign wr_en   = we | de;
    assign wr_data = (de ? d : q) & (we ? '0 : '1);
    logic [DW-1:0] unused_wd;
    assign unused_wd = wd;

  end else begin : gen_hw
    // Default fallback: only HW can write
    assign wr_en   = de;
    assign wr_data = d;
    logic          unused_we;
    logic [DW-1:0] unused_wd, unused_q;
    assign unused_we = we;
    assign unused_wd = wd;
    assign unused_q  = q;
  end

  // --------------------------------------------------------------------------
  // Register flop logic
  // --------------------------------------------------------------------------
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q <= RESVAL;  // Reset value
    end else if (wr_en) begin
      q <= wr_data; // Write new value
    end
  end

  // --------------------------------------------------------------------------
  // Output logic
  // --------------------------------------------------------------------------

  assign ds = wr_en ? wr_data : qs; // Data staged for write
  assign qe = wr_en;                // Qualified write enable

  if (SwAccess == SwAccessRC) begin : gen_qs_rc
    // For RC, read value is what's written by HW if collision occurs
    assign qs = (de && we) ? d : q;
  end else begin : gen_qs_normal
    assign qs = q; // Normal case
  end

endmodule

