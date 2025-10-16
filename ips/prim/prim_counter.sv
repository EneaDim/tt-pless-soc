module prim_counter #(
  parameter int             Width = 4,
  parameter logic [Width:0] ResetValue = '0
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic en_i,
  input  logic clr_i,
  input  logic up_down_i,
  input  logic [Width-1:0] step_i,
  input  logic [Width-1:0] tc_val_i,
  output logic [Width-1:0] val_o,
  output logic tc_o
);

  logic [Width:0] count_q;
  logic [Width:0] count_d;
  logic uflow, oflow;
  logic [Width-1:0] cnt_sat;

  // Saturation Logic
  assign oflow =  up_down_i && count_q[Width];
  assign uflow = !up_down_i && count_q[Width];
  
  // Main Count Logic
  always_comb begin
    count_d = count_q;
    if (clr_i) begin
      count_d = '0;
    end else begin
      if (en_i) begin
        if (uflow) begin
            count_d = {Width{1'b0}};
        end else if (oflow) begin    
            count_d = {Width{1'b1}};
        end else begin
          if (up_down_i) begin
            count_d = count_q + {1'b0, step_i};
          end else begin
            count_d = count_q - {1'b0, step_i};
          end
        end  
      end else begin
        count_d = count_q;
      end
    end  
  end
  
  // SEQUENTIAL PROCESS
  prim_ff #(
    .Width(Width+1),
    .ResetValue(ResetValue)
  ) u_sync_1 (
    .clk_i,
    .rst_ni,
    .d_i(count_d),
    .q_o(count_q)
  );

  // OUTPUT ASSIGNMENT
  assign val_o = count_q[Width-1:0];
  assign tc_o = (count_q[Width-1:0] == tc_val_i) ? 1'b1 : 1'b0;

endmodule

