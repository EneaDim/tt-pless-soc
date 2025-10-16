module prim_ram #(
  parameter int ADDR_WIDTH  = 16,
  parameter int DATA_WIDTH  = 32,
  parameter int MEM_DEPTH   = 1 << ADDR_WIDTH,
  parameter string VMEM_FILE = ""
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic                  en_i,
  input  logic                  we_i,
  input  logic [ADDR_WIDTH-1:0] addr_i,
  input  logic [DATA_WIDTH-1:0] wdata_i,
  output logic [DATA_WIDTH-1:0] rdata_o
);

  // Internal memory storage
  logic [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

  // Read and write logic
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      rdata_o <= '0;
    end else if (en_i) begin
      if (we_i) begin
        mem[addr_i] <= wdata_i;
      end else begin
        rdata_o <= mem[addr_i];
      end
    end
  end

  // Memory initialization from VMEM file
  initial begin
    if (VMEM_FILE != "") begin
      $readmemh(VMEM_FILE, mem);
    end
  end

endmodule
