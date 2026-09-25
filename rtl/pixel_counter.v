`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 03:50:59 PM
// Design Name: 
// Module Name: pixel_counter
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

module pixel_counter #(
    parameter WIDTH  = 320,
    parameter HEIGHT = 240
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       pixel_valid,
    input  wire       frame_start,
    output reg  [8:0] x,
    output reg  [7:0] y,
    output wire       frame_done
);

    // frame_done asserts combinationally on the exact cycle of the final pixel
    assign frame_done = (x == WIDTH - 1) && (y == HEIGHT - 1) && pixel_valid;

    always @(posedge clk) begin
        if (reset || frame_start) begin
            x <= 0;
            y <= 0;
        end else if (pixel_valid) begin
            if (x < WIDTH - 1) begin
                x <= x + 1;
            end else begin
                x <= 0;
                if (y < HEIGHT - 1) begin
                    y <= y + 1;
                end else begin
                    y <= 0;
                end
            end
        end
    end

endmodule