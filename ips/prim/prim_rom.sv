module prim_rom #(
  parameter int ADDR_WIDTH  = 16,
  parameter int DATA_WIDTH  = 32,
  parameter int MEM_DEPTH   = 1 << ADDR_WIDTH,
  parameter string VMEM_FILE = ""
) (
  input  logic          clk_i,
  input  logic          rst_ni,
  input  logic [ADDR_WIDTH-1:0] addr_i,
  output logic [DATA_WIDTH-1:0] rdata_o
);

  // Internal ROM storage
  logic [DATA_WIDTH-1:0] rom [0:MEM_DEPTH-1];

  // ROM read logic
  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      rdata_o <= '0;
    end else begin
      rdata_o <= rom[addr_i];
    end
  end

  // ROM initialization
  initial begin
    if (VMEM_FILE != "") begin
      $readmemh(VMEM_FILE, rom);
    end
  end

endmodule
