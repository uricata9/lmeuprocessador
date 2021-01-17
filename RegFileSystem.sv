  
module RegFileSystem (
  
    input [4:0] regA, regB, regD,
    input [31:0] data_to_w,
    input clk, RegWriteEn,
    output [31:0] regA_data, regB_data,
    output  supervisor_mode,
    input TLB_MISS,
    input [31:0] TLB_PC_REG, TLB_ADDR_REG,
    input IRET);

    reg [31:0] regfileSystem [31:0];
    integer i;
    wire [4:0] regA_int;

    
    initial begin
        for (i=1; i<31; i=i+1) begin
            regfileSystem[i]=0;
	    end
        regfileSystem[4] = 32'b0000_0000_0000_0000_0000_0000_0000_0000;
    end
  
    always @(posedge clk)begin
	    if (RegWriteEn) 
	 	    regfileSystem[regD] <= data_to_w;


        if (TLB_MISS) begin
             regfileSystem[0] <= TLB_PC_REG;
             regfileSystem[1] <= TLB_ADDR_REG;
             regfileSystem[4] <= 32'b0000_0000_0000_0000_0000_0000_0000_0001;
        end

        if (IRET) begin
            regfileSystem[4] <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
        end

    end
    
    assign regA_data = regfileSystem[regA];
    assign regB_data = regfileSystem[regB];
    assign supervisor_mode = regfileSystem[4][0:0];

endmodule