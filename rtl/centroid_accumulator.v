`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:39:49 PM
// Design Name: 
// Module Name: centroid_accumulator
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

module centroid_accumulator #(
    parameter WIDTH  = 320,
    parameter HEIGHT = 240
)(
    input  wire        clk,
    input  wire        reset,
    input  wire        frame_start,
    input  wire        frame_done,
    input  wire        pixel_valid,
    input  wire        roi_valid,
    input  wire        line_pixel,
    input  wire  [8:0] x,
    output reg  [23:0] sum_x,
    output reg  [15:0] pixel_count,
    output reg         result_valid
);

    always @(posedge clk) begin
        if (reset || frame_start) begin
            sum_x        <= 24'd0;
            pixel_count  <= 16'd0;
            result_valid <= 1'b0;
        end else begin
            // Accumulate when valid line pixel is inside ROI
            if (pixel_valid && roi_valid && line_pixel) begin
                sum_x       <= sum_x + x;
                pixel_count <= pixel_count + 1;
            end
            
            // result_valid timing:
            // frame_done asserts combinationally during the exact cycle of the final pixel.
            // We assert result_valid on the next clock edge, guaranteeing the final 
            // pixel's X coordinate is fully latched into sum_x before downstream logic reads it.
            if (frame_done) begin
                result_valid <= 1'b1;
            end
        end
    end

endmodule