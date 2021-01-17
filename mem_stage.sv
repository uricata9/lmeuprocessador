module mem_stage(
    input clk, reset,zero, flush,
    input WB_EN_INIT, MEM_R_EN_INIT, MEM_W_EN_INIT,
    input [31:0] regBdata_write_data,regData_address,
    input [31:0] PCNEXT_INIT,
    input is_BRANCH,
    input EN_REG,
    input [4:0] regD_init,
    input MEM_TO_REG_INIT,
    output reg WB_EN,
    output reg MEM_TO_REG,
    output reg [31:0] read_data_mem,
    output reg [31:0] alu_result,
    output reg BRANCH,
    output reg [31:0] PCNEXT,
    output reg [4:0] regD,
    input [127:0] data_from_mem,
    input read_ready_from_mem,
    input written_data_ack_from_mem,
    output reg reqD_mem,
    output reg [25:0] reqAddrD_mem,
    output reg [127:0] data_to_mem,
    output reg reqD_cache_write,
    output reg [25:0] reqAddrD_write_mem,
    output reg reqD_stop,
    input TLB_WRITE_INIT,
    input injected_nop_init,
    input injecting_nop_mem,
    output reg injected_nop,
    input supervisor_mode,
    input TLB_MISS_INIT,
    output reg TLB_MISS_M,
    output reg TLB_MISS,
    input [31:0]  PC_INIT,
    output reg [31:0]  PC_TO_REG,
    output reg [31:0]  ADDRESS_TO_REG,
    output reg [31:0] logic_page_from_trad_ITLB,
    output reg [19:0] pyshical_page_from_trad_ITLB,
    input WB_SYS_EN_INIT,
    output reg WB_SYS_EN
);

    wire [31:0] read_data_mem_intern;
    wire TLB_MIS_MEM, MEM_R_EN_INT, MEM_W_EN_INT,TLB_MISS_MEM;
    wire [19:0] PhysicalAddress_tlb;
    assign BRANCH = is_BRANCH & zero;

    //assign read_data_mem_intern=read_data_mem;

    assign inject_nop = injected_nop_init | injecting_nop_mem;

    assign MEM_R_EN_INT = MEM_R_EN_INIT & !inject_nop;
    assign MEM_R_EN_INT = MEM_W_EN_INIT & !inject_nop;

    data_cache data_cache(
        .clk(clk), 
        .reset(reset),
        .flush(flush), 
        .mem_read(MEM_R_EN_INT),
        .mem_write(MEM_W_EN_INT), 
        .address({12'b0,PhysicalAddress_tlb}), 
        .writedata(regBdata_write_data), 
        .readdata(read_data_mem_intern),

        .data_from_mem ( data_from_mem),
        .read_ready_from_mem (read_ready_from_mem),
        .written_data_ack( written_data_ack_from_mem),
        .reqD_mem (reqD_mem),
        .reqD_stop(reqD_stop),
        .reqAddrD_mem ( reqAddrD_mem),
        .reqD_cache_write ( reqD_cache_write),
        .data_to_mem ( data_to_mem),
        .reqAddrD_write_mem(reqAddrD_write_mem)
    );

    i_d_TLB dTLB(
        .reset(reset), 
        .clk(clk),
        .flush(flush),
        .mem_read(EN_REG),
        .Address(regData_address),
        .tlb_write(TLB_WRITE_INIT),
        .reg_logic_page(alu_result),
        .reg_physical_page(regBdata_write_data[19:0]),
        .PhysicalAddress(PhysicalAddress_tlb),
        .supervisor_mode(supervisor_mode),
        .tlb_miss(TLB_MISS_MEM)
    );

    /*test_dataMem test_data_mem(
        .mem_read(MEM_R_EN_INIT),
        .memwrite(MEM_W_EN_INIT),
        .address(regData_address),
        .writedata(regBdata_write_data),
        .readdata(read_data_mem_intern)
    )*/

 //STAGE REGISTER 
    always @ (posedge clk) begin
        if (reset) begin
            WB_EN <= 0;
            MEM_TO_REG <= 0;
            read_data_mem <= 0;
            alu_result <= 0;
            PCNEXT <= 32'b00000000000000000000000000000000;
            regD <= 0;
        end
        else if (EN_REG) begin
            WB_EN <= WB_EN_INIT;
            MEM_TO_REG <= MEM_R_EN_INIT;
            alu_result <= regData_address;
            read_data_mem <= read_data_mem_intern;
            PCNEXT <= PCNEXT_INIT;
            regD <= regD_init;
            TLB_MISS_M <= TLB_MISS_INIT | TLB_MIS_MEM ;
            PC_TO_REG <= PC_INIT;
            ADDRESS_TO_REG <=regData_address;
            logic_page_from_trad_ITLB <= alu_result;
            pyshical_page_from_trad_ITLB <= regBdata_write_data[19:0];
            TLB_MISS <= TLB_MISS_MEM;
            WB_SYS_EN <= WB_SYS_EN_INIT;
        end
    end

endmodule