module decode_stage(
    
    input clk,reset,flush,
    input [31:0] PCNEXT_init,
    input [31:0] instruction,
    input [4:0] registerD,
    input [31:0]registerD_data,
    input RegW_en,
    input RegW_en_System,
    input EN_REG,
    input block_pipe_data_cache,
    input block_pipe_instr_cache,
    output reg [31:0] RegAdata,
    output reg [31:0] RegBdata,
    output reg [31:0] lower_half_instruction,
    output reg [31:0] PCNEXT,
    output reg WB_EN, MEM_R_EN, MEM_W_EN,
    output reg [4:0] regD_reg,
    output reg [4:0] regD_imme,
    output reg ALU_REG_DEST,
    output reg is_BRANCH,
    output reg [5:0] FUNCTION,
    output reg [4:0] regA, regB,
    output reg MEM_TO_REG,
    output reg [1:0] ALU_OP,
    output reg EN_REG_FETCH, EN_REG_DECODE, EN_REG_ALU, EN_REG_MEM,
    output reg is_immediate,
    output reg TLB_WRITE,
    output reg TLB_MISS,
    input [31:0] PC_INIT,
    output reg [31:0] PC_TO_REG,
    input last_stage_nop,
    output reg injected_nop,
    output reg injecting_nop_mem,
    input TLB_MISS_TRAP,
    input TLB_MISS_INST,
    input [31:0] TLB_PC_REG,
    input [31:0] TLB_ADDR_REG,
    output supervisor_mode_fetch,
    output reg supervisor_mode,
    output reg WB_SYS_EN   );
    
    wire [31:0] instruction_internal,lower_half_instruction_internal;
    wire [31:0] PC_internal,PCnext_internal;
    wire [31:0] regAdata_internal,regBdata_internal;
    wire [31:0] regAdata_internalSystem,regBdata_internalSystem;
    wire [4:0] regD_reg_internal, regD_imme_internal;
    wire ALU_REG_DEST_INT, IS_BRANCH_INT;
    wire MEM_R_EN_INT, MEM_W_EN_INT, MEM_TO_REG_INT, WB_EN_INT;
    wire [1:0] ALU_OP_INT;
    wire [5:0] FUNCTION_INT;
    wire [4:0] regA_int, regB_int, regD_init,regD_int;
    wire EN_REG_FETCH_INT, EN_REG_DECODE_INT, EN_REG_ALU_INT, EN_REG_MEM_INT;
    wire is_immediate_int;

    wire [31:0] inject_nop;
    wire IRET_INT;
    wire injecting_nop, injecting_nop_mem_int, supervisor_mode_int;
    wire RegW_en_System_out;
    
    assign EN_REG_FETCH = EN_REG_FETCH_INT;
    assign EN_REG_DECODE = EN_REG_DECODE_INT;
    assign EN_REG_ALU = EN_REG_ALU_INT;
    assign EN_REG_MEM = EN_REG_MEM_INT;

    control control(
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .ALU_REG_DEST(ALU_REG_DEST_INT),
        .is_branch(IS_BRANCH_INT),
        .MEM_R_EN(MEM_R_EN_INT),
        .MEM_W_EN(MEM_W_EN_INT),
        .MEM_TO_REG(MEM_TO_REG_INT),
        .WB_EN(WB_EN_INT),
        .FUNCTION(FUNCTION_INT),
        .regA(regA_int),
        .regB(regB_int),
        .regD(regD_int),
        .ALU_OP(ALU_OP_INT),
        .EN_REG_FETCH(EN_REG_FETCH_INT),
        .EN_REG_DECODE(EN_REG_DECODE_INT),
        .EN_REG_ALU(EN_REG_ALU_INT),
        .EN_REG_MEM(EN_REG_MEM_INT),
        .is_immediate(is_immediate_int),
        .block_pipe_instr_cache(block_pipe_instr_cache),
        .block_pipe_data_cache(block_pipe_data_cache),
        .inject_nop(inject_nop),
        .injecting_nop(injecting_nop),
        .injecting_nop_mem(injecting_nop_mem_int),
        .regASystem(regASystem),
        .regDSystem(regDSystem),
        .RegW_en_System(RegW_en_System_out),
        .TLB_WRITE(TLB_WRITE),
        .TLB_MISS_MEM(TLB_MISS_TRAP),
        .last_stage_nop(last_stage_nop),
        .IRET(IRET_INT),
        .TLB_MISS_INSTR(TLB_MISS_INST)
    );


    RegFile registers(
        .clk(clk),
        .regA(regA_int),
        .regB(regB_int),
        .regD(regD_int),
        .data_to_w(registerD_data),
        .RegWriteEn(RegW_en),
        .regA_data(regAdata_internal),
        .regB_data(regBdata_internal)
    );

    RegFileSystem RegFileSystem(
        .clk(clk),
        .regA(regA_int),
        .regB(regB_int),
        .regD(regD_int),
        .data_to_w(registerD_data),
        .RegWriteEn(RegW_en_System),
        .regA_data(regAdata_internalSystem),
        .regB_data(regBdata_internalSystem),
        .TLB_MISS(TLB_MISS_TRAP),
        .TLB_PC_REG(TLB_PC_REG),
        .TLB_ADDR_REG(TLB_ADDR_REG),
        .supervisor_mode(supervisor_mode_int),
        .IRET(IRET_INT)
    );

    mux2Data nop_injection(
        .a(instruction),
        .b(inject_nop),
        .y(instruction_internal),
        .select(injecting_nop)
    );


    assign lower_half_instruction_internal = { 16'b0, instruction_internal[15:0] };
    assign regD_reg_internal = instruction_internal[20:16];
    assign regD_imme_internal = instruction_internal[15:11];

    assign supervisor_mode_fetch = supervisor_mode_int;

    //STAGE REGISTER 
    always @ (posedge clk) begin
        if (reset) begin
            RegAdata <= 0;
            RegBdata <= 0;
            lower_half_instruction  <= 0;
            PCNEXT <= 0;
            WB_EN <= 0;
            MEM_R_EN <= 0;
            MEM_W_EN <= 0;
            regD_reg  <= 0;
            regD_imme  <= 0;
            ALU_REG_DEST <= 0;
            is_BRANCH <= 0;
            MEM_R_EN <= 0;
            MEM_W_EN <= 0;
            MEM_TO_REG <= 0;
            WB_EN <= 0;
            FUNCTION <= 6'b000000;
            regA  <= 5'b00000;
            regB <= 5'b00000;
            ALU_OP <= 0;
            is_immediate <= 0;
        end
        else begin
            if (flush) begin
                RegAdata <= 0;
                RegBdata <= 0;
                lower_half_instruction  <= 0;
                PCNEXT <= 0;
                WB_EN <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                regD_reg  <= 0;
                regD_imme  <= 0;
                ALU_REG_DEST <= 0;
                is_BRANCH <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                WB_EN <= 0;
                FUNCTION <= 6'b000000;
                regA  <= 5'b00000;
                regB <= 5'b00000;
                ALU_OP <= 0;
                is_immediate <= 0;
            end
            else if (EN_REG) begin
                RegAdata <= regAdata_internal;
                RegBdata <= regBdata_internal;
                lower_half_instruction  <= lower_half_instruction_internal;
                PCNEXT<= PCNEXT_init;
                WB_EN <= WB_EN_INT;
                MEM_R_EN <= MEM_R_EN_INT;
                regD_reg <= regD_reg_internal;
                regD_imme <= regD_imme_internal;
                ALU_REG_DEST <= ALU_REG_DEST_INT;
                is_BRANCH <= IS_BRANCH_INT;
                MEM_R_EN <= MEM_R_EN_INT;
                MEM_TO_REG <= MEM_TO_REG_INT;
                FUNCTION <= FUNCTION_INT;
                regA  <= regA_int;
                regB <= regB_int;
                ALU_OP <= ALU_OP_INT;
                is_immediate <= is_immediate_int;
                injected_nop <=injecting_nop;
                TLB_MISS <= TLB_MISS_INST;
                PC_TO_REG <= PC_INIT;
                injecting_nop_mem <= injecting_nop_mem_int;
                supervisor_mode <= supervisor_mode_int;
                WB_SYS_EN <=RegW_en_System_out;
            end

        end
    end

endmodule