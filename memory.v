module memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire        clk,

    input  wire        rd_en_i,    // Indica uma solicitação de leitura
    input  wire        wr_en_i,    // Indica uma solicitação de escrita

    input  wire [31:0] addr_i,     // Endereço
    input  wire [31:0] data_i,     // Dados de entrada (para escrita)
    output wire [31:0] data_o,     // Dados de saída (para leitura)

    output wire        ack_o       // Confirmação da transação
);

initial begin
    if (MEMORY_FILE != "") begin
        $readmemh(MEMORY_FILE, memory);
    end
end

reg [31:0] memory [0:MEMORY_SIZE - 1]; // Tamanho da memoria especificado

assign data_o = (rd_en_i) ? memory[addr_i[31:2]] : 32'b0; 

always @(posedge clk) begin
    if (wr_en_i) begin
        memory[addr_i[31:2]] <= data_i;
    end
end

endmodule
