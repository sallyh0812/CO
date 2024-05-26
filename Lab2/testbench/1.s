        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
hun:    .word   0x00114514      # 0($gp)
hah:    .word   0xf1919810
        .word   0x1
        .word   0x2
        .word   0x3             # 16($gp)

        .text   0x00400000      # start of Text (pointed by PC), 
                                # Be careful there might be some other instructions in JsSPIM.
                                # Recommend at least 9 instructions to cover out those other instructions.
.data
int_a: .word 4
int_b: .word 3
int_c: .word 2

.text
main:
    # Load values of int_a, int_b, int_c, int_d
    lw $t3, int_a
    lw $t4, int_b
    lw $t5, int_c
    # Bubble sort algorithm
    li $a0, 1
    li $t1, 2           # Set the maximum number of comparisons
    li $t0, 0           # Outer loop counter (i)

outer_loop:
    slt $t8, $t0, $t1   # if i>=3: end
    beq $t8, $zero, end_sort
    li $t2, 0           # j = 0
    add $t0, $t0, $a0    # i++

inner_loop:
    slt $t8, $t2, $t1   # if j>=3: outer loop
    beq $t8, $zero, outer_loop  # Exit the loop if no more comparisons needed

swap_loop:
    # Compare and swap int_a and int_b
    slt $t9, $t3, $t4
    beq $t9, $zero, swap_ab

    # Compare and swap int_b and int_c
    slt $t9, $t4, $t5
    beq $t9, $zero, swap_bc

    j next_iteration    # No swaps needed, go to the next iteration

swap_ab:
    # Swap int_a and int_b
    add $t7, $t3, $zero       # Temporary register to store int_a
    add $t3, $t4, $zero       # int_a = int_b
    add $t4, $t7, $zero       # int_b = temporary

    j next_iteration    # Go to the next iteration

swap_bc:
    # Swap int_b and int_c
    add $t7, $t4, $zero       # Temporary register to store int_b
    add $t4, $t5, $zero       # int_b = int_c
    add $t5, $t7, $zero       # int_c = temporary

    j next_iteration    # Go to the next iteration

next_iteration:
    # Increment outer loop counter
    add $t2, $t2, $a0    # j++
    j inner_loop        # Continue inner loop

end_sort:
    # End of program
    sw $t3, int_a
    sw $t4, int_b
    sw $t5, int_c
    li      $a0, 0x11111111 # test li (lui, ori)       
