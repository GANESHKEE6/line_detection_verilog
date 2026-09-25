`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:58:30 PM
// Design Name: 
// Module Name: centroid_divider_tb
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

module centroid_divider_tb();

    reg         clk;
    reg         reset;
    reg         start;
    reg  [23:0] sum_x;
    reg  [15:0] pixel_count;
    
    wire [8:0]  line_x;
    wire        result_valid;
    wire        divide_by_zero;

    integer     pass_count;

    // Instantiate DUT
    centroid_divider u_divider (
        .clk(clk),
        .reset(reset),
        .start(start),
        .sum_x(sum_x),
        .pixel_count(pixel_count),
        .line_x(line_x),
        .result_valid(result_valid),
        .divide_by_zero(divide_by_zero)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        reset = 1;
        start = 0;
        sum_x = 0;
        pixel_count = 0;
        pass_count = 0;

        #25;
        @(negedge clk);
        reset = 0;

        $display("==================================================");
        $display("STEP 8 CENTROID DIVIDER VERIFICATION");
        $display("==================================================");

        // CASE 1: Standard calculation
        @(negedge clk);
        sum_x = 188453; pixel_count = 1143; start = 1;
        @(negedge clk); start = 0;
        wait(result_valid);
        $display("CASE 1");
        $display("sum_x = %0d\npixel_count = %0d\nRTL line_x = %0d\nExpected = 164", sum_x, pixel_count, line_x);
        if (line_x == 164 && divide_by_zero == 0) begin $display("PASS\n"); pass_count = pass_count + 1; end
        else $display("FAIL\n");

        // CASE 2: sum_x is 0
        @(negedge clk);
        sum_x = 0; pixel_count = 100; start = 1;
        @(negedge clk); start = 0;
        wait(result_valid);
        $display("CASE 2");
        $display("sum_x = %0d\npixel_count = %0d\nRTL line_x = %0d\nExpected = 0", sum_x, pixel_count, line_x);
        if (line_x == 0 && divide_by_zero == 0) begin $display("PASS\n"); pass_count = pass_count + 1; end
        else $display("FAIL\n");

        // CASE 3: Maximum line_x
        @(negedge clk);
        sum_x = 31900; pixel_count = 100; start = 1;
        @(negedge clk); start = 0;
        wait(result_valid);
        $display("CASE 3");
        $display("sum_x = %0d\npixel_count = %0d\nRTL line_x = %0d\nExpected = 319", sum_x, pixel_count, line_x);
        if (line_x == 319 && divide_by_zero == 0) begin $display("PASS\n"); pass_count = pass_count + 1; end
        else $display("FAIL\n");

        // CASE 4: Divide by Zero
        @(negedge clk);
        sum_x = 100; pixel_count = 0; start = 1;
        @(negedge clk); start = 0;
        wait(result_valid);
        $display("CASE 4");
        $display("sum_x = %0d\npixel_count = %0d\nRTL line_x = %0d\nExpected = 0 (div-by-zero flag)", sum_x, pixel_count, line_x);
        if (line_x == 0 && divide_by_zero == 1) begin $display("PASS\n"); pass_count = pass_count + 1; end
        else $display("FAIL\n");

        if (pass_count == 4) $display("Overall result:\nPASS");
        else $display("Overall result:\nFAIL");
        
        $display("==================================================");
        $stop;
    end

endmodule