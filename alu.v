module alu(alu_function,alu_sel,alu_src1,alu_src2,shamt,alu_result,alu_zero,alu_result);

/***********************************************************/

/*boolean logic*/
`define TRUE  1
`define FALSE 0
`define GROUND 32'h0000_0000
//Define
`define DATA_WIDTH 32
`define OPERATE 5
`define SHMAT 5

`define CTRL_SLL   5'b00000
`define CTRL_SRL   5'b00010

`define CTRL_MULT  5'b01000
`define CTRL_MULTU 5'b01001
`define CTRL_DIV   5'b01010
`define CTRL_DIVU  5'b01011

`define CTRL_ADD   5'b10000
`define CTRL_ADDU  5'b10001
`define CTRL_SUB   5'b10010
`define CTRL_SUBU  5'b10011
`define CTRL_AND   5'b10100
`define CTRL_OR    5'b10101
`define CTRL_XOR   5'b10110
`define CTRL_NOR   5'b10111

`define CTRL_SLT   5'b11010
`define CTRL_SLTU  5'b11011

//Inputs
input [`DATA_WIDTH-1:00]alu_src1;
input [`DATA_WIDTH-1:00]alu_src2;
input alu_sel;
input [`OPERATE-1:00]alu_function;
input [`SHMAT-1:00]shamt;
//Outputs
output alu_zero;
output reg[`DATA_WIDTH-1:00]alu_result;


/********************************************************/


assign alu_zero=(alu_src1==alu_src2)?1:0;

always@(alu_function,alu_src1,alu_src2)begin
	if(alu_sel==0)
	case(alu_function)
		`CTRL_SLL:begin
			alu_result=alu_src1<<shamt;
			end
		`CTRL_SRL:begin
			alu_result=alu_src1>>shamt;
			end	
	    `CTRL_ADD:begin
            alu_result=alu_src1+alu_src2;
             end
		`CTRL_ADDU:begin
            alu_result=alu_src1+alu_src2;
             end
        `CTRL_SUB:begin
		    alu_result=alu_src1-alu_src2;
			end
		`CTRL_SUBU:begin
		    alu_result=alu_src1-alu_src2;
			end
		`CTRL_AND:begin
			alu_result=alu_src1&alu_src2;
			end
		`CTRL_OR:begin
			alu_result=alu_src1|alu_src2;
			end
		`CTRL_XOR:begin
			alu_result=alu_src1^alu_src2;
			end
		`CTRL_NOR:begin
			alu_result=~(alu_src1|alu_src2);
			end
		`CTRL_SLT:begin
			alu_result=alu_src1<alu_src2?32'h0000_0001:32'h0000_0000;
			end
		`CTRL_SLTU:begin
			alu_result=alu_src1<alu_src2?32'h0000_0001:32'h0000_0000;
			end
		default:begin
			alu_result=`GROUND;
			$display("0Error in alu_EX!");
			end
	endcase
	else if(alu_sel==1)
		case(alu_function)
			`CTRL_MULT:
				alu_result=alu_src1*alu_src2;
			`CTRL_MULTU:
				alu_result=alu_src1*alu_src2;
			`CTRL_DIV:
				alu_result=alu_src1/alu_src2;
			`CTRL_DIVU:
				alu_result=alu_src1/alu_src2;
			default:begin
				alu_result=`GROUND;
				$display("1Error in alu_EX!");
			end
		endcase
	else begin
		alu_result=`GROUND;
		$display("xError in alu_EX!");
	end
end


/********************************************************/


endmodule
