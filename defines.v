/*===================================
*reference : P360
===================================*/
`define WORD_WIDTH 32
`define RAM_WIDTH 8
`define OPCODE_WIDTH 6
`define REGADDR_WIDTH 5
`define IMM_WIDTH 16
`define FUNCT_WIDTH 6
`define SHAMT_WIDTH 5

`define RAM_SIZE 128
`define REG_SIZE 32

`define MEM_WIDTH 1024
`define ADDR_WIDTH 10

//boolean representation
    `define TRUE 1'b1
    `define FALSE 1'b0
    `define DCARE 1'bx

//ctrl_lines
    //alu_src
        `define FROM_IMM 1'b1
        `define FROM_RT 1'b0
    //pc_src
        `define PC_JUMP 1'b1
        `define PC_INCRESE 1'b0
    //reg_src (mem to reg)
        `define FROM_MEM 1'b1
        `define FROM_ALU 1'b0
    //reg_dst
        `define TO_RD 1'b1
        `define TO_RT 1'b0

//IR_index
    `define OPCODE 31:26
    `define RS 25:21
    `define RT 20:16
    `define RD 15:11
    `define SHAMT 10:6
    `define FUNCT 5:0
    `define IMM 15:0
    `define ADDR 25:0

//OPCODE
    `define LW 6'h23
    `define SW 6'h2b
    `define BEQ 6'h4
    `define ADDI 6'h8
    `define RTYPE 6'h0
    
//FUNCT
    `define ADD 6'h20
    `define SUB 6'h22
    `define SLL 6'h00

//ALU_OP
    `define ALUOP_LW 2'b00
    `define ALUOP_SW 2'b00
    `define ALUOP_ADDI 2'b00
    `define ALUOP_BEQ 2'b01
    `define ALUOP_RTYPE 2'b10
    
//ALU_FUNCT
    `define ALU_ADD 4'b0010
    `define ALU_SUB 4'b0110
    `define ALU_AND 4'b0000
    `define ALU_OR 4'b0001
    `define ALU_SLT 4'b0111
    `define ALU_NOR 4'b1100
    `define ALU_SLL 4'b0011 //custom
    
