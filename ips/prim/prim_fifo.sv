module prim_fifo #(
  parameter DEPTH = 12,
  parameter WIDTH = 8,
  parameter ASYNC = 1,
  parameter RD_BUFFER = 1
)(
  input  logic             rd_clk_i,     // Read clock input
  input  logic             wr_clk_i,     // Write clock input
  input  logic             rst_ni,       // Active-low reset
  input  logic [WIDTH-1:0] wdata_i,      // Data input
  input  logic             wvalid_i,     // Write data valid input
  output logic             wready_o,     // Write data ready output
  output logic [WIDTH-1:0] rdata_o,      // Data output
  output logic             rvalid_o,     // Read data valid output
  input  logic             rready_i,     // Read data ready input
  output logic             fifo_full,    // FIFO full flag
  output logic             fifo_empty    // FIFO empty flag
);

  // Pointer width based on the DEPTH
  localparam CNTR_WIDTH = $clog2(DEPTH);

  // Pointer registers and logic signals
  logic [CNTR_WIDTH-1:0] rd_gray_pointer, rd_binary_pointer;
  logic [CNTR_WIDTH-1:0] rd_gray_pointer_d;
  logic [CNTR_WIDTH-1:0] rd_binary_pointer_next;
  logic [CNTR_WIDTH-1:0] wr_gray_pointer, wr_binary_pointer;
  logic [CNTR_WIDTH-1:0] wr_gray_pointer_d;
  logic [CNTR_WIDTH-1:0] wr_binary_pointer_next;
  logic [WIDTH-1:0] fifo_stored [DEPTH-1:0];
  logic [CNTR_WIDTH-1:0] rd_gray_pointer_sync[1:0];
  logic [CNTR_WIDTH-1:0] wr_gray_pointer_sync[1:0];
  logic rdptr_eq_next_wrptr;

  // Write pointer logic
  assign wr_binary_pointer_next = (wr_binary_pointer == DEPTH-1) ? {CNTR_WIDTH{1'b0}} : wr_binary_pointer + 1;
  
  always_ff @ (posedge wr_clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      wr_binary_pointer <= '0;
    end else if ((wvalid_i & !rdptr_eq_next_wrptr) | (fifo_full & !rdptr_eq_next_wrptr)) begin
      wr_binary_pointer <= wr_binary_pointer_next;
    end
  end
  
  always_ff @ (posedge wr_clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      fifo_stored <= '{default: {WIDTH{1'b0}}};
    end else if (wvalid_i & !fifo_full) begin
      fifo_stored[wr_binary_pointer] <= wdata_i;
    end
  end

  // Read pointer logic
  assign rd_binary_pointer_next = (rd_binary_pointer == DEPTH-1) ? {CNTR_WIDTH{1'b0}} : rd_binary_pointer + 1;
  
  always_ff @ (posedge rd_clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rd_binary_pointer <= '0;
    end else if (rvalid_o & !fifo_empty) begin
      rd_binary_pointer <= rd_binary_pointer_next;
    end
  end
  
  if(RD_BUFFER == 1) begin  : y_rd_buf 
    always_ff @ (posedge rd_clk_i or negedge rst_ni) begin
      if (~rst_ni) 
        rdata_o <= '0; 
      else if (rvalid_o & !fifo_empty) 
        rdata_o <= fifo_stored[rd_binary_pointer];
    end
  end else begin : n_rd_buf 
    assign rdata_o = (rvalid_o & !fifo_empty) ? fifo_stored[rd_binary_pointer] : '0; 
  end

  // Synchronous pointer synchronization
  if (ASYNC == 1) begin : async_pointers 
    always_ff @ (posedge rd_clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        {wr_gray_pointer_sync[1], wr_gray_pointer_sync[0]} <= '0;
      end else begin
        {wr_gray_pointer_sync[1], wr_gray_pointer_sync[0]} <= {wr_gray_pointer_sync[0], wr_gray_pointer};
      end
    end

    always_ff @ (posedge wr_clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        {rd_gray_pointer_sync[1], rd_gray_pointer_sync[0]} <= '0;
      end else begin
        {rd_gray_pointer_sync[1], rd_gray_pointer_sync[0]} <= {rd_gray_pointer_sync[0], rd_gray_pointer};
      end
    end
  end

  // Write gray pointer logic with prim_bin2gray module
  if(ASYNC == 1) begin : async_grey_wr_pointers 
    // Convert binary pointer to gray code using prim_bin2gray
    prim_bin2gray #(
      .N(CNTR_WIDTH)
    ) bin2gray_inst_0 (
      .A(wr_binary_pointer_next),
      .Z(wr_gray_pointer_d)
    );
    always_ff @ (posedge wr_clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        wr_gray_pointer <= '0;
      end else if ((wvalid_i & !rdptr_eq_next_wrptr) | (fifo_full & !rdptr_eq_next_wrptr)) begin
        wr_gray_pointer <= wr_gray_pointer_d;
      end
    end
  end

  // Read gray pointer logic with prim_bin2gray module
  if(ASYNC == 1) begin : async_grey_rd_pointers 
    // Convert binary pointer to gray code using prim_bin2gray
    prim_bin2gray #(
      .N(CNTR_WIDTH)
    ) bin2gray_inst_0 (
      .A(rd_binary_pointer_next),
      .Z(rd_gray_pointer_d)
    );
    always_ff @ (posedge rd_clk_i or negedge rst_ni) begin
      if (~rst_ni) begin
        rd_gray_pointer <= '0;
      end else if (rvalid_o & !fifo_empty) begin
        rd_gray_pointer <= rd_gray_pointer_d;
      end
    end
  end

  // Flag logic for FIFO full and empty states
  if (ASYNC == 1) begin : async_flags
    assign rdptr_eq_next_wrptr = (rd_gray_pointer_sync[1] == wr_gray_pointer);
    assign fifo_empty = (wr_gray_pointer_sync[1] == rd_gray_pointer);
  end else begin : sync_flags
    assign rdptr_eq_next_wrptr = (rd_binary_pointer == wr_binary_pointer_next);
    assign fifo_empty = (wr_binary_pointer == rd_binary_pointer);
  end
  
  always_ff @(posedge wr_clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      fifo_full <= 1'b0;
    end else if(wvalid_i & rdptr_eq_next_wrptr) begin
      // When next write pointer == read pointer AND wvalid_i, it means last entry of FIFO is being filled, do not update pointer
      fifo_full <= 1'b1;
    end else if(!rdptr_eq_next_wrptr) begin
      // Deassert when any read operation is completed: write pointer != read pointer
      fifo_full <= 1'b0;
    end
  end

  // Write ready
  assign wready_o = !fifo_full;
  
  // Read valid
  always_ff @ (posedge rd_clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
      rvalid_o <= 1'b0;
    end else begin
      rvalid_o <= !fifo_empty & rready_i;
    end
  end

endmodule
