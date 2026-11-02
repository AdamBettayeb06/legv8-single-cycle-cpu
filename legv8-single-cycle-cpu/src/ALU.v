`timescale 1ns / 1ps
// Define the 4-bit ALU control values for each supported operation
`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

module ALU(
    output reg [63:0] BusW,    // 64-bit result from the ALU
    input      [63:0] BusA,    // First 64-bit input
    input      [63:0] BusB,    // Second 64-bit input
    input      [3:0]  ALUCtrl, // Selects which ALU operation to perform
    output            Zero     // Becomes 1 when BusW is equal to zero
);

    // Combinational ALU logic
    // Whenever an input changes, the ALU result is recalculated
    always @(*) begin

        // Select the operation based on the ALU control signal
        case (ALUCtrl)

            // Bitwise AND between BusA and BusB
            `AND:
                BusW = BusA & BusB;

            // Bitwise OR between BusA and BusB
            `OR:
                BusW = BusA | BusB;

            // Add BusA and BusB
            `ADD:
                BusW = BusA + BusB;

            // Subtract BusB from BusA
            `SUB:
                BusW = BusA - BusB;

            // Pass BusB directly to the output
            // This operation is used for CBZ
            `PassB:
                BusW = BusB;

            // Default value prevents an unintended latch
            // if ALUCtrl has an unsupported value
            default:
                BusW = 64'b0;

        endcase
    end

    // Zero flag:
    // Set to 1 whenever the entire 64-bit output is zero
    // Otherwise, set it to 0
    assign Zero = (BusW == 64'b0);

endmodule
