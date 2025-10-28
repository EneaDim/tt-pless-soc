`default_nettype none
// Tiny Tapeout wrapper for your processor-less SoC
// Top name must start with tt_um_
module tt_um_eneadim_soc (
  input  wire [7:0] ui_in,    // inputs
  output wire [7:0] uo_out,   // outputs
  input  wire [7:0] uio_in,   // bidir in
  output wire [7:0] uio_out,  // bidir out
  output wire [7:0] uio_oe,   // bidir oe (1=drive)
  input  wire       ena,      // tile enable
  input  wire       clk,      // system clock
  input  wire       rst_n     // async reset, active-low
);

  // ------------------------
  // Internal nets
  // ------------------------
  // UART
  wire uart_rx;
  wire uart_tx;
  wire uart_tx_en;

  // PWM
  wire pwm;
  wire pwm_en;  // opzionale, non esposto

  // GPIO (bidir su uio[4:1])
  wire [1:0] gpio_in;
  wire [1:0] gpio_out;
  wire [1:0] gpio_oe_i; // from SoC

  // Alias dagli ingressi fisici
  assign uart_rx = ui_in[0];
  assign gpio_in = uio_in[2:1];

  // ------------------------
  // SoC instance
  // ------------------------
  soc u_soc (
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
    .cio_gpio_en_o (gpio_oe_i)

  );

  // ------------------------
  // Bidirectional mapping
  // ------------------------
  // uio[0] = SPI SDIO bidirezionale
  assign uio_out[0] = 1'b1;
  assign uio_oe [0] = ena;

  // uio[4:1] = GPIO[3:0]
  assign uio_out[2:1] = gpio_out;
  assign uio_oe [2:1] = gpio_oe_i & {2{ena}};

  // uio[7:5] non usati
  assign uio_out[7:3] = 5'b000;
  assign uio_oe [7:3] = 5'b000;

  // ------------------------
  // Pure outputs mapping
  // ------------------------
  // uo_out[0] = UART TX
  // uo_out[1] = SPI SCLK
  // uo_out[2] = SPI CS
  // uo_out[6:3] = {PWM_EN[1:0], PWM[1:0]}
  // uo_out[7] = UART TX EN (opzionale)
  wire [7:0] uo_int;
  assign uo_int[0]   = uart_tx;
  assign uo_int[2:1] = {pwm_en, pwm};
  assign uo_int[3]   = uart_tx_en;
  assign uo_int[7:4] = 4'h0;

  // Quando il tile non è selezionato, metti in safe state
  assign uo_out = ena ? uo_int : 8'b0;

endmodule

`default_nettype wire

