`timescale 1ns/1ps

module directed_tb;

    //==========================
    // DUT Inputs
    //==========================
    reg clk;
    reg areset;
    reg bump_left;
    reg bump_right;
    reg ground;
    reg dig;

    //==========================
    // DUT Outputs
    //==========================
    wire walk_left;
    wire walk_right;
    wire aaah;
    wire digging;
        lemmings_fsm dut(
        .clk(clk),
        .areset(areset),
        .bump_left(bump_left),
        .bump_right(bump_right),
        .ground(ground),
        .dig(dig),
        .walk_left(walk_left),
        .walk_right(walk_right),
        .aaah(aaah),
        .digging(digging)
    );
            // Verification Statistics
    integer tests_run    = 0;
    integer tests_passed = 0;
    integer tests_failed = 0;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        $dumpfile("sim/directed.vcd");
        $dumpvars(0, directed_tb);
    end
    // Generic Check Task
    task check;
        input condition;
        input [255:0] test_name;
        begin
            tests_run = tests_run + 1;

            if (condition) begin
                tests_passed = tests_passed + 1;
                $display("[PASS] %0s", test_name);
            end
            else begin
                tests_failed = tests_failed + 1;
                $display("[FAIL] %0s", test_name);
            end
        end
    endtask
    initial begin
        tests_run    = 0;
        tests_passed = 0;
        tests_failed = 0;
        $display("---------------------------");
        $display("Running Reset Test");
        $display("---------------------------");
        areset = 1;
        bump_left = 0;
        bump_right = 0;
        ground = 1;
        dig = 0;
        #20;
        areset = 0;
        #10;
        check(
            walk_left &&
            !walk_right &&
            !aaah &&
            !digging,
            "Reset Test");
        $display("\n====================================");
        $display("Verification Summary");
        $display("====================================");
        $display("Tests Run    : %0d", tests_run);
        $display("Passed       : %0d", tests_passed);
        $display("Failed       : %0d", tests_failed);
        if (tests_failed == 0)
        $display("RESULT       : PASS");
        else
        $display("RESULT       : FAIL");
        $display("====================================");
        $finish;
    end

endmodule