module immediate_generator (
    input wire [31:0] instr_i,  // Entrada: Instrução
    output reg [31:0] imm_o     // Saída: Imediato extraído da instrução
);


localparam LW_OPCODE        = 7'b0000011;
localparam SW_OPCODE        = 7'b0100011;
localparam JAL_OPCODE       = 7'b1101111;
localparam LUI_OPCODE       = 7'b0110111;
localparam JALR_OPCODE      = 7'b1100111;
localparam AUIPC_OPCODE     = 7'b0010111;
localparam BRANCH_OPCODE    = 7'b1100011;
localparam IMMEDIATE_OPCODE = 7'b0010011;

//Estender o sinal = Repetir o último bit

always @(*) begin
    case (instr_i[6:0]) // Dependendo do OPCODE 
        LW_OPCODE:          imm_o = {{20{instr_i[31]}},instr_i[31:20]}; //OK
        
        SW_OPCODE:          imm_o = {{20{instr_i[31]}},instr_i[31:25],instr_i[11:7]}; //OK
        
        JAL_OPCODE:         imm_o = {{11{instr_i[31]}},instr_i[31],instr_i[19:12],instr_i[20],instr_i[30:21],1'b0}; //OK   
        
        LUI_OPCODE:         imm_o = {{instr_i[31:12]},{12{1'b0}}}; //OK      
        
        JALR_OPCODE:        imm_o = {{20{instr_i[31]}},instr_i[31:20]}; //OK     
        
        AUIPC_OPCODE:       imm_o = {{instr_i[31:12]},{12{1'b0}}}; //OK 
        
        BRANCH_OPCODE:      imm_o = {{19{instr_i[31]}},instr_i[31],instr_i[7],instr_i[30:25],instr_i[11:8],1'b0}; //OK
        
        IMMEDIATE_OPCODE:   imm_o = {{20{instr_i[31]}},instr_i[31:20]}; //OK
        
        default:            imm_o = 32'b0;
    endcase
end
    
endmodule