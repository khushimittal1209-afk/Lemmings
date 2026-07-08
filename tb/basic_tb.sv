`timescale 1ns/1ps

module tb_lemmings;

    // DUT Inputs
    reg clk;
    reg areset;
    reg bump_left;
    reg bump_right;
    reg ground;
    reg dig;

    // DUT Outputs
    wire walk_left;
    wire walk_right;
    wire aaah;
    wire digging;

    //==================================================
    // DUT
    //==================================================
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

    //==================================================
    // Clock Generation (100 MHz)
    //==================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //==================================================
    // Waveform Dump
    //==================================================
    initial begin
        $dumpfile("sim/wave.vcd");
        $dumpvars(0, tb_lemmings);
    end

    //==================================================
    // Test Sequence
    //==================================================
    initial begin

        // Initialize
        areset      = 1;
        bump_left   = 0;
        bump_right  = 0;
        ground      = 1;
        dig         = 0;

        #20;
        areset = 0;

        // Walk Left
        #20;

        // Hit left wall -> Walk Right
        bump_left = 1;
        #10;
        bump_left = 0;

        #20;

        // Fall
        ground = 0;
        #100;

        // Land safely
        ground = 1;
        #20;

        // Dig
        dig = 1;
        #20;
        dig = 0;

        #40;

        $finish;

    end

endmodule