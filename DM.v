`include "defines.v"

`define MEM_WIDTH 1024
`define ADDR_WIDTH 10

module DMemory(clk, rst ,mem_write, mem_read, mem_addr, mem_wdata, mem_rdata);

	input clk, rst, mem_write, mem_read;
	input [`ADDR_WIDTH-1:0] mem_addr;
	input [`WORD_WIDTH-1:0] mem_wdata;
	output [`WORD_WIDTH-1:0] mem_rdata;

	reg [`WORD_WIDTH-1:0] mem[`MEM_WIDTH-1:0];
	reg [`WORD_WIDTH-1:0] temp;
	reg [`ADDR_WIDTH-1:0] i;
	
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