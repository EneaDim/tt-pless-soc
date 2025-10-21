// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module pwm_chan #(
  parameter int CntDw = 16
) (
  input        clk_i,
  input        rst_ni,

  input        pwm_en_i,
  input        invert_i,
  input [15:0] phase_delay_i,
  input [15:0] duty_cycle_a_i,

  input [15:0] phase_ctr_i,
  input        cycle_end_i,
  input [3:0]  dc_resn_i,

  output logic pwm_o
);

  logic [15:0] on_phase;
  logic [15:0] off_phase;
  logic        phase_wrap;
  logic        pwm_int;


  // For cases when the desired duty_cycle does not line up with the chosen resolution
  // we mask away any used bits.
  logic [15:0] dc_mask;
  // Mask is de-asserted for first dc_resn_i + 1 bits.
  // e.g. for dc_resn = 12, dc_mask = 16'b0000_0000_0000_0111
  // Bits marked as one in this mask are unused in computing
  // turn-on or turn-off times
  assign dc_mask = 16'hffff >> (dc_resn_i + 1);

  // Explicitly round down the phase_delay and duty_cycle
  logic [15:0] phase_delay_masked, duty_cycle_masked;
  assign phase_delay_masked = phase_delay_i & ~dc_mask;
  assign duty_cycle_masked  = duty_cycle_a_i & ~dc_mask;

  assign on_phase                = phase_delay_masked;
  assign {phase_wrap, off_phase} = {1'b0, phase_delay_masked} +
                                   {1'b0, duty_cycle_masked};

  logic on_phase_exceeded;
  logic off_phase_exceeded;

  assign on_phase_exceeded  = (phase_ctr_i >= on_phase);
  assign off_phase_exceeded = (phase_ctr_i >= off_phase);

  // Latch pwm_en_i signal

  logic pwm_en_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      pwm_en_q <= 1'b0;
    end else begin
      if (!pwm_int) begin
        pwm_en_q <= pwm_en_i;
      end
    end
  end

  assign pwm_int = (!pwm_en_q) ? 1'b0 :
                   phase_wrap ? on_phase_exceeded | ~off_phase_exceeded :
                                on_phase_exceeded & ~off_phase_exceeded;

  assign pwm_o = invert_i ? ~pwm_int : pwm_int;

endmodule : pwm_chan
