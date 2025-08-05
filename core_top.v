module core_top #(
    parameter MEMORY_FILE = ""
)(
    input  wire        clk,
    input  wire        rst_n
);

// insira seu código aqui

// Fios
wire rd_en_core_to_mem;
wire wr_en_core_to_mem;
wire [31:0] data_i_mem_to_core;
wire [31:0] data_core_to_mem;   
wire [31:0] addr_core_to_mem;          
wire ack_o;

assign ack_o = 1'b1;

//---------Componentes---------//
core #(
    .BOOT_ADDRESS(32'h00000000)
) core_processador(
    .clk(clk),
    .rst_n(rst_n),
    .rd_en_o(rd_en_core_to_mem),
    .wr_en_o(wr_en_core_to_mem),
    .data_i(data_i_mem_to_core),
    .addr_o(addr_core_to_mem),
    .data_o(data_core_to_mem)
);

memory #(
    .MEMORY_FILE(MEMORY_FILE),
    .MEMORY_SIZE(4096)
) mem(
    .clk(clk),
    .rd_en_i(rd_en_core_to_mem),   // Indica uma solicitação de leitura
    .wr_en_i(wr_en_core_to_mem),   // Indica uma solicitação de escrita
    .addr_i(addr_core_to_mem),     // Endereço
    .data_i(data_core_to_mem),     // Dados de entrada (para escrita)
    .data_o(data_i_mem_to_core),   // Dados de saída (para leitura)
    .ack_o(ack_o)                  // Confirmação da transação
);

endmodule