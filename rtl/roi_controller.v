`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:27:21 PM
// Design Name: 
// Module Name: roi_controller
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

module roi_controller #(
    parameter WIDTH   = 320,
    parameter HEIGHT  = 240,
    parameter X_START = 0,
    parameter X_END   = 319,
    parameter Y_START = 120,
    parameter Y_END   = 239
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       pixel_valid,
    input  wire [8:0] x,
    input  wire [7:0] y,
    output reg        roi_valid
);

    // Combinational block: Evaluates instantly when x, y, or pixel_valid changes.
    // END coordinates are INCLUSIVE (e.g., y <= 239 means row 239 is processed).
    always @(*) begin
        if (pixel_valid && 
           (x >= X_START) && (x <= X_END) && 
           (y >= Y_START) && (y <= Y_END)) begin
            roi_valid = 1'b1;
        end else begin
            roi_valid = 1'b0;
        end
    end

endmodule