`timescale 1ns / 1ps
// <111613025>

/* checkout FIGURE C.5.10 (Bottom) */
/* [Prerequisite] complete bit_alu.v */
module msb_bit_alu (
    input        a,          // 1 bit, a
    input        b,          // 1 bit, b
    input        less,       // 1 bit, Less
    input        a_invert,   // 1 bit, Ainvert
    input        b_invert,   // 1 bit, Binvert
    input        carry_in,   // 1 bit, CarryIn
    input  [1:0] operation,  // 2 bit, Operation
    output reg       result,     // 1 bit, Result (Must it be a reg?)
    output       set,        // 1 bit, Set
    output       overflow    // 1 bit, Overflow
);

    /* Try to implement the most significant bit ALU by yourself! */
    /* Be careful with overflow in SLT, checkout Exercise C.24 */

    /* [step 1] invert input on demand */
    wire ai, bi;
    assign ai = a_invert ? ~a : a;
    assign bi = b_invert ? ~b : b;

    /* [step 2] implement a 1-bit full adder */
    wire sum, carry_out;
    assign carry_out = (ai & bi) | (ai & carry_in) | (bi & carry_in);
    assign sum       = ai ^ bi ^ carry_in;
    assign overflow = (carry_in ^ carry_out) & (operation == 2'b10);
    assign set = (carry_in ^ carry_out) ? ~sum : sum;

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
