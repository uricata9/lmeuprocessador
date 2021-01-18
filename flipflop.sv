
module flipflop (
    
    input clk, reset, writeEn,
    input [31:0] regIn,
    output reg [31:0] regOut);

    always @ (posedge clk) begin
        if (reset == 1) regOut <= 32'b0000_0000_0000_0000_0001_0000_0000_0000;
        else if (writeEn) regOut <= regIn;
    end
endmodule // register