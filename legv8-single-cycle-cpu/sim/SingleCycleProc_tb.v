`timescale 1ns / 1ps
// Runs the test program in InstructionMemory.v and checks the final
// register and memory contents.
module SingleCycleProc_tb;
    reg         CLK = 0, reset = 1;
    reg  [63:0] startpc = 64'd0;
    wire [63:0] currentpc, MemtoRegOut;
    integer errors = 0, cycles = 0;

    SingleCycleProc dut(.reset(reset), .startpc(startpc), .currentpc(currentpc),
                        .MemtoRegOut(MemtoRegOut), .CLK(CLK));

    always #10 CLK = ~CLK;

    task check(input [255:0] name, input [63:0] got, input [63:0] want);
        if (got !== want) begin
            $display("FAIL %0s: got %0d, expected %0d", name, got, want);
            errors = errors + 1;
        end else
            $display("ok   %0s = %0d", name, got);
    endtask

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, SingleCycleProc_tb);
        @(posedge CLK); @(posedge CLK); #1 reset = 0;
        while (currentpc !== 64'h2c && cycles < 200) begin
            @(posedge CLK); cycles = cycles + 1;
        end
        #5;
        $display("reached halt at PC 0x%0h after %0d cycles", currentpc, cycles);
        check("X2 (sum)",       dut.register_file.registers[2], 15);
        check("X1 (counter)",   dut.register_file.registers[1], 0);
        check("mem[8]",         dut.data_memory.mem[1], 15);
        check("X3 (LDUR)",      dut.register_file.registers[3], 15);
        check("X4 (AND)",       dut.register_file.registers[4], 15);
        check("X5 (ORR)",       dut.register_file.registers[5], 15);
        check("X6 (SUB)",       dut.register_file.registers[6], 0);
        if (errors == 0) $display("PROCESSOR TEST PASSED");
        else             $display("PROCESSOR TEST FAILED: %0d errors", errors);
        $finish;
    end
endmodule
