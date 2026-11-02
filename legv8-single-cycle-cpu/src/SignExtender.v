`timescale 1ns / 1ps
// Define the 2-bit SignOp values for each instruction type
`define Itype  2'b00
`define Dtype  2'b01
`define CBtype 2'b10
`define Btype  2'b11

module SignExtender(
    output reg [63:0] SignExOut,   // 64-bit extended immediate output
    input      [25:0] Instruction, // Lower 26 bits of the ARMv8 instruction
    input      [1:0]  SignOp       // Selects which instruction format is being used
);

    // Combinational logic:
    // Any change in the inputs causes the output to be recalculated
    always @(*) begin

        // Choose how to extend the immediate based on instruction type
        case (SignOp)

            // I-Type instructions use bits [21:10]
            // The immediate is 12 bits and is unsigned,
            // so it is zero-extended to 64 bits
            `Itype:
                SignExOut = {
                    52'b0,             // Add 52 zeros on the left
                    Instruction[21:10] // Original 12-bit immediate
                };

            // D-Type instructions use bits [20:12]
            // The immediate is 9 bits and can be negative,
            // so it must be sign-extended
            `Dtype:
                SignExOut = {
                    {55{Instruction[20]}}, // Repeat the sign bit 55 times
                    Instruction[20:12]     // Original 9-bit immediate
                };

            // CB-Type instructions use bits [23:5]
            // The immediate is 19 bits and is signed
            // It is also shifted left by 2 bits because branch
            // addresses are multiples of 4 bytes
            `CBtype:
                SignExOut = {
                    {43{Instruction[23]}}, // Repeat the sign bit 43 times
                    Instruction[23:5],     // Original 19-bit branch immediate
                    2'b00                  // Shift left by 2 by appending two zeros
                };

            // B-Type instructions use bits [25:0]
            // The immediate is 26 bits and is signed
            // It is also shifted left by 2 bits
            `Btype:
                SignExOut = {
                    {36{Instruction[25]}}, // Repeat the sign bit 36 times
                    Instruction[25:0],     // Original 26-bit branch immediate
                    2'b00                  // Shift left by 2
                };

            // Safety/default case:
            // Guarantees that SignExOut is assigned for every possible input,
            // preventing an unintended latch
            default:
                SignExOut = 64'b0;

        endcase
    end

endmodule
