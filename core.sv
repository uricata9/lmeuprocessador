module core(
    input clk, reset, flush
);

    //Fetch - Decode
    wire [31:0] instruction_to_decode;
    wire [31:0] PCnext_to_decode;

    //Decode - ALU
    wire [31:0] RegAdata_to_alu, RegBdata_to_alu;
    wire [31:0] lower_half_instruction_to_alu;
    wire WB_EN_TO_ALU, MEM_R_EN_TO_ALU, MEM_W_EN_TO_ALU, ALU_REG_DEST_TO_ALU;
    wire [31:0] PC_TO_ALU;
    wire [4:0] regD_reg_ALU, regD_imme_ALU;
    wire is_BRANCH_TO_ALU;
    wire [1:0] ALU_OP_TO_ALU;
    wire [5:0] FUNCTION_TO_ALU;
    wire [4:0] reg_s, reg_t;
    wire MEM_TO_REG_TO_ALU;

    // ALU -ALU 


    //ALU - Mem
    wire [31:0] regDdata_to_mem, regBdata_to_mem;
    wire zero_to_mem;
    wire WB_EN_TO_MEM, MEM_R_EN_TO_MEM, MEM_W_EN_TO_MEM;
    wire [31:0] PC_TO_MEM;
    wire is_BRANCH_TO_MEM;
    wire MEM_TO_REG_TO_MEM;

    //Mem - WB
    wire WB_EN_TO_WB;
    wire MEM_TO_REG_TO_WB;
    wire [31:0] alu_result_to_wb;
    wire [31:0] read_data_mem_to_wb;


    //WB - Decode

    wire [31:0] write_data_to_reg;
    wire [4:0] destination_reg;
    wire RegW_en_to_decode;

    //MEM to Fetch

    wire BRANCH_TO_FETCH;
    wire [31:0] PCNEXT_TO_FETCH;

    //REgister D wires

    wire [4:0] regD_to_wb;
    wire [4:0] regD_to_mem;

    wire is_immediate;

    //Control registers enables

    wire EN_REG_FETCH, EN_REG_DECODE, EN_REG_ALU, EN_REG_MEM;

    //CONTROL MEM AND BLOCKED PIPE

    // fetch - RAM
    wire reqI_cache, read_ready_for_icache, write,written_data_ack;
    wire [127:0] data_to_cache,data_to_mem;
    wire [19:0] reqAddrI_mem;
    // fetch - Decode

    // MEM - RAM

    wire reqD_cache, reqD_stop,reqD_cache_write;
    wire read_ready_for_dcache;
    wire [19:0] reqAddrD_mem,reqAddrD_write_mem;

    wire block_pipe_data_cache, block_pipe_instr_cache;

    assign block_pipe_data_cache = reqD_cache | reqD_stop;

    assign block_pipe_instr_cache = reqI_cache;

    //TLB

    wire TLB_WRITE_TO_ALU, TLB_WRITE_TO_MEM;
    wire supervisor_mode_fetch, supervisor_mode_to_alu, supervisor_mode_to_mem;
    wire last_stage_nop, NOP_TO_ALU, NOP_TO_MEM, injecting_nop_mem;

    wire TLB_MISS_TO_DEC_FROM_FETCH, TLB_MISS_TO_DEC_FROM_MEM, TLB_MISS_TO_MEM, TLB_MISS_TO_ALU, TLB_MISS_TRAP;
    wire [31:0] TLB_PC_TO_DEC, TLB_PC_TO_ALU, TLB_PC_TO_MEM,TLB_PC_TO_REG, TLB_PC_REG;
    wire [19:0] pyshical_page_from_trad_ITLB;
    wire [31:0] logic_page_from_trad_ITLB,TLB_ADDR_REG;
    wire RegW_en_System_to_decode;
    wire WB_SYS_EN_TO_WB, WB_SYS_EN_TO_MEM, WB_SYS_EN_TO_ALU;
    fetch_stage fetch_state(
        .PCbranch(PCNEXT_TO_FETCH),
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .writePCEn(EN_REG_FETCH),
        .BRANCH(BRANCH_TO_FETCH),
        .PCnext(PCnext_to_decode),
        .instruction(instruction_to_decode),
        .EN_REG ( EN_REG_FETCH),
        .read_ready_from_mem(read_ready_for_icache),
        .written_data_ack_from_mem(written_data_ack),
        .reqI_mem(reqI_cache),
        .reqAddrI_mem(reqAddrI_mem),
        .instr_from_mem(data_to_cache),
        .tlb_write(TLB_WRITE_TO_MEM),
        .TLB_MISS(TLB_MISS_TO_DEC_FROM_FETCH),
        .PC_TLB(TLB_PC_TO_DEC),
        .TLB_MISS_MEM(TLB_MISS_TRAP),
        .supervisor_mode(supervisor_mode_fetch),
        .logic_page_from_trad(logic_page_from_trad_ITLB),
        .pyshical_page_from_trad(pyshical_page_from_trad_ITLB)
    );

    decode_stage decode_state(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .PCNEXT_init(PCnext_to_decode),
        .instruction(instruction_to_decode),
        .registerD(destination_reg),
        .registerD_data(write_data_to_reg),
        .RegW_en ( RegW_en_to_decode),
        .RegW_en_System(RegW_en_System_to_decode),
        .EN_REG ( EN_REG_DECODE),
        .RegAdata(RegAdata_to_alu),
        .RegBdata(RegBdata_to_alu),
        .lower_half_instruction(lower_half_instruction_to_alu),
        .PCNEXT(PC_TO_ALU),
        .WB_EN(WB_EN_TO_ALU), 
        .MEM_R_EN(MEM_R_EN_TO_ALU), 
        .MEM_W_EN(MEM_W_EN_TO_ALU),
        .regD_reg(regD_reg_ALU),
        .regD_imme(regD_imme_ALU),
        .ALU_OP(ALU_OP_TO_ALU),
        .ALU_REG_DEST(ALU_REG_DEST_TO_ALU),
        .is_BRANCH(is_BRANCH_TO_ALU),
        .FUNCTION(FUNCTION_TO_ALU),
        .regA(reg_s),
        .regB(reg_t),
        .MEM_TO_REG(MEM_TO_REG_TO_ALU),
        .EN_REG_FETCH(EN_REG_FETCH),
        .EN_REG_DECODE(EN_REG_DECODE),
        .EN_REG_ALU(EN_REG_ALU),
        .EN_REG_MEM(EN_REG_MEM),
        .is_immediate(is_immediate),
        .block_pipe_data_cache(block_pipe_data_cache),
        .block_pipe_instr_cache(block_pipe_instr_cache),
        .TLB_WRITE(TLB_WRITE_TO_ALU),
        .last_stage_nop(last_stage_nop),
        .injected_nop(NOP_TO_ALU),
        .TLB_MISS_INST(TLB_MISS_TO_DEC_FROM_FETCH),
        .TLB_MISS(TLB_MISS_TO_ALU),
        .PC_INIT(TLB_PC_TO_DEC),
        .PC_TO_REG(TLB_PC_TO_ALU),
        .TLB_MISS_TRAP(TLB_MISS_TRAP),
        .TLB_PC_REG(TLB_PC_REG),
        .TLB_ADDR_REG(TLB_ADDR_REG),
        .injecting_nop_mem(injecting_nop_mem),
        .supervisor_mode(supervisor_mode_to_alu),
        .supervisor_mode_fetch(supervisor_mode_fetch),
        .WB_SYS_EN(WB_SYS_EN_TO_ALU)
    );
     wire jump_regD;
    alu_stage alu_state(
        .clk(clk),
        .reset(reset),
        .mem_regD(regD_to_mem),
        .wb_regD(regD_to_wb),
        .RegW_en_mem(WB_EN_TO_MEM),
        .RegW_en_wb(RegW_en_to_decode),
        .regAdata_init(RegAdata_to_alu),
        .regBdata_init(RegBdata_to_alu),
        .reg_s(reg_s),
        .reg_t(reg_t),
        .regFromWB(write_data_to_reg),
        .regFromMem(alu_result_to_wb),
        .lower_half_instruction(lower_half_instruction_to_alu),
        .FUNCTION(FUNCTION_TO_ALU),
        .WB_EN_INIT(WB_EN_TO_ALU), 
        .MEM_R_EN_INIT(MEM_R_EN_TO_ALU),
        .MEM_W_EN_INIT(MEM_W_EN_TO_ALU),
        .MEM_TO_REG_INIT( MEM_TO_REG_TO_ALU),
        .is_immediate(is_immediate),
        .PCNEXT_init(PC_TO_ALU),
        .ALU_OP(ALU_OP_TO_ALU),
        .REG_DEST(ALU_REG_DEST_TO_ALU),
        .regD_reg(regD_reg_ALU),
        .regD_imme(regD_imme_ALU),
        .is_BRANCH_init(is_BRANCH_TO_ALU),
        .EN_REG ( EN_REG_ALU),
        .regDdata(regDdata_to_mem),
        .regBdata(regBdata_to_mem),
        .zero(zero_to_mem),
        .WB_EN(WB_EN_TO_MEM), 
        .MEM_R_EN(MEM_R_EN_TO_MEM),
        .MEM_W_EN(MEM_W_EN_TO_MEM),
        .MEM_TO_REG( MEM_TO_REG_TO_MEM),
        .PCNEXT(PC_TO_MEM),
        .regD ( regD_to_mem),
        .is_BRANCH(is_BRANCH_TO_MEM),
        .TLB_WRITE_INIT(TLB_WRITE_TO_ALU),
        .TLB_WRITE(TLB_WRITE_TO_MEM),
        .injected_nop_init(NOP_TO_ALU),
        .injected_nop(NOP_TO_MEM),
        .TLB_MISS_INT(TLB_MISS_TO_ALU),
        .TLB_MISS(TLB_MISS_TO_MEM),
        .PC_INIT(TLB_PC_TO_ALU),
        .PC_TO_REG(TLB_PC_TO_MEM),
        .supervisor_mode_init(supervisor_mode_to_alu),
        .supervisor_mode(supervisor_mode_to_mem),
        .WB_SYS_EN_INIT(WB_SYS_EN_TO_ALU),
        .WB_SYS_EN(WB_SYS_EN_TO_MEM),
        .jump_regD(jump_regD)
    );
   
    mem_stage mem_state(
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .jump_regD(jump_regD),
        .WB_EN_INIT(WB_EN_TO_MEM), 
        .MEM_R_EN_INIT(MEM_R_EN_TO_MEM),
        .MEM_W_EN_INIT(MEM_W_EN_TO_MEM),
        .regBdata_write_data(regBdata_to_mem),
        .regData_address(regDdata_to_mem),
        .PCNEXT_INIT(PC_TO_MEM),
        .zero(zero_to_mem),
        .is_BRANCH(is_BRANCH_TO_MEM),
        .WB_EN(WB_EN_TO_WB),
        .MEM_TO_REG_INIT( MEM_TO_REG_TO_MEM),
        .MEM_TO_REG( MEM_TO_REG_TO_WB),
        .read_data_mem( read_data_mem_to_wb),
        .alu_result (alu_result_to_wb),
        .regD_init (regD_to_mem),
        .regD (regD_to_wb),
        .BRANCH (BRANCH_TO_FETCH),
        .PCNEXT (PCNEXT_TO_FETCH),
        .EN_REG (EN_REG_MEM),
        .data_from_mem(data_to_cache),
        .read_ready_from_mem(read_ready_for_dcache),
        .written_data_ack_from_mem(written_data_ack),
        .reqD_mem(reqD_cache),
        .reqAddrD_mem(reqAddrD_mem),
        .data_to_mem(data_to_mem),
        .reqD_cache_write(reqD_cache_write),
        .reqAddrD_write_mem(reqAddrD_write_mem),
        .reqD_stop(reqD_stop),
        .TLB_WRITE_INIT(TLB_WRITE_TO_MEM),
        .TLB_MISS_M(TLB_MISS_M),
        .injected_nop_init(NOP_TO_MEM),
        .injected_nop(last_stage_nop),
        .TLB_MISS_INIT(TLB_MISS_TO_MEM),
        .TLB_MISS(TLB_MISS_TRAP),
        .PC_INIT(TLB_PC_TO_MEM),
        .PC_TO_REG(TLB_PC_TO_REG),
        .ADDRESS_TO_REG(TLB_ADDR_REG),
        .injecting_nop_mem(injecting_nop_mem),
        .supervisor_mode(supervisor_mode_to_mem),
        .logic_page_from_trad_ITLB(logic_page_from_trad_ITLB),
        .pyshical_page_from_trad_ITLB(pyshical_page_from_trad_ITLB),
        .WB_SYS_EN_INIT(WB_SYS_EN_TO_MEM),
        .WB_SYS_EN(WB_SYS_EN_TO_WB)
    );

    writeB_stage writeB_state(
        .clk(clk),
        .reset(reset),
        .RegW_en_init(WB_EN_TO_WB),
        .alu_result(alu_result_to_wb),
        .memReadVal(read_data_mem_to_wb),
        .RegD_init(regD_to_wb),
        .MemToReg( MEM_TO_REG_TO_WB),
        .WriteData(write_data_to_reg),
        .RegD(destination_reg),
        .RegW_en(RegW_en_to_decode),
        .WB_SYS_EN_INIT(WB_SYS_EN_TO_WB),
        .RegW_en_System(RegW_en_System_to_decode)
    );

    memory_controller memory_controller(
        .clk(clk), 
        .reset(reset), 
        .reqI_cache (reqI_cache),
        .reqD_cache (reqD_cache),
        .reqD_cache_write ( reqD_cache_write),
        .reqAddrD_mem ( reqAddrD_mem),
        .reqAddrI_mem ( reqAddrI_mem),
        .data_from_cache ( data_to_mem),
        .data_to_cache (data_to_cache),
        .read_ready_for_icache (read_ready_for_icache),
        .read_ready_for_dcache(read_ready_for_dcache),
        .written_data_ack (written_data_ack),
        .reqAddrD_write_mem(reqAddrD_write_mem)
    );

endmodule