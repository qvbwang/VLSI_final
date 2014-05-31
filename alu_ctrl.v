
module alu_ctrl(ir_funct, ir_op4bit, alu_op, 
                alu_function, alu_sel);

//Define
`define OPERATE 5

`define ALU_IOP_CHECK  ir_op4bit[03:01]
`define ALU_IOP_SLTI  3'b101
`define ALU_IOP_SLTIU 3'b101
`define ALU_IOP_CTRL_STANDARD  {ir_op4bit[03],1'b0,ir_op4bit[02:00]}
`define ALU_IOP_CTRL_SHIT  {ir_op4bit[03],1'b1,ir_op4bit[02:00]}
`define ALU_IOP_SEL  1'b0

`define FUNC      ir_funct[05:00]
`define FUNC_CTRL {ir_funct[05],ir_funct[03:00]}
`define FUNC_SEL ir_funct[04]


`define LWSW_ADD   5'b10000
`define BEQ_SUB    5'b10010

//Inputs 
//from ctrl
input [05:00]ir_funct;
input [03:00]ir_op4bit;
input [01:00]alu_op;


//Outputs
output[`OPERATE-1:00]alu_function; 
output alu_sel;



/***********************************************************/


//Connection of graph
//ALU control
reg [`OPERATE-1:00]alu_function;
assign alu_sel=(alu_op==`ALUOP_RTYPE)?`FUNC_SEL:`ALU_IOP_SEL;
always@(ir_funct,ir_op4bit,alu_op)begin
	case(alu_op)
		`ALUOP_LW:begin
			alu_function=`LWSW_ADD;
		end
		`ALUOP_SW:begin
			alu_function=`LWSW_ADD;
		end
		`ALUOP_BEQ:begin
			alu_function=`BEQ_SUB;
		end
		`ALUOP_RTYPE:begin
			alu_function=`FUNC_CTRL;	
		end
		`ALUOP_ITYPE:begin
			if(ir_op4bit==`ALU_IOP_SLTI)
				alu_function=`ALU_IOP_CTRL_SHIT;
			else
				alu_function=`ALU_IOP_CTRL_STANDARD;
		end
		default:begin
			alu_function=5'b00000;
			$display("Error in EX!");
		end
		endcase
end


/***********************************************************/


endmodule
