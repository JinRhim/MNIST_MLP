`timescale 1ns/1ns
module MNIST_MLP_tb;

reg clk;
reg input_en; 
wire output_en;
reg [7:0] pixel_in;
wire [3:0] index;

// Instantiate the DUT
MNIST_MLP dut (
    .clk(clk),
    .input_en(input_en),
    .pixel_in(pixel_in),
    .inference_index(index), 
    .output_en(output_en)
);

initial begin
    clk = 1;
    forever #5 clk = ~clk; // 100MHz clock
end


// MNIST pixel data loading and test
initial begin
    // File handling variables
    integer file, r;
    reg [7:0] buffer[0:783]; // Buffer for MNIST dataset, adjust size as needed
    reg [7:0] hex_digit;

    // Open the file
    file = $fopen("mnist_hex.txt", "r");
    if (file == 0) begin
        $display("Failed to open mnist_hex.txt");
        $finish;
    end
    
    // Read the file into the buffer
    for (int i = 0; i < 784; i++) begin
        r = $fscanf(file, "%2h", hex_digit);
        buffer[i] = hex_digit;
    end
    
    // Close the file
    $fclose(file);
    input_en = 1; 

    // Input the pixel values into the DUT
    for (int i = 0; i < 784; i++) begin
        @(negedge clk);   	
	    pixel_in = buffer[i];
	//$display("TestBench Pixel Input: %d Buffer: %2h",i, pixel_in);
    end
    @(negedge clk);
    pixel_in = 8'hFF; // insert padding pixel. This will be ignored
    @(negedge clk);
    input_en = 0;
    $display("tb pixel input done =====\n");

    //$display("\n====== Input done======================================\n.");
 
    //$finish;
end

endmodule
