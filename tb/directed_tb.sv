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
    //==================================================
// Stimulus Tasks
//==================================================

// Reset DUT
task reset_dut;
begin
    areset     = 1;
    bump_left  = 0;
    bump_right = 0;
    ground     = 1;
    dig        = 0;

    #20;
    areset = 0;
    #10;
end
endtask

// Hit left wall
task hit_left_wall;
begin
    bump_left = 1;
    #10;
    bump_left = 0;
    #10;
end
endtask

// Hit right wall
task hit_right_wall;
begin
    bump_right = 1;
    #10;
    bump_right = 0;
    #10;
end
endtask
//--------------------------------------------------
// Safe Fall (<20 cycles)
//--------------------------------------------------
task safe_fall;
    input integer cycles;
    integer i;
begin

    ground = 0;

    for(i=0; i<cycles; i=i+1)
        #10;

    ground = 1;

    #10;

end
endtask
//--------------------------------------------------
// Fatal Fall (>=20 cycles)
//--------------------------------------------------
task fatal_fall;
    input integer cycles;
    integer i;
begin

    ground = 0;

    for(i=0; i<cycles; i=i+1)
        #10;

    ground = 1;

    #10;

end
endtask
//--------------------------------------------------
// Dig Left
//--------------------------------------------------
task dig_left;
begin
    dig = 1;
    #10;
    dig = 0;
    #10;
end
endtask

//--------------------------------------------------
// Dig Right
//--------------------------------------------------
task dig_right;
begin
    hit_left_wall();   // Move to RIGHT
    dig = 1;
    #10;
    dig = 0;
    #10;
end
endtask
//--------------------------------------------------
// Dig Left -> Fall
//--------------------------------------------------
task dig_to_fall_left;
begin
    dig = 1;
    #10;
    dig = 0;

    // Ground disappears
    ground = 0;

    #10;
end
endtask
    initial begin
        tests_run    = 0;
        tests_passed = 0;
        tests_failed = 0;
        $display("---------------------------");
        $display("Running Reset Test");
        $display("---------------------------");
        reset_dut();
        check(
            walk_left &&
            !walk_right &&
            !aaah &&
            !digging,
            "Reset Test");
            //--------------------------------------------------
// Test 2 : Left Wall Collision
//--------------------------------------------------

$display("---------------------------");
$display("Running Left Wall Test");
$display("---------------------------");

reset_dut();

hit_left_wall();

check(
    walk_right &&
    !walk_left &&
    !aaah &&
    !digging,
    "Left Wall Test"
);
//--------------------------------------------------
// Test 3 : Right Wall Collision
//--------------------------------------------------

$display("---------------------------");
$display("Running Right Wall Test");
$display("---------------------------");

reset_dut();

// First make the lemming walk right
hit_left_wall();

// Now hit the right wall
hit_right_wall();

check(
    walk_left &&
    !walk_right &&
    !aaah &&
    !digging,
    "Right Wall Test"
);
//--------------------------------------------------
// Test 4 : Safe Fall
//--------------------------------------------------

$display("---------------------------");
$display("Running Safe Fall Test");
$display("---------------------------");

reset_dut();

safe_fall(19);

check(
    walk_left &&
    !walk_right &&
    !aaah &&
    !digging,
    "Safe Fall Test"
);
//--------------------------------------------------
// Test 5 : Fatal Fall
//--------------------------------------------------

$display("---------------------------");
$display("Running Fatal Fall Test");
$display("---------------------------");

reset_dut();

fatal_fall(20);

$display("state      = %0d", dut.state);
$display("count      = %0d", dut.count);
$display("walk_left  = %b", walk_left);
$display("walk_right = %b", walk_right);
$display("aaah       = %b", aaah);
$display("digging    = %b", digging);

check(
    !walk_left &&
    !walk_right &&
    !aaah &&
    !digging,
    "Fatal Fall Test"
);
//--------------------------------------------------
// Test 6 : Dig Left
//--------------------------------------------------

$display("---------------------------");
$display("Running Dig Left Test");
$display("---------------------------");

reset_dut();

dig_left();

check(
    digging &&
    !walk_left &&
    !walk_right &&
    !aaah,
    "Dig Left Test"
);
//--------------------------------------------------
// Test 7 : Dig Right
//--------------------------------------------------

$display("---------------------------");
$display("Running Dig Right Test");
$display("---------------------------");

reset_dut();

dig_right();

check(
    digging &&
    !walk_left &&
    !walk_right &&
    !aaah,
    "Dig Right Test"
);
//--------------------------------------------------
// Test 8 : Dig -> Fall
//--------------------------------------------------

$display("---------------------------");
$display("Running Dig To Fall Test");
$display("---------------------------");

reset_dut();

dig_to_fall_left();

check(
    aaah &&
    !walk_left &&
    !walk_right &&
    !digging,
    "Dig To Fall Test"
);
//--------------------------------------------------
// Test 9 : Permanent SPLAT
//--------------------------------------------------

$display("---------------------------");
$display("Running Permanent SPLAT Test");
$display("---------------------------");

reset_dut();

fatal_fall(20);

// Try to change everything
ground = 1;
dig = 1;
bump_left = 1;
bump_right = 1;

#20;

check(
    !walk_left &&
    !walk_right &&
    !aaah &&
    !digging,
    "Permanent SPLAT Test"
);
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