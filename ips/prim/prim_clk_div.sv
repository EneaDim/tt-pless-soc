// Clock Divider Module
// This module divides the input clock by a configurable RATIO, generating a pulse
// on clk_o every RATIO input clock cycles when enabled. In testmode, the clock is bypassed.

module prim_clk_div #(
  parameter int unsigned RATIO = 4  // Division ratio (must be > 0)
)(
  input  logic clk_i,      // Input clock
  input  logic rst_ni,     // Asynchronous active-low reset
  input  logic testmode_i, // Test mode: bypass divider logic when high
  input  logic en_i,       // Enable signal for clock divider
  output logic clk_o       // Output pulse signal or bypassed clock
);

  // Counter to track clock cycles
  logic [RATIO-1:0] counter_q;
  // Internal signal to generate divided clock pulse
  logic clk_q;

  // Sequential logic to implement clock division
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      // Reset counter and output pulse
      clk_q   <= 1'b0;
      counter_q <= '0;
    end else begin
      // Default: no output pulse
      clk_q <= 1'b0;
      // If enabled, increment counter
      if (en_i) begin
        if (counter_q == (RATIO[RATIO-1:0] - 1)) begin
          // If counter reaches RATIO-1, emit a pulse and reset counter
          clk_q   <= 1'b1;
          counter_q <= '0;
        end else begin
          // Otherwise, increment counter
          counter_q <= counter_q + 1;
        end
      end
    end
  end
  
  // Output assignment
  // In test mode, bypass the divider and output clk_i directly.
  assign clk_o = testmode_i ? clk_i : clk_q;

endmodule
