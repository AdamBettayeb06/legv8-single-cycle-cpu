`timescale 1ns / 1ps
// Testbench for the 64-bit ALU
module ALU_tb;

    // Inputs to the ALU
    reg  [63:0] BusA;
    reg  [63:0] BusB;
    reg  [3:0]  ALUCtrl;

    // Outputs from the ALU
    wire [63:0] BusW;
    wire        Zero;

    // Counters used by the testbench
    integer i;
    integer errors;
    integer tests;

    // Local ALU control values
    // These match the control encodings from the prelab
    localparam ALU_AND   = 4'b0000;
    localparam ALU_OR    = 4'b0001;
    localparam ALU_ADD   = 4'b0010;
    localparam ALU_SUB   = 4'b0110;
    localparam ALU_PASSB = 4'b0111;

    // Instantiate the ALU being tested
    ALU DUT (
        .BusW(BusW),
        .BusA(BusA),
        .BusB(BusB),
        .ALUCtrl(ALUCtrl),
        .Zero(Zero)
    );


    // -------------------------------------------------------------
    // run_test
    //
    // Applies one set of inputs to the ALU, calculates the expected
    // result independently, and checks both BusW and the Zero flag.
    // -------------------------------------------------------------
    task run_test;

        input [3:0]  ctrl;
        input [63:0] a;
        input [63:0] b;

        reg [63:0] expected;
        reg        expectedZero;

        begin

            // Apply the requested inputs to the ALU
            ALUCtrl = ctrl;
            BusA    = a;
            BusB    = b;

            // Calculate the expected result based on the operation
            case (ctrl)

                // Expected result for bitwise AND
                ALU_AND:
                    expected = a & b;

                // Expected result for bitwise OR
                ALU_OR:
                    expected = a | b;

                // Expected result for addition
                ALU_ADD:
                    expected = a + b;

                // Expected result for subtraction
                ALU_SUB:
                    expected = a - b;

                // Pass BusB directly to the output
                ALU_PASSB:
                    expected = b;

                // Should never occur in this testbench
                default:
                    expected = 64'b0;

            endcase

            // Determine what the Zero flag should be
            expectedZero = (expected == 64'b0);

            // Give the combinational ALU time to update
            #1;

            // Count this test
            tests = tests + 1;

            // Check both the ALU result and the Zero flag
            if ((BusW !== expected) || (Zero !== expectedZero)) begin

                // Print information about any failed test
                $display(
                    "ERROR: Ctrl=%b A=%h B=%h Expected=%h Got=%h ExpectedZero=%b GotZero=%b",
                    ctrl, a, b, expected, BusW, expectedZero, Zero
                );

                errors = errors + 1;
            end

        end
    endtask


    // -------------------------------------------------------------
    // test_extremes
    //
    // Tests every combination of all zeros and all ones:
    //
    // A = 0,       B = 0
    // A = 0,       B = all 1s
    // A = all 1s,  B = 0
    // A = all 1s,  B = all 1s
    //
    // This is called once for every ALU function.
    // -------------------------------------------------------------
    task test_extremes;

        input [3:0] ctrl;

        begin

            run_test(
                ctrl,
                64'h0000000000000000,
                64'h0000000000000000
            );

            run_test(
                ctrl,
                64'h0000000000000000,
                64'hFFFFFFFFFFFFFFFF
            );

            run_test(
                ctrl,
                64'hFFFFFFFFFFFFFFFF,
                64'h0000000000000000
            );

            run_test(
                ctrl,
                64'hFFFFFFFFFFFFFFFF,
                64'hFFFFFFFFFFFFFFFF
            );

        end
    endtask


    // -------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------
    initial begin

        // Create a waveform file that can be opened in GTKWave
        $dumpfile("ALU_tb.vcd");
        $dumpvars(0, ALU_tb);

        // Initialize counters
        errors = 0;
        tests  = 0;


        // =========================================================
        // AND TESTS
        // =========================================================

        // Test all four zero/one extreme combinations
        test_extremes(ALU_AND);

        // Perform 100 randomized AND tests
        for (i = 0; i < 100; i = i + 1) begin

            // Two $random calls are concatenated because
            // $random normally produces 32 random bits
            run_test(
                ALU_AND,
                {$random, $random},
                {$random, $random}
            );

        end


        // =========================================================
        // OR TESTS
        // =========================================================

        // Test all four zero/one extreme combinations
        test_extremes(ALU_OR);

        // Perform 100 randomized OR tests
        for (i = 0; i < 100; i = i + 1) begin

            run_test(
                ALU_OR,
                {$random, $random},
                {$random, $random}
            );

        end


        // =========================================================
        // ADD TESTS
        // =========================================================

        // Test all four zero/one extreme combinations
        test_extremes(ALU_ADD);

        // Perform 100 randomized ADD tests
        for (i = 0; i < 100; i = i + 1) begin

            run_test(
                ALU_ADD,
                {$random, $random},
                {$random, $random}
            );

        end

        // Explicit unsigned overflow test:
        // Maximum 64-bit value + 1 wraps around to zero
        run_test(
            ALU_ADD,
            64'hFFFFFFFFFFFFFFFF,
            64'h0000000000000001
        );

        // Explicit signed overflow test:
        // Largest positive signed 64-bit value + 1
        // produces 0x8000000000000000
        run_test(
            ALU_ADD,
            64'h7FFFFFFFFFFFFFFF,
            64'h0000000000000001
        );


        // =========================================================
        // SUB TESTS
        // =========================================================

        // Test all four zero/one extreme combinations
        test_extremes(ALU_SUB);

        // Perform 100 randomized SUB tests
        for (i = 0; i < 100; i = i + 1) begin

            run_test(
                ALU_SUB,
                {$random, $random},
                {$random, $random}
            );

        end


        // =========================================================
        // PassB TESTS
        // =========================================================

        // Test all four zero/one extreme combinations
        test_extremes(ALU_PASSB);

        // Perform 100 randomized PassB tests
        for (i = 0; i < 100; i = i + 1) begin

            run_test(
                ALU_PASSB,
                {$random, $random},
                {$random, $random}
            );

        end


        // =========================================================
        // Final testbench result
        // =========================================================

        if (errors == 0)
            $display(
                "ALL ALU TESTS PASSED: %0d tests completed",
                tests
            );
        else
            $display(
                "ALU TESTS FAILED: %0d errors in %0d tests",
                errors,
                tests
            );

        // End simulation
        $finish;

    end

endmodule
