module store_buffer (    
    input clk, reset,flush, 
    input mem_read,
    input mem_write, 
    input [31:0] address, 
    input [31:0] writedata,
    input cache_ready_to_catch,
    output [31:0] data_read,
    output hit_storeBuffer,
    output [63:0] data_to_cache,
    output sending_data_to_cache,
    output storeBuffer_full);


    reg [63:0] storeBuffer [0:3];
    reg storeBuffer_valid [0:3];

    always @ (posedge clk) begin

        if (reset == 1'b1 ) begin
            for (int k = 0; k < 4; k++) begin         
                store_buffer[k] = 64'b0;
                storeBuffer_valid = 1'b0;
            end
            head=0;
            sending_data_to_cache = 0;
            hit_storeBuffer = 0;
            storeBuffer_full = 1'b0;
            
        end
        
        if (mem_read == 1'b1) begin
            hit_storeBuffer = 1'b0;
            for (int k = 0; k < 4; k++) begin
                assign storeBuffer_line = storeBuffer[k];
                if (storeBuffer_valid[k] == 1'b1 && storeBuffer_line[63:32] == address) begin
                    data_read = storeBuffer_line[31:0];
                    hit_storeBuffer = 1'b1;
                end
            end
        end

        if (mem_write == 1'b1) begin
            for (int k = 0; k < 4; k++) begin
                assign storeBuffer_line = storeBuffer[k];
                if (storeBuffer_valid[k] == 1'b1 && storeBuffer_line[63:32] == address) begin
                    storeBuffer_line[31:0] = writedata;
                    hit_storeBuffer = 1'b1;
                end
                if (storeBuffer_valid[k] == 1'b0) begin
                    storeBuffer_line[31:0] = writedata;
                    hit_storeBuffer = 1'b0;
                end
            end
        end

        if (cache_ready_to_catch == 1'b1) begin
            if (storeBuffer_valid[0] == 1'b1) begin
                    
                sending_data_to_cache= 1'b1;
                data_to_cache = storeBuffer[0];
                storeBuffer_valid[k] == 1'b0;
                int valid = 1;
                for (int k = 1; k < 4 && valid == 1; k++) begin
                    if (storeBuffer_valid[k] == 1'b1) begin
                        storeBuffer[k-1] == storeBuffer[k];
                        storeBuffer_valid[k-1] == 1'b1;
                        storeBuffer_valid[k] == 1'b0;
                    end
                    else begin
                        valid == 0;
                    end
                end
            end
            else begin
                sending_data_to_cache= 1'b0;
            end
        end

        if (storeBuffer_valid[3] == 1'b1) begin
            storeBuffer_full = 1'b1;
        end
        else 
            storeBuffer_full = 1'b0;
        end

    end


endmodule