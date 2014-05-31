`include "defines.v"

module ctrl (           ir_opcode, 
                /*EX*/  reg_dst, alu_src, alu_op, 
                /*M*/   branch, mem_read, mem_write, 
                /*WB*/  reg_src, reg_write                );
    input [`OPCODE_WIDTH-1:0] ir_opcode;
    output reg_dst, alu_src, branch, mem_read, mem_write, reg_src, reg_write;
    output [1:0] alu_op;
    
    reg reg_dst, branch, mem_read, mem_write, reg_src, alu_src, reg_write;
    reg [1:0] alu_op;
    
    always @(ir_opcode) begin
        case(ir_opcode)
            `LW: begin
                //EX_STAGE
                alu_op = `ALUOP_LW;
                alu_src = `FROM_IMM;
                reg_dst = `TO_RT;
                //M_STAGE
                branch = `FALSE;
                mem_read = `TRUE;
                mem_write = `FALSE;
                //WB_STAGE
                reg_src = `FROM_MEM;
                reg_write = `TRUE;
            end
            `SW: begin
                //EX_STAGE
                alu_op = `ALUOP_SW;
                alu_src = `FROM_IMM;
                reg_dst = `DCARE;
                //M_STAGE
                branch = `FALSE;
                mem_read = `FALSE;
                mem_write = `TRUE;
                //WB_STAGE
                reg_src = `DCARE;
                reg_write = `FALSE;
            end
            `ADDI: begin
                //EX_STAGE
                alu_op = `ALUOP_ADDI;
                alu_src = `FROM_IMM;
                reg_dst = `TO_RT;
                //M_STAGE
                branch = `FALSE;
                mem_read = `FALSE;
                mem_write = `FALSE;
                //WB_STAGE
                reg_src = `FROM_ALU;
                reg_write = `TRUE;
            end
            `BEQ: begin
                //EX_STAGE
                alu_op = `ALUOP_BEQ;
                alu_src = `FROM_RT;
                reg_dst = `DCARE;
                //M_STAGE
                branch = `TRUE;
                mem_read = `FALSE;
                mem_write = `FALSE;
                //WB_STAGE
                reg_src = `DCARE;
                reg_write = `FALSE;
            end
            /*`RTYPE*/default: begin
                //EX_STAGE
                alu_op = `ALUOP_RTYPE;
                alu_src = `FROM_RT;
                reg_dst = `TO_RD;
                //M_STAGE
                branch = `FALSE;
                mem_read = `FALSE;
                mem_write = `FALSE;
                //WB_STAGE
                reg_src = `FROM_ALU;
                reg_write = `TRUE;
            end
        endcase
    end
endmodule
