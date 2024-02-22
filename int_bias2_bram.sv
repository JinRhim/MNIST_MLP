`timescale 1ns/1ns
module int_bias2_bram (
    input wire clk,
    input wire [0:0] addr,
    output reg [159:0] data
);

reg [159:0] mem[0:0]; // 40 hex char --> 160 bits 

initial begin   
    mem[0] = 160'hfff800090000fff800050013fffe0009ffebffff;
end

always @(posedge clk) begin
    data <= mem[addr];
end

endmodule
