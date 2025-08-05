module alu_control (
    input wire is_immediate_i,
    input wire [1:0] ALU_CO_i,
    input wire [6:0] FUNC7_i,
    input wire [2:0] FUNC3_i,
    output reg [3:0] ALU_OP_o
);

localparam LOAD_STORE = 2'b00; // Tipo I e S
localparam BRANCH = 2'b01;     // Tipo B
localparam ALU = 2'b10;        // Tipo I e R
localparam INVALID = 2'b11;

always @(*) begin
    case (ALU_CO_i)

        LOAD_STORE : begin //Todas as funcoes somam
            case (FUNC3_i)
                default: ALU_OP_o = 4'b0010; 
            endcase
        end

        BRANCH : begin // Se zero então saída 0 = 1;
            case (FUNC3_i)
                3'b000: ALU_OP_o = 4'b1010; //BEQ Se for Igual
                3'b001: ALU_OP_o = 4'b0011; //BNE Se for Diferente
                3'b100: ALU_OP_o = 4'b1100; //BLT Se for Menor
                3'b101: ALU_OP_o = 4'b1110; //BGE Se for Maior ou Igual
                3'b110: ALU_OP_o = 4'b1101; //BLTU Se for Menor Unsigned
                3'b111: ALU_OP_o = 4'b1111; //BGEU Se for Maior Igual Unsigned
                default: ALU_OP_o = 4'b1010;
            endcase
        end 
        
        ALU : begin
            case (FUNC3_i)
                3'b000: begin // Pode ser soma ou subtracao dependendo do func7
                    if (is_immediate_i) begin  // Se for de imediato só pode ser ADD
                        ALU_OP_o =  4'b0010;
                    end
                    else begin 
                        if (FUNC7_i == 7'b0000000) begin // Func7 = 0 ADD
                            ALU_OP_o =  4'b0010;  // ADD     
                        end
                        else begin
                            ALU_OP_o = 4'b1010; // SUB
                        end
                    end
                end
                3'b001: ALU_OP_o = 4'b0100; // SLL
                3'b010: ALU_OP_o = 4'b1110; // SLT
                3'b011: ALU_OP_o = 4'b1111; // SLTU
                3'b100: ALU_OP_o = 4'b1000; // XOR
                3'b101: begin 
                    if (FUNC7_i == 7'b0000000) begin  // SRL
                        ALU_OP_o = 4'b0101;
                    end
                    else begin // SRA
                        ALU_OP_o = 4'b0111;
                    end
                end
                3'b110: ALU_OP_o = 4'b0001; // OR
                3'b111: ALU_OP_o = 4'b0000; // AND
                default: ALU_OP_o = 4'b0000;
            endcase
        end 

        default: ALU_OP_o = 4'b0000;

    endcase
end


endmodule
