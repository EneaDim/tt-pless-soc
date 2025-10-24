`default_nettype none
// Tiny Tapeout wrapper for your processor-less SoC
// Top name must start with tt_um_
module tt_um_eneadim_soc (
  input  logic [7:0] ui_in,    // inputs
  output logic [7:0] uo_out,   // outputs
  input  logic [7:0] uio_in,   // bidir in
  output logic [7:0] uio_out,  // bidir out
  output logic [7:0] uio_oe,   // bidir oe (1=drive)
  input  logic       ena,      // tile enable
  input  logic       clk,      // system clock
  input  logic       rst_n     // async reset, active-low
);

  // ------------------------
  // Internal nets
  // ------------------------
  // UART
  logic uart_rx;
  logic uart_tx;
  logic uart_tx_en;

  // SPI
  logic spi_cs;
  logic spi_sclk;
  logic spi_sdio_o;
  logic spi_sdio_i;
  logic spi_sdioz;  // 1 = high-Z request from SoC

  // PWM
  logic [1:0] pwm;
  logic [1:0] pwm_en;  // opzionale, non esposto

  // GPIO (bidir su uio[4:1])
  logic [3:0] gpio_in;
  logic [3:0] gpio_out;
  logic [3:0] gpio_oe_i; // from SoC

  // Alias dagli ingressi fisici
  assign uart_rx = ui_in[0];
  assign gpio_in = uio_in[4:1];

  // ------------------------
  // SoC instance
  // ------------------------
  soc #(
    .SramInitFile("")
  ) u_soc (
    .clk_i         (clk),
    .rst_ni        (rst_n),

    // UART
    .cio_rx_i      (uart_rx),
    .cio_tx_o      (uart_tx),
    .cio_tx_en_o   (uart_tx_en),

    // PWM
    .cio_pwm_o     (pwm),
    .cio_pwm_en_o  (pwm_en),

    // GPIO
    .cio_gpio_i    (gpio_in),
    .cio_gpio_o    (gpio_out),
    .cio_gpio_en_o (gpio_oe_i),

    // SPI
    .spi_cs_o      (spi_cs),
    .spi_sclk_o    (spi_sclk),
    .spi_sdioz_o   (spi_sdioz),
    .spi_sdio_i    (spi_sdio_i),
    .spi_sdio_o    (spi_sdio_o)
  );

  // ------------------------
  // Bidirectional mapping
  // ------------------------
  // uio[0] = SPI SDIO bidirezionale
  assign uio_out[0] = spi_sdio_o;
  assign uio_oe [0] = ena & ~spi_sdioz;   // drive quando non in Z
  assign spi_sdio_i  = uio_in[0];

  // uio[4:1] = GPIO[3:0]
  assign uio_out[4:1] = gpio_out;
  assign uio_oe [4:1] = gpio_oe_i & {4{ena}};

  // uio[7:5] non usati
  assign uio_out[7:5] = 3'b000;
  assign uio_oe [7:5] = 3'b000;

  // ------------------------
  // Pure outputs mapping
  // ------------------------
  // uo_out[0] = UART TX
  // uo_out[1] = SPI SCLK
  // uo_out[2] = SPI CS
  // uo_out[6:3] = {PWM_EN[1:0], PWM[1:0]}
  // uo_out[7] = UART TX EN (opzionale)
  logic [7:0] uo_int;
  assign uo_int[0]   = uart_tx;
  assign uo_int[1]   = spi_sclk;
  assign uo_int[2]   = spi_cs;
  assign uo_int[6:3] = {pwm_en[1:0], pwm[1:0]};
  assign uo_int[7]   = uart_tx_en;

  // Quando il tile non è selezionato, metti in safe state
  assign uo_out = ena ? uo_int : 8'b0;

endmodule

`default_nettype wire

