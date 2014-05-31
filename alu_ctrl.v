
module alu_ctrl(ir_funct, ir_op4bit, alu_op, 
                alu_function, alu_sel);

//Define
`define OPERATE 5

`define ALU_IOP_CHECK  ir_op4bit[03:01]
`define ALU_IOP_SLTI  3'b101
`define ALU_IOP_SLTIU 3'b101
`define ALU_IOP_CTRL_STANDARD  {ir_op4bit[03],1'b0,ir_op4bit[06:04]}
`define ALU_IOP_CTRL_SHIT  {ir_op4bit[03],1'b1,ir_op4bit[06:04]}
`define ALU_IOP_SEL  1'b0

`define FUNC      ir_funct[05:00]
`define FUNC_CTRL {ir_funct[05],ir_funct[03:00]}
`define FUNC_SEL ir_funct[04]

`define LW_SW      2'b00
`define BEQ        2'b01
`define RMATH      2'b10
`define IMATH      2'b11
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
reg [`OPERATE-1:00]ctrl_ALU;
assign alu_sel=(alu_op==`RMATH)?`FUNC_SEL:`ALU_IOP_SEL;
always@(ir_funct,ir_op4bit,alu_op)begin
	case(alu_op)
		`LW_SW:begin
			ctrl_ALU=`LWSW_ADD;
		end
		`BEQ:begin
			ctrl_ALU=`BEQ_SUB;
		end
		`RMATH:begin
			ctrl_ALU=`FUNC_CTRL;	
		end
		`IMATH:begin
			if(ir_op4bit==`ALU_IOP_SLTI)
				ctrl_ALU=`ALU_IOP_CTRL_SHIT;
			else
				ctrl_ALU=`ALU_IOP_CTRL_STANDARD;
		end
		default:begin
			ctrl_ALU=5'b00000;
			$display("Error in EX!");
		end
		endcase
end


/***********************************************************/


endmodule
