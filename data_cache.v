`include "defines.v"

module data_cache(clk, rst ,mem_write, mem_read, mem_addr, mem_wdata, mem_rdata);

	input clk, rst, mem_write, mem_read;
	input [`WORD_WIDTH-1:0] mem_addr;
	input [`WORD_WIDTH-1:0] mem_wdata;
	output [`WORD_WIDTH-1:0] mem_rdata;

	reg [`WORD_WIDTH-1:0] mem[0:`MEM_WIDTH-1];
	reg [`WORD_WIDTH-1:0] temp;
	reg [`WORD_WIDTH-1:0] i;
	
	always@(posedge clk)
	begin
		if(rst) 
			for(i = 0; i < `MEM_WIDTH ; i = i + 1)
				mem[i] <= 32'b0;
		else if (mem_write) 
			mem[mem_addr] <= mem_wdata;
		else if (mem_read) 
			temp <= mem[mem_addr];
		else;
	end
	
	assign mem_rdata = temp;

endmodule
