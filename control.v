module control (
    
    input clk,reset,
    input [31:0] instruction,
    output reg ALU_REG_DEST,
    output reg is_branch,
    output reg MEM_R_EN, MEM_W_EN,
    output reg MEM_TO_REG,
    output reg WB_EN,
    output reg [1:0] ALU_OP,
    output reg [5:0] FUNCTION ,
    output reg [4:0] regA, regB, regD,
    output reg EN_REG_FETCH, EN_REG_DECODE, EN_REG_ALU, EN_REG_MEM,
    output reg is_immediate
    );

    // Reg to Reg           //Reg-Immediate     //Branch            //Jump
    //31-26 Operation       31-26 Operation     31-26 Operation     31-26 Operation
    //25-21 RegA            25-21 RegA          25-21 RegA          25-21 regA
    //20-16 RegB            20-16 RegD          20-16 RegB/OpX
    //15-11 RegD            15-0 Immediate      15-0 Immediate      15-0 target
    //10-6 NULL             
    //5-0 OpX


    /*              31:26
    aritmetic       00000
    compare         00001
    addi            00010 
    loadb           00011    
    loadw           00100   
    storeb          00101
    storew          00110
    mvl             00111
    mvh             01000
    mvi             01001
    jal             01010´
    jump            01011
    float_op        01100
    loadf           01101
    storef          01110
    tlbwrite        10000
    iret            10001





    */

    wire [5:0] FUNCTION_INT;

    assign FUNCTION_INT = instruction [31:26];

    assign regA = instruction [25:21];

    reg [1:0] ALU_OP_internal;

    //wire [4:0] regD,regB;

    always @ ( * ) begin 

        FUNCTION <= FUNCTION_INT;
        case({FUNCTION_INT})
            6'b000000: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b10;
                regD <= instruction[15:11];
                regB <= instruction[20:16];
                is_immediate  <= 0;
            end
            6'b000001: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b10;
                regD <= instruction[15:11];
                regB <= instruction[20:16];
                is_immediate  <= 0;
            end
            6'b0000010: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b11;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 1;
            end
            //Load
            6'b000011: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 1;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 1;
                ALU_OP <= 2'b00;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 0;
            end
            6'b000100: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 1;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 1;
                ALU_OP <= 2'b00;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 0;
            end
            //Store
            6'b000101: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 1;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b00;
                regB <= instruction[20:16];
                regD <= 6'b000000;
                is_immediate  <= 0;
            end
            6'b000110: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 1;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b00;
                regB <= instruction[20:16];
                regD <= 6'b000000;
                is_immediate  <= 0;
            end
            //Move
            6'b000111: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b00;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 0;
            end
                
            6'b001000: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b00;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 0;
            end
            6'b001001: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b00;
                regD <= instruction[20:16];
                regB <= 6'b000000;
                is_immediate  <= 0;
            end
            //Branches      
            6'b001010: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 1;
                is_branch <= 1;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b01;
                regD <= 6'b000000;
                regB <= instruction[20:16];
                is_immediate  <= 0;
            end
            6'b001011: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 1;
                is_branch <= 1;
                MEM_R_EN <= 0;
                MEM_W_EN <= 0;
                MEM_TO_REG <= 0;
                ALU_OP <= 2'b01;
                regD <= 6'b000000;
                regB <= instruction[20:16];
                is_immediate  <= 0;
            end
            //Float
            6'b001100: begin
                WB_EN = 1;
                ALU_REG_DEST = 1;
                is_branch = 0;
                MEM_R_EN = 0;
                MEM_W_EN = 0;
                MEM_TO_REG = 0;
                ALU_OP = 2'b10;
                is_immediate  <= 0;
            end
            6'b001101: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <=0;
                MEM_TO_REG <=0;
                ALU_OP <= 2'b10;
                is_immediate  <= 0;
            end
            6'b001110: begin
                WB_EN <= 1;
                ALU_REG_DEST <= 1;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <=0;
                MEM_TO_REG <=0;
                ALU_OP <= 2'b10;
                is_immediate  <= 0;
            end
            default: begin
                WB_EN <= 0;
                ALU_REG_DEST <= 0;
                is_branch <= 0;
                MEM_R_EN <= 0;
                MEM_W_EN <=0;
                MEM_TO_REG <=0;
                ALU_OP <= 2'b10;
                is_immediate  <= 0;
            end
            //Advanced
            //5'b10000: begin
            //5'b10001: begin
        endcase
    end 
    always @ (reset) begin

        if (reset == 1) begin
            EN_REG_FETCH = 1;
            EN_REG_DECODE = 1;
            EN_REG_ALU = 1;
            EN_REG_MEM = 1;
        end
    end 
endmodule // register