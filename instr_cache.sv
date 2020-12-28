module instr_cache (    
    input clk, reset,flush, 
    input mem_read,
    input [31:0] address, 
    output reg [31:0] readdata,
    input [127:0] data_from_mem,
    input read_ready_from_mem,
    input written_data_ack,
    output reg reqI_mem,
    output reg [25:0] reqAddrI_mem);

    reg [127:0] dataCache [0:3];
    reg [25:0] dataTag [0:3];
    reg dataValid [0:3];

    wire [3:0] addr_byte;
    wire [1:0] addr_index;
    wire [25:0] addr_tag;
    reg req_valid;
    reg pending_req;
    reg ready_next;
    wire [31:0] next_instruction;
    reg cache_hit;

    assign addr_byte = address[3:0];
    assign    addr_index = address[5:4];
        
    assign    addr_tag = address[31:6];
    integer row;
    always @ (posedge clk) begin
    
         
        if (reset == 1'b1 || flush == 1'b1) begin
            for (int k = 0; k < 4; k++) begin         
                cache_hit = 1'b0;
                req_valid = 1'b1;
                pending_req = 1'b0;
                dataValid[k] = 0;
                reqI_mem = 1'b0;
            end
        end

        /*case ({addr_index})

            2'b00: begin
                row = 0;
            end

            2'b01: begin
                row = 1;
            end

            2'b10: begin
                row = 2;
            end

            2'b11: begin
                row = 3;
            end
            
        endcase*/

        row = addr_index;

        if (pending_req && read_ready_from_mem == 1'b1) begin
                        
            
            dataCache [row] = data_from_mem;
            dataTag [row] = addr_tag;
            pending_req = 1'b0;
            dataValid [row] = 1'b1;
            ready_next = 1'b1;
            readdata = {dataCache [row][addr_byte + 3],dataCache [row][addr_byte + 2], dataCache [row][addr_byte + 1], dataCache [row][addr_byte] };
            reqI_mem = 1'b0;
            

                
        end
        
        if (pending_req == 1'b1 && written_data_ack == 1'b1) begin
            pending_req = 1'b0;
        end

        if (!pending_req && req_valid && mem_read) begin
            if (dataTag [row] == addr_tag) begin
                if (dataValid [row] == 1'b1) begin
                    readdata = {dataCache [row][addr_byte + 3],dataCache [row][addr_byte + 2], dataCache [row][addr_byte + 1], dataCache [row][addr_byte] };
                    cache_hit=1'b1;
                end
            end

            else begin
                cache_hit = 1'b0;
            end

            if (cache_hit == 1'b0) begin
        
                pending_req = 1'b1;
                reqAddrI_mem = address[31:4];
                reqI_mem = 1'b1;
                ready_next = 1'b0;

            end
        end



    end

endmodule // insttructionMem