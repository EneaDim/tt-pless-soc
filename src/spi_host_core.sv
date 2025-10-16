module spi_host_core 
  import spi_host_reg_pkg::*; 
#(
  parameter int unsigned FifoDepth=3
)(
  input        clk_i,    // System clock
  input        rst_ni,   // Active low reset

  input  spi_host_reg2hw_t reg2hw,
  output spi_host_hw2reg_t hw2reg,
  
  output logic cs_o,     // Chip Select
  output logic sclk_o,   // Serial Clock
  output logic sdioz_o,  // Serial Data Output HZ, to read data
  input  logic sdio_i,   // Serial Data Input
  output logic sdio_o    // Serial Data Input/Output
);

  // State definitions
  typedef enum logic [1:0] {
    IDLE     = 2'b00,
    TRANSFER = 2'b01,
    DONE     = 2'b10
  } state_t;

  state_t current_state, next_state;

  // SPI parameters
  parameter integer DATA_WIDTH = 8;    // Width of data in FIFO, max 16
  parameter integer NUM_BYTES = 3;     // Number of bytes to transfer, max 8
  localparam int unsigned FifoDepthW = $clog2(FifoDepth+1); 

  logic [7:0] current_byte_q, current_byte_d; // Current byte to transmit
  logic       cs_q, cs_d;
  logic       sdio_q, sdio_d;
  logic       sdioz_q, sdioz_d;
  logic       sclk_en;
  logic [2:0] byte_cnt_q, byte_cnt_d, byte_cnt_max;
  logic [3:0] bit_cnt_q, bit_cnt_d;
  logic       tx_fifo_rready_q, tx_fifo_rready_d;
  logic       rx_fifo_wvalid_q, rx_fifo_wvalid_d;

  logic       r_wn_d, r_wn_q; // SPI CMD : Read = 1, Write = 0

  logic [FifoDepthW-1:0] rx_fifo_depth, tx_fifo_depth;

  logic       enable, sclk;
  logic       spi_fifo_txrst, spi_fifo_rxrst;
  logic [7:0] tx_fifo_rdata, tx_fifo_wdata;
  logic       rx_fifo_rready, rx_fifo_rvalid;
  logic       rx_fifo_wvalid, rx_fifo_wready;
  logic       tx_fifo_rready, tx_fifo_rvalid;
  logic       tx_fifo_wready, tx_fifo_wvalid;
  logic [7:0] rx_fifo_rdata, rx_fifo_wdata;

  assign byte_cnt_max = NUM_BYTES[2:0];
  
  //////////////
  // CTRL2REG //
  //////////////
  // SPI enable
  assign enable         = reg2hw.ctrl.en.q;
  // TX FIFO rst
  assign spi_fifo_txrst = reg2hw.ctrl.txrst.q;
  // RX FIFO rst
  assign spi_fifo_rxrst = reg2hw.ctrl.rxrst.q;
  // RX FIFO RREADY
  assign rx_fifo_rready = reg2hw.rdata.re;
  // RX_FIFO WDATA
  assign rx_fifo_wdata  = current_byte_q;
  // RX_FIFO WDATA
  assign rx_fifo_wvalid = rx_fifo_wvalid_q;
  // TX FIFO WDATA
  assign tx_fifo_wdata  = reg2hw.wdata.q;
  // TX FIFO WVALID
  assign tx_fifo_wvalid = reg2hw.wdata.qe;
  // TX FIFO RREADY
  assign tx_fifo_rready = tx_fifo_rready_q;
  //////////////
  // REG2CTRL //
  //////////////
  // Read Data
  assign hw2reg.rdata.d    = rx_fifo_rdata;
  // RX EMPTY
  assign hw2reg.status.rxempty.d = ~rx_fifo_rvalid;
  // RX FULL
  assign hw2reg.status.rxfull.d  = ~rx_fifo_wready;
  // TX EMPTY
  assign hw2reg.status.txempty.d = ~tx_fifo_rvalid;
  // TX FULL
  assign hw2reg.status.txfull.d  = ~tx_fifo_wready;

  // Clock divider for SCLK
  prim_flop #( .Width(1), .ResetValue(0)
  ) u_clk_div2 ( 
    .clk_i, 
    .rst_ni,
    .d_i(sclk_en & ~sclk),
    .q_o(sclk)
  );
  //  Drive sclk from q of a flop
  prim_flop #( .Width(1), .ResetValue(0)
  ) u_sclk_driver (
    .clk_i,
    .rst_ni,
    .d_i(sclk & ~cs_q),
    .q_o(sclk_o)
  );

  // Output assignment
  assign cs_o = cs_q;
  assign sdioz_o = sdioz_q;
  assign sdio_o = sdio_q;

  // TX FIFO
  prim_fifo_sync #(
    .Width   (8),
    .Pass    (1'b0),
    .Depth   (FifoDepth)
  ) u_spi_txfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (spi_fifo_txrst),
    .wvalid_i(tx_fifo_wvalid),
    .wready_o(tx_fifo_wready),
    .wdata_i (tx_fifo_wdata),
    .depth_o (tx_fifo_depth),
    .full_o  (),
    .rvalid_o(tx_fifo_rvalid),
    .rready_i(tx_fifo_rready),
    .rdata_o (tx_fifo_rdata),
    .err_o   ()
  );

  // RX FIFO
  prim_fifo_sync #(
    .Width   (8),
    .Pass    (1'b0),
    .Depth   (FifoDepth)
  ) u_spi_rxfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (spi_fifo_rxrst),
    .wvalid_i(rx_fifo_wvalid),
    .wready_o(rx_fifo_wready),
    .wdata_i (rx_fifo_wdata),
    .depth_o (rx_fifo_depth),
    .full_o  (),
    .rvalid_o(rx_fifo_rvalid),
    .rready_i(rx_fifo_rready),
    .rdata_o (rx_fifo_rdata),
    .err_o   ()
  );

  // STATE LATCHING
  always_ff @(posedge clk_i or negedge rst_ni)
    begin: state_latching
      if (~rst_ni) begin
        current_state <= IDLE;
      end else begin
        current_state <= next_state;
      end
  end
  
  // OUTPUT LATCHING
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      cs_q             <= 1'b1;
      sdio_q           <= 1'b0;
      sdioz_q          <= 1'b0;
      byte_cnt_q       <= 3'b000;
      bit_cnt_q        <= 4'b000;
      current_byte_q   <= 8'h00;
      tx_fifo_rready_q <= 1'b0;
      rx_fifo_wvalid_q <= 1'b0;
      r_wn_q           <= 1'b0;
    end else begin
      cs_q             <= cs_d;
      sdio_q           <= sdio_d;
      sdioz_q          <= sdioz_d;
      byte_cnt_q       <= byte_cnt_d;
      bit_cnt_q        <= bit_cnt_d;
      current_byte_q   <= current_byte_d;
      tx_fifo_rready_q <= tx_fifo_rready_d;
      rx_fifo_wvalid_q <= rx_fifo_wvalid_d;
      r_wn_q           <= r_wn_d;
    end
  end

  // STATE TRANSITION AND OUTPUT DEFINITION
  always_comb begin
    next_state       = current_state;  // FSM State
    cs_d             = cs_q;           // Chip Select
    sclk_en          = 1'b0;
    sdio_d           = sdio_q;         // SDIO signal
    sdioz_d          = 1'b0;           // HZ SDIO
    byte_cnt_d       = byte_cnt_q;     // Byte Count
    bit_cnt_d        = bit_cnt_q;      // Bit Count
    current_byte_d   = current_byte_q; // Shift reg
    tx_fifo_rready_d = 1'b0;           // Read Ready from UART
    rx_fifo_wvalid_d = 1'b0;           // Read Ready from UART
    r_wn_d           = r_wn_q;         // R/!W SPI cmd
    unique case (current_state)
      IDLE: begin
        cs_d = 1'b1;   // CS hi after done
        if (enable && tx_fifo_wvalid && tx_fifo_wready) begin
          // Read data from UART and write in FIFO
          // Update byte counts
          byte_cnt_d = byte_cnt_q + 1;
          if (byte_cnt_q == (byte_cnt_max-1)) begin
            // FSM transition to TRANSFER
            // Setup signals to be ready at TRANSFER
            next_state = TRANSFER;
            tx_fifo_rready_d = 1'b1;
            current_byte_d = tx_fifo_rdata;
            r_wn_d = tx_fifo_rdata[7];
          end
        end
      end
      TRANSFER: begin
        cs_d = 1'b0; // CS low
        sclk_en = 1'b1;
        if (byte_cnt_q > (byte_cnt_max-2)) begin
          // INSTRUCTION
          if (bit_cnt_q < DATA_WIDTH[3:0]) begin
            // For each bit
            if (~sclk) begin
              // Shift out the current bit
              sdio_d = current_byte_q[7]; // MSB first
              current_byte_d = {current_byte_q[6:0], 1'b0}; // Shift left
              bit_cnt_d = bit_cnt_q + 1'b1;
            end
          end else begin
            // Byte transfer done
            if (tx_fifo_rvalid) begin
              // FIFO check if data available
              // Move to the next byte
              byte_cnt_d = byte_cnt_q - 1'b1;
              bit_cnt_d = 0;
              tx_fifo_rready_d = 1'b1;
              current_byte_d = tx_fifo_rdata;
            end
          end
        end else begin
          // DATA
          if (r_wn_q == 1'b0) begin
            // Write Data
            if (bit_cnt_q < DATA_WIDTH[3:0]) begin
              // For each bit
              if (~sclk) begin
                // Shift out the current bit
                sdio_d = current_byte_q[7]; // MSB first
                current_byte_d = {current_byte_q[6:0], 1'b0};
                bit_cnt_d = bit_cnt_q + 1'b1;
              end
            end else begin
              // Byte transfer done
              if (tx_fifo_rvalid) begin
                // Move to the next byte
                byte_cnt_d = byte_cnt_q - 1'b1;
                bit_cnt_d = 0;
                tx_fifo_rready_d = 1'b1;
                current_byte_d = tx_fifo_rdata;
              end else begin
                sclk_en = 1'b0; // Disable SCLK drive
                bit_cnt_d = 0;
                next_state = DONE;
              end
            end
          end else begin
            sdioz_d = 1'b1;
            // Read Data
            if (bit_cnt_q < DATA_WIDTH[3:0]) begin
              if (sclk) begin
                // Shift out the current bit
                current_byte_d = {current_byte_q[6:0], sdio_i};
              end else begin
                bit_cnt_d = bit_cnt_q + 1'b1;
              end
            end else begin
              rx_fifo_wvalid_d = 1'b1;
              current_byte_d = {current_byte_q[6:0], sdio_i};
              bit_cnt_d = 0;
              if (tx_fifo_rvalid) begin
                // Move to the next byte
                byte_cnt_d = byte_cnt_q - 1'b1;
                tx_fifo_rready_d = 1'b1;
              end else begin
                sclk_en = 1'b0; // Disable SCLK drive
                next_state = DONE;
              end
            end
          end
        end
      end
      DONE: begin
        cs_d = 1'b1;   // CS hi after done
        sdio_d = 1'b0; // Drive low SDIO
        sdioz_d = 1'b0; // Drive low SDIO
        // Reset counters
        byte_cnt_d = 0;
        bit_cnt_d = 0;
        next_state = IDLE; // Go back to IDLE
        //if (r_wn_q == 1'b1) begin
        //  rx_fifo_wvalid_d = 1'b1;
        //end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule
