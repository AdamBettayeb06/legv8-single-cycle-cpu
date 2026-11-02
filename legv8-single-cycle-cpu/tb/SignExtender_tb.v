`timescale 1ns / 1ps
// Testbench for the SignExtender module
module SignExtender_tb;

    // Inputs to the SignExtender
    reg  [25:0] Instruction;
    reg  [1:0]  SignOp;

    // Output from the SignExtender
    wire [63:0] SignExOut;

    // Expected output calculated by the testbench
    reg  [63:0] Expected;

    // Loop counter and error counter
    integer i;
    integer errors;

    // Instantiate the SignExtender being tested
    SignExtender DUT (
        .SignExOut(SignExOut),
        .Instruction(Instruction),
        .SignOp(SignOp)
    );

    initial begin

        // Create a VCD waveform file for GTKWave
        $dumpfile("SignExtender_tb.vcd");
        $dumpvars(0, SignExtender_tb);

        // Start with zero errors
        errors = 0;

        // ---------------------------------------------------------
        // Test I-Type: SignOp = 00
        // I-Type uses Instruction[21:10] and zero-extends it
        // ---------------------------------------------------------
        SignOp = 2'b00;

        for (i = 0; i < 100; i = i + 1) begin

            // Generate a random 26-bit instruction value
            Instruction = $random;

            // Calculate what the correct output should be
            Expected = {52'b0, Instruction[21:10]};

            // Allow combinational logic to update
            #1;

            // Compare actual output against expected output
            if (SignExOut !== Expected) begin
                $display(
                    "ERROR I-Type: Instruction=%h Expected=%h Got=%h",
                    Instruction, Expected, SignExOut
                );
                errors = errors + 1;
            end
        end


        // ---------------------------------------------------------
        // Test D-Type: SignOp = 01
        // D-Type uses Instruction[20:12] and sign-extends it
        // ---------------------------------------------------------
        SignOp = 2'b01;

        for (i = 0; i < 100; i = i + 1) begin

            // Generate a random 26-bit instruction value
            Instruction = $random;

            // Sign-extend the 9-bit immediate to 64 bits
            Expected = {
                {55{Instruction[20]}},
                Instruction[20:12]
            };

            // Allow combinational logic to update
            #1;

            // Compare actual output against expected output
            if (SignExOut !== Expected) begin
                $display(
                    "ERROR D-Type: Instruction=%h Expected=%h Got=%h",
                    Instruction, Expected, SignExOut
                );
                errors = errors + 1;
            end
        end


        // ---------------------------------------------------------
        // Test CB-Type: SignOp = 10
        // CB-Type uses Instruction[23:5], sign-extends it,
        // and shifts the result left by 2 bits
        // ---------------------------------------------------------
        SignOp = 2'b10;

        for (i = 0; i < 100; i = i + 1) begin

            // Generate a random 26-bit instruction value
            Instruction = $random;

            // Sign-extend the 19-bit immediate and append two zeros
            Expected = {
                {43{Instruction[23]}},
                Instruction[23:5],
                2'b00
            };

            // Allow combinational logic to update
            #1;

            // Compare actual output against expected output
            if (SignExOut !== Expected) begin
                $display(
                    "ERROR CB-Type: Instruction=%h Expected=%h Got=%h",
                    Instruction, Expected, SignExOut
                );
                errors = errors + 1;
            end
        end


        // ---------------------------------------------------------
        // Test B-Type: SignOp = 11
        // B-Type uses Instruction[25:0], sign-extends it,
        // and shifts the result left by 2 bits
        // ---------------------------------------------------------
        SignOp = 2'b11;

        for (i = 0; i < 100; i = i + 1) begin

            // Generate a random 26-bit instruction value
            Instruction = $random;

            // Sign-extend the 26-bit immediate and append two zeros
            Expected = {
                {36{Instruction[25]}},
                Instruction[25:0],
                2'b00
            };

            // Allow combinational logic to update
            #1;

            // Compare actual output against expected output
            if (SignExOut !== Expected) begin
                $display(
                    "ERROR B-Type: Instruction=%h Expected=%h Got=%h",
                    Instruction, Expected, SignExOut
                );
                errors = errors + 1;
            end
        end


        // ---------------------------------------------------------
        // Print the overall result after all 400 tests
        // ---------------------------------------------------------
        if (errors == 0)
            $display("ALL SIGN EXTENDER TESTS PASSED");
        else
            $display("SIGN EXTENDER TESTS FAILED: %0d errors", errors);

        // End the simulation
        $finish;

    end

endmodule
