// ============================================================================
// Top Module =================================================================
// ============================================================================

module MNIST_MLP(
    input wire clk,
    input wire input_en, 
    input wire [7:0] pixel_in,
    output reg [3:0] inference_index,
    output reg output_en
);

// Assuming each weight is 16 bits and there are 32 weights per row.
localparam int WEIGHTS_PER_ROW = 32;
localparam int TOTAL_PIXELS = 784; // 28x28 image

// Buffer for a single 28x28 grayscale image
reg [7:0] pixel_buffer[0:TOTAL_PIXELS];
integer buffer_index = 0; 

reg [9:0] w1_addr = 10'b0000000000;
wire [0:0] b1_addr = 1'b0;
reg [9:0] w2_addr = 6'b000000;
wire [0:0] b2_addr = 1'b0;

wire [511:0] w1_bram_data; //512-bit wide BRAM data for weights
wire [511:0] b1_bram_data; //512-bit wide BRAM data for weights
wire [159:0] w2_bram_data; //160-bit wide BRAM data for weights
wire [159:0] b2_bram_data; //160-bit wide BRAM data for weights

reg reg_loader = 1'b1;
reg[7:0] a_reg;    //w1 processing 
reg[511:0] b_reg; 

reg signed [31:0] c_reg[31:0]; // b1 processing 
reg [511:0] d_reg;

reg signed [31:0] e_reg;  // w2 processing 
reg signed [31:0] f_reg[9:0];  // b2 processing 

reg signed [31:0] g_reg[9:0];  //softmax processing

reg signed[15:0] b_reg_parsed; 
reg signed[31:0] mult_out; 
reg signed [WEIGHTS_PER_ROW-1:0] w1_product_reg[31:0];
reg signed [WEIGHTS_PER_ROW-1:0] b1_product_reg[31:0];
reg signed [31:0] w2_product_reg[9:0];
reg signed [31:0] b2_product_reg[9:0];

// Temporary storage for multiplication results
reg signed [31:0] w1_out[31:0];
reg signed [31:0] b1_out[31:0];
reg signed [31:0] w2_out[9:0];
reg signed [31:0] b2_out[9:0];
reg signed [31:0] softmax_out[9:0];

// ============================================================================
// Memory Module ==============================================================
// ============================================================================


int_weight1_bram w1_bram (
    .clk(clk),
    .addr(w1_addr+1),
    .data(w1_bram_data)
);

int_bias1_bram b1_bram (
    .clk(clk),
    .addr(b1_addr),
    .data(b1_bram_data)
);

int_weight2_bram w2_bram (
    .clk(clk),
    .addr(31-w2_addr),
    .data(w2_bram_data)
);

int_bias2_bram b2_bram (
    .clk(clk),
    .addr(b2_addr),
    .data(b2_bram_data)
);

// ============================================================================
// Weight Processing Module ===================================================
// ============================================================================

weight1_multiplier w1_mul (
	.a(a_reg),
	.b(b_reg),
	.product(w1_product_reg)
);

bias1_adder b1_add (
	.c(c_reg),
	.d(d_reg),
	.product(b1_product_reg)
);

weight2_multiplier w2_mul (
	.input_node(e_reg),
	.w2_mem(w2_bram_data),
	.product(w2_product_reg)
);

bias2_adder b2_add (
	.input_node(f_reg),
	.b2_mem(b2_bram_data),
	.product(b2_product_reg)
);

softmax softmax_mul (
    .input_data(g_reg), 
    .softmax_out(softmax_out)
);

// ============================================================================
// Logic ======================================================================
// ============================================================================

initial begin
    output_en = 0;
    // Initialize w1_out array to 0
    for (int i = 0; i < WEIGHTS_PER_ROW; i=i+1) begin
        w1_out[i] = 0;
    end
	 for (int i = 0; i < 10; i=i+1) begin
        w2_out [i] = 0;
    end
end

