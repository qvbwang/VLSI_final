`include "defines.v"

module ir_cache(    clk, rst, 
                    ir_addr, ir_data);
    input clk, rst;
    input [`WORD_WIDTH-1:0] ir_addr;
    output [`WORD_WIDTH-1:0] ir_data;
    
    reg [`WORD_WIDTH-1:0] ir_data;
    reg [`RAM_WIDTH-1:0] ir_mem[0:`RAM_SIZE-1];
    
    always @(posedge clk or posedge rst) begin
        if(rst)
            $readmemb("ir.txt", ir_mem);
        else
            ir_data = {ir_mem[ir_addr], ir_mem[ir_addr+1], ir_mem[ir_addr+2], ir_mem[ir_addr+3]}; // hard code!
    end
endmodule
