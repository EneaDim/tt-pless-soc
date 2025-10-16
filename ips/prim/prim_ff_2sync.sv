module prim_ff_2sync #(
  parameter int               Width      = 16,
  parameter logic [Width-1:0] ResetValue = '0
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic [Width-1:0] d_i,
  output logic [Width-1:0] q_o
);

  logic [Width-1:0] d_o;
  logic [Width-1:0] intq;

  prim_flop #(
    .Width(Width),
    .ResetValue(ResetValue)
  ) u_sync_1 (
    .clk_i,
    .rst_ni,
    .d_i(d_i),
    .q_o(intq)
  );

  prim_flop #(
    .Width(Width),
    .ResetValue(ResetValue)
  ) u_sync_2 (
    .clk_i,
    .rst_ni,
    .d_i(intq),
    .q_o
  );

endmodule
