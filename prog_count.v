`include "defines.v"

module prog_count(  clk, rst, 
                    pc_src, pc_jumpaddr, pc_nowaddr, pc_nxtaddr);
    input clk, rst;
    input pc_src;
    input [`WORD_WIDTH-1:0] pc_jumpaddr;
    output [`WORD_WIDTH-1:0] pc_nowaddr, pc_nxtaddr;
    
    reg [`WORD_WIDTH-1:0] pc_nowaddr, pc_nxtaddr;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            pc_nxtaddr <= 0;
        end
        else
            case(pc_src)
                `PC_JUMP:  begin
                    pc_nxtaddr <= pc_jumpaddr;
                end
                /*`PC_INCRESE*/default: begin
                    pc_nowaddr <= pc_nxtaddr;
                    pc_nxtaddr <= pc_nxtaddr + 4; // hard code!
                end
            endcase
    end
endmodule
