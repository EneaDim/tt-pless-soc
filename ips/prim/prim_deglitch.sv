// Module: prim_filter
// Description: Debounces or filters a noisy serial input signal.
//              The signal must be stable for 'SIZE' clock cycles before the output changes.
//              Uses an up/down counter to confirm stability.

module prim_deglitch #(
  parameter bit AsyncOn = 0, // If set a 2-stage sync will be added
  parameter int unsigned SIZE = 4 // Number of stable samples required to accept a signal change
)(
  input  logic clk_i,    // Clock input
  input  logic rst_ni,   // Asynchronous active-low reset
  input  logic en_i,     // Enable input
  input  logic d_i,      // Serial input data (possibly noisy)
  output logic q_o       // Filtered (deglitched) output
);

  // Minimum number of bits needed to count up to SIZE
  localparam int unsigned COUNT_WIDTH = $clog2(SIZE + 1);

  logic [COUNT_WIDTH-1:0] count_q; // Counter for input stability tracking
  logic d_s; // Data synced

  if (AsyncOn) begin : gen_async
    // Run this through a 2 stage synchronizer to
    // prevent metastability.
    prim_ff_2sync #(
      .Width(1),
      .ResetValue('0)
    ) prim_flop_2sync (
      .clk_i,
      .rst_ni,
      .d_i(d_i),
      .q_o(d_s)
    );
  end else begin : gen_sync
    assign d_s = d_i;
  end

  // Sequential logic to update the counter
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      count_q <= '0; // Reset counter
    end else if (en_i) begin
      // Increment counter if input is high and not yet at maximum
      if (d_s && count_q < SIZE[COUNT_WIDTH-1:0])
        count_q <= count_q + 1;
      // Decrement counter if input is low and not yet at zero
      else if (~d_s && count_q > 0)
        count_q <= count_q - 1;
    end
  end

  // Combinational logic to set output based on counter state
  always_comb begin
    q_o = 1'b0;
    if (count_q == SIZE[COUNT_WIDTH-1:0])
      q_o = 1'b1;
    else if (count_q == 0)
      q_o = 1'b0;
    // Output retains previous value otherwise (no assignment needed here)
  end

endmodule

