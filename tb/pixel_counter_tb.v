`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 03:52:11 PM
// Design Name: 
// Module Name: pixel_counter_tb
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

module pixel_counter_tb();

    reg        clk;
    reg        reset;
    reg        pixel_valid;
    reg        frame_start;
    wire [8:0] x;
    wire [7:0] y;
    wire       frame_done;

    reg [0:0]  pixel_mem [0:76799];
    reg [0:0]  current_pixel;
    
    integer    i;

    pixel_counter #(
        .WIDTH(320),
        .HEIGHT(240)
    ) uut (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .frame_start(frame_start),
        .x(x),
        .y(y),
        .frame_done(frame_done)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize
        reset = 1;
        pixel_valid = 0;
        frame_start = 0;
        
        $readmemb("/home/ganesh/line_detection_rtl/data/input_binary.mem", pixel_mem);

        #25; 
        
        // Synchronize stimulus cleanly to the falling edge
        @(negedge clk);
        reset = 0;
        frame_start = 1;
        
        @(negedge clk);
        frame_start = 0;

        $display("==================================================");
        $display("PIXEL COUNTER VERIFICATION");
        $display("==================================================");

        // Stream and sample precisely on the negedge
        for (i = 0; i < 76800; i = i + 1) begin
            @(negedge clk);
            
            // Present current stimulus
            pixel_valid = 1;
            current_pixel = pixel_mem[i];
            
            // Outputs x and y are stable here. They represent the CURRENT pixel coordinate.
            if (i == 0)      $display("\nPixel 0:\nx=%0d y=%0d", x, y);
            if (i == 1)      $display("\nPixel 1:\nx=%0d y=%0d", x, y);
            if (i == 319)    $display("\nPixel 319:\nx=%0d y=%0d", x, y);
            if (i == 320)    $display("\nPixel 320:\nx=%0d y=%0d", x, y);
            if (i == 321)    $display("\nPixel 321:\nx=%0d y=%0d", x, y);
            if (i == 639)    $display("\nPixel 639:\nx=%0d y=%0d", x, y);
            if (i == 640)    $display("\nPixel 640:\nx=%0d y=%0d", x, y);
            if (i == 76799)  $display("\nPixel 76799:\nx=%0d y=%0d\n\nframe_done = %b", x, y, frame_done);
        end

        // End of frame
        @(negedge clk);
        pixel_valid = 0;
        
        $display("\n==================================================");
        $stop;
    end

endmodule