`include "defines.v"

/*
*[140604] modified to fit new "async_reg.v" and "prog_count.v"
*[140604] fix branch bug
*[140604] make some pipeline flushable and stallable
*[140604] move feedback pc_jumpaddrFB, pc_srcFB earlier to 3rd stage.
*         So branch taken will have penalty of 2 cycles
*[140607] bug fixed : Stall IF will lost one instruction
*/

`include "alu.v"
`include "alu_ctrl.v"
`include "ctrl.v"
`include "ir_cache.v"
`include "prog_count.v"
`include "async_reg.v"
`include "data_cache.v"

module processor(clk, rst, mem_read, mem_write, mem_addr, mem_rdata, mem_wdata);

    //input output list
    //-----------------------------------------------------------------------------------------------------------
    input clk, rst;
    input [`WORD_WIDTH-1:0] mem_rdata;
    output mem_read, mem_write;
    output [`WORD_WIDTH-1:0] mem_addr;
    output [`WORD_WIDTH-1:0] mem_wdata;
    
    //cross stage signals
    //-----------------------------------------------------------------------------------------------------------
    // pipeline register reset (flush, will behave like nop)
    wire flush_ID, flush_EX;
    // Feedback from 3th stage(EX) to 1st stage(IF)
    wire pc_srcFB;
    wire [`WORD_WIDTH-1:0] pc_jumpaddrFB;
    // Feedback from 5th stage(WB) to 2nd stage(ID)
    wire [`WORD_WIDTH-1:0] reg_wdataFB;
    reg [`REGADDR_WIDTH-1:0] reg_waddrFB;
    reg reg_writeFB;
    
    assign flush_ID = (pc_srcFB == `PC_JUMP) ? `TRUE : `FALSE;
    assign flush_EX = (pc_srcFB == `PC_JUMP) ? `TRUE : `FALSE;
    wire stall_IF = `FALSE;
    wire stall_ID = `FALSE;
    
    //===========================================================================================================
    //1st stage(IF)
    //-----------------------------------------------------------------------------------------------------------
    // Signals to next stage
    wire [`WORD_WIDTH-1:0] pc_nowaddrIF, pc_nxtaddrIF;
    wire [`WORD_WIDTH-1:0] ir_dataIF;
    
    //internal wire
    wire [`WORD_WIDTH-1:0] ir_addrIF =  stall_IF ?                                          pc_nowaddrIF : 
                                        (pc_srcFB==`PC_JUMP && pc_nxtaddrIF!=`PC_INIT) ?    pc_jumpaddrFB : pc_nxtaddrIF;
    
    //instances
    prog_count PC ( .clk(clk), .rst(rst), 
                    .stall(stall_IF), .pc_src(pc_srcFB), 
                    .jumpaddr(pc_jumpaddrFB), .nowaddr(pc_nowaddrIF), .nxtaddr(pc_nxtaddrIF)
                    );
    ir_cache I_CACHE (  .clk(clk), .rst(rst), 
                        .ir_addr(ir_addrIF), .ir_data(ir_dataIF)
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
    
    // Pipeline register (note that this pipeline reg has both sync and async resets)
    always@(posedge clk or posedge rst) begin : IF_ID
        if(rst) begin
            pc_nxtaddrID <= pc_nxtaddrIF;
            ir_dataID <= 0;
        end
        else if(flush_ID) begin
            pc_nxtaddrID <= pc_nxtaddrIF;
            ir_dataID <= 0;
        end
        else if(stall_ID) begin
            pc_nxtaddrID <= pc_nxtaddrIF;
            ir_dataID <= 0;
        end
        else begin
            pc_nxtaddrID <= pc_nxtaddrIF;
            ir_dataID <= ir_dataIF;
        end
    end
    
    //instances
    async_reg register (    .rst(rst), .reg_write(reg_writeFB),
                            .reg_raddr1(ir_dataID[`RS]), .reg_raddr2(ir_dataID[`RT]), .reg_waddr(reg_waddrFB),
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
    
    // New signals to next stage
    wire [`WORD_WIDTH-1:0] alu_resultEX;
    wire alu_zeroEX;
    wire [`REGADDR_WIDTH-1:0] reg_waddrEX = (reg_dstEX == `TO_RD) ? ir_dataEX[`RD] : ir_dataEX[`RT];
    
    // Pipeline register
    always@(posedge clk) begin : ID_EX
        if(flush_EX) begin
            reg_rsEX <= 0;
            reg_rtEX <= 0;
            alu_opEX <= `ALUOP_RTYPE;
            reg_dstEX <= `TO_RD;
            alu_srcEX <= `FROM_RT;
            reg_writeEX <= `TRUE;
            immediateEX <= immediateID;
            pc_nxtaddrEX <= pc_nxtaddrID;
            ir_dataEX <= 0;
            branchEX <= `FALSE;
            mem_readEX <= `FALSE;
            mem_writeEX <= `FALSE;
            reg_srcEX <= `FROM_ALU;
        end
        else begin
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
        end
    end
    
    //internal wire
    wire [`WORD_WIDTH-1:0] alu_src1EX = reg_rsEX;
    wire [`WORD_WIDTH-1:0] alu_src2EX = (alu_srcEX == `FROM_IMM) ? immediateEX : reg_rtEX;
    wire [4:0] alu_functionEX; // hard code!
    wire alu_sel;
    
    // Feedback
    assign pc_jumpaddrFB = (immediateEX<<2) + pc_nxtaddrEX; // hard code!
    assign pc_srcFB = (branchEX && alu_zeroEX) ? `PC_JUMP : `PC_INCRESE;
 
    //instances
    alu_ctrl ALU_CTRL ( .ir_funct(ir_dataEX[`FUNCT]), .ir_op4bit(ir_dataEX[29:26]), .alu_op(alu_opEX), 
                        .alu_function(alu_functionEX), .alu_sel(alu_selEX)
                        );
    alu ALU (   .alu_function(alu_functionEX), .alu_sel(alu_selEX),
                .alu_src1(alu_src1EX), .alu_src2(alu_src2EX), .shamt(ir_dataEX[`SHAMT]), 
                .alu_result(alu_resultEX), .alu_zero(alu_zeroEX)
                );
    //===========================================================================================================

    //===========================================================================================================
    //4th stage(MEM)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage
    reg [`WORD_WIDTH-1:0] reg_rtMEM;
    reg mem_readMEM, mem_writeMEM;
    
    // Signals from previous stage and to next stage
    reg [`WORD_WIDTH-1:0] alu_resultMEM;
    reg reg_writeMEM, reg_srcMEM;
    reg [`REGADDR_WIDTH-1:0] reg_waddrMEM;
    
    // New signal to next stage
    wire [`WORD_WIDTH-1:0] mem_rdataMEM;
    
    // Pipeline register
    always@(posedge clk) begin : EX_MEM
        reg_rtMEM <= reg_rtEX;
        mem_readMEM <= mem_readEX;
        mem_writeMEM <= mem_writeEX;
        reg_writeMEM <= reg_writeEX;
        reg_srcMEM <= reg_srcEX;
        alu_resultMEM <= alu_resultEX;
        reg_waddrMEM <= reg_waddrEX;
    end
    
    //instances
    data_cache D_CACHE( .clk(clk), .rst(rst), 
                        .mem_read(mem_readMEM), .mem_write(mem_writeMEM), 
                        .mem_addr(alu_resultMEM), .mem_rdata(mem_rdataMEM), .mem_wdata(reg_rtMEM));
    //===========================================================================================================
    
    //===========================================================================================================
    //5th stage(WB)
    //-----------------------------------------------------------------------------------------------------------
    // Signals from previous stage
    //(feedback) reg_waddrFB, reg_writeFB
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