always @(posedge clk) begin
    if (output_en) begin end 
    else if (input_en) begin
	    $display("Buffer Input index: %d pixel_in: %2h,", buffer_index, pixel_in);
        pixel_buffer[buffer_index] <= pixel_in;
        buffer_index <= (buffer_index + 1);
    end
    else if (w1_addr < TOTAL_PIXELS) begin // W1 Processing
		if (reg_loader) begin
			$display("\n=======register loaded======\n");
			a_reg <= pixel_buffer[w1_addr]; // buffer[0] -> xxxx error
			b_reg <= w1_bram_data;
			//w1_addr <= w1_addr + 1;
			reg_loader <= 0; 
		end
		else begin			
			if (a_reg != 0) begin
				for (int i = 0; i < WEIGHTS_PER_ROW; i = i + 1) begin
					b_reg_parsed = w1_bram_data[16*i +: 16];
					w1_out[i] = w1_out[i]+w1_product_reg[i];
					$display("w1_Addr: %d, a_reg = 0x%h (%d), b_reg = 0x%h (%d), product =0x%h (%d)", w1_addr ,a_reg, a_reg, b_reg_parsed, b_reg_parsed, w1_product_reg[i], w1_product_reg[i]);
					//$display("w1_Addr: %d, a_reg = 0x%h (%d), b_reg = 0x%h (%d), product =0x%h (%d)", w1_addr ,a_reg, a_reg, b_reg_parsed, b_reg_parsed, mult_out, mult_out);
					//$display("Buffer Index: %d, a_reg = %d (%b), b_reg = %d (%b), product =%d (%b)", buffer_index ,a_reg, a_reg, b_reg_parsed, b_reg_pased, product_reg, product_reg);
					//$display("mul[%d]: %d", mul[i], mul[i]);
				end
				$display("\n");
			end
			a_reg <= pixel_buffer[w1_addr+1]; // buffer[0] -> xxxx error
			b_reg <= w1_bram_data;
			w1_addr <= w1_addr + 1; // Assuming next row of weights for the next pixel
		end
	end
    else if (w1_addr == TOTAL_PIXELS) begin    //bias1 adder loop 
		$display("\n========== Bias 1 Adder Loop ===============\n");
		if (!reg_loader) begin
			$display("\n========== Register Loader ===============\n");
			c_reg <= w1_out;
			d_reg <= b1_bram_data;
			reg_loader <= 1; 
		end
		else begin
			$display("\n========== adding b1_out ===============\n");
			b1_out <= b1_product_reg;
			w1_addr <= w1_addr + 1;
		end  
	end
    else if (w2_addr < 32) begin  //w2 multiplication processing =========
        if (!reg_loader) begin
            $display("\n========== Weight 2 Register Loader ===============\n");
            e_reg <= b1_out[w2_addr];
            reg_loader <= 1; 
        end 
        else begin
            if (e_reg != 0) begin
                for (int i = 0; i < 10; i = i + 1) begin
                    w2_out[i] = w2_out[i] + w2_product_reg[i]; 
                    $display("w2 Iteration :%d, w2_product_reg: %d",i, w2_product_reg[i]);
                end
            end
            $display("\n%d",w2_addr);
            e_reg <= b1_out[w2_addr]; 
            w2_addr <= w2_addr + 1;
        end
    end
    else if (w2_addr == 32) begin   //b2 adder processing ==========
        if (reg_loader) begin
            f_reg <= w2_out; 
            reg_loader <= 0;
        end
        else begin 
            b2_out <= b2_product_reg; 
            w2_addr = w2_addr + 1; 
        end
    end
    else if (w2_addr == 33) begin // Softmax Layer ===================
        g_reg <= b2_out;
        w2_addr = w2_addr + 1;
    end
	else begin
        // Processing complete, handle accumulator or final output logic
        // This example just shows setting segment_out from the first product
        // Real implementation would accumulate or otherwise process mul[] values
		$display("\n\n\nOutput ==================\n\n\n\n\n\n\n\n");
        //addr <= 0;
		buffer_index <= 0;
		output_en <= 1;
		for (int i = 0; i < 10; i = i + 1) begin 
            //$display("Layer 2 Output: [%d]: 0x%h", i, b2_out[i], b2_out[i]);
			$display("Softmax Output: [%d]: 0x%h", 9-i, softmax_out[i], softmax_out[i]);
            if (softmax_out[i] == 1) begin 
                $display("\nInference Output from MNIST Dataset: %d\n", 9-i);
					 inference_index <= 9-i;
            end
		end
        //$display("Inference Output from MNIST Dataset: %d", index);
		$display("OUTPUT_EN:%d", output_en);
		$display("\n\n=================End =================\n\n");
    end
end

endmodule


