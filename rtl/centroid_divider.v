`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:57:58 PM
// Design Name: 
// Module Name: centroid_divider
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

module centroid_divider (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire [23:0] sum_x,
    input  wire [15:0] pixel_count,
    output reg  [8:0]  line_x,
    output reg         result_valid,
    output reg         divide_by_zero
);

    // 1-cycle registered deterministic interface
    always @(posedge clk) begin
        if (reset) begin
            line_x         <= 9'd0;
            result_valid   <= 1'b0;
            divide_by_zero <= 1'b0;
        end else if (start) begin
            if (pixel_count == 16'd0) begin
                line_x         <= 9'd0;
                divide_by_zero <= 1'b1;
            end else begin
                // Integer division (fractional part is discarded)
                line_x         <= sum_x / pixel_count;
                divide_by_zero <= 1'b0;
            end
            result_valid <= 1'b1;
        end else begin
            result_valid <= 1'b0;
        end
    end

endmodule