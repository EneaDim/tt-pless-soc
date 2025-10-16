// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: UART top level wrapper file

`include "prim_assert.sv"

module uart import uart_reg_pkg::*; (
  input           clk_i,
  input           rst_ni,

  // Bus Interface
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,

  // ===== Verso tlul_adapter_host 
  output logic        req_i,
  input  logic        gnt_o,
  output logic [31:0] addr_i,
  output logic        we_i,
  output logic [31:0] wdata_i,
  output logic [3:0]  be_i,
  input  logic        valid_o,
  input  logic [31:0] rdata_o,
  input  logic        err_o,
  input  logic        intg_err_o,

  // Generic IO
  input           cio_rx_i,
  output logic    cio_tx_o,
  output logic    cio_tx_en_o,

  // Interrupts
  output logic    intr_tx_watermark_o ,
  output logic    intr_tx_empty_o ,
  output logic    intr_rx_watermark_o ,
  output logic    intr_tx_done_o  ,
  output logic    intr_rx_overflow_o  ,
  output logic    intr_rx_frame_err_o ,
  output logic    intr_rx_break_err_o ,
  output logic    intr_rx_timeout_o   ,
  output logic    intr_rx_parity_err_o
);

  uart_reg2hw_t reg2hw;
  uart_hw2reg_t hw2reg;

  uart_reg_top u_reg (
    .clk_i,
    .rst_ni,
    .tl_i,
    .tl_o,
    .reg2hw,
    .hw2reg,
    .devmode_i(1'b1)
  );

    // uart_core con porte streaming
  logic core_tx;

  logic       rx_valid_o;
  logic [7:0] rx_data_o;
  logic       rx_pop_i;

  logic       tx_valid_i;
  logic [7:0] tx_data_i;
  logic       tx_ready_o;

  uart_core u_uart_core (
    .clk_i,
    .rst_ni,
    .reg2hw,
    .hw2reg,
    .rx (cio_rx_i),
    .tx (core_tx),

    .rx_valid_o (rx_valid_o),
    .rx_data_o  (rx_data_o),
    .rx_pop_i   (rx_pop_i),

    .intr_tx_watermark_o,
    .intr_tx_empty_o,
    .intr_rx_watermark_o,
    .intr_tx_done_o,
    .intr_rx_overflow_o,
    .intr_rx_frame_err_o,
    .intr_rx_break_err_o,
    .intr_rx_timeout_o,
    .intr_rx_parity_err_o
  );

  assign cio_tx_o    = core_tx;
  assign cio_tx_en_o = 1'b1;

  // Bridge UART↔host
  uart_host_bridge u_bridge (
    .clk_i, .rst_ni,

    .rx_valid_i (rx_valid_o),
    .rx_data_i  (rx_data_o),
    .rx_pop_o   (rx_pop_i),

    // → tlul_adapter_host nel top
    .req_o   (req_i),
    .gnt_i   (gnt_o),
    .addr_o  (addr_i),
    .we_o    (we_i),
    .wdata_o (wdata_i),
    .be_o    (be_i),

    // ← risposta dall'adapter
    .valid_i    (valid_o),
    .rdata_i    (rdata_o),
    .err_i      (err_o),
    .intg_err_i (intg_err_o)
  );

endmodule
