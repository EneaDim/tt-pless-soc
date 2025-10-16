module prim_clk_gate (
  input  logic clk_i,
  input  logic en_i,
  input  logic test_en_i,
  output logic clk_o
);

  logic en_latch;

  // Explicit latch: transparent when clk_i is low
  always_latch begin
    if (!clk_i) begin
      en_latch = en_i | test_en_i;
    end
  end

  assign clk_o = en_latch & clk_i;

endmodule

