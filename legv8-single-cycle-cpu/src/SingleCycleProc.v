`timescale 1ns / 1ps
// ECEN 350 Lab 07, Question 2
// Complete single-cycle ARMv8 processor top level.
// This connects the control unit and the datapath components from Labs 5/6.

module SingleCycleProc (
    input              reset,
    input      [63:0]  startpc,
    output reg [63:0]  currentpc,
    output     [63:0]  MemtoRegOut,
    input              CLK
);

    // Instruction fetch and program counter.
    wire [63:0] nextpc;
    wire [31:0] instruction;

    // Instruction fields and register-file addresses.
    wire [4:0]  rd;
    wire [4:0]  readRegA;
    wire [4:0]  readRegB;
    wire [10:0] opcode;

    // Main control-unit outputs.
    wire       Reg2Loc;
    wire       ALUSrc;
    wire       MemtoReg;
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       Branch;
    wire       Uncondbranch;
    wire [3:0] ALUOp;
    wire [1:0] SignOp;

    // Datapath connections.
    wire [63:0] regoutA;
    wire [63:0] regoutB;
    wire [63:0] extimm;
    wire [63:0] aluInputB;
    wire [63:0] aluout;
    wire [63:0] memReadData;
    wire        zero;

    // The PC is synchronously reset and otherwise receives NextPC.
    // The #3 delay matches the starter file's simulation timing.
    always @(posedge CLK) begin
        if (reset)
            currentpc <= #3 startpc;
        else
            currentpc <= #3 nextpc;
    end

    assign rd       = instruction[4:0];
    assign readRegA = instruction[9:5];
    assign readRegB = Reg2Loc ? instruction[4:0] : instruction[20:16];
    assign opcode   = instruction[31:21];

    InstructionMemory imem (
        .Data    (instruction),
        .Address (currentpc)
    );

    SC_Control main_control (
        .Reg2Loc     (Reg2Loc),
        .ALUSrc      (ALUSrc),
        .MemtoReg    (MemtoReg),
        .RegWrite    (RegWrite),
        .MemRead     (MemRead),
        .MemWrite    (MemWrite),
        .Branch      (Branch),
        .Uncondbranch(Uncondbranch),
        .ALUOp       (ALUOp),
        .SignOp      (SignOp),
        .opcode      (opcode)
    );

    RegisterFile register_file (
        .BusA  (regoutA),
        .BusB  (regoutB),
        .BusW  (MemtoRegOut),
        .RA    (readRegA),
        .RB    (readRegB),
        .RW    (rd),
        .RegWr (RegWrite),
        .Clk   (CLK)
    );

    SignExtender sign_extender (
        .SignExOut  (extimm),
        .Instruction(instruction[25:0]),
        .SignOp     (SignOp)
    );

    // ALUSrc chooses register B versus the sign/zero-extended immediate.
    assign aluInputB = ALUSrc ? extimm : regoutB;

    ALU arithmetic_logic_unit (
        .BusW    (aluout),
        .BusA    (regoutA),
        .BusB    (aluInputB),
        .ALUCtrl (ALUOp),
        .Zero    (zero)
    );

    // Store data comes directly from the second register-file read port.
    DataMemory data_memory (
        .ReadData    (memReadData),
        .Address     (aluout),
        .WriteData   (regoutB),
        .MemoryRead  (MemRead),
        .MemoryWrite (MemWrite),
        .Clock       (CLK)
    );

    // Loads write memory data; other register-writing instructions use ALU data.
    assign MemtoRegOut = MemtoReg ? memReadData : aluout;

    NextPClogic next_pc_logic (
        .NextPC      (nextpc),
        .CurrentPC   (currentpc),
        .SignExtImm64(extimm),
        .Branch      (Branch),
        .ALUZero     (zero),
        .Uncondbranch(Uncondbranch)
    );

endmodule
