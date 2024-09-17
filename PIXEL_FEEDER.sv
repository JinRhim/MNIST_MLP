module PIXEL_FEEDER(
    input logic clk,
    input logic output_en,  // wait until module finishes calculation. High --> reset 
    output logic [7:0] pixel_out,
    output logic input_en
);

    logic [9:0] address = 0; // Address for ROM (sufficient for 784 depth)
    logic [7:0] rom_data;   // Data from ROM

    // Instantiate the PIXEL_ROM module
    PIXEL_ROM rom_inst (
        .clk(clk),
        .addr(address),
        .data(rom_data)
    );

    // Control and data feed sequence
    initial begin
        input_en <= 0;
        address <= 0;
        @(posedge clk);
        // Simulate loading and processing data
        for (int i = 0; i < 784; i++) begin
            input_en <= 1;
            address <= i;
            pixel_out <= rom_data;  // Directly assign ROM data to pixel output
            @(posedge clk);
        end
        input_en <= 0; // Disable MLP after the last data
        
        wait (output_en);
    end
endmodule







