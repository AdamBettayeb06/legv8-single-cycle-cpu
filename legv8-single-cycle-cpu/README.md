# Single-cycle LEGv8 processor in Verilog

A 64-bit single-cycle processor for LEGv8, the teaching subset of ARMv8 from Patterson and Hennessy, which I built over several labs in ECEN 350 (Computer Architecture, Texas A&M, fall 2026). Every instruction finishes in one clock cycle: fetch, decode, register read, ALU, memory access, and write-back all happen between two clock edges.

## The datapath

Each lab added one piece, and the last one wired them together. [docs/datapath.html](docs/datapath.html) is a diagram of how they connect (download it and open it in a browser).

| Module | What it does |
|---|---|
| `RegisterFile.v` | 32 64-bit registers with two read ports and one write port. Register 31 always reads as zero (XZR) and ignores writes. |
| `ALU.v` | 64-bit AND, OR, add, subtract, and pass-B, plus the Zero flag that CBZ uses. |
| `SignExtender.v` | Pulls the immediate out of I, D, CB, and B format instructions and sign or zero extends it to 64 bits. Branch offsets get shifted left 2, since instructions are 4 bytes apart. |
| `NextPClogic.v` | Picks PC + 4, or PC + offset when a branch is taken (B always, CBZ when the register is zero). |
| `SC_Control.v` | Decodes the 11-bit opcode into the datapath control signals (Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, UncondBranch, ALUOp, SignOp). |
| `SingleCycleProc.v` | The top level: program counter, instruction field decoding, and the muxes that connect everything. |

Supported instructions: ADD, SUB, AND, ORR (register), ADDI, SUBI, LDUR, STUR, CBZ, and B. That's enough to write loops, branches, and memory access.

## Testing

Each module in `src/` has a testbench in `tb/`. The ALU testbench runs 522 cases and the next-PC testbench runs 80. All of them pass.

To test the whole processor, I hand-assembled a short program into `sim/InstructionMemory.v`. It sums 1 through 5 in a loop, stores the result to memory, loads it back, and then runs AND, ORR, and SUB on it. `sim/SingleCycleProc_tb.v` runs it and checks the final registers and memory. The PC jumps back to the top of the loop five times while the counter in X1 counts down and the sum in X2 builds to 15, then it runs straight through to the halt in 29 cycles.

```
iverilog -g2012 -o cpu src/*.v sim/*.v
vvp cpu
```

```
reached halt at PC 0x2c after 29 cycles
ok   X2 (sum) = 15
ok   X1 (counter) = 0
ok   mem[8] = 15
...
PROCESSOR TEST PASSED
```

## Assembly

Before building the hardware, I wrote ARMv8 assembly and debugged it in gdb. `assembly/power.S` is a recursive power function that sets up its own stack frame, saves the return address and a callee-saved register, and calls itself and a multiply routine. On an ARM64 machine:

```
cd assembly && make && ./power_test
power(2, 10) = 1024
power(3, 4) = 81
power(5, 0) = 1
power(7, 3) = 343
```
