`include "defines.v"

`include "alu.v"
`include "alu_ctrl.v"
`include "ctrl.v"
`include "ir_cache.v"
`include "prog_count.v"
`include "register.v"
`include "data_cache.v"
`include "forward.v"

module processor(clk, rst, mem_read, mem_write, mem_addr, mem_rdata, mem_wdata);

    //input output list
    //-----------------------------------------------------------------------------------------------------------
    input clk, rst;
    input [`WORD_WIDTH-1:0] mem_rdata;
    output mem_read, mem_write;
    output [`WORD_WIDTH-1:0] mem_addr;
    output [`WORD_WIDTH-1:0] mem_wdata;
    
    //===========================================================================================================
    //1st stage(IF)
    //-----------------------------------------------------------------------------------------------------------
    // Signals to next stage
    wire [`WORD_WIDTH-1:0] pc_nxtaddrIF;
    wire [`WORD_WIDTH-1:0] ir_dataIF;
    
    // Feedback signals declaration
    wire pc_srcFB; // feedback from 4th stage
    reg [`WORD_WIDTH-1:0] pc_jumpaddrFB; // feedback from 4th stage
    
    //instances
    prog_count PC ( .clk(clk), .rst(rst), 
                    .pc_src(pc_srcFB), 
                    .pc_jumpaddr(pc_jumpaddrFB), .pc_nxtaddr(pc_nxtaddrIF)
                    );
    ir_cache I_CACHE (  .clk(clk), .rst(rst), 
                        .ir_addr(pc_nxtaddrIF), .ir_data(ir_dataIF)
                        );
    //===========================================================================================================
    
    //===========================================================================================================
    //2nd stage(ID)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage and to next stage
    reg [`WORD_WIDTH-1:0] pc_nxtaddrID;
    reg [`WORD_WIDTH-1:0] ir_dataID;
    
    // New signal to next stage
    wire [`WORD_WIDTH-1:0] reg_rsID, reg_rtID;
    wire [1:0] alu_opID; // hard code!
    wire reg_dstID, alu_srcID, branchID, mem_readID, mem_writeID, reg_srcID, reg_writeID;
    wire [`WORD_WIDTH-1:0] immediateID = {{(`WORD_WIDTH-`IMM_WIDTH){ir_dataID[`IMM_WIDTH-1]}}, ir_dataID[`IMM]};
    wire [`REGADDR_WIDTH-1:0] src1_addrID= ir_dataID[`RS];
    wire [`REGADDR_WIDTH-1:0] src2_addrID= ir_dataID[`RT];
    
    // Pipeline register
    always@(posedge clk or posedge rst) begin : IF_ID
        if(rst) begin
            pc_nxtaddrID <= 0;
            ir_dataID <= 0;
        end
        else begin
            pc_nxtaddrID <= pc_nxtaddrIF;
            ir_dataID <= ir_dataIF;
        end
    end
    
    // Feedback signals declaration
    wire [`WORD_WIDTH-1:0] reg_wdataFB; // feedback from 5th stage
    reg [`REGADDR_WIDTH-1:0] reg_waddrFB; // feedback from 5th stage
    reg reg_writeFB; // feedback from 5th stage
    
    //instances
    register REG (  .clk(clk), .rst(rst), 
                    .reg_write(reg_writeFB),
                    .reg_addr1(ir_dataID[`RS]), .reg_addr2(ir_dataID[`RT]), .reg_waddr(reg_waddrFB),
                    .reg_data1(reg_rsID), .reg_data2(reg_rtID), .reg_wdata(reg_wdataFB)
                    );
    ctrl CTRL (         .ir_opcode(ir_dataID[`OPCODE]), 
                /*EX*/  .reg_dst(reg_dstID), .alu_src(alu_srcID), .alu_op(alu_opID), 
                /*M*/   .branch(branchID), .mem_read(mem_readID), .mem_write(mem_writeID), 
                /*WB*/  .reg_src(reg_srcID), .reg_write(reg_writeID)
                );
    //===========================================================================================================
    
    //===========================================================================================================
    //3rd stage(EX)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage
    reg [`WORD_WIDTH-1:0] reg_rsEX;
    reg [1:0] alu_opEX; // hard code!
    reg reg_dstEX, alu_srcEX;
    reg [`WORD_WIDTH-1:0] immediateEX;
    reg [`WORD_WIDTH-1:0] pc_nxtaddrEX, ir_dataEX;
    
    // Signals from previous stage and to next stage
    reg [`WORD_WIDTH-1:0] reg_rtEX;
    reg branchEX, mem_readEX, mem_writeEX, reg_writeEX, reg_srcEX;
    reg [`REGADDR_WIDTH-1:0] src1_addrEX;
    reg [`REGADDR_WIDTH-1:0] src2_addrEX;
    
    // New signals to next stage
    wire [`WORD_WIDTH-1:0] alu_resultEX;
    wire alu_zeroEX;
    wire [`WORD_WIDTH-1:0] pc_jumpaddrEX = (immediateEX<<2) + pc_nxtaddrEX; // hard code!
    wire [`REGADDR_WIDTH-1:0] reg_waddrEX = (reg_dstEX == `TO_RD) ? ir_dataEX[`RD] : ir_dataEX[`RT];
    
    // Pipeline register
    always@(posedge clk) begin : ID_EX
        reg_rsEX <= reg_rsID;
        reg_rtEX <= reg_rtID;
        alu_opEX <= alu_opID;
        reg_dstEX <= reg_dstID;
        alu_srcEX <= alu_srcID;
        reg_writeEX <= reg_writeID;
        immediateEX <= immediateID;
        pc_nxtaddrEX <= pc_nxtaddrID;
        ir_dataEX <= ir_dataID;
        branchEX <= branchID;
        mem_readEX <= mem_readID;
        mem_writeEX <= mem_writeID;
        reg_srcEX <= reg_srcID;
        src1_addrEX<=src1_addrID;
        src2_addrEX<=src2_addrID;
    end
    
    //internal wire
    wire is_ForwordA;
    wire sel_ForwordA;
    wire is_ForwordB;
    wire sel_ForwordB;
    wire [`WORD_WIDTH-1:0] alu_src1EX = is_ForwordA ?(sel_ForwordA ? alu_resultMEM:reg_wdataFB):reg_rsEX;
    wire [`WORD_WIDTH-1:0] alu_src2EX = is_ForwordB ?(sel_ForwordB ? alu_resultMEM:reg_wdataFB):
                                        (alu_srcEX == `FROM_IMM) ? immediateEX : reg_rtEX;
    wire [4:0] alu_functionEX; // hard code!
    wire alu_sel;
 
    //instances
    alu_ctrl ALU_CTRL ( .ir_funct(ir_dataEX[`FUNCT]), .ir_op4bit(ir_dataEX[29:26]), .alu_op(alu_opEX), 
                        .alu_function(alu_functionEX), .alu_sel(alu_selEX)
                        );
    alu ALU (   .alu_function(alu_functionEX), .alu_sel(alu_selEX),
                .alu_src1(alu_src1EX), .alu_src2(alu_src2EX), .shamt(ir_dataEX[`SHAMT]), 
                .alu_result(alu_resultEX), .alu_zero(alu_zeroEX)
                );
    forward FU(  .src1_addrEX(src1_addrEX), .src2_addrEX(src2_addrEX), .reg_writeMEM(reg_writeMEM),
                 .reg_waddrMEM(reg_waddrMEM), .reg_writeFB(reg_writeFB), .reg_waddrFB(reg_waddrFB),
                 .is_ForwordA(is_ForwordA), .sel_ForwordA(sel_ForwordA), .is_ForwordB(is_ForwordB),
	         .sel_ForwordB(sel_ForwordB) );
    //===========================================================================================================

    //===========================================================================================================
    //4th stage(MEM)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage
    reg [`WORD_WIDTH-1:0] reg_rtMEM;
    reg branchMEM, mem_readMEM, mem_writeMEM;
    reg alu_zeroMEM;
    //(feedback) pc_jumpaddrFB 
    
    // Signals from previous stage and to next stage
    reg [`WORD_WIDTH-1:0] alu_resultMEM;
    reg reg_writeMEM, reg_srcMEM;
    reg [`REGADDR_WIDTH-1:0] reg_waddrMEM;
    
    // New signal to next stage
    wire [`WORD_WIDTH-1:0] mem_rdataMEM;
    
    // Pipeline register
    always@(posedge clk) begin : EX_MEM
        reg_rtMEM <= reg_rtEX;
        branchMEM <= branchEX;
        mem_readMEM <= mem_readEX;
        mem_writeMEM <= mem_writeEX;
        reg_writeMEM <= reg_writeEX;
        reg_srcMEM <= reg_srcEX;
        alu_resultMEM <= alu_resultEX;
        alu_zeroMEM <= alu_zeroEX;
        pc_jumpaddrFB <= pc_jumpaddrEX;
        reg_waddrMEM <= reg_waddrEX;
    end
    
    // Feedback
    assign pc_srcFB = (branchMEM && alu_zeroMEM);
    
    //instances
    data_cache D_CACHE(   .clk(clk), .rst(rst), 
                           .mem_read(mem_readMEM), .mem_write(mem_writeMEM), 
                           .mem_addr(alu_resultMEM), .mem_rdata(mem_rdataMEM), .mem_wdata(reg_rtMEM));
    //===========================================================================================================
    
    //===========================================================================================================
    //5th stage(WB)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage
    //(feedback) reg_waddrFB, reg_writeWB
    reg [`WORD_WIDTH-1:0] alu_resultWB;
    reg reg_srcWB;
    reg [`WORD_WIDTH-1:0] mem_rdataWB;
    
    // Pipeline register
    always@(posedge clk) begin : MEM_WB
        reg_writeFB <= reg_writeMEM;
        reg_waddrFB <= reg_waddrMEM;
        alu_resultWB <= alu_resultMEM;
        reg_srcWB <= reg_srcMEM;
        mem_rdataWB <= mem_rdataMEM;
    end
    
    // Feedback
    assign reg_wdataFB = (reg_srcWB == `FROM_MEM) ? mem_rdataWB : alu_resultWB;
    //===========================================================================================================
endmodule
