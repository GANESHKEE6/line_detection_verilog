`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 05:06:28 PM
// Design Name: 
// Module Name: line_classifier_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module line_classifier_tb();

    reg  [8:0] line_x;
    reg        line_valid;
    wire [1:0] direction;

    // Symbolic states for readability in testbench checks
    localparam [1:0] LEFT    = 2'b00,
                     CENTER  = 2'b01,
                     RIGHT   = 2'b10,
                     NO_LINE = 2'b11;

    integer pass_count;
    integer total_cases;

    // Instantiate DUT
    line_classifier #(
        .WIDTH(320)
    ) u_classifier (
        .line_x(line_x),
        .line_valid(line_valid),
        .direction(direction)
    );

    initial begin
        pass_count = 0;
        total_cases = 10;

        $display("==================================================");
        $display("STEP 9 LINE CLASSIFIER VERIFICATION");
        $display("==================================================");

        // CASE 1
        line_valid = 1; line_x = 0; #10;
        $display("CASE 1: line_x=0, valid=1 -> Got=%0d, Exp=0 (LEFT)", direction);
        if (direction == LEFT) pass_count = pass_count + 1;

        // CASE 2
        line_valid = 1; line_x = 50; #10;
        $display("CASE 2: line_x=50, valid=1 -> Got=%0d, Exp=0 (LEFT)", direction);
        if (direction == LEFT) pass_count = pass_count + 1;

        // CASE 3
        line_valid = 1; line_x = 106; #10;
        $display("CASE 3: line_x=106, valid=1 -> Got=%0d, Exp=0 (LEFT)", direction);
        if (direction == LEFT) pass_count = pass_count + 1;

        // CASE 4
        line_valid = 1; line_x = 107; #10;
        $display("CASE 4: line_x=107, valid=1 -> Got=%0d, Exp=1 (CENTER)", direction);
        if (direction == CENTER) pass_count = pass_count + 1;

        // CASE 5
        line_valid = 1; line_x = 160; #10;
        $display("CASE 5: line_x=160, valid=1 -> Got=%0d, Exp=1 (CENTER)", direction);
        if (direction == CENTER) pass_count = pass_count + 1;

        // CASE 6
        line_valid = 1; line_x = 212; #10;
        $display("CASE 6: line_x=212, valid=1 -> Got=%0d, Exp=1 (CENTER)", direction);
        if (direction == CENTER) pass_count = pass_count + 1;

        // CASE 7
        line_valid = 1; line_x = 213; #10;
        $display("CASE 7: line_x=213, valid=1 -> Got=%0d, Exp=2 (RIGHT)", direction);
        if (direction == RIGHT) pass_count = pass_count + 1;

        // CASE 8
        line_valid = 1; line_x = 319; #10;
        $display("CASE 8: line_x=319, valid=1 -> Got=%0d, Exp=2 (RIGHT)", direction);
        if (direction == RIGHT) pass_count = pass_count + 1;

        // CASE 9
        line_valid = 0; line_x = 0; #10;
        $display("CASE 9: line_x=0, valid=0 -> Got=%0d, Exp=3 (NO_LINE)", direction);
        if (direction == NO_LINE) pass_count = pass_count + 1;

        // CASE 10
        line_valid = 0; line_x = 160; #10;
        $display("CASE 10: line_x=160, valid=0 -> Got=%0d, Exp=3 (NO_LINE)", direction);
        if (direction == NO_LINE) pass_count = pass_count + 1;

        $display("\n==================================================");
        if (pass_count == total_cases) 
            $display("Overall result: PASS (%0d/%0d)", pass_count, total_cases);
        else 
            $display("Overall result: FAIL (%0d/%0d)", pass_count, total_cases);
        $display("==================================================");

        $stop;
    end

endmodule