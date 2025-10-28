`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk    /* verilator public_flat */;
  reg rst_n  /* verilator public_flat */;
  reg ena    /* verilator public_flat */;
  reg [7:0] ui_in   /* verilator public_flat */;
  reg [7:0] uio_in  /* verilator public_flat */;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  initial begin
    clk    = 1'b0;
    rst_n  = 1'b0;
    ena    = 1'b1;
    ui_in  = '0;
    uio_in = '0;
  end

  // Replace tt_um_eneadim_soc with your module name:
  tt_um_eneadim_soc user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
