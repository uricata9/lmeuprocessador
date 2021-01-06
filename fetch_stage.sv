module fetch_stage(
    input [31:0] PCbranch,
    input clk,reset,writePCEn,flush,
    input BRANCH, 
    input EN_REG,
    input [127:0] instr_from_mem,
    input read_ready_from_mem,
    input written_data_ack_from_mem,
    output reg [31:0] PCnext,
    output reg [31:0] instruction,
    output reg reqI_mem,
    output reg [25:0] reqAddrI_mem);

    wire [31:0] PC_internal_plus_4,PC_address_to_PC,instruction_internal;
    reg [31:0] PC;
    mux2Data muxSelectPC(
        .select(BRANCH),
        .a(PC_internal_plus_4),
        .b(PCbranch),
        .y(PC_address_to_PC)
    );

    assign PC_internal_plus_4 = PC +4;

    /*test_instrMem inst_cache(
        .rst(reset),
        .addr(PC_internal_plus_4),
        .instruction(instruction_internal)
    );*/

    instr_cache instr_cache(
        .clk(clk),
        .reset(reset),
        .flush(flush), 
        .mem_read(EN_REG),
        .address(PCnext), 
        .readdata(instruction_internal),
        .data_from_mem(instr_from_mem),
        .read_ready_from_mem(read_ready_from_mem),
        .written_data_ack(written_data_ack_from_mem),
        .reqI_mem(reqI_mem),
        .reqAddrI_mem(reqAddrI_mem)
    );

    iTLB iTLB(
        .reset(reset), 
        .clk(clk),
        .flush(flush),
        .VirtualAddress,
    input supervisor_mode,
    input tlb_write,
    input [19:0] reg_logic_page,
    input [7:0] reg_physical_page,
    output reg [19:0] PhysicalAddress,
    output reg tlb_miss
    );

    //STAGE REGISTER 
    always @ (posedge clk) begin

        if (flush || reset) begin
            instruction <= 0;
            PCnext <= 0;
            PC  <= 0;
        end
        else if (EN_REG) begin
            instruction <= instruction_internal;
            PC <= PC_address_to_PC;
            PCnext <= PC_internal_plus_4;
        end
    end

endmodule

