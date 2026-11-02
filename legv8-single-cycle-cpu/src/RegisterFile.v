`timescale 1ns / 1ps
module RegisterFile(
    output wire [63:0] BusA,
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA,
    input  wire [4:0]  RB,
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);

    // 32 registers, each 64 bits wide
    reg [63:0] registers [0:31];

    // Temporary values for the two read ports
    reg [63:0] BusA_internal;
    reg [63:0] BusB_internal;

    // Combinational reads
    always @(*) begin
        if (RA == 5'd31)
            BusA_internal = 64'd0;
        else
            BusA_internal = registers[RA];

        if (RB == 5'd31)
            BusB_internal = 64'd0;
        else
            BusB_internal = registers[RB];
    end

    // Required output delay
    assign #3 BusA = BusA_internal;
    assign #3 BusB = BusB_internal;

    // Sequential write
    always @(posedge Clk) begin
        if (RegWr && (RW != 5'd31))
            registers[RW] <= BusW;
    end

endmodule
