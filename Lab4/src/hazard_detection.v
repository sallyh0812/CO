`timescale 1ns / 1ps
// <your student id>

/** [Reading] 4.7 p.372-375
 * Understand when and how to detect stalling caused by data hazards.
 * When read a reg right after it was load from memory,
 * it is impossible to solve the hazard just by forwarding.
 */

/* checkout FIGURE 4.59 to understand why a stall is needed */
/* checkout FIGURE 4.60 for how this unit should be connected */
module hazard_detection (
    input        ID_EX_mem_read,
    input  [4:0] ID_EX_rt,
    input        ID_EX_reg_write,
    input        EX_MEM_mem_to_reg,
    input  [4:0] EX_MEM_write_reg,
    input        IF_ID_branch,
    input  [4:0] IF_ID_rs,
    input  [4:0] IF_ID_rt,
    output       pc_write,        // only update PC when this is set
    output       IF_ID_write,     // only update IF/ID stage registers when this is set
    output      stall            // insert a stall (bubble) in ID/EX when this is set
);

    /** [step 3] Stalling
     * 1. calculate stall by equation from textbook.
     * 2. Should pc be written when stall?
     * 3. Should IF/ID stage registers be updated when stall?
     */

    assign stall = ((ID_EX_mem_read) & 
                            ((ID_EX_rt == IF_ID_rs) | (ID_EX_rt == IF_ID_rt))) | //first stall (lw -> add)
                    ((EX_MEM_mem_to_reg & IF_ID_branch) & 
                            ((EX_MEM_write_reg == IF_ID_rs) | (EX_MEM_write_reg == IF_ID_rt))) | //second stall (lw -> beq)
                    ((IF_ID_branch & ID_EX_reg_write) & 
                            ((ID_EX_rt == IF_ID_rs) | (ID_EX_rt == IF_ID_rt))); //stall (add -> beq)
    assign pc_write = ~stall;
    assign IF_ID_write = ~stall;


endmodule
