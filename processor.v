`include "defines.v"

`include "alu.v"
`include "alu_ctrl.v"
`include "ctrl.v"
`include "ir_mem.v"
`include "prog_count.v"
`include "register.v"

module processor(clk, rst, mem_read, mem_write, mem_addr, mem_rdata, mem_wdata);

	input clk, rst;
	input [`RAM_WIDTH-1:0] mem_rdata;
	output mem_read, mem_write;
	output [`WORD_WIDTH-1:0] mem_addr;
	output [`RAM_WIDTH-1:0] mem_wdata;
	
	wire [`WORD_WIDTH-1:0] pc_nowaddr, pc_nxtaddr;
	wire [`WORD_WIDTH-1:0] ir_data, rs, rt, alu_result, reg_wdata;
	wire reg_dst, alu_src, branch, mem_read, mem_write, reg_src, reg_write, pc_src;
	wire [`REGADDR_WIDTH-1:0] reg_waddr;
	wire alu_zero;
	wire [1:0] alu_op; // hard code!
	wire [3:0] alu_function; // hard code!
	reg [`WORD_WIDTH-1:0] pc_jumpaddr;
//1st stage
	prog_count PC (	.clk(clk), .rst(rst), .pc_src(pc_src), 
					.pc_jumpaddr(pc_jumpaddr), .pc_nowaddr(pc_nowaddr), .pc_nxtaddr(pc_nxtaddr)
					);
	ir_mem IR (		.clk(clk), .rst(rst), 
					.ir_addr(pc_nxtaddr), .ir_data(ir_data), 
					.mem_addr(mem_addr), .mem_rdata(mem_rdata)
					);
	
//2nd stage
	register REG (	.clk(clk), .rst(rst), .reg_write(reg_write),
					.reg_addr1(ir_data[`RS]), .reg_addr2(ir_data[`RT]), .reg_waddr(reg_waddr),
					.reg_data1(rs), .reg_data2(rt), .reg_wdata(reg_wdata)
					);
	ctrl CTRL (			.ir_opcode(ir_data[`OPCODE]), 
				/*EX*/	.reg_dst(reg_dst), .alu_src(alu_src), .alu_op(alu_op), 
				/*M*/	.branch(branch), .mem_read(mem_read), .mem_write(mem_write), 
				/*WB*/	.reg_src(reg_src), .reg_write(reg_write)
				);
	
	wire [`WORD_WIDTH-1:0] immediate = {{(`WORD_WIDTH-`IMM_WIDTH){ir_data[`IMM_WIDTH-1]}}, ir_data[`IMM]};
	
//3rd stage
	wire [`WORD_WIDTH-1:0] alu_src1 = rs;
	wire [`WORD_WIDTH-1:0] alu_src2 = (alu_src == `FROM_IMM) ? immediate : ir_data[`RT];
	assign reg_waddr = (reg_dst == `TO_RD) ? ir_data[`RD] : ir_data[`RT];
	alu_ctrl ALU_CTRL (.ir_funct(ir_data[`FUNCT]), .alu_op(alu_op), .alu_function(alu_function));
					
	alu ALU (		.alu_function(alu_function), 
					.alu_src1(alu_src1), .alu_src2(alu_src2), .shamt(ir_data[`SHAMT]), 
					.alu_result(alu_result), .alu_zero(alu_zero)
					);

	always @(pc_nxtaddr or immediate)
		pc_jumpaddr = (immediate<<2) + pc_nxtaddr; // hard code!
		
//4th stage
	assign pc_src = (branch && alu_zero);
	assign mem_addr = alu_result;
	assign mem_wdata = rt;
	
//5th stage
	assign reg_wdata = (reg_src == `FROM_MEM) ? mem_rdata : alu_result;
	
endmodule