module w1_signed_mult(
    output reg [31:0] out,  // Output width adjusted for combinational logic
    input wire [7:0] a,
    input wire [15:0] b
);
    assign out = $signed({1'b0,a})*$signed(b);

endmodule


// Note: The module's functionality is kept the same. SystemVerilog enhancements include the use of 'logic' type for signals and 'always_ff' and 'always_comb' for better clarity and distinction between sequential and combinational logic.

module weight1_multiplier(
    input wire [7:0] a,  // 8-bit unsigned input
    input wire [511:0] b, // 512-bit input, corrected comment
    output reg signed [31:0] product[31:0] // Corrected type to logic
);

genvar i; 
generate 
    for (i = 0; i < 32; i = i + 1) begin: gen_mult 
        // Corrected signed extension and slicing
        //wire signed [15:0] b_signed = $signed(b[i*16 +: 16]); // Correct slicing
        wire [15:0] b_parsed = b[i*16 +: 16]; // Correct slicing
        
        w1_signed_mult m0(.out(product[i]), .a(a), .b(b[i*16 +: 16]));

        // Debugging: Print a_signed and b_signed values
        // always @(product[i]) begin
        //     $display("Iteration %d: a_signed = %d (%h)(%b), b_signed = %d (%h) (%b), product = %d (%h) (%b)", i, a,a,a, $signed(b_parsed), $signed(b_parsed), $signed(b_parsed), product[i], product[i], product[i]);
        // end
    end 
endgenerate

endmodule



module bias1_adder(
    input signed [31:0] c[31:0], //w1_out
    input [511:0] d,  //512 bit bias ram content
    output reg signed [31:0] product[31:0] // 32 bit 2's complement output
);

genvar i; 
generate 
    for (i = 0; i < 32; i = i + 1) begin: gen_mult 
        //force generate 
        wire signed [31:0]parsed_bias = $signed(d[i*16 +: 16]);
        wire signed [31:0] temp_product = c[i] + parsed_bias;
        
        always @(*) begin
            if (temp_product < 0) 
                product[i] = 0;
            else
                product[i] = temp_product;
        end
    end 
endgenerate

endmodule


module weight2_multiplier(
    input wire signed [31:0] input_node, // input from layer 1 processor 
    input wire [159:0] w2_mem,
    output reg signed [31:0] product[9:0] 
);

genvar i; 
generate 
    for (i = 0; i < 10; i = i +1) begin: gen_mult
        wire signed [15:0] parsed_weight = w2_mem[i*16 +: 16];
        
        assign product[i] = $signed(input_node)*$signed(parsed_weight);
        // Debugging: Print a_signed and b_signed values
        always @(product[i]) begin
            $display("w2 Iteration %d: a_signed = %d (%h)(%b), b_signed = %d (%h) (%b), product = %d (%h) (%b)", i, $signed(input_node),$signed(input_node),$signed(input_node), $signed(parsed_weight), $signed(parsed_weight), $signed(parsed_weight), product[i], product[i], product[i]);
        end
    end
endgenerate
endmodule


module bias2_adder(
    input wire signed [31:0] input_node[9:0],
    input wire [159:0] b2_mem, 
    output reg signed [31:0] product[9:0]
);
genvar i; 
generate 
    for (i = 0; i < 10; i = i + 1) begin: gen_mult 
        //force generate 
        wire signed [31:0]parsed_bias = $signed(b2_mem[i*16 +: 16]);
        assign product[i] = input_node[i] + parsed_bias;
    end 
endgenerate

endmodule


module softmax(
    input wire signed [31:0] input_data[9:0], // Array of 10 32-bit inputs
    output reg signed[31:0] softmax_out[9:0] // Array of 10 32-bit outputs
);
    // Assuming fixed-point representation for simplicity
    reg signed[31:0] max_value;
    reg [31:0] exp_values[9:0];
    reg [31:0] sum_exp_values;
    integer i;

    always @(input_data[9]) begin
        // Step 1: Find MAx value ============================
        max_value = input_data[0];
        for (i = 1; i < 10; i = i + 1) begin
            if (input_data[i] > max_value) begin
                max_value = input_data[i];
            end
        end
        // Step 2: Calculate 2^Element Value ========================
        for (i = 0; i < 10; i = i + 1) begin
            exp_values[i] = (24'h800000 >> (max_value - input_data[i]));
            $display("Exp Values: %b", exp_values[i]);
        end
        // Step 3: Calculate Sum Exponential Value
        sum_exp_values = 0;
        for (i = 0; i < 10; i = i + 1) begin
            sum_exp_values = sum_exp_values + exp_values[i];
        end 

        //Step 4: Divide the number -> Output
        for (i = 0; i < 10; i = i + 1) begin
            // Placeholder for division/normalization
            // Actual implementation would likely use a reciprocal approximation and a multiplication
            softmax_out[i] = exp_values[i] / sum_exp_values; // Simplified, assumes direct division is possible
        end
    end
endmodule
