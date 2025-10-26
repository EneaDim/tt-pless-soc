module soc #(
  SramInitFile = ""
) (
  // Clock and reset.
  input  logic clk_i,
  input  logic rst_ni,
  // I/O
  input  logic cio_rx_i,
  output logic cio_tx_o,
  output logic cio_tx_en_o,

  output logic [1:0] cio_pwm_o,
  output logic [1:0] cio_pwm_en_o,
  input logic [3:0] cio_gpio_i,
  output logic [3:0] cio_gpio_o,
  output logic [3:0] cio_gpio_en_o,
  output logic spi_cs_o,
  output logic spi_sclk_o,
  output logic spi_sdioz_o,
  input logic spi_sdio_i,
  output logic spi_sdio_o
);


  // Local parameters.
  localparam int unsigned MemSize       = 128 * 1024; // 128 KiB
  localparam int unsigned DataWidth     = 32;
  localparam int unsigned AddrOffset    = $clog2(DataWidth / 8);
  localparam int unsigned SramAddrWidth = $clog2(MemSize) - AddrOffset;  
  

  // Read/write signals.
  logic                     uart_req;
  logic                     uart_gnt;
  logic                     uart_we;
  logic [(DataWidth/8)-1:0] uart_be;
  logic [DataWidth-1:0]     uart_addr;
  logic [DataWidth-1:0]     uart_wdata;
  logic                     uart_rvalid;
  logic [DataWidth-1:0]     uart_rdata;
  logic                     uart_err;
  

  // TileLink signals.
  tlul_pkg::tl_h2d_t tl_uart_host_h2d;
  tlul_pkg::tl_d2h_t tl_uart_host_d2h;
  tlul_pkg::tl_h2d_t tl_uart_h2d;
  tlul_pkg::tl_d2h_t tl_uart_d2h;

  // UART host
  uart u_uart (
    .clk_i, .rst_ni,

    .tl_i(tl_uart_h2d),
    .tl_o(tl_uart_d2h),

    .req_o   (uart_req),
    .gnt_i   (uart_gnt),
    .addr_o  (uart_addr),
    .we_o    (uart_we),
    .wdata_o (uart_wdata),
    .be_o    (uart_be),
    .valid_i (uart_rvalid),
    .rdata_i (uart_rdata),
    .err_i   (uart_err),
    .intg_err_i(),

    .cio_rx_i, .cio_tx_o, .cio_tx_en_o,

    .intr_tx_watermark_o(),
    .intr_tx_empty_o(),
    .intr_rx_watermark_o(),
    .intr_tx_done_o(),
    .intr_rx_overflow_o(),
    .intr_rx_frame_err_o(),
    .intr_rx_break_err_o(),
    .intr_rx_timeout_o(),
    .intr_rx_parity_err_o()
  );



  // TileLink host adapter to connect Ibex to bus.
  tlul_adapter_host uart_host_adapter (
    .clk_i,
    .rst_ni,

    .req_i        (uart_req),
    .gnt_o        (uart_gnt),
    .addr_i       (uart_addr),
    .we_i         (uart_we),
    .wdata_i      (uart_wdata),
    .wdata_intg_i ('0),
    .be_i         (uart_be),
    .instr_type_i (prim_mubi_pkg::MuBi4False),

    .valid_o      (uart_rvalid),
    .rdata_o      (uart_rdata),
    .rdata_intg_o (),
    .err_o        (uart_err),
    .intg_err_o   (),


    .tl_o         (tl_uart_host_h2d),
    .tl_i         (tl_uart_host_d2h)
  );

  tlul_pkg::tl_h2d_t tl_pwm_h2d;
  tlul_pkg::tl_d2h_t tl_pwm_d2h;
  tlul_pkg::tl_h2d_t tl_gpio_h2d;
  tlul_pkg::tl_d2h_t tl_gpio_d2h;
  tlul_pkg::tl_h2d_t tl_rv_timer_h2d;
  tlul_pkg::tl_d2h_t tl_rv_timer_d2h;
  tlul_pkg::tl_h2d_t tl_spi_host_h2d;
  tlul_pkg::tl_d2h_t tl_spi_host_d2h;

  // Our main data bus.
  xbar_main xbar (
    // Clock and reset.
    .clk_i,
    .rst_ni,

    // Host interfaces.
    .tl_uart_host_i (tl_uart_host_h2d),
    .tl_uart_host_o (tl_uart_host_d2h),

    // Device interfaces.
    .tl_uart_o (tl_uart_h2d),
    .tl_uart_i (tl_uart_d2h),
    .tl_pwm_o     (tl_pwm_h2d),
    .tl_pwm_i     (tl_pwm_d2h),
    .tl_gpio_o     (tl_gpio_h2d),
    .tl_gpio_i     (tl_gpio_d2h),
    .tl_rv_timer_o     (tl_rv_timer_h2d),
    .tl_rv_timer_i     (tl_rv_timer_d2h),
    .tl_spi_host_o     (tl_spi_host_h2d),
    .tl_spi_host_i     (tl_spi_host_d2h),

    .scanmode_i (prim_mubi_pkg::MuBi4False)
  );

  // Instantiate pwm
  pwm u_pwm (
    .clk_i,
    .rst_ni,
    .tl_i(tl_pwm_h2d),
    .tl_o(tl_pwm_d2h),
    .cio_pwm_o,
    .cio_pwm_en_o
  );
  // Instantiate gpio
  gpio u_gpio (
    .clk_i,
    .rst_ni,
    .tl_i(tl_gpio_h2d),
    .tl_o(tl_gpio_d2h),
    .cio_gpio_i,
    .cio_gpio_o,
    .cio_gpio_en_o,
    .intr_gpio_o()
  );
  // Instantiate rv_timer
  rv_timer u_rv_timer (
    .clk_i,
    .rst_ni,
    .tl_i(tl_rv_timer_h2d),
    .tl_o(tl_rv_timer_d2h),
    .intr_timer_expired_hart0_timer0_o()
  );
  // Instantiate spi_host
  spi_host u_spi_host (
    .clk_i,
    .rst_ni,
    .tl_i(tl_spi_host_h2d),
    .tl_o(tl_spi_host_d2h),
    .spi_cs_o,
    .spi_sclk_o,
    .spi_sdioz_o,
    .spi_sdio_i,
    .spi_sdio_o
  );

endmodule
