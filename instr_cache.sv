module instr_cache (    
    input clk, reset,zero, 
    input [31:0] address,
    input [127:0] data_from_mem,
    input read_ready_from_mem,
    output reqI_mem,
    output [31:0] reqAddrI_mem,
    output [31:0] instruction);

    reg [127:0] instCache [0:3];
    reg [17:0] instTag [0:3];
    reg instValid [0:3];
    reg [1:0] countValid [0:3];

    logic [1:0] addr_byte, addr_index;
    wire [17:0] addr_tag;
    wire req_valid;
    wire pending_req;
    wire ready_next;
    wire [31:0] next_instruction;
    wire cache_hit;
    wire [1:0] lastcountValid;

    always @ (posedge clk) begin
        
        addr_byte = address[6:0];
        addr_index = address[8:7];
        
        addr_tag = address[31:9];
  	    cache_hit = 1'b0;
         
        if (reset) begin
            for (int k = 0; k < 4; k++) begin         
                countValid [k*2+1:k*2] = 2'b00;
            end
        
        end

        if (!pending_req && req_valid) begin
            for (int i=0; i < 4; i++) begin
                if (instTag [i*18+17:i*18] == addr_tag) begin
                    if (instValid [i] == 1'b1) begin
                        next_instruction = instCache [addr_index*128+addr_byte+31:addr_index*128+addr_byte];
                        cache_hit=1'b1;
                        
                        lastcountValid = countValid [i*2];

                        for (int k = 0; k < 4; k++) begin
                            if (i != k && countValid[k*2+1:k*2] < lastcountValid[k*2+1:k*2]) begin
                                countValid [k*2+1:k*2] = countValid [k*2+1:k*2] + 2'b01;
                            end
                        end

                        countValid [i*2+1:i*2] == 2'b00;

                    end
                end
            end

            if (cache_hit == 1'b0) begin
                pending_req = 1'b1;
                reqAddrI_mem = address[31:7];
                reqI_mem = 1'b1;
                ready_next = 1'b0;
            end
        end

        row_cache = -1; //undefined

        if (read_ready_from_mem == 1'b1) begin
            
            for (int i=0; i < 4; i++) begin
                if (instValid [i] == 1'b0) begin
                    row_cache = i;
                end

            if (row_cache == -1) begin
                for (int i=0; i < 4; i++) begin
                    if (countValid [i*2+1:i*2] == 2'b11) begin
                        row_cache = i;
                        countValid [i*2+1:i*2] = 2'b00;
                    end
                    else begin
                        countValid [i*2+1:i*2] = countValid [i*2+1:i*2] + 2'b01;
                    end
                end
            end

            instCache [row_cache*128+127:row_cache*128] = data_from_mem;
            instTag [row_cache*18+17:row_cache*18] = addr_tag;
            pending_req = 1'b0;
            instValid [row_cache] = 1'b1;
            ready_next = 1'b1;
            next_instruction = instCache [addr_index*128+addr_byte+32:addr_index*128+addr_byte];
        end

    end

endmodule // insttructionMem