`timescale 1ns / 1ps
`define OPCODE_ANDREG 11'b10001010000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000

`define OPCODE_ADDIMM 11'b1001000100?
`define OPCODE_SUBIMM 11'b1101000100?

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b000101?????
`define OPCODE_CBZ    11'b10110100???

`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

module SC_Control(
    output reg       Reg2Loc,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Uncondbranch,
    output reg [3:0] ALUOp,
    output reg [1:0] SignOp,
    input [10:0]     opcode
);

always @(*) begin

    // Default: all control signals are zero.
    // Prevents unintended latches.
    Reg2Loc     = 1'b0;
    ALUSrc      = 1'b0;
    MemtoReg    = 1'b0;
    RegWrite    = 1'b0;
    MemRead     = 1'b0;
    MemWrite    = 1'b0;
    Branch      = 1'b0;
    Uncondbranch = 1'b0;
    ALUOp       = 4'b0000;
    SignOp      = 2'b00;

    casez (opcode)

        // LDUR: Load from memory
        `OPCODE_LDUR: begin
            Reg2Loc  = 1'bx;
            ALUSrc   = 1'b1;
            MemtoReg = 1'b1;
            RegWrite = 1'b1;
            MemRead  = 1'b1;
            ALUOp    = 4'b0010;
            SignOp   = 2'b01;
        end

        // STUR: Store to memory
        `OPCODE_STUR: begin
            Reg2Loc  = 1'b1;
            ALUSrc   = 1'b1;
            MemtoReg = 1'bx;
            MemWrite = 1'b1;
            ALUOp    = 4'b0010;
            SignOp   = 2'b01;
        end

        // ADD (register)
        `OPCODE_ADDREG: begin
            RegWrite = 1'b1;
            ALUOp    = 4'b0010;
            SignOp   = 2'bxx;
        end

        // SUB (register)
        `OPCODE_SUBREG: begin
            RegWrite = 1'b1;
            ALUOp    = 4'b0110;
            SignOp   = 2'bxx;
        end

        // AND (register)
        `OPCODE_ANDREG: begin
            RegWrite = 1'b1;
            ALUOp    = 4'b0000;
            SignOp   = 2'bxx;
        end

        // ORR (register)
        `OPCODE_ORRREG: begin
            RegWrite = 1'b1;
            ALUOp    = 4'b0001;
            SignOp   = 2'bxx;
        end

        // ADD (immediate)
        `OPCODE_ADDIMM: begin
            Reg2Loc  = 1'bx;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 4'b0010;
            SignOp   = 2'b00;
        end

        // SUB (immediate)
        `OPCODE_SUBIMM: begin
            Reg2Loc  = 1'bx;
            ALUSrc   = 1'b1;
            RegWrite = 1'b1;
            ALUOp    = 4'b0110;
            SignOp   = 2'b00;
        end

        // CBZ: Conditional branch if zero
        `OPCODE_CBZ: begin
            Reg2Loc = 1'b1;
            MemtoReg = 1'bx;
            Branch   = 1'b1;
            ALUOp    = 4'b0111;
            SignOp   = 2'b10;
        end

        // B: Unconditional branch
        `OPCODE_B: begin
            Reg2Loc     = 1'bx;
            ALUSrc      = 1'bx;
            MemtoReg    = 1'bx;
            Branch      = 1'bx;
            Uncondbranch = 1'b1;
            ALUOp       = 4'bxxxx;
            SignOp      = 2'b11;
        end

        // Unsupported opcodes: all zeros
        default: begin
            // Keep default values.
        end

    endcase
end

endmodule
