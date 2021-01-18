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

    wire [31:0] PC_internal_plus_4, PC_internal_plus_4_int,PC_address_to_PC,instruction_internal;
    wire [31:0] PC_INTERNAL;
    reg cache_hit;
    int count_ready_next_inst;
    mux2Data muxSelectPC(
        .select(BRANCH),
        .a(PC_internal_plus_4),
        .b(PCbranch),
        .y(PC_address_to_PC)
    );

    assign PC_internal_plus_4 = PC_INTERNAL +4;

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
        .address(PC_INTERNAL), 
        .readdata(instruction_internal),
        .data_from_mem(instr_from_mem),
        .read_ready_from_mem(read_ready_from_mem),
        .written_data_ack(written_data_ack_from_mem),
        .reqI_mem(reqI_mem),
        .reqAddrI_mem(reqAddrI_mem),
        .cache_hit(cache_hit)
    );

    flipflop PC(
        .clk(clk),
        .reset(reset),
        .writeEn(EN_REG & !read_ready_from_mem & cache_hit ),
        .regIn(PC_address_to_PC),
        .regOut(PC_INTERNAL)
    );

    assign instruction = instruction_internal;

    //STAGE REGISTER 
    always @ (posedge clk) begin

        if (flush || reset) begin
            PCnext <= 0;
            //count_ready_next_inst <= 1;
        end
        else if (EN_REG && !read_ready_from_mem) begin
            
            PCnext <= PC_address_to_PC;
        end

        /*if (count_ready_next_inst == 0) begin
            count_ready_next_inst = 1;
        end
        if (read_ready_from_mem) begin
            count_ready_next_inst = 0;
        end*/

    end

endmodule

