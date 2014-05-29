`include "defines.v"

module alu_ctrl (ir_funct, alu_op, alu_function);
	input [`FUNCT_WIDTH-1:0] ir_funct;
	input [1:0] alu_op; // hard code!
	output [3:0] alu_function; // hard code!
	
	reg [3:0] alu_function; // hard code!
	
	always @(alu_op or ir_funct) begin
		case(alu_op)
			`ALUOP_LW: 
				alu_function = `ALU_ADD;
			`ALUOP_SW: 
				alu_function = `ALU_ADD;
			`ALUOP_BEQ: 
				alu_function = `ALU_SUB;
			/*`ALUOP_RTYPE*/default: begin
				case(ir_funct)
					`ADD: alu_function = `ALU_ADD;
					`SUB: alu_function = `ALU_SUB;
					/*`SLL*/default: alu_function = `ALU_SLL;
				endcase
			end
		endcase
	end
endmodule
