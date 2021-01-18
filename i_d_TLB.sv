module i_d_TLB(    
    input reset, clk, flush,
    input [31:0] Address,
    input mem_read,
    input supervisor_mode,
    input tlb_write,
    input [31:0] reg_logic_page,
    input [19:0] reg_physical_page,
    output reg [19:0] PhysicalAddress,
    output reg tlb_miss,
    output reg fetch);

    reg [32:0] page_table [3:0];
    reg [19:0] page_traduction [3:0];
    reg valid_page [3:0];
    reg [1:0] countLRU [3:0];
    reg [19:0] page_tag;
    reg [11:0] page_offset;
    reg tlb_hit;
    reg ready_next;
    int row_cache;


    always @ (negedge clk) begin
        
        page_tag = Address [31:12];
        page_offset =  Address [11:0];
        row_cache = -1; //undefined
        if (reset || flush) begin
            for (int i=0; i <=4; i++ ) begin
                page_table[i] = 20'b0;
                tlb_miss = 0;
                valid_page [i] = 0;
                PhysicalAddress = 32'b0000_0000_0000_0000_0001_0000_0000_0000;
            end
            fetch = 1'b1;
        end

        if (supervisor_mode)
           PhysicalAddress = Address[19:0];

        
        else if  (mem_read && !supervisor_mode) begin
            if ( supervisor_mode == 1'b0 && tlb_write == 1'b0) begin
                tlb_miss=1'b1;
                for (int i=0; i < 4; i++) begin
                    if (page_table [i] == page_tag) begin
                        if (valid_page [i] == 1'b1) begin
                            PhysicalAddress[19:12] = page_traduction [i]; 
                            PhysicalAddress[11:0] = page_offset;
                            tlb_miss=1'b0;

                            for (int k = 0; k < 4; k++) begin
                                if (i != k && countLRU[k] <  countLRU [i]) begin
                                    countLRU [k] = countLRU [k] + 2'b01;
                                end
                            end

                            countLRU [i] = 2'b00;

                        end
                    end
                end
            end
            else if ( supervisor_mode ==1'b1 && tlb_write == 1'b1 && tlb_miss == 1'b1) begin

                for (int i=0; i < 4; i++) begin
                    if (valid_page [i] == 1'b0) begin
                        row_cache = i;
                    end
                end
                if (row_cache == -1) begin
                    for (int i=0; i < 4; i++) begin
                        if (countLRU [i] == 2'b11) begin
                            row_cache = i;
                            countLRU [i] = 2'b00;
                        end
                        else begin
                            countLRU [i] = countLRU [i] + 2'b01;
                        end
                    end
                end

                page_table [row_cache] = reg_logic_page;
                page_traduction [row_cache] = reg_physical_page;
                valid_page [row_cache] = 1'b1;
                tlb_miss = 1'b0;
                fetch = 1'b1;
            end
            if (tlb_miss == 1'b1)
                fetch = 1'b0;
            else if (supervisor_mode == 1'b1)
                fetch = 1'b1;
        end


    
    end

endmodule 