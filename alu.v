`include "defines.v"

module alu(alu_function,alu_sel,alu_src1,alu_src2,shamt,alu_result,alu_zero,alu_result);

/***********************************************************/

//Inputs
input [`WORD_WIDTH-1:00]alu_src1;
input [`WORD_WIDTH-1:00]alu_src2;
input alu_sel;
input [`ALUFUNCT_WIDTH-1:00]alu_function;
input [`SHAMT_WIDTH-1:00]shamt;
//Outputs
output alu_zero;
output reg[`WORD_WIDTH-1:00]alu_result;


/********************************************************/


assign alu_zero=(alu_src1==alu_src2)?1:0;

always@(alu_function,alu_src1,alu_src2)begin
	if(alu_sel==0)
	case(alu_function)
		`ALUFUNCT_SLL:begin
			alu_result=alu_src1<<shamt;
			end
		`ALUFUNCT_SRL:begin
			alu_result=alu_src1>>shamt;
			end	
	    `ALUFUNCT_ADD:begin
            alu_result=alu_src1+alu_src2;
             end
		`ALUFUNCT_ADDU:begin
            alu_result=alu_src1+alu_src2;
             end
        `ALUFUNCT_SUB:begin
		    alu_result=alu_src1-alu_src2;
			end
		`ALUFUNCT_SUBU:begin
		    alu_result=alu_src1-alu_src2;
			end
		`ALUFUNCT_AND:begin
			alu_result=alu_src1&alu_src2;
			end
		`ALUFUNCT_OR:begin
			alu_result=alu_src1|alu_src2;
			end
		`ALUFUNCT_XOR:begin
			alu_result=alu_src1^alu_src2;
			end
		`ALUFUNCT_NOR:begin
			alu_result=~(alu_src1|alu_src2);
			end
		`ALUFUNCT_SLT:begin
			alu_result=alu_src1<alu_src2?`TRUE:`FALSE;
			end
		`ALUFUNCT_SLTU:begin
			alu_result=alu_src1<alu_src2?`TRUE:`FALSE;
			end
		default:begin
			alu_result=0;
			$display("0Error in alu_EX!");
			end
	endcase
	else if(alu_sel==1)
		case(alu_function)
			`ALUFUNCT_MULT:
				alu_result=alu_src1*alu_src2;
			`ALUFUNCT_MULTU:
				alu_result=alu_src1*alu_src2;
			`ALUFUNCT_DIV:
				alu_result=alu_src1/alu_src2;
			`ALUFUNCT_DIVU:
				alu_result=alu_src1/alu_src2;
			default:begin
				alu_result=0;
				$display("1Error in alu_EX!");
			end
		endcase
	else begin
		alu_result=0;
		$display("xError in alu_EX!");
	end
end


/********************************************************/


endmodule
