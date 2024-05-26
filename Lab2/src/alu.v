`timescale 1ns / 1ps
// <111613025>

module alu (
    input  [31:0] a,        // 32 bits, source 1 (A)
    input  [31:0] b,        // 32 bits, source 2 (B)
    input  [ 3:0] ALU_ctl,  // 4 bits, ALU control input
    output [31:0] result,   // 32 bits, result
    output        zero,     // 1 bit, set to 1 when the output is 0
    output        overflow  // 1 bit, overflow
);
    
    wire [31:0] less, a_invert, b_invert, carry_in;
    wire [30:0] carry_out;
    wire [63:0] operation;  // flatten vector
    wire        set;  // set of most significant bit
    
    bit_alu lsbs[30:0] (
        .a        (a[30:0]),
        .b        (b[30:0]),
        .less     (less[30:0]),
        .a_invert (a_invert[30:0]),
        .b_invert (b_invert[30:0]),
        .carry_in (carry_in[30:0]),
        .operation(operation[61:0]),
        .result   (result[30:0]),
        .carry_out(carry_out[30:0])
    );
    
    msb_bit_alu msb (
        .a        (a[31]),
        .b        (b[31]),
        .less     (less[31]),
        .a_invert (a_invert[31]),
        .b_invert (b_invert[31]),
        .carry_in (carry_in[31]),
        .operation(operation[63:62]),
        .result   (result[31]),
        .set      (set),
        .overflow (overflow)
    );
    
    assign less[0] = set;
    assign less[31:1] = 0;

    assign a_invert = {32{ALU_ctl[3]}};
    wire b_negate;
    assign b_negate = ALU_ctl[2];
    assign b_invert = {32{b_negate}};

    assign carry_in[0] = b_negate;
    assign carry_in[31:1] = carry_out[30:0];

    assign operation = {32{ALU_ctl[1:0]}};

    assign zero = (result == 32'b0) ? 1 : 0;


endmodule
