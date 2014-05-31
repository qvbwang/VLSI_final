`include "defines.v"

module ID(ir,wrt_dt,wrt_reg,reg_wrt,read_data1,read_data2,offset,rt,rd,opcode,shamt,funct);

    input  [`WORD_WIDTH-1:  0] ir,      //instruction
                          wrt_dt;  //write_data
    input  [`REGADDR_WIDTH-1:0] wrt_reg; //write_register
    input                 reg_wrt; //RegWrite

    output [`WORD_WIDTH-1:  0] read_data1,read_data2, //read_data1,read_data2   
                          offset;
    output [`REGADDR_WIDTH-1:0] rt,rd; 
    output [`OPCODE_WIDTH-1: 0] opcode;
    output [`SHAMT_WIDTH-1: 0] shamt;
    output [`FUNCT_WIDTH-1: 0] funct;
    
    reg    [`WORD_WIDTH-1:  0] read_data1,read_data2, //output最好用reg
                          offset;
    reg    [`REGADDR_WIDTH-1:0] rt,rd; 
    reg    [`OPCODE_WIDTH-1: 0] opcode;
    reg    [`SHAMT_WIDTH-1: 0] shamt;
    reg    [`FUNCT_WIDTH-1: 0] funct;
        
    reg    [`WORD_WIDTH-1:  0] REG[0:`REG_SIZE-1];

    initial
    begin
        $readmemh("REGFILE.txt",REG);
    end

    always@(ir)
    begin
        read_data1 = REG[ir[`RS]]; //glue logic => not good!
        read_data2 = REG[ir[`RT]];
        offset = (ir[`IMM_WIDTH-1]==0)?{16'b0000_0000_0000_0000,ir[`IMM]}:{16'b1111_1111_1111_1111,ir[`IMM]}; //sign extend
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
