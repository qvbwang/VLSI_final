`include "defines.v"

/*
*[140604] changes "ID.v" to "async_reg.v", and trim the design goal to just a register
*/

module async_reg (  rst, reg_write,
                    reg_raddr1, reg_raddr2, reg_waddr,
                    reg_data1, reg_data2, reg_wdata
					);

    input                       rst, reg_write;
    input  [`REGADDR_WIDTH-1:0] reg_raddr1, reg_raddr2, reg_waddr;
    input  [`WORD_WIDTH-1:0] reg_wdata;
    output [`WORD_WIDTH-1:0] reg_data1,reg_data2;
        
    reg    [`WORD_WIDTH-1:0] reg_file [0:`REG_SIZE-1];

    assign reg_data1 = reg_file[reg_raddr1];
    assign reg_data2 = reg_file[reg_raddr2];
    
    always@(rst or reg_write or reg_waddr)
    begin
        if(rst)
            reg_file[0] = 0;
        else if(reg_write && reg_waddr!=0) // preserve $zero
            reg_file[reg_waddr] = reg_wdata;
        else
            reg_file[reg_waddr] = reg_file[reg_waddr];
    end

endmodule
