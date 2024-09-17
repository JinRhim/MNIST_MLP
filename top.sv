`timescale 1ns / 10ps

module top(
	// input 		          		CLOCK2_50,
	// input 		          		CLOCK3_50,
	// input 		          		CLOCK4_50,
    input logic CLOCK_50,
    output logic [3:0] inference_index, // Output prediction from MLP
    output logic output_en             // Output enable signal from MLP
);

    // Signals for MNIST_MLP
    logic [7:0] pixel_in;        // Input pixel data
    // logic [3:0] inference_index; // Output prediction from MLP
    // logic output_en;             // Output enable signal from MLP

    // Control and data feed signals
    logic input_en;              // Enable signal for MLP

    // Instantiate the MNIST_MLP module
    MNIST_MLP mnist_mlp (
        .clk(CLOCK_50),          // Connect system clock to MNIST_MLP clock
        .input_en(input_en),     // Connect enable signal
        .pixel_in(pixel_in),     // Connect pixel input
        .inference_index(inference_index),  // Connect output prediction
        .output_en(output_en)    // Connect output enable
    );

    // Instantiate the control and data feed module (acting like a testbench)
    PIXEL_FEEDER pixel_feeder (
        .clk(CLOCK_50),
        .pixel_out(pixel_in),
        .input_en(input_en),
        .output_en(output_en)
    );

endmodule
