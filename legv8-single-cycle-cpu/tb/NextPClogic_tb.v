`timescale 1ns / 1ps
// Testbench for the NextPClogic module
module NextPClogic_tb;

    // Inputs to the NextPC module
    reg [63:0] CurrentPC;
    reg [63:0] SignExtImm64;
    reg        Branch;
    reg        ALUZero;
    reg        Uncondbranch;

    // Output from the NextPC module
    wire [63:0] NextPC;

    // Counters for the testbench
    integer i;
    integer b;
    integer u;
    integer z;
    integer errors;
    integer tests;


    // Instantiate the NextPC module being tested
    NextPClogic DUT (
        .NextPC(NextPC),
        .CurrentPC(CurrentPC),
        .SignExtImm64(SignExtImm64),
        .Branch(Branch),
        .ALUZero(ALUZero),
        .Uncondbranch(Uncondbranch)
    );


    // -------------------------------------------------------------
    // run_test
    //
    // Applies one set of inputs, calculates the expected NextPC,
    // and compares the expected result with the actual output.
    // -------------------------------------------------------------
    task run_test;

        input        testBranch;
        input        testUncondbranch;
        input        testALUZero;
        input [63:0] testPC;
        input [63:0] testImm;

        reg [63:0] expectedNextPC;

        begin

            // Apply the inputs to the module
            Branch       = testBranch;
            Uncondbranch = testUncondbranch;
            ALUZero      = testALUZero;
            CurrentPC    = testPC;
            SignExtImm64 = testImm;

            // Determine what the correct NextPC should be.
            //
            // Take the branch if:
            // 1. It is an unconditional branch, OR
            // 2. It is a conditional branch and ALUZero is 1.
            if (testUncondbranch ||
                (testBranch && testALUZero)) begin

                // Branch is taken
                expectedNextPC = testPC + testImm;

            end
            else begin

                // Branch is not taken, so move to the next
                // 32-bit ARMv8 instruction
                expectedNextPC = testPC + 64'd4;

            end

            // Allow the combinational logic to update
            #1;

            // Count the test
            tests = tests + 1;

            // Compare the actual output against the expected output
            if (NextPC !== expectedNextPC) begin

                // Print information about any failed test
                $display(
                    "ERROR: Branch=%b Uncond=%b Zero=%b PC=%h Imm=%h Expected=%h Got=%h",
                    testBranch,
                    testUncondbranch,
                    testALUZero,
                    testPC,
                    testImm,
                    expectedNextPC,
                    NextPC
                );

                errors = errors + 1;

            end

        end
    endtask


    // -------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------
    initial begin

        // Create a waveform file for examination in GTKWave
        $dumpfile("NextPClogic_tb.vcd");
        $dumpvars(0, NextPClogic_tb);

        // Initialize counters
        errors = 0;
        tests  = 0;


        // ---------------------------------------------------------
        // Test all 8 possible combinations of the three
        // control inputs:
        //
        // Branch, Uncondbranch, ALUZero
        //
        // Each combination receives 10 random data tests.
        // ---------------------------------------------------------
        for (b = 0; b < 2; b = b + 1) begin

            for (u = 0; u < 2; u = u + 1) begin

                for (z = 0; z < 2; z = z + 1) begin

                    // Run 10 randomized CurrentPC and
                    // SignExtImm64 values for this control combination
                    for (i = 0; i < 10; i = i + 1) begin

                        // Two $random calls are concatenated to
                        // create a full 64-bit random value
                        run_test(
                            b,
                            u,
                            z,
                            {$random, $random},
                            {$random, $random}
                        );

                    end
                end
            end
        end


        // ---------------------------------------------------------
        // Print the final result
        // ---------------------------------------------------------
        if (errors == 0)
            $display(
                "ALL NEXTPC TESTS PASSED: %0d tests completed",
                tests
            );
        else
            $display(
                "NEXTPC TESTS FAILED: %0d errors in %0d tests",
                errors,
                tests
            );

        // End the simulation
        $finish;

    end

endmodule
