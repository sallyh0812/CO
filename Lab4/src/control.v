`timescale 1ns / 1ps
// <111613025>

/* Copy your Control (and its components) from Lab 2 */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [31:26]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output [1:0] alu_op       // ALUOp passed to ALU Control unit
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.18 */
    /* You can check the "Green Card" to get the opcode/funct for each instruction. */
    wire R_format;
    wire lw;
    wire sw;
    wire beq;
    wire addi; //001000
    wire [5:0] op;

    assign op = opcode;

    assign R_format = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
    assign lw = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign sw = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
    assign beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign addi = ~op[5] & ~op[4] & op[3] & ~op[2] & ~op[1] & ~op[0];
    
    assign reg_dst = R_format;
    assign alu_src = lw | sw | addi;
    assign mem_to_reg = lw;
    assign reg_write = R_format | lw | addi;
    assign mem_read = lw;
    assign mem_write = sw;
    assign branch = beq;
    
    assign alu_op[1] = R_format | addi;
    assign alu_op[0] = beq | addi;
endmodule