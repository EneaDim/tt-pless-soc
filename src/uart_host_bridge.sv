// uart_host_bridge.sv
// Converte la seriale (byte stream) in richieste/risposte tipo Ibex LSU
// da collegare a tlul_adapter_host nel top.

module uart_host_bridge (
  input  logic clk_i,
  input  logic rst_ni,

  // Stream dalla UART core
  input  logic       rx_valid_i,
  input  logic [7:0] rx_data_i,
  output logic       rx_pop_o,

  // ===== Interfaccia "host" verso tlul_adapter_host =====
  output logic        req_o,
  input  logic        gnt_i,
  output logic [31:0] addr_o,
  output logic        we_o,
  output logic [31:0] wdata_o,
  output logic [3:0]  be_o,

  // Risposta dall'adapter (già dopo il fabric)
  input  logic        valid_i,
  input  logic [31:0] rdata_i,
  input  logic        err_i,
  input  logic        intg_err_i
);

  // --------------------------
  // Parser richiesta (frame)
  // --------------------------
  typedef enum logic [2:0] {RXF_IDLE, RXF_HDR, RXF_ADDR, RXF_WDATA, RXF_LAUNCH, RXF_WAIT_GNT} rxf_e;
  rxf_e rxf_st_q, rxf_st_d;

  logic [1:0]  idx_q, idx_d;
  logic [31:0] sh_q,  sh_d;
  logic [7:0]  op_q, bebyte_q, op_d, bebyte_d;

  logic [31:0] addr_q, addr_d;
  logic [31:0] wdata_q, wdata_d;
  logic [3:0]  be_q, be_d;
  logic        we_q, we_d;
  logic        req_q, req_d;

  // Consumiamo il byte quando siamo in uno stato attivo del parser
  assign rx_pop_o = (rxf_st_q != RXF_IDLE) && rx_valid_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rxf_st_q <= RXF_IDLE;
      idx_q    <= '0;
      sh_q     <= '0;
      op_q     <= '0;
      bebyte_q <= 8'hF;

      addr_q   <= '0;
      wdata_q  <= '0;
      be_q     <= 4'hF;
      we_q     <= 1'b0;
      req_q    <= 1'b0;
    end else begin
      rxf_st_q <= rxf_st_d;
      idx_q    <= idx_d;
      sh_q     <= sh_d;
      op_q     <= op_d;
      bebyte_q <= bebyte_d;

      addr_q   <= addr_d;
      wdata_q  <= wdata_d;
      be_q     <= be_d;
      we_q     <= we_d;
      req_q    <= req_d;
    end
  end

  always_comb begin
    rxf_st_d = rxf_st_q;
    idx_d    = idx_q;
    sh_d     = sh_q;
    op_d     = op_q;
    bebyte_d = bebyte_q;

    addr_d   = addr_q;
    wdata_d  = wdata_q;
    be_d     = be_q;
    we_d     = we_q;
    req_d    = req_q;

    unique case (rxf_st_q)
      RXF_IDLE: begin
        idx_d    = '0;
        sh_d     = '0;
        if (rx_valid_i && rx_data_i==8'hA5) begin // SOF
          rxf_st_d = RXF_HDR;
        end
      end

      RXF_HDR: begin
        if (rx_valid_i) begin
          case (idx_q)
            2'd0: /* VER=0x01 */;
            2'd1: op_d     = rx_data_i;      // 0=READ,1=WRITE
            2'd2: /* RSV  */ ;
            2'd3: bebyte_d = rx_data_i;      // BE
          endcase
          if (idx_q==2'd3) begin
            idx_d    = '0;
            rxf_st_d = RXF_ADDR;
          end else idx_d = idx_q + 2'd1;
        end
      end

      RXF_ADDR: begin
        if (rx_valid_i) begin
          sh_d = {rx_data_i, sh_q[31:8]};
          if (idx_q==2'd3) begin
            addr_d = {rx_data_i, sh_q[31:8]};
            if (op_q==8'd1) begin
              idx_d    = '0;
              rxf_st_d = RXF_WDATA; // write → attendo payload
            end else begin
              we_d     = 1'b0;      // read
              be_d     = 4'hF;
              wdata_d  = '0;
              rxf_st_d = RXF_LAUNCH;
            end
          end else idx_d = idx_q + 2'd1;
        end
      end

      RXF_WDATA: begin
        if (rx_valid_i) begin
          sh_d = {rx_data_i, sh_q[31:8]};
          if (idx_q==2'd3) begin
            wdata_d  = {rx_data_i, sh_q[31:8]};
            be_d     = bebyte_q[3:0];
            we_d     = 1'b1;
            rxf_st_d = RXF_LAUNCH;
          end else idx_d = idx_q + 2'd1;
        end
      end

      RXF_LAUNCH: begin
        req_d    = 1'b1;       // alza la richiesta
        rxf_st_d = RXF_WAIT_GNT;
      end

      RXF_WAIT_GNT: begin
        if (req_q && gnt_i) begin
          req_d    = 1'b0;     // abbassa dopo grant
          we_d     = 1'b0;      // read
          rxf_st_d = RXF_IDLE; // parser può iniziare un nuovo comando
        end
      end
    endcase
  end

  // Uscite verso tlul_adapter_host
  assign req_o    = req_q;
  assign addr_o   = addr_q & 32'hFFFF_FFFC; // allineamento parola (opzionale)
  assign we_o     = we_q;
  assign wdata_o  = wdata_q;
  assign be_o     = be_q;


endmodule

