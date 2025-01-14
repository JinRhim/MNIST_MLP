`timescale 1ns / 10ps

module testbench;

    // Testbench Variables
    logic CLOCK_50;   // Clock signal

    // Outputs from the top module
    logic [3:0] inference_index;
    logic output_en;

    // Instantiate the top module
    top dut (
        .CLOCK_50(CLOCK_50),
        .inference_index(inference_index),
        .output_en(output_en)
    );

    // Clock generation
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50; // 50 MHz clock, 10 ns period (half-period of 10 ns)
    end

    // Monitor Outputs
    initial begin
        $monitor("Time: %t, Output Enable: %b, Inference Index: %h", $time, output_en, inference_index);
    end

    // Test sequence
    initial begin


        @(posedge CLOCK_50);
        // Display final outputs or any important messages
        if (output_en) begin
            $display("Inference Completed with Index: %d", inference_index);
        end 
    end

endmodule
