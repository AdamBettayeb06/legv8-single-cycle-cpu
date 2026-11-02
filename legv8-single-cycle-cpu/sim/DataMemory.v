`timescale 1ns / 1ps
// Stand-in data memory: 64-bit words, byte addressed, asynchronous read,
// write on the rising clock edge.
module DataMemory(
    output reg [63:0] ReadData,
    input      [63:0] Address,
    input      [63:0] WriteData,
    input             MemoryRead,
    input             MemoryWrite,
    input             Clock
);
    reg [63:0] mem [0:31];
    integer i;
    initial for (i = 0; i < 32; i = i + 1) mem[i] = 64'd0;

    always @(*) ReadData = MemoryRead ? mem[Address[7:3]] : 64'd0;

    always @(posedge Clock)
        if (MemoryWrite) mem[Address[7:3]] <= WriteData;
endmodule
