module prim_lifo #(
  parameter int DEPTH = 12,         // Number of entries in the LIFO
  parameter int WIDTH = 8        // Width of each data entry
)(
  input  logic           clk_i,   // Clock input
  input  logic           rst_ni,  // Active-low synchronous reset

  // Write interface (input with ready/valid)
  input  logic [WIDTH-1:0]  wdata_i,   // Data input
  input  logic           wvalid_i,  // Write valid
  output logic           wready_o,  // Write ready

  // Read interface (output with ready/valid)
  output logic [WIDTH-1:0]  rdata_o,   // Data output
  output logic           rvalid_o,  // Read valid
  input  logic           rready_i,  // Read ready

  // Status flags
  output logic           lifo_full_o,
  output logic           lifo_empty_o
);

  localparam int CNTR_WIDTH = $clog2(DEPTH);   // Pointer bit width

  logic [CNTR_WIDTH-1:0] pointer;        // Stack pointer
  logic [WIDTH-1:0] lifo_stored [DEPTH];  // Storage array

  logic wr_en, rd_en;

  // Write and read enable logic based on handshake
  assign wr_en = wvalid_i && wready_o;
  assign rd_en = rvalid_o && rready_i;

  // Write ready: can accept data if not full
  assign wready_o = !lifo_full_o;

  // Read valid: data available if not empty
  assign rvalid_o = !lifo_empty_o;

  // Stack pointer control
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pointer <= '0;
    end else begin
      case ({rd_en, wr_en})
        2'b01: if (!lifo_full_o)  pointer <= pointer + 1;    // Write
        2'b10: if (!lifo_empty_o) pointer <= pointer - 1;    // Read
        default: /* no change or bypass handled below */ ;
      endcase
    end
  end

  // Memory write logic
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      for (int i = 0; i < DEPTH; i++) begin
        lifo_stored[i] <= '0;
      end
    end else if (wr_en && !lifo_full_o) begin
      lifo_stored[pointer] <= wdata_i;
    end
  end

  // Memory read logic
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_o <= '0;
    end else if (rd_en && !lifo_empty_o) begin
      rdata_o <= lifo_stored[pointer - 1];
    end else if (wvalid_i && rready_i && lifo_empty_o) begin
      // Bypass: data written and read in same cycle when empty
      rdata_o <= wdata_i;
    end
  end

  // Empty flag
  assign lifo_empty_o = (pointer == 0);

  // Full flag
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      lifo_full_o <= 1'b0;
    end else if (rd_en) begin
      lifo_full_o <= 1'b0;
    end else if ((pointer == CNTR_WIDTH'((DEPTH - 1))) && wr_en) begin
      lifo_full_o <= 1'b1;
    end
  end

endmodule

