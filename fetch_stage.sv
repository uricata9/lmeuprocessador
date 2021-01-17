module fetch_stage(
    input [31:0] PCbranch,
    input clk,reset,writePCEn,flush,
    input BRANCH, 
    input EN_REG,
    input [127:0] instr_from_mem,
    input read_ready_from_mem,
    input written_data_ack_from_mem,
    input supervisor_mode,
    input [31:0] logic_page_from_trad,
    input [19:0] pyshical_page_from_trad,
    output reg [31:0] PCnext,
    output reg [31:0] instruction,
    output reg reqI_mem,
    output reg [25:0] reqAddrI_mem,
    input tlb_write,
    input TLB_MISS_MEM,
    output reg [31:0] PC_TLB,
    output reg TLB_MISS);

    wire [31:0] PC_internal_plus_4, PC_internal_plus_4_int,PC_address_to_PC,instruction_internal;
    reg [31:0] PC,PC_TLB_MISS;
    reg cache_hit;
    int count_ready_next_inst;
    wire [19:0] PhysicalAddress_tlb;

    assign TLB_MISS_TOT = TLB_MISS | TLB_MISS_MEM;
    mux4Data muxSelectPC(
        .select({TLB_MISS_TOT,BRANCH}),
        .a(PC_internal_plus_4),
        .b(PCbranch),
        .c(PC_TLB_MISS),
        .d(PC_TLB_MISS),
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
        .address({12'b0,PhysicalAddress_tlb}), 
        .readdata(instruction_internal),
        .data_from_mem(instr_from_mem),
        .read_ready_from_mem(read_ready_from_mem),
        .written_data_ack(written_data_ack_from_mem),
        .reqI_mem(reqI_mem),
        .reqAddrI_mem(reqAddrI_mem),
        .cache_hit(cache_hit)
    );

    i_d_TLB iTLB(
        .reset(reset), 
        .clk(clk),
        .flush(flush),
        .mem_read(EN_REG),
        .Address(PC),
        .supervisor_mode(supervisor_mode),
        .tlb_write(tlb_write),
        .reg_logic_page(logic_page_from_trad),
        .reg_physical_page(pyshical_page_from_trad),
        .PhysicalAddress(PhysicalAddress_tlb),
        .tlb_miss(TLB_MISS_INT)
    );

    assign instruction = instruction_internal;

    //STAGE REGISTER 
    always @ (posedge clk) begin

        if (flush || reset) begin
            PCnext <= 0;
            PC <= 32'b0000_0000_0000_0000_0001_0000_0000_0000; 
            PC_TLB_MISS <= 32'b0000_0000_0000_0000_0010_0000_0000_0000;
            //count_ready_next_inst <= 1;
        end
        else if (EN_REG && !read_ready_from_mem) begin
            PC <= PC_address_to_PC;
            PC_TLB <= PC_address_to_PC;
            PCnext <= PC_internal_plus_4;
         TLB_MISS = TLB_MISS_INT;
        end

        /*if (count_ready_next_inst == 0) begin
            count_ready_next_inst = 1;
        end
        if (read_ready_from_mem) begin
            count_ready_next_inst = 0;
        end*/

    end

endmodule

