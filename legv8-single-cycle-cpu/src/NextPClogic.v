`timescale 1ns / 1ps
// NextPC logic determines the address of the next instruction
module NextPClogic(
    output reg [63:0] NextPC,       // Address of the next instruction
    input      [63:0] CurrentPC,    // Address of the current instruction
    input      [63:0] SignExtImm64, // Sign-extended branch offset
    input             Branch,       // 1 for a conditional branch such as CBZ
    input             ALUZero,      // 1 when the ALU result is zero
    input             Uncondbranch  // 1 for an unconditional branch such as B
);

    // Combinational logic:
    // Recalculate NextPC whenever any input changes
    always @(*) begin

        // Take the branch in either of these situations:
        //
        // 1. Unconditional branch:
        //      Uncondbranch = 1
        //
        // 2. Conditional branch whose condition is true:
        //      Branch = 1 AND ALUZero = 1
        //
        // SignExtImm64 has already been shifted left by 2
        // by the Sign Extender, so no additional shift is needed here.
        if (Uncondbranch || (Branch && ALUZero)) begin

            // Branch is taken:
            // Add the signed branch offset to the current PC
            NextPC = CurrentPC + SignExtImm64;

        end
        else begin

            // Branch is not taken:
            // Move to the next ARMv8 instruction.
            // Each instruction is 4 bytes, so PC increases by 4.
            NextPC = CurrentPC + 64'd4;

        end
    end

endmodule
