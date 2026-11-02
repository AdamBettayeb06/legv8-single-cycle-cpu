`timescale 1ns / 1ps
module SC_Control_tb;

    reg [10:0] opcode;

    wire Reg2Loc;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire Branch;
    wire Uncondbranch;
    wire [3:0] ALUOp;
    wire [1:0] SignOp;

    integer test_count;
    integer error_count;
    integer invalid_count;
    integer seed;
    integer i;

    reg [10:0] random_opcode;

    // Instantiate control unit
    SC_Control dut (
        .Reg2Loc(Reg2Loc),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .Uncondbranch(Uncondbranch),
        .ALUOp(ALUOp),
        .SignOp(SignOp),
        .opcode(opcode)
    );

    // Expected output order:
    // Reg2Loc, ALUSrc, MemtoReg, RegWrite,
    // MemRead, MemWrite, Branch, Uncondbranch,
    // ALUOp[3:0], SignOp[1:0]

    localparam [13:0] E_LDUR =
        {1'bx,1'b1,1'b1,1'b1,1'b1,1'b0,1'b0,1'b0,4'b0010,2'b01};

    localparam [13:0] E_STUR =
        {1'b1,1'b1,1'bx,1'b0,1'b0,1'b1,1'b0,1'b0,4'b0010,2'b01};

    localparam [13:0] E_ADDREG =
        {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0010,2'bxx};

    localparam [13:0] E_SUBREG =
        {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0110,2'bxx};

    localparam [13:0] E_ANDREG =
        {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0000,2'bxx};

    localparam [13:0] E_ORRREG =
        {1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0001,2'bxx};

    localparam [13:0] E_ADDIMM =
        {1'bx,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0010,2'b00};

    localparam [13:0] E_SUBIMM =
        {1'bx,1'b1,1'b0,1'b1,1'b0,1'b0,1'b0,1'b0,4'b0110,2'b00};

    localparam [13:0] E_CBZ =
        {1'b1,1'b0,1'bx,1'b0,1'b0,1'b0,1'b1,1'b0,4'b0111,2'b10};

    localparam [13:0] E_B =
        {1'bx,1'bx,1'bx,1'b0,1'b0,1'b0,1'bx,1'b1,4'bxxxx,2'b11};

    // Compare outputs, ignoring don't-care bits
    function matches_expected;
        input [13:0] actual;
        input [13:0] expected;
        integer bit_index;

        begin
            matches_expected = 1'b1;

            for (bit_index = 0; bit_index < 14;
                 bit_index = bit_index + 1) begin

                if ((expected[bit_index] !== 1'bx) &&
                    (actual[bit_index] !== expected[bit_index]))
                    matches_expected = 1'b0;
            end
        end
    endfunction

    // Check whether opcode is supported
    function is_supported;
        input [10:0] code;

        begin
            casez (code)
                11'b10001010000,
                11'b10101010000,
                11'b10001011000,
                11'b11001011000,
                11'b1001000100?,
                11'b1101000100?,
                11'b000101?????,
                11'b10110100???,
                11'b11111000010,
                11'b11111000000:
                    is_supported = 1'b1;

                default:
                    is_supported = 1'b0;
            endcase
        end
    endfunction

    // Self-checking test task
    task check;
        input [10:0] test_opcode;
        input [13:0] expected;

        reg [13:0] actual;

        begin
            opcode = test_opcode;
            #2;

            actual = {
                Reg2Loc,
                ALUSrc,
                MemtoReg,
                RegWrite,
                MemRead,
                MemWrite,
                Branch,
                Uncondbranch,
                ALUOp,
                SignOp
            };

            test_count = test_count + 1;

            if (!matches_expected(actual, expected)) begin
                $display("ERROR: opcode=%b expected=%b actual=%b",
                         test_opcode, expected, actual);
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        test_count = 0;
        error_count = 0;
        invalid_count = 0;
        seed = 12345;
        opcode = 11'b0;

        // Generate waveform file
        $dumpfile("SC_Control_tb.vcd");
        $dumpvars(0, SC_Control_tb);

        $display("Starting SC_Control tests...");

        // Fixed instruction opcodes
        check(11'b11111000010, E_LDUR);
        check(11'b11111000000, E_STUR);
        check(11'b10001011000, E_ADDREG);
        check(11'b11001011000, E_SUBREG);
        check(11'b10001010000, E_ANDREG);
        check(11'b10101010000, E_ORRREG);

        // ADD immediate: 2 variants
        for (i = 0; i < 2; i = i + 1)
            check({10'b1001000100, i[0]}, E_ADDIMM);

        // SUB immediate: 2 variants
        for (i = 0; i < 2; i = i + 1)
            check({10'b1101000100, i[0]}, E_SUBIMM);

        // CBZ: 8 variants
        for (i = 0; i < 8; i = i + 1)
            check({8'b10110100, i[2:0]}, E_CBZ);

        // B: 32 variants
        for (i = 0; i < 32; i = i + 1)
            check({6'b000101, i[4:0]}, E_B);

        // 10 randomly generated unsupported opcodes
        while (invalid_count < 10) begin
            random_opcode = $random(seed);

            if (!is_supported(random_opcode)) begin
                check(random_opcode, 14'b00000000000000);
                invalid_count = invalid_count + 1;
            end
        end

        $display("================================");
        $display("Total tests: %0d", test_count);
        $display("Errors: %0d", error_count);

        if (error_count == 0)
            $display("PASS: All tests passed!");
        else
            $display("FAIL: Some tests failed.");

        $display("================================");

        $finish;
    end

endmodule
