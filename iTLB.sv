module iTLB(    
    input reset, clk, flush,
    input [31:0] VirtualAddress,
    input supervisor_mode,
    input tlb_write,
    input [19:0] reg_logic_page,
    input [7:0] reg_physical_page,
    output reg [19:0] PhysicalAddress,
    output reg tlb_miss);

    reg [19:0] page_table [3:0];
    reg [7:0] page_traduction [3:0];
    reg valid_page [3:0];
    reg [1:0] countLRU [3:0];
    wire [19:0] page_tag;
    wire [11:0] page_offset;
    wire tlb_hit;

    int row_cache;


    always @ (posedge clk) begin
        
        page_tag = VirtualAddress [31:12];
        page_offset =  VirtualAddress [11:0];

        if (reset || flush) begin
            for (i=0; i <=4; i++ ) begin
                page_table[i] = 20'b0;
                tlb_miss = 0;
                valid_page [i] = 0;
            end
        end
        row_cache = -1; //undefined

        if ( supervisor_mode == 1'b0 && tlb_write == 1'b0) begin
            tlb_miss=1'b1;
            for (i=0; i < 4; i++) begin
                if (page_tag [i] == page_tag) begin
                    if (valid_page [i] == 1'b1) begin
                        PhysicalAddress[19:12] = page_traduction [i]; 
                        PhysicalAddress[11:0] = page_offset
                        tlb_miss=1'b0;
                        
                        countLRU [i];

                        for (k = 0; k < 4; k++) begin
                            if (i != k && countLRU[k] <  countLRU [i]) begin
                                countLRU [k] = countValid [k] + 2'b01;
                            end
                        end

                        countLRU [i] == 2'b00;

                    end
                end
            end

        else if ( supervisor_mode == 1'b0 && tlb_write == 1'b1) begin

            for (i=0; i < 4; i++) begin
                if (valid_page [i] == 1'b0) begin
                    row_cache = i;
                end

            if (row_cache == -1) begin
                for (i=0; i < 4; i++) begin
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

        end
    
    end

endmodule 