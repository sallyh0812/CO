`timescale 1ns / 1ps
// <111613025>

/** [Reading] 4.4 p.318-321
 * "Designing the Main Control Unit"
 */
/** [Prerequisite] alu_control.v
 * This module is the Control unit in FIGURE 4.17
 * You can implement it by any style you want.
 */

/* checkout FIGURE 4.16/18 to understand each definition of control signals */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [31:26]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output       jump,
    output       shftr,      // shift right for ori
    output       shftl,       // shift left for lui
    output [1:0] alu_op       // ALUOp passed to ALU Control unit
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.18 */
    /* You can check the "Green Card" to get the opcode/funct for each instruction. */
    wire R_format;
    wire lw;
    wire sw;
    wire beq;
    wire [5:0] op;
    wire j;
    wire lui;
    wire ori;

    assign op = opcode;

    assign R_format = ~op[5] & ~op[4] & ~op[3] & ~op[2] & ~op[1] & ~op[0];
    assign lw = op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & op[0];
    assign sw = op[5] & ~op[4] & op[3] & ~op[2] & op[1] & op[0];
    assign beq = ~op[5] & ~op[4] & ~op[3] & op[2] & ~op[1] & ~op[0];
    assign j = ~op[5] & ~op[4] & ~op[3] & ~op[2] & op[1] & ~op[0];

    assign lui = ~op[5] & ~op[4] & op[3] & op[2] & op[1] & op[0];
    assign ori = ~op[5] & ~op[4] & op[3] & op[2] & ~op[1] & op[0];

    assign reg_dst = R_format;
    assign alu_src = lw | sw | lui | ori;
    assign mem_to_reg = lw;
    assign reg_write = R_format | lw | lui | ori;
    assign mem_read = lw;
    assign mem_write = sw;
    assign branch = beq;
    assign jump = j;
    assign shftl = lui;
    assign shftr = ori;

    assign alu_op[1] = R_format | lui | ori;
    assign alu_op[0] = beq | lui | ori;
endmodule
