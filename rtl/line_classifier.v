`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 05:05:57 PM
// Design Name: 
// Module Name: line_classifier
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
/////////////////////////////////////////////////////////////////////////////////

module line_classifier #(
    parameter WIDTH = 320
)(
    input  wire [8:0] line_x,
    input  wire       line_valid,
    output reg  [1:0] direction
);

    // Symbolic states using localparam
    localparam [1:0] LEFT    = 2'b00,
                     CENTER  = 2'b01,
                     RIGHT   = 2'b10,
                     NO_LINE = 2'b11;

    // Parameter-derived boundaries based on WIDTH = 320
    localparam [8:0] BOUND_L = WIDTH / 3;             // Truncates to 106
    localparam [8:0] BOUND_R = (2 * WIDTH) / 3;       // Truncates to 213

    always @(*) begin
        if (!line_valid) begin
            direction = NO_LINE;
        end else if (line_x <= BOUND_L) begin          // Changed from < to <= to include 106 in LEFT
            direction = LEFT;
        end else if (line_x < BOUND_R) begin
            direction = CENTER;
        end else begin
            direction = RIGHT;
        end
    end

endmodule