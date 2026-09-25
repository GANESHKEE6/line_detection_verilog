`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 05:24:26 PM
// Design Name: 
// Module Name: line_detector_top_tb
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

module line_detector_top_tb();

    reg        clk;
    reg        reset;
    reg        frame_start;
    reg        pixel_valid;
    reg        line_pixel;
    
    wire [8:0] line_x;
    wire [1:0] direction;
    wire       detected;
    wire       frame_done;
    wire       result_valid;

    reg [0:0]  pixel_mem [0:76799];
    integer    i, t;
    integer    file_handle;

    localparam [1:0] LEFT    = 2'b00,
                     CENTER  = 2'b01,
                     RIGHT   = 2'b10,
                     NO_LINE = 2'b11;

    line_detector_top #(
        .WIDTH(320),
        .HEIGHT(240),
        .X_START(0),
        .X_END(319),
        .Y_START(96),
        .Y_END(239)
    ) u_top (
        .clk(clk),
        .reset(reset),
        .frame_start(frame_start),
        .pixel_valid(pixel_valid),
        .line_pixel(line_pixel),
        .line_x(line_x),
        .direction(direction),
        .detected(detected),
        .frame_done(frame_done),
        .result_valid(result_valid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        frame_start = 0;
        pixel_valid = 0;
        line_pixel = 0;

        file_handle = $fopen("/home/ganesh/line_detection_rtl/data/rtl_results.txt", "w");
        if (file_handle == 0) begin
            $display("ERROR: Could not open data/rtl_results.txt for writing!");
            $stop;
        end

        #25;
        
        for (t = 1; t <= 5; t = t + 1) begin
            if (t == 1)      $readmemb("/home/ganesh/line_detection_rtl/data/test1.mem", pixel_mem);
            else if (t == 2) $readmemb("/home/ganesh/line_detection_rtl/data/test2.mem", pixel_mem);
            else if (t == 3) $readmemb("/home/ganesh/line_detection_rtl/data/test3.mem", pixel_mem);
            else if (t == 4) $readmemb("/home/ganesh/line_detection_rtl/data/test4.mem", pixel_mem);
            else if (t == 5) $readmemb("/home/ganesh/line_detection_rtl/data/test5.mem", pixel_mem);

            @(negedge clk);
            reset = 1;
            @(negedge clk);
            reset = 0;
            frame_start = 1;
            @(negedge clk);
            frame_start = 0;

            for (i = 0; i < 76800; i = i + 1) begin
                @(negedge clk);
                pixel_valid = 1;
                line_pixel  = pixel_mem[i];
            end

            @(negedge clk);
            pixel_valid = 0;

            @(posedge result_valid);
            #2;

            $fwrite(file_handle, "TEST_ID=%0d\n", t);
            $fwrite(file_handle, "PIXEL_COUNT=%0d\n", u_top.u_acc.pixel_count);
            $fwrite(file_handle, "SUM_X=%0d\n", u_top.u_acc.sum_x);
            $fwrite(file_handle, "LINE_X=%0d\n", line_x);
            
            if (direction == LEFT)
                $fwrite(file_handle, "DIRECTION=LEFT\n");
            else if (direction == CENTER)
                $fwrite(file_handle, "DIRECTION=CENTER\n");
            else if (direction == RIGHT)
                $fwrite(file_handle, "DIRECTION=RIGHT\n");
            else
                $fwrite(file_handle, "DIRECTION=NO_LINE\n");
                
            $fwrite(file_handle, "DETECTED=%0d\n", detected ? 1 : 0);

            $display("Regression Test %0d completed successfully.", t);
            #100;
        end

        $fclose(file_handle);
        $display("\nAll regression tests completed and logged to data/rtl_results.txt");
        #50;
        $stop;
    end

endmodule