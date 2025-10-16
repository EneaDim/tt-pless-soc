module prim_shreg #(
  parameter LENGHT=8
) (
  input  logic              clk_i,    // Clock input
  input  logic              rst_ni,   // Additional reset signal
  input  logic              en_i,     // Enable shift signal
  input  logic              serial_i, // Input value
  output logic [LENGHT-1:0] pdata_o,  // Parallel output value
  output logic              serial_o  // Serial output value
);

  // Internal signals
  logic [LENGHT-1:0] shift_reg; // Shift register for debouncing
  
  // Shift Reg definition
  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      shift_reg <= 0;
    end else if (en_i) begin
      // Shift in the current data_i
      shift_reg <= {shift_reg[LENGHT-2:0], serial_i};
    end
  end
  // Parallel output data
  assign pdata_o = shift_reg;
  // Serial output data
  assign serial_o = shift_reg[LENGHT-1];

endmodule

