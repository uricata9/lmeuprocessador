module ram_memory(    
    input reset, 
    input [25:0] data_requested,
    output reg [127:0] data_returned,
    input [127:0] data_to_write,
    input write_to_mem);

    reg [31:0] memory [10485:0]; //han de ser 20 bits per addreces fisiques

    reg [31:0] shifted_adress;

    always @ (*) begin
        
        if (reset == 1'b1) begin
            /*for (int i=0; i < 1048576; i++) begin
                memory[i] = i;
            end*/
            memory[0] <=   32'b00000000000000000000000000000000;
            memory[1] <=   32'b00000000000000000000000000000001;
            memory[2] <=   32'b00000000000000000000000000000010;
            memory[3] <=   32'b00000000000000000000000000000011;
            memory[4] <=   32'b00000000000000000000000000000100;
            memory[5] <=   32'b00000000000000000000000000000101;
            memory[6] <=   32'b00000000000000000000000000000110;
            memory[7] <=   32'b00000000000000000000000000000111;
            memory[8] <=   32'b00000000000000000000000000001000;
            memory[9] <=   32'b00000000000000000000000000001001;
            memory[10] <=  32'b00000000000000000000000000001010;
            memory[11] <=  32'b00000000000000000000000000001011;
            memory[12] <=  32'b00000000000000000000000000001100;
            memory[13] <=  32'b00000000000000000000000000001101;
            memory[14] <=  32'b00000000000000000000000000001110;
            memory[15] <=  32'b00000000000000000000000000001111;
            memory[16] <=  32'b00000000000000000000000000010000;
            memory[17] <=  32'b00000000000000000000000000010001;
            memory[18] <=  32'b00000000000000000000000000010010;
            memory[19] <=  32'b00000000000000000000000000010011;
            memory[20] <=  32'b00000000000000000000000000010100;
            memory[21] <=  32'b00000000000000000000000000010101;
            memory[22] <=  32'b00000000000000000000000000010110;
            memory[23] <=  32'b00000000000000000000000000010111;
            memory[24] <=  32'b00000000000000000000000000011000;
            memory[25] <=  32'b00000000000000000000000000011001;
            memory[26] <=  32'b00000000000000000000000000011010;
            memory[27] <=  32'b00000000000000000000000000011011;
            memory[28] <=  32'b00000000000000000000000000011100;
            memory[29] <=  32'b00000000000000000000000000011101;
            memory[30] <=  32'b00000000000000000000000000011110;
            memory[31] <=  32'b00000000000000000000000000011111;
            
            
        end
        
        else begin
            shifted_adress = data_requested << 2;
            data_returned = {memory[shifted_adress + 3], memory[shifted_adress + 2], memory[shifted_adress + 1], memory[shifted_adress]};
            if (write_to_mem == 1'b1) begin
                {memory[shifted_adress + 3], memory[shifted_adress + 2], memory[shifted_adress + 1], memory[shifted_adress]} = data_to_write;
            end
        end

    end

endmodule // insttructionMem