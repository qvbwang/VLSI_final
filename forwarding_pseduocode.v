//Change these define with the correct ones.
`define dst 5 
`define data 32

`define sw 00	//these tree are concerned about controller
`define rmath 10 //
`define imath 11//

module forward(ctrl_type,source_id,terminal_id,result_ex,dst_ex,wb_ctrl_ex,mux_dst_ex,mux_src1_id,mux_src2_id,data_forward);
/**Look the code below with the Concept Graph will make it more easier to understand .**/

//port from ID stage!
	input [1:0]ctrl_type;//this is a signal from Controller in ID stage
	input [`dst-1:0]source_id;//capture it from IR in ID stage
	input [`dst-1:0]terminal_id;//capture it from IR in ID stage

//port from EX stage!
	input [`data-1:0]result_ex;//capture it from ALU in EX stage
	input [`dst-1:0]dst_ex;
	input mux_dst_ex;
	input wb_ctrl_ex;
	
//port to src1 and src2! (Plz add two mux ,thx~)
	output reg mux_src1_id;//Add this one
	output reg mux_src2_id;//,and this one.
	//two mux coupled  SRC1(to alu) and SRC2(to alu) 
	
	
	output reg [`data-1:0]data_forward;//two Mux upward choose This data at sel signal at 1'b1

	always@(ctrl_type,source_id,result_ex,dst_ex,mux_dst_ex,wb_ctrl_ex)begin
		case(ctrl_type)
			`sw:begin
				mux_src2_id=0;
				if(source_id==dst_ex)begin
					mux_src1_id=1;
					data_forward=result_ex;
					end
				else	begin
					mux_src1_id=1;
					data_forward=result_ex;
					end
				end
			`rmath:begin
				if(source_id==dst_ex)begin
					mux_src2_id=0;
					mux_src1_id=1;
					data_forward=result_ex;
					end
				else if(terminal_id==dst_ex)	begin
					mux_src2_id=1;
					mux_src1_id=0;
					data_forward=result_ex;
					end
				else	begin
					mux_src2_id=0;
					mux_src1_id=0;
					data_forward=32'h0000_0000;
					end
				end
			`imath:begin
				mux_src2_id=0;
				if(source_id==dst_ex)begin
					mux_src1_id=1;
					data_forward=result_ex;
					end
				else	begin
					mux_src1_id=1;
					data_forward=result_ex;
					end
				end
			default:begin
				mux_src1_id=0;
				mux_src2_id=0;
				data_forward=32'h0000_0000;
				end
			endcase
	end
endmodule
			
