/*LOGIC DESIGN HW2
*referenced data-sheet info: SDLS168 – JANUARY 1981 – REVISED MARCH 1988
*student: E14013174
*/

module SN74S381(A, B, S, Cn, F, P_, G_);//4-bit ALU of Texas Instruments
	input[3:0] 	A, B;
	input[2:0] 	S;
	input 		Cn;
	output[3:0]	F;
	output		P_, G_;//with propagate, generate carry output
	
	reg[3:0] F;
	reg[3:0] p_, g_;
	
	assign P_ = p_[3] | p_[2] | p_[1] | p_[0];
	assign G_ = (g_[3]) & 
				(p_[3] | g_[2]) & 
				(p_[3] | p_[2] | g_[1]) & 
				(p_[3] | p_[2] | p_[1] | g_[0]);
	
	parameter	CLAER = 0,
				SUB_BA = 1,
				SUB_AB = 2,
				ADD = 3,
				XOR = 4,
				OR = 5,
				AND = 6,
				PSET = 7;
	
	integer i;
	
	always@(S or A or B or Cn)
		case(S)
			//act CLEAR in the default case
			SUB_BA: begin
				F = B - A + Cn - 1;//carry = 1 means no overflow in subtraction
				for(i = 0; i<4; i = i+1) begin
					p_[i] = B[i]^A[i];
					g_[i] = (~B[i])|A[i];
				end
			end
			SUB_AB: begin
				F = A - B + Cn - 1;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = A[i]^B[i];
					g_[i] = (~A[i])|B[i];
				end
			end
			ADD: begin
				F = A + B + Cn;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = ~(A[i]^B[i]);
					g_[i] = ~(A[i]&B[i]);
				end
			end
			XOR: begin
				F = A ^ B;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = ~(A[i]^B[i]);
					g_[i] = 1;
				end
			end
			OR: begin
				F = A | B;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = ~(A[i]|B[i]);
					g_[i] = 1;
				end
			end
			AND: begin
				F = A & B;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = ~(A[i]&B[i]);
					g_[i] = 1;
				end
			end
			PSET: begin
				F = 4'b1111;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = 0;
					g_[i] = 1;
				end
			end
			default: begin
				F = 4'b0000;
				for(i = 0; i<4; i = i+1) begin
					p_[i] = 1;
					g_[i] = 1;
				end
			end
		endcase
endmodule

module ALU32(A, B, S, C_in, F, C_out);
	input[31:0] 	A, B;
	input[2:0] 		S;
	input 			C_in;
	output[31:0]	F;
	output			C_out;
	
	wire P[0:7], G[0:7];
	reg C[0:7];
	
	SN74S381 ALU0(A[3:0],	B[3:0],		S[2:0], C[0], F[3:0],	~P[0], ~G[0]);
	SN74S381 ALU1(A[7:4],	B[7:4],		S[2:0], C[1], F[7:4],	~P[1], ~G[1]);
	SN74S381 ALU2(A[11:8],	B[11:8],	S[2:0], C[2], F[11:8],	~P[2], ~G[2]);
	SN74S381 ALU3(A[15:12],	B[15:12],	S[2:0], C[3], F[15:12], ~P[3], ~G[3]);
	SN74S381 ALU4(A[19:16],	B[19:16],	S[2:0], C[4], F[19:16], ~P[4], ~G[4]);
	SN74S381 ALU5(A[23:20],	B[23:20],	S[2:0], C[5], F[23:20], ~P[5], ~G[5]);
	SN74S381 ALU6(A[27:24],	B[27:24],	S[2:0], C[6], F[27:24], ~P[6], ~G[6]);
	SN74S381 ALU7(A[31:28],	B[31:28],	S[2:0], C[7], F[31:28], ~P[7], ~G[7]);
	
	integer i;
	always@(A or B or S or C_in) begin
		C[0] = C_in;
		for(i = 1; i<8; i=i+1)
			C[i] = G[i-1] | (P[i-1]&C[i-1]);
	end
endmodule

`timescale 1ns/100ps
module testbench;//try all conditions in the truth table of data-sheet
	wire[3:0] A, B;
	reg[2:0] S;
	reg Cn;
	
	reg An, Bn;
	
	assign A = {4{An}};
	assign B = {4{Bn}};
	SN74S381 ALU(	.A(A),
					.B(B),
					.S(S),
					.Cn(Cn));
	
	integer i, j;
	initial begin
		for(i = 0; i<8; i=i+1) begin
			#1 S = i;
			for(j = 0; j<8; j=j+1)
				#1 {Cn, An, Bn} = j;
		end
	$finish;
	end
endmodule
