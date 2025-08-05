module core #(
    parameter BOOT_ADDRESS = 32'h00000000
) (
    // Control signal
    input wire clk,
    // input wire halt,
    input wire rst_n,

    // Memory BUS
    // input  wire ack_i,
    output wire rd_en_o,
    output wire wr_en_o, // deveria ser _o
    // output wire [3:0]  byte_enable,
    input  wire [31:0] data_i,
    output wire [31:0] addr_o,
    output wire [31:0] data_o

);

//insira seu código aqui

// ---------------- PC ----------------
reg [31:0] PC;
wire [31:0] pc_MUX;

assign pc_MUX = (lorD == 1'b0) ? PC : reg_Alu_Out;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        PC <= BOOT_ADDRESS;
    else if (pc_write | (pc_write_cond & alu_zero))
        PC <= mux_saida_ULA;
end


// ---------------- Sinais para memória ----------------
assign rd_en_o = memory_read;  //sai da unidade de controle
assign wr_en_o = memory_write; //sai da unidade de controle
assign addr_o  = pc_MUX;       //sai do PC

// ---------------- PC_OLD ----------------
reg [31:0] PC_OLD;
always @(posedge clk) begin
    if (ir_write)
        PC_OLD <= PC;
end

// ---------------- Instruction Register ----------------
reg [31:0] instruction;

always @(posedge clk) begin
    if (ir_write)
        instruction <= data_i;
end

wire [6:0] opCode         = instruction[6:0];
wire [4:0] registradorA   = instruction[19:15];
wire [4:0] registradorB   = instruction[24:20];
wire [4:0] write_register = instruction[11:7];
wire [2:0] func3          = instruction[14:12];
wire [6:0] func7          = instruction[31:25]; 

// ---------------- Registrador de memória ----------------
reg [31:0] reg_memory_data;

always @(posedge clk) begin
    reg_memory_data <= data_i;
end

// ---------------- MUX Write Data ----------------
wire [31:0] mux_WriteData = (memory_to_reg == 1'b0) ? reg_Alu_Out : reg_memory_data;

// ---------------- Registradores A e B ----------------
wire [31:0] wire_regA, wire_regB;
reg  [31:0] regA, regB;

always @(posedge clk) begin
    regA <= wire_regA;
    regB <= wire_regB;
end

assign data_o = regB;

// ---------------- MUX A e B para ULA ----------------
wire [31:0] mux_A_to_ULA = (alu_src_a == 2'b00) ? PC :
                           (alu_src_a == 2'b01) ? regA :
                           (alu_src_a == 2'b10) ? PC_OLD :
                           32'b0;

wire [31:0] mux_B_to_ULA = (alu_src_b == 2'b00) ? regB :
                           (alu_src_b == 2'b01) ? 32'd4 :
                           (alu_src_b == 2'b10) ? imediato_out :
                           32'b0;

// ---------------- ALU ----------------
wire [31:0] alu_result;
wire alu_zero;
reg  [31:0] reg_Alu_Out;
wire [31:0] mux_saida_ULA = (pc_source == 1'b0) ? alu_result : reg_Alu_Out;

always @(posedge clk) begin
    reg_Alu_Out <= alu_result;
end

alu alu_inst (
    .ALU_OP_i(wire_alu_op_o),
    .ALU_RS1_i(mux_A_to_ULA),
    .ALU_RS2_i(mux_B_to_ULA),
    .ALU_RD_o(alu_result),
    .ALU_ZR_o(alu_zero)
);

// ---------------- Controle da ALU ----------------
wire [3:0] wire_alu_op_o;

alu_control controle_alu (
    .is_immediate_i(is_immediate),
    .ALU_CO_i(aluop),
    .FUNC7_i(func7),
    .FUNC3_i(func3),
    .ALU_OP_o(wire_alu_op_o)
);

// ---------------- Gerador de Imediatos ----------------
wire [31:0] imediato_out;

immediate_generator gerador_de_imediatos (
    .instr_i(instruction),
    .imm_o(imediato_out)
);

// ---------------- Banco de Registradores ----------------
registers banco_de_registradores (
    .clk(clk),
    .wr_en_i(reg_write),
    .RS1_ADDR_i(registradorA),
    .RS2_ADDR_i(registradorB),
    .RD_ADDR_i(write_register),
    .data_i(mux_WriteData),
    .RS1_data_o(wire_regA),
    .RS2_data_o(wire_regB)
);

// ---------------- Unidade de Controle ----------------
wire pc_write;
wire ir_write;
wire pc_source;
wire reg_write;
wire memory_read;
wire is_immediate;
wire memory_write;
wire pc_write_cond;
wire lorD;
wire memory_to_reg;
wire [1:0] aluop;
wire [1:0] alu_src_a;
wire [1:0] alu_src_b;

control_unit unidade_de_controle (
    .clk(clk),
    .rst_n(rst_n),
    .instruction_opcode(opCode),
    .pc_write(pc_write),
    .ir_write(ir_write),
    .pc_source(pc_source),
    .reg_write(reg_write),
    .memory_read(memory_read),
    .is_immediate(is_immediate),
    .memory_write(memory_write),
    .pc_write_cond(pc_write_cond),
    .lorD(lorD),
    .memory_to_reg(memory_to_reg),
    .aluop(aluop),
    .alu_src_a(alu_src_a),
    .alu_src_b(alu_src_b)
);

endmodule
