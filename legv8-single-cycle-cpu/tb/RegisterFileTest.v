`timescale 1ns / 1ps
module RegisterFileTest();

    wire [63:0] BusA;
    wire [63:0] BusB;

    reg  [63:0] BusW;
    reg  [4:0]  RA;
    reg  [4:0]  RB;
    reg  [4:0]  RW;
    reg         RegWr;
    reg         Clk;

    reg [63:0] expected [0:31];
    reg [63:0] random_value;

    integer i;
    integer errors;

    RegisterFile DUT (
        .BusA(BusA),
        .BusB(BusB),
        .BusW(BusW),
        .RA(RA),
        .RB(RB),
        .RW(RW),
        .RegWr(RegWr),
        .Clk(Clk)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #5 Clk = ~Clk;
    end

    // VCD file
    initial begin
        $dumpfile("RegisterFileTest.vcd");
        $dumpvars(0, RegisterFileTest);
    end

    // Testing
    initial begin

        errors = 0;
        RegWr = 0;
        RA = 0;
        RB = 0;
        RW = 0;
        BusW = 0;

        // ------------------------------------------------
        // TEST 1: Write enabled
        // ------------------------------------------------
        for (i = 0; i < 31; i = i + 1) begin

            random_value = {$random, $random};

            @(negedge Clk);

            RW = i;
            BusW = random_value;
            RegWr = 1;

            // Save what SHOULD be in the register
            expected[i] = random_value;

            @(posedge Clk);
            #1;

            RA = i;
            RB = i;

            // RegisterFile has #3 output delay
            #4;

            $display(
                "WRITE ON: Reg=%0d Written=%h BusA=%h BusB=%h",
                i, expected[i], BusA, BusB
            );

            if ((BusA !== expected[i]) ||
                (BusB !== expected[i])) begin

                $display("ERROR at register %0d", i);
                errors = errors + 1;
            end
        end


        // ------------------------------------------------
        // TEST 2: Write disabled
        // ------------------------------------------------
        for (i = 0; i < 31; i = i + 1) begin

            random_value = {$random, $random};

            @(negedge Clk);

            RW = i;
            BusW = random_value;
            RegWr = 0;

            @(posedge Clk);
            #1;

            RA = i;
            RB = i;

            #4;

            $display(
                "WRITE OFF: Reg=%0d Attempted=%h Expected=%h BusA=%h BusB=%h",
                i, random_value, expected[i], BusA, BusB
            );

            if ((BusA !== expected[i]) ||
                (BusB !== expected[i])) begin

                $display("ERROR: register changed while RegWr=0");
                errors = errors + 1;
            end
        end


        // ------------------------------------------------
        // TEST 3: Register 31 / XZR
        // ------------------------------------------------
        @(negedge Clk);

        RW = 5'd31;
        BusW = 64'hDEADBEEFDEADBEEF;
        RegWr = 1;

        @(posedge Clk);
        #1;

        RA = 5'd31;
        RB = 5'd31;

        #4;

        $display(
            "XZR TEST: BusA=%h BusB=%h",
            BusA, BusB
        );

        if ((BusA !== 64'd0) ||
            (BusB !== 64'd0)) begin

            $display("ERROR: XZR did not return zero");
            errors = errors + 1;
        end


        // ------------------------------------------------
        // Final result
        // ------------------------------------------------
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTING COMPLETE: %0d errors", errors);

        $finish;

    end

endmodule
