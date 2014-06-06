`include "defines.v"

/*
*[140604] add function: stall
*[140607] bug fixed : Stall IF will lost one instruction
*/

module prog_count(  clk, rst, 
                    stall, pc_src, jumpaddr, nowaddr, nxtaddr);
    input clk, rst;
    input stall, pc_src;
    input [`WORD_WIDTH-1:0] jumpaddr;
    output [`WORD_WIDTH-1:0] nowaddr, nxtaddr;
    
    reg [`WORD_WIDTH-1:0] nowaddr, nxtaddr;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            nowaddr <= `PC_INIT;
            nxtaddr <= `PC_INIT;
        end
        else if(stall) begin
            nowaddr <= nowaddr;
            nxtaddr <= nxtaddr;
        end
        else
            case(pc_src)
                `PC_JUMP: begin
                    nowaddr <= jumpaddr;
                    nxtaddr <= jumpaddr + 4; // hard code!
                end
                /*`PC_INCRESE*/default: begin
                    nowaddr <= nxtaddr;
                    nxtaddr <= nxtaddr + 4; // hard code!
                end
            endcase
    end
endmodule
