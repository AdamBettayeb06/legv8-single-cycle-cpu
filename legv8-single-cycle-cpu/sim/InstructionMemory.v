`timescale 1ns / 1ps
// Stand-in instruction memory so the processor can be simulated outside the
// course environment. Holds a small test program: sum 1..5 in a loop,
// store and reload the result, then exercise AND, ORR, and SUB.
module InstructionMemory(
    output reg [31:0] Data,
    input      [63:0] Address
);
    always @(*) begin
        case (Address)
            64'h000: Data = 32'h910017e1;  // ADDI X1, XZR, #5  (n = 5)
            64'h004: Data = 32'h910003e2;  // ADDI X2, XZR, #0  (sum = 0)
            64'h008: Data = 32'hb4000081;  // loop: CBZ X1, done  (exit when n == 0)
            64'h00c: Data = 32'h8b010042;  // ADD  X2, X2, X1  (sum += n)
            64'h010: Data = 32'hd1000421;  // SUBI X1, X1, #1  (n -= 1)
            64'h014: Data = 32'h17fffffd;  // B    loop
            64'h018: Data = 32'hf80083e2;  // done: STUR X2, [XZR, #8]  (store sum)
            64'h01c: Data = 32'hf84083e3;  // LDUR X3, [XZR, #8]  (load it back)
            64'h020: Data = 32'h8a020064;  // AND  X4, X3, X2  (15 & 15 = 15)
            64'h024: Data = 32'haa010065;  // ORR  X5, X3, X1  (15 | 0 = 15)
            64'h028: Data = 32'hcb020066;  // SUB  X6, X3, X2  (15 - 15 = 0)
            64'h02c: Data = 32'h14000000;  // halt: B halt
            default: Data = 32'h14000000;  // B . (spin)
        endcase
    end
endmodule
