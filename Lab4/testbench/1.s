        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
        .word   0x0             # 0($gp)
        .word   0x1             # 4($gp)
        .word   0x2             # 8($gp)
        .word   0x3             # 12($gp)

        .text   0x00400000      # start of Text (pointed by PC), 
                                # Be careful there might be some other instructions in JsSPIM.
                                # Recommend at least 9 instructions to cover out those other instructions.

main:   lw      $t0, 0($gp)        # Load t0 from memory t0 = 0
        addi    $t1, $t0, 5        # t1 = t0 + 5, forwarding t1 = 5
        lw      $t1, 4($gp)        # t1 = 1
        addi    $t2, $t1, 4        # t2 = t1 + 4, forwarding t2 = 5
        add     $t3, $t2, $t1      # t3 = t2 + t1, forwarding from both t2 and t1 t3 = 9
        lw      $t4, 8($gp)        # t4 = 2
        sub     $t5, $t4, $t3      # t5 = t4 - t3, forwarding from t4 t5 = -7
        or      $t6, $t5, $t4      # t6 = t5 | t4, forwarding from t5
        and     $t7, $t6, $t3      # t7 = t6 & t3, forwarding from t6

loop:   beq     $t4, $t2, end      # Branch if t4 == t2 == 5
        addi    $t4, $t4, 1        # t4 = t4 + 1, forwarding t4 = 3
        beq     $0,  $0,  loop
        add     $s0, $0, $t0       # Will not execute if branch is taken
        add     $s1, $0, $t1
        
end:    add     $s2, $t5, $t4      # s0 = t5 + t4 = -7 + 5 = -2
        slt     $s3, $t2, $t3      # s3 = 1
