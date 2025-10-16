// Two-Phase Clock Domain Crossing Module with Toggle-Handshake protocol 
// This module safely transfers data between two asynchronous clock domains

module cdc_2phase #(
  parameter type T = logic    // Parameterized data type
)(
  input  logic src_clk_i,     // Clock for source domain
  input  logic src_rst_ni,    // Active-low reset for source domain
  input  T     src_data_i,    // Data input in source domain
  input  logic src_valid_i,   // Valid signal in source domain
  output logic src_ready_o,   // Ready signal in source domain

  input  logic dst_clk_i,     // Clock for destination domain
  input  logic dst_rst_ni,    // Active-low reset for destination domain
  output T     dst_data_o,    // Data output in destination domain
  output logic dst_valid_o,   // Valid signal in destination domain
  input  logic dst_ready_i    // Ready signal in destination domain
);

  // Asynchronous handshake signals
  (* dont_touch = "true" *) logic async_req;   // Toggles when new data is available
  (* dont_touch = "true" *) logic async_ack;   // Toggles when data is received
  (* dont_touch = "true" *) T async_data;      // Data transferred between domains

  // Instantiate source domain logic
  cdc_2phase_src #(.T(T)) i_src (
    .rst_ni       ( src_rst_ni  ),
    .clk_i        ( src_clk_i   ),
    .data_i       ( src_data_i  ),
    .valid_i      ( src_valid_i ),
    .ready_o      ( src_ready_o ),
    .async_req_o  ( async_req   ),
    .async_ack_i  ( async_ack   ),
    .async_data_o ( async_data  )
  );

  // Instantiate destination domain logic
  cdc_2phase_dst #(.T(T)) i_dst (
    .rst_ni       ( dst_rst_ni  ),
    .clk_i        ( dst_clk_i   ),
    .data_o       ( dst_data_o  ),
    .valid_o      ( dst_valid_o ),
    .ready_i      ( dst_ready_i ),
    .async_req_i  ( async_req   ),
    .async_ack_o  ( async_ack   ),
    .async_data_i ( async_data  )
  );

endmodule

// Source Domain Half
module cdc_2phase_src #(
  parameter type T = logic
)(
  input  logic clk_i,
  input  logic rst_ni,
  input  T     data_i,
  input  logic valid_i,
  output logic ready_o,
  output logic async_req_o,
  input  logic async_ack_i,
  output T     async_data_o
);

  // Internal registers
  (* dont_touch = "true" *) logic req_src_q, ack_src_q, ack_q;
  (* dont_touch = "true" *) T data_src_q;

  // Toggle request and latch data when new data is accepted
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_src_q  <= 0;
      data_src_q <= '0;
    end else if (valid_i && ready_o) begin
      req_src_q  <= ~req_src_q;
      data_src_q <= data_i;
    end
  end

  // Synchronize acknowledgment from destination domain
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ack_src_q <= 0;
      ack_q     <= 0;
    end else begin
      ack_src_q <= async_ack_i;
      ack_q     <= ack_src_q;
    end
  end

  // Outputs
  assign ready_o       = (req_src_q == ack_q); // Ready when last data was acknowledged
  assign async_req_o   = req_src_q;
  assign async_data_o  = data_src_q;

endmodule

// Destination Domain Half
module cdc_2phase_dst #(
  parameter type T = logic
)(
  input  logic clk_i,
  input  logic rst_ni,
  output T     data_o,
  output logic valid_o,
  input  logic ready_i,
  input  logic async_req_i,
  output logic async_ack_o,
  input  T     async_data_i
);

  // Synchronizer and data registers
  (* dont_touch = "true" *) (* async_reg = "true" *)
  logic req_dst_q, req_q0, req_q1, ack_dst_q;
  (* dont_touch = "true" *) T data_dst_q;

  // Toggle acknowledgment when data is accepted by destination
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ack_dst_q <= 0;
    end else if (valid_o && ready_i) begin
      ack_dst_q <= ~ack_dst_q;
    end
  end

  // Latch data when a new request is detected and output is not valid
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_dst_q <= '0;
    end else if (req_q0 != req_q1 && !valid_o) begin
      data_dst_q <= async_data_i;
    end
  end

  // Synchronize request signal from source domain
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      req_dst_q <= 0;
      req_q0    <= 0;
      req_q1    <= 0;
    end else begin
      req_dst_q <= async_req_i;
      req_q0    <= req_dst_q;
      req_q1    <= req_q0;
    end
  end

  // Outputs
  assign valid_o       = (ack_dst_q != req_q1); // Valid when new data received
  assign data_o        = data_dst_q;
  assign async_ack_o   = ack_dst_q;

endmodule
