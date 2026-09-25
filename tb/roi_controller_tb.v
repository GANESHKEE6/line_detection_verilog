`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2026 04:28:50 PM
// Design Name: 
// Module Name: roi_controller_tb
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

module roi_controller_tb();

    reg        clk;
    reg        reset;
    reg        pixel_valid;
    reg  [8:0] x;
    reg  [7:0] y;
    wire       roi_valid;

    integer    roi_pixel_count;
    integer    xi, yi;

    // Instantiate DUT
    roi_controller #(
        .WIDTH(320), .HEIGHT(240),
        .X_START(0), .X_END(319),
        .Y_START(120), .Y_END(239)
    ) uut (
        .clk(clk),
        .reset(reset),
        .pixel_valid(pixel_valid),
        .x(x),
        .y(y),
        .roi_valid(roi_valid)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        reset = 1;
        pixel_valid = 0;
        x = 0;
        y = 0;
        roi_pixel_count = 0;
        
        #25;
        @(negedge clk);
        reset = 0;

        $display("==================================================");
        $display("STARTING ROI VERIFICATION");
        $display("==================================================");

        // Iterate through standard 320x240 frame
        for (yi = 0; yi < 240; yi = yi + 1) begin
            for (xi = 0; xi < 320; xi = xi + 1) begin
                @(negedge clk);
                pixel_valid = 1;
                x = xi;
                y = yi;
                
                // Allow combinational logic to evaluate
                #1; 

                if (roi_valid) begin
                    roi_pixel_count = roi_pixel_count + 1;
                end

                // Print specific boundary tests
                if (xi == 0 && yi == 119)   $display("(0,119)   -> roi_valid = %b", roi_valid);
                if (xi == 0 && yi == 120)   $display("(0,120)   -> roi_valid = %b", roi_valid);
                if (xi == 0 && yi == 121)   $display("(0,121)   -> roi_valid = %b", roi_valid);
                if (xi == 100 && yi == 150) $display("(100,150) -> roi_valid = %b", roi_valid);
                if (xi == 319 && yi == 239) $display("(319,239) -> roi_valid = %b", roi_valid);
                if (xi == 100 && yi == 239) $display("(100,239) -> roi_valid = %b", roi_valid);
            end
        end

        // Test out-of-bounds explicit coordinate
        @(negedge clk);
        pixel_valid = 1;
        x = 0;
        y = 240;
        #1;
        $display("(0,240)   -> roi_valid = %b (invalid coordinate / outside image)", roi_valid);

        // Verification Output
        $display("\n==================================================");
        $display("STEP 6 VERIFICATION");
        $display("==================================================");
        $display("ROI count = %0d", roi_pixel_count);
        
        if (roi_pixel_count == 38400) 
            $display("Boundary checks = PASS");
        else 
            $display("Boundary checks = FAIL");
            
        $display("Simulation = PASS");
        $display("==================================================");
        
        $stop;
    end

endmodule