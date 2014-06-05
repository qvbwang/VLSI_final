`include "defines.v"

/*
*[140604] add function: stall
*/

module prog_count(  clk, rst, 
                    stall, pc_src, jumpaddr, nxtaddr);
    input clk, rst;
    input stall, pc_src;
    input [`WORD_WIDTH-1:0] jumpaddr;
    output [`WORD_WIDTH-1:0] nxtaddr;
    
    reg [`WORD_WIDTH-1:0] nxtaddr;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            nxtaddr <= `PC_INIT;
        end
        else if(stall)
            nxtaddr <= nxtaddr;
        else
            case(pc_src)
                `PC_JUMP: begin
                    nxtaddr <= jumpaddr + 4; // hard code!
                end
                /*`PC_INCRESE*/default: begin
                    nxtaddr <= nxtaddr + 4; // hard code!
                end
            endcase
    end
endmodule
