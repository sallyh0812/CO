`timescale 1ns / 1ps
// <111613025>

/** [Prerequisite] pipelined (Lab 3), forwarding, hazard_detection
 * This module is the pipelined MIPS processor "similar to" FIGURE 4.60 (control hazard is not solved).
 * You can implement it by any style you want, as long as it passes testbench.
 */

module pipelined #(
    parameter integer TEXT_BYTES = 1024,        // size in bytes of instruction memory
    parameter integer TEXT_START = 'h00400000,  // start address of instruction memory
    parameter integer DATA_BYTES = 1024,        // size in bytes of data memory
    parameter integer DATA_START = 'h10008000   // start address of data memory
) (
    input clk,  // clock
    input rstn  // negative reset
);

    /** [step 0] Copy from Lab 3
     * You should modify your pipelined processor from Lab 3, so copy to here first.
     */
    /* Instruction Memory */
    wire [31:0] instr_mem_address, instr_mem_instr;
    instr_mem #(
        .BYTES(TEXT_BYTES),
        .START(TEXT_START)
    ) instr_mem (
        .address(instr_mem_address),
        .instr  (instr_mem_instr)
    );

    /* Register Rile */
    wire [4:0] reg_file_read_reg_1, reg_file_read_reg_2, reg_file_write_reg;
    wire reg_file_reg_write;
    wire [31:0] reg_file_write_data, reg_file_read_data_1, reg_file_read_data_2;
    reg_file reg_file (
        .clk        (~clk),                  // only write when negative edge
        .rstn       (rstn),
        .read_reg_1 (reg_file_read_reg_1),
        .read_reg_2 (reg_file_read_reg_2),
        .reg_write  (reg_file_reg_write),
        .write_reg  (reg_file_write_reg),
        .write_data (reg_file_write_data),
        .read_data_1(reg_file_read_data_1),
        .read_data_2(reg_file_read_data_2)
    );

    /* ALU */
    wire [31:0] alu_a, alu_b, alu_result;
    wire [3:0] alu_ALU_ctl;
    wire alu_zero, alu_overflow;
    alu alu (
        .a       (alu_a),
        .b       (alu_b),
        .ALU_ctl (alu_ALU_ctl),
        .result  (alu_result),
        .zero    (alu_zero),
        .overflow(alu_overflow)
    );

    /* Data Memory */
    wire data_mem_mem_read, data_mem_mem_write;
    wire [31:0] data_mem_address, data_mem_write_data, data_mem_read_data;
    data_mem #(
        .BYTES(DATA_BYTES),
        .START(DATA_START)
    ) data_mem (
        .clk       (~clk),                 // only write when negative edge
        .mem_read  (data_mem_mem_read),
        .mem_write (data_mem_mem_write),
        .address   (data_mem_address),
        .write_data(data_mem_write_data),
        .read_data (data_mem_read_data)
    );

    /* ALU Control */
    wire [1:0] alu_control_alu_op;
    wire [5:0] alu_control_funct;
    wire [3:0] alu_control_operation;
    alu_control alu_control (
        .alu_op   (alu_control_alu_op),
        .funct    (alu_control_funct),
        .operation(alu_control_operation)
    );

    /* (Main) Control */
    wire [5:0] control_opcode;
    // Execution/address calculation stage control lines
    wire control_reg_dst, control_alu_src;
    wire [1:0] control_alu_op;
    // Memory access stage control lines
    wire control_branch, control_mem_read, control_mem_write;
    // Wire-back stage control lines
    wire control_reg_write, control_mem_to_reg;
    control control (
        .opcode    (control_opcode),
        .reg_dst   (control_reg_dst),
        .alu_src   (control_alu_src),
        .mem_to_reg(control_mem_to_reg),
        .reg_write (control_reg_write),
        .mem_read  (control_mem_read),
        .mem_write (control_mem_write),
        .branch    (control_branch),
        .alu_op    (control_alu_op)
    );


    wire [1:0] forward_A, forward_B;
    wire pc_write;
    wire IF_ID_write;
    wire stall;

    /** [step 1] Instruction fetch (IF)*/
    // 1.
    reg [31:0] pc;  // DO NOT change this line
    // 2.
    assign instr_mem_address = pc;
    // 3.
    wire [31:0] pc_4 = pc + 4;
    // 4.
    reg [31:0] IF_ID_instr, IF_ID_pc_4;
    always @(posedge clk)
        if (rstn) begin
            if (IF_ID_write !== 0) begin
                IF_ID_instr <= instr_mem_instr;
                IF_ID_pc_4  <= pc_4;
            end else begin
                IF_ID_instr <= IF_ID_instr;
                IF_ID_pc_4  <= IF_ID_pc_4;
            end
        end
    always @(negedge rstn) begin
        IF_ID_instr <= 'bx;  // a.
        IF_ID_pc_4  <= 'bx;  // b.
    end

    /** [step 2] Instruction decode and register file read (ID) */

    assign control_opcode = IF_ID_instr[31:26];
    assign reg_file_read_reg_1 = IF_ID_instr[25:21];
    assign reg_file_read_reg_2 = IF_ID_instr[20:16];

    wire [31:0] sign_extend;
    assign sign_extend = {{16{IF_ID_instr[15]}}, IF_ID_instr[15:0]};

    wire [31:0] shftl2;
    assign shftl2 = (sign_extend << 2);

    wire [31:0] branch_target_addr;
    assign branch_target_addr = shftl2 + IF_ID_pc_4;
    
    wire [31:0] cmpr1, cmpr2;
    assign cmpr1 = forward_A === 'b10 ? EX_MEM_result :
                    forward_A === 'b01 ? reg_file_write_data :
                    reg_file_read_data_1;

    assign cmpr2 = forward_B === 'b10 ? EX_MEM_result :
                    forward_B === 'b01 ? reg_file_write_data :
                    reg_file_read_data_2;

    wire [31:0] next_pc;
    assign next_pc = (control_branch === 'b1 & cmpr1 == cmpr2) ? 
                    branch_target_addr : pc_4;

    reg [31:0] ID_EX_instr, ID_EX_pc_4, ID_EX_reg_read_data1, ID_EX_reg_read_data2, ID_EX_sign_extend, ID_EX_write_reg;
    reg [8:0] ID_EX_CONTROL; // WB: MemtoReg, RegWrite; MEM: Branch, MemWrite, MemRead; EX: ALUSrc, RegDst, ALUOp[1:0];

    always @(posedge clk)
        if (rstn) begin
            // a.
            ID_EX_CONTROL <= stall === 'b1 ? 'b0 : {control_mem_to_reg, control_reg_write, 
                            control_branch, control_mem_write, control_mem_read, 
                            control_alu_src, control_reg_dst, control_alu_op};
            // b.
            ID_EX_instr <= IF_ID_instr;
            ID_EX_pc_4  <= IF_ID_pc_4;
            //c.
            ID_EX_reg_read_data1 <= reg_file_read_data_1;
            ID_EX_reg_read_data2 <= reg_file_read_data_2;
            //d.
            ID_EX_sign_extend <= sign_extend;
            //e.
            

        end
    always @(negedge rstn) begin
        ID_EX_instr <= 'bx;
        ID_EX_pc_4  <= 'bx;
        ID_EX_reg_read_data1 <= 'bx;
        ID_EX_reg_read_data2 <= 'bx; 
        ID_EX_sign_extend <= 'bx;
        ID_EX_write_reg <= 'bx;
        ID_EX_CONTROL <= 'bx;
    end

    /** [step 3] Execute or address calculation (EX)*/

    assign alu_control_alu_op = ID_EX_CONTROL[1:0]; //alu_op
    assign alu_control_funct = ID_EX_instr[5:0];
    assign alu_ALU_ctl = alu_control_operation;

    // assign alu_a = ID_EX_reg_read_data1;
    // assign alu_b = ID_EX_CONTROL[3] ? ID_EX_sign_extend : ID_EX_reg_read_data2;  //alu_src

    reg [31:0] EX_MEM_pc_4, EX_MEM_branch_target_addr, EX_MEM_result, EX_MEM_read_data2;
    reg EX_MEM_zero;
    reg [4:0] EX_MEM_write_reg;
    reg [4:0] EX_MEM_CONTROL; // WB: MemtoReg, RegWrite; MEM: Branch, MemWrite, MemRead;

    always @(posedge clk)
        if (rstn) begin
            // a.
            EX_MEM_pc_4 <= ID_EX_pc_4;
            EX_MEM_CONTROL <=  ID_EX_CONTROL[8:4];
            
            //EX_MEM_branch_target_addr <= branch_target_addr;

            //EX_MEM_zero <= alu_zero;

            EX_MEM_result <= alu_result;

            EX_MEM_read_data2 <= ID_EX_reg_read_data2;

            //reg [8:0] ID_EX_CONTROL; // WB: MemtoReg, RegWrite; MEM: Branch, MemWrite, MemRead; EX: ALUSrc, RegDst, ALUOp[1:0];
            EX_MEM_write_reg <= ID_EX_CONTROL[2] ? ID_EX_instr[15:11] : ID_EX_instr[20:16];
            
        end
    always @(negedge rstn) begin
        EX_MEM_pc_4 <= 'bx;
        EX_MEM_branch_target_addr <= 'bx;
        EX_MEM_zero <= 'bx;
        EX_MEM_result <= 'bx;
        EX_MEM_CONTROL <= 'bx;
    end



    /** [step 4] Memory access (MEM)*/

    //reg [4:0] EX_MEM_CONTROL; // WB: MemtoReg, RegWrite; MEM: Branch, MemWrite, MemRead;
    
    assign data_mem_write_data = EX_MEM_read_data2;
    assign data_mem_address = EX_MEM_result;
    assign data_mem_mem_read = EX_MEM_CONTROL[0];
    assign data_mem_mem_write = EX_MEM_CONTROL[1];

    reg [31:0] MEM_WB_mem_read_data, MEM_WB_result;
    reg [4:0] MEM_WB_write_reg;
    reg [1:0] MEM_WB_CONTROL; // WB: MemtoReg, RegWrite;
    always @(posedge clk)
        if (rstn) begin
            // a.
            MEM_WB_CONTROL <=  EX_MEM_CONTROL[4:3];
            
            // b.
            MEM_WB_mem_read_data <= data_mem_read_data;

            // c.
            MEM_WB_result <= EX_MEM_result;

            //d.
            MEM_WB_write_reg <= EX_MEM_write_reg;

        end
    always @(negedge rstn) begin
        MEM_WB_CONTROL <= 'bx;
        MEM_WB_mem_read_data <= 'bx;
        MEM_WB_result <= 'bx;
        MEM_WB_write_reg <= 'bx;
    end

    always @(posedge clk)
        if (rstn) begin
            if (pc_write !== 'b0)
                pc = next_pc;
            pc <= pc_write !== 'b0 ? next_pc : pc;  // 5.
        end
    always @(negedge rstn) begin
        pc <= 32'h00400000;
    end


    /** [step 5] Write-back (WB)*/
    assign reg_file_write_reg = MEM_WB_write_reg;
    assign reg_file_reg_write = MEM_WB_CONTROL[0]; //reg_write
    assign reg_file_write_data = MEM_WB_CONTROL[1] ? MEM_WB_mem_read_data : MEM_WB_result;

    //TODO
    /** [step 2] Connect Forwarding unit
     * 1. add `ID_EX_rs` into ID/EX stage registers
     * 2. Use a mux to select correct ALU operands according to forward_A/B
     *    Hint don't forget that alu_b might be sign-extended immediate!
     */
    wire [4:0] ID_EX_rs, ID_EX_rt;

    assign ID_EX_rs = ID_EX_instr[25:21];
    assign ID_EX_rt = ID_EX_instr[20:16];
    forwarding forwarding (
        .ID_EX_rs        (ID_EX_rs),
        .ID_EX_rt        (ID_EX_rt),
        .EX_MEM_reg_write(EX_MEM_CONTROL[3]),
        .EX_MEM_rd       (EX_MEM_write_reg),
        .MEM_WB_reg_write(MEM_WB_CONTROL[0]),
        .MEM_WB_rd       (MEM_WB_write_reg),
        .forward_A       (forward_A),
        .forward_B       (forward_B)
    );

    //assign alu_a = ID_EX_reg_read_data1;
    //assign alu_b = ID_EX_CONTROL[3] ? ID_EX_sign_extend : ID_EX_reg_read_data2;  //alu_src
    assign alu_a = forward_A === 2'b10 ? EX_MEM_result :
                    forward_A === 2'b01 ? reg_file_write_data : 
                    ID_EX_reg_read_data1;  // forward 1st operand
     
    assign alu_b =  ID_EX_CONTROL[3] ? ID_EX_sign_extend :  //alu_src
                    forward_B === 2'b10 ? EX_MEM_result :
                    forward_B === 2'b01 ? reg_file_write_data : 
                    ID_EX_reg_read_data2;  // forward 2nd operand

    /** [step 4] Connect Hazard Detection unit
     * 1. use `pc_write` when updating PC
     * 2. use `IF_ID_write` when updating IF/ID stage registers
     * 3. use `stall` when updating ID/EX stage registers
     */
    hazard_detection hazard_detection (
        .ID_EX_mem_read(ID_EX_CONTROL[4]),
        .ID_EX_rt      (ID_EX_instr[20:16]),
        .ID_EX_reg_write(ID_EX_CONTROL[7]),
        .EX_MEM_mem_to_reg(EX_MEM_CONTROL[4]),
        .EX_MEM_write_reg(EX_MEM_write_reg),
        .IF_ID_branch(control_branch),
        .IF_ID_rs      (IF_ID_instr[25:21]),
        .IF_ID_rt      (IF_ID_instr[20:16]),
        .pc_write      (pc_write),            // implicitly declared
        .IF_ID_write   (IF_ID_write),         // implicitly declared
        .stall         (stall)                // implicitly declared
    );

    /** [step 5] Control Hazard
     * This is the most difficult part since the textbook does not provide enough information.
     * By reading p.377-379 "Reducing the Delay of Branches",
     * we can disassemble this into the following steps:
     * 1. Move branch target address calculation & taken or not from EX to ID
     * 2. Move branch decision from MEM to ID
     * 3. Add forwarding for registers used in branch decision from EX/MEM
     * 4. Add stalling:
          branch read registers right after an ALU instruction writes it -> 1 stall
          branch read registers right after a load instruction writes it -> 2 stalls
     */

endmodule  // pipelined
