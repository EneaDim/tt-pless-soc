module spi_host
  import spi_host_reg_pkg::*; 
#(
  parameter int unsigned FifoDepth=3
)(
  // CLK & RSTN
  input           clk_i,
  input           rst_ni,

  // Bus Interface
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  // Generic IO
  output logic spi_cs_o,     // Chip Select
  output logic spi_sclk_o,   // Serial Clock
  output logic spi_sdioz_o,  // Serial Data Output HZ, to read data
  input  logic spi_sdio_i,   // Serial Data Input
  output logic spi_sdio_o    // Serial Data Input/Output
);

  spi_host_reg2hw_t reg2hw;
  spi_host_hw2reg_t hw2reg;

  spi_host_reg_top u_spi_host_reg (
    .clk_i,
    .rst_ni,
    .tl_i,
    .tl_o,
    .reg2hw,
    .hw2reg,
    .devmode_i(1'b1)
  );

  spi_host_core #(
    .FifoDepth(FifoDepth)
  ) u_spi_host_core (
    .clk_i,
    .rst_ni,
    .reg2hw,
    .hw2reg,
    .cs_o   (spi_cs_o),
    .sclk_o (spi_sclk_o),
    .sdioz_o(spi_sdioz_o),
    .sdio_i (spi_sdio_i),
    .sdio_o (spi_sdio_o)
  );

endmodule

