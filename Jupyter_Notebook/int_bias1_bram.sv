`timescale 1ns/1ns
module int_bias1_bram (
    input wire clk,
    input wire [-1:0] addr,
    output reg [511:0] data
);

reg [511:0] mem[0:0];

initial begin
    mem[0] = 512'h0000000000000000000000000000000000000001000000010000000000000001000000000000000000000000000000000000000000010000000000000000ffff;
end

always @(posedge clk) begin
    data <= mem[addr];
end

endmodule
