module data_cache_generator (
    
    input clk, reset, flush,
    input requested_data_to_mem,
    output reg mem_read, mem_write,
    output reg [31:0] address, writedata);

    reg [31:0] coses_a_fer [31:0];
    reg reads [31:0];
    reg writes [31:0];
    reg blocked;
    integer count;
    always @ (posedge clk) begin
  	    

        /*if (requested_data_to_mem == 1'b1) begin
            blocked = 1'b1;
        end
        else begin
            blocked = 1'b0;
        end*/
        #10ps
        if (reset) begin
           
            count =0;
            for (int i = 0; i < 20;i++) begin
                reads[i] = 1;
            end
            for (int i = 20; i < 32;i++) begin
                reads[i] = 0;
            end
            for (int i = 20; i < 32;i++) begin
                writes[i] = 1;
            end
            for (int i = 0; i < 20;i++) begin
                writes[i] = 0;
            end

            coses_a_fer[0] <=   32'b00000000000000000000000000000000;
            coses_a_fer[1] <=   32'b00000000000000000000000000000100;
            coses_a_fer[2] <=   32'b00000000000000000000000000001000;
            coses_a_fer[3] <=   32'b00000000000000000000000000001100;
            coses_a_fer[4] <=   32'b00000000000000000000000000010000;
            coses_a_fer[5] <=   32'b00000000000000000000000000010100;
            coses_a_fer[6] <=   32'b00000000000000000000000000011000;
            coses_a_fer[7] <=   32'b00000000000000000000000000011100;
            coses_a_fer[8] <=   32'b00000000000000000000000000100000;
            coses_a_fer[9] <=   32'b00000000000000000000000000100100;
            coses_a_fer[10] <=  32'b00000000000000000000000000101000;
            coses_a_fer[11] <=  32'b00000000000000000000000000101100;
            coses_a_fer[12] <=  32'b00000000000000000000000000110000;
            coses_a_fer[13] <=  32'b00000000000000000000000000110100;
            coses_a_fer[14] <=  32'b00000000000000000000000000111000;
            coses_a_fer[15] <=  32'b00000000000000000000000000111100;
            coses_a_fer[16] <=  32'b00000000000000000000000001000000;
            coses_a_fer[17] <=  32'b00000000000000000000000001000100;
            coses_a_fer[18] <=  32'b00000000000000000000000001001000;
            coses_a_fer[19] <=  32'b00000000000000000000000001001100;
            coses_a_fer[20] <=  32'b00000000000000000000000001010000;
            coses_a_fer[21] <=  32'b00000000000000000000000001010100;
            coses_a_fer[22] <=  32'b00000000000000000000000001011000;
            coses_a_fer[23] <=  32'b00000000000000000000000001011100;
            coses_a_fer[24] <=  32'b00000000000000000000000001100000;
            coses_a_fer[25] <=  32'b00000000000000000000000001100100;
            coses_a_fer[26] <=  32'b00000000000000000000000001101000;
            coses_a_fer[27] <=  32'b00000000000000000000000001101100;
            blocked = 1'b0;
        end

        else if (requested_data_to_mem == 1'b1) begin
            blocked = 1'b1;
        end

        else if (requested_data_to_mem == 1'b0 && blocked == 1'b1) begin
            blocked = 1'b0;
        end
        else if (requested_data_to_mem == 1'b0 && blocked == 1'b0) begin
            
            address=coses_a_fer[count];
            mem_read=reads[count];
            mem_write=writes[count];
            count = count + 1;
        end

        
    end


endmodule // insttructionMem