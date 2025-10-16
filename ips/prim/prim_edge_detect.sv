module prim_edge_detect (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic en_i,
  input  logic serial_i,
  output logic r_edge_o,
  output logic f_edge_o
);

  logic serial_q;

  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_sync_1 (
    .clk_i,
    .rst_ni,
    .d_i(serial_i),
    .q_o(serial_q)
  );

  assign f_edge_o = (~serial_i) & serial_q;
  assign r_edge_o =  serial_i & (~serial_q);

endmodule
