`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 05:19:05 PM
// Design Name: 
// Module Name: line_detector_top
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

module line_detector_top #(
    parameter WIDTH   = 320,
    parameter HEIGHT  = 240,
    parameter X_START = 0,
    parameter X_END   = 319,
    parameter Y_START = 96,  // Configured to match Python ROI (bottom 60%)
    parameter Y_END   = 239
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       frame_start,
    input  wire       pixel_valid,
    input  wire       line_pixel,
    output wire [8:0] line_x,
    output wire [1:0] direction,
    output wire       detected,
    output wire       frame_done,
    output wire       result_valid
);

    // Internal inter-module wires
    wire [8:0]  x;
    wire [7:0]  y;
    wire        w_frame_done;
    wire        roi_valid;
    wire [23:0] sum_x;
    wire [15:0] pixel_count;
    wire        acc_result_valid;
    wire        div_result_valid;
    wire        divide_by_zero;
    wire        line_valid;

    // 1. Spatial Pixel Coordinate Generator
    pixel_counter #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) u_counter (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .frame_start(frame_start),
        .x(x),
        .y(y),
        .frame_done(w_frame_done)
    );

    // 2. Region of Interest (ROI) Gatekeeper
    roi_controller #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .X_START(X_START),
        .X_END(X_END),
        .Y_START(Y_START),
        .Y_END(Y_END)
    ) u_roi (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .x(x),
        .y(y),
        .roi_valid(roi_valid)
    );

    // 3. Centroid Accumulator (Summation & Count)
    centroid_accumulator #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT)
    ) u_acc (
        .clk(clk),
        .reset(reset),
        .frame_start(frame_start),
        .frame_done(w_frame_done),
        .pixel_valid(pixel_valid),
        .roi_valid(roi_valid),
        .line_pixel(line_pixel),
        .x(x),
        .sum_x(sum_x),
        .pixel_count(pixel_count),
        .result_valid(acc_result_valid)
    );

    // 4. Centroid Divider (Calculates sum_x / pixel_count on frame completion)
    centroid_divider u_div (
        .clk(clk),
        .reset(reset),
        .start(acc_result_valid),
        .sum_x(sum_x),
        .pixel_count(pixel_count),
        .line_x(line_x),
        .result_valid(div_result_valid),
        .divide_by_zero(divide_by_zero)
    );

    // Detection status logic
    assign detected     = (pixel_count > 16'd0) && !divide_by_zero;
    assign line_valid   = detected && div_result_valid;

    // 5. Line Position Direction Classifier
    line_classifier #(
        .WIDTH(WIDTH)
    ) u_classifier (
        .line_x(line_x),
        .line_valid(line_valid),
        .direction(direction)
    );

    // Top-level output assignments
    assign frame_done   = w_frame_done;
    assign result_valid = div_result_valid;

endmodule