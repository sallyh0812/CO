`timescale 1ns / 1ps
// <111613025>

module bit_alu (
    input            a,          // 1 bit, a
    input            b,          // 1 bit, b
    input            less,       // 1 bit, Less
    input            a_invert,   // 1 bit, Ainvert
    input            b_invert,   // 1 bit, Binvert
    input            carry_in,   // 1 bit, CarryIn
    input      [1:0] operation,  // 2 bit, Operation
    output reg       result,     // 1 bit, Result (Must it be a reg?)
    output           carry_out   // 1 bit, CarryOut
);

    wire ai, bi;  // what's the difference between `wire` and `reg` ?
    assign ai = a_invert ? ~a : a;  // remember `?` operator in C/C++?
    assign bi = b_invert ? ~b : b;  // you can use logical expression too!

    /* [step 2] implement a 1-bit full adder */
    wire sum;
    assign carry_out = (ai & bi) | (ai & carry_in) | (bi & carry_in);
    assign sum       = ai ^ bi ^ carry_in;

    /* [step 3] using a mux to assign result */
    always @(*) begin  // `*` auto captures sensitivity ports, now it's combinational logic
        case (operation)  // `case` is similar to `switch` in C
            2'b00:   result <= ai & bi;  // AND
            2'b01:   result <= a | b;  // OR
            2'b10:   result <= sum;  // ADD
            2'b11:   result <= less; // SLT
            default: result <= 0;  // should not happened
        endcase
    end
endmodule
