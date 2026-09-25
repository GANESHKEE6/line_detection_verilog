`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:41:29 PM
// Design Name: 
// Module Name: centroid_accumulator_tb
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
module centroid_accumulator_tb();

    reg        clk;
    reg        reset;
    reg        frame_start;
    reg        pixel_valid;
    reg  [0:0] line_pixel;
    
    wire [8:0] x;
    wire [7:0] y;
    wire       frame_done;
    wire       roi_valid;
    
    wire [23:0] sum_x;
    wire [15:0] pixel_count;
    wire        result_valid;

    reg  [0:0] pixel_mem [0:76799];
    integer    i;
    integer    rtl_centroid;

    // 1. Instantiate Pixel Counter
    pixel_counter #(
        .WIDTH(320), .HEIGHT(240)
    ) u_pixel_counter (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .frame_start(frame_start),
        .x(x),
        .y(y),
        .frame_done(frame_done)
    );

    // 2. Instantiate ROI Controller 
    // IMPORTANT OVERRIDE: Python used ROI_START_Y_PCT = 0.4 (240 * 0.4 = 96)
    // We override Y_START to 96 here to guarantee identical ROI definitions.
    roi_controller #(
        .WIDTH(320), .HEIGHT(240),
        .X_START(0), .X_END(319),
        .Y_START(96), .Y_END(239) 
    ) u_roi_controller (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .x(x),
        .y(y),
        .roi_valid(roi_valid)
    );

    // 3. Instantiate Accumulator
    centroid_accumulator #(
        .WIDTH(320), .HEIGHT(240)
    ) u_accumulator (
        .clk(clk),
        .reset(reset),
        .frame_start(frame_start),
        .frame_done(frame_done),
        .pixel_valid(pixel_valid),
        .roi_valid(roi_valid),
        .line_pixel(line_pixel),
        .x(x),
        .sum_x(sum_x),
        .pixel_count(pixel_count),
        .result_valid(result_valid)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus and Verification
    initial begin
        reset = 1;
        frame_start = 0;
        pixel_valid = 0;
        line_pixel = 0;
        
        $readmemb("/home/ganesh/line_detection_rtl/data/input_binary.mem", pixel_mem);

        #25;
        @(negedge clk);
        reset = 0;
        frame_start = 1;
        
        @(negedge clk);
        frame_start = 0;

        // Stream Pixels securely on the negedge
        for (i = 0; i < 76800; i = i + 1) begin
            @(negedge clk);
            pixel_valid = 1;
            line_pixel = pixel_mem[i];
        end

        // End of frame
        @(negedge clk);
        pixel_valid = 0;
        
        // Wait for result_valid
        wait(result_valid == 1);
        
        // Integer Division (Testbench ONLY)
        if (pixel_count > 0)
            rtl_centroid = sum_x / pixel_count;
        else
            rtl_centroid = 0;

        $display("\n==================================================");
        $display("STEP 7 CENTROID ACCUMULATOR VERIFICATION");
        $display("==================================================");
        $display("RTL pixel_count = %0d", pixel_count);
        $display("Python pixel_count = 1143\n");
        $display("RTL sum_x = %0d\n", sum_x);
        $display("RTL centroid = %0d", rtl_centroid);
        $display("Python line_x = 164\n");
        
        if (pixel_count == 1143) $display("Pixel count match = PASS");
        else $display("Pixel count match = FAIL");
        
        if (rtl_centroid == 164) $display("Centroid match = PASS");
        else $display("Centroid match = FAIL");
        $display("==================================================\n");

        $stop;
    end
endmodule