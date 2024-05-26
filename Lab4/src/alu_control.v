`timescale 1ns / 1ps
// <111613025>

/* Copy your ALU Control (if you have one) from Lab 2 */
module alu_control (
    input  [1:0] alu_op,    // ALUOp
    input  [5:0] funct,     // Funct field
    output [3:0] operation  // Operation
);

    assign operation[3] = 0;
    assign operation[2] = (~alu_op[1] & alu_op[0]) | (alu_op[1] & ~alu_op[0] & funct[1]);
    assign operation[1] = (~alu_op[1] | ~funct[2]) | (alu_op[1] & alu_op[0]);
    assign operation[0] = (alu_op[1] & ~alu_op[0]) & (funct[0] | funct[3]);

endmodule
