`include "defines.v"

`include "processor.v"

`timescale 1ns/1ps
module testbench;
	parameter clk_duty = 20;
	
	reg clk, rst;
	
	always #clk_duty clk = ~clk;
	
	wire mem_read, mem_write;
	wire [`WORD_WIDTH-1:0] mem_addr;
	wire [`WORD_WIDTH-1:0] mem_rdata, mem_wdata;
	
	processor CPU(clk, rst, mem_read, mem_write, mem_addr, mem_rdata, mem_wdata);
	initial begin
		rst = 1'b1;
		clk = 1'b1;
		#1 rst = 1'b0;
	end
endmodule
