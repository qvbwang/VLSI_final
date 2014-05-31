`define OPCODE   31:26
`define RS       25:21
`define RT	 20:16
`define RD	 15:11
`define SHAMT    10: 6
`define FUNCT     5: 0
`define OFFSET   15: 0
`define ADDR     25: 0
`define SIGNBIT  15
 
`define WIDTH   32
`define MAXREG  32
`define REGADDR 5
`define OPWDTH  6
`define SHWDTH  5
`define FCWDTH  6
module ID(ir,wrt_dt,wrt_reg,reg_wrt,read_data1,read_data2,offset,rt,rd,opcode,shamt,funct);

	input  [`WIDTH-1:  0] ir,      //instruction
	                      wrt_dt;  //write_data
	input  [`REGADDR-1:0] wrt_reg; //write_register
	input				  reg_wrt; //RegWrite

	output [`WIDTH-1:  0] read_data1,read_data2, //read_data1,read_data2  	
						  offset;
	output [`REGADDR-1:0] rt,rd; 
	output [`OPWDTH-1: 0] opcode;
	output [`SHWDTH-1: 0] shamt;
	output [`FCWDTH-1: 0] funct;
	
	reg    [`WIDTH-1:  0] read_data1,read_data2, //output最好用reg
						  offset;
	reg    [`REGADDR-1:0] rt,rd; 
	reg    [`OPWDTH-1: 0] opcode;
	reg    [`SHWDTH-1: 0] shamt;
	reg    [`FCWDTH-1: 0] funct;
		
	reg    [`WIDTH-1:  0] REG[`MAXREG-1:0];

	initial
	begin
		$readmemh("REGFILE.txt",REG);
	end

	always@(ir)
	begin
		read_data1 = REG[ir[`RS]]; //glue logic => not good!
		read_data2 = REG[ir[`RT]];
	    	offset = (ir[`SIGNBIT]==0)?{16'b0000_0000_0000_0000,ir[`OFFSET]}:{16'b1111_1111_1111_1111,ir[`OFFSET]}; //sign extend
		rt     = ir[`RT];
	    	rd     = ir[`RD];
		opcode = ir[`OPCODE];
		shamt  = ir[`SHAMT];
		funct  = ir[`FUNCT];
	end
	
	always@(wrt_dt or wrt_reg or reg_wrt)
	begin
		if(reg_wrt)
			REG[wrt_reg] = wrt_dt; //write and read synchronously => ??  
	end

endmodule 
