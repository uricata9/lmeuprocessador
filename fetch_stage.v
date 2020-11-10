module fetch_stage(
    input [31:0] PCbranch,
    input clk,reset,writePCEn,flush,
    input BRANCH, 
    input EN_REG,
    output reg [31:0] PCnext,
    output reg [31:0] instruction);

    wire [31:0] PC_internal_plus_4,PC_address_to_PC,instruction_internal;
    reg [31:0] PC;
    mux2Data muxSelectPC(
        .select(BRANCH),
        .a(PC_internal_plus_4),
        .b(PCbranch),
        .y(PC_address_to_PC)
    );

    assign PC_internal_plus_4 = PC +4;

    test_instrMem inst_cache(
        .rst(reset),
        .addr(PC_internal_plus_4),
        .instruction(instruction_internal)
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

