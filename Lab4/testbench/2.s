        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
        .word   0x0             # 0($gp)
        .word   0x1             # 4($gp)
        .word   0x2             # 8($gp)
        .word   0x3             # 12($gp)

        .text   0x00400000      # start of Text (pointed by PC), 
                                # Be careful there might be some other instructions in JsSPIM.
                                # Recommend at least 9 instructions to cover out those other instructions.

main:   lw      $t0, 0($gp)        # Load t0 from memory t0 = 0
        lw      $t4, 0($gp)
        lw      $t1, 4($gp)        # Load t1 from memory t1 = 1
        lw      $t2, 0($gp)        # t2 = 0
        addi    $t2, 2             

loop:   beq     $t0, $t2, end      # should stall 1, check if beq can fetch correct $t2
        addi    $t0, $t0, 1
        sub     $t3, $t1, $t0
        lw      $t3, 8($gp)         # t3 = 2 
        beq     $t2, $t3, loop      # should stall 2, taken
        addi    $t4, $t4, 1
        add     $a3, $t4, $t4
        
end:    sw      $t4, 0($gp)      # s3 = 0
        lw      $t2, 0($gp)      # test lw after sw
        sw      $t2, 12($gp)     # test sw after lw
