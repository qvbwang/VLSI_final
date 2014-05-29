`include "defines.v"

module alu (	alu_function, 
				alu_src1, alu_src2, shamt, 
				alu_result, alu_zero	);
				
	input [3:0] alu_function; // hard code!
	input [`WORD_WIDTH-1:0] alu_src1, alu_src2;
	input [`SHAMT_WIDTH-1:0] shamt;
	output [`WORD_WIDTH-1:0] alu_result;
	output alu_zero;
	
	assign alu_zero = (alu_result == 0);
	reg [`WORD_WIDTH-1:0] alu_result;
	
	always@(alu_function or alu_src1 or alu_src2 or shamt)
		case(alu_function)
			`ALU_ADD: 
				alu_result = alu_src1 + alu_src2;
			`ALU_SUB: 
				alu_result = alu_src1 - alu_src2;
			`ALU_SLL: 
				alu_result = alu_src2 << shamt;
			default: 
				alu_result = 32'h0;//other opcode
		endcase
endmodule
