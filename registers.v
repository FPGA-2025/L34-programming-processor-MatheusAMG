module registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,
    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);

reg [31:0] register_bank [0:31];

assign RS1_data_o = register_bank[RS1_ADDR_i]; //Pegar o conteudo do registrador RS1 e coloca-lo na saída
assign RS2_data_o = register_bank[RS2_ADDR_i]; //Pegar o conteudo do registrador RS2 e coloca-lo na saída

always @(posedge clk) begin //Não tenho que iniciar os registradores com um rst_n
    if (wr_en_i && (RD_ADDR_i != 5'b0)) begin
        register_bank[RD_ADDR_i] = data_i;
    end
    register_bank[0] = 32'b0;
end


endmodule