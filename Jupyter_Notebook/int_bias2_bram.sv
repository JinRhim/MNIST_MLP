`timescale 1ns/1ns
module int_bias2_bram (
    input wire clk,
    input wire [-1:0] addr,
    output reg [39:0] data
);

reg [39:0] mem[0:0];

initial begin
    mem[0] = 512'hfff800090000fff800050013fffe0009ffebffff;
end

always @(posedge clk) begin
    data <= mem[addr];
end

endmodule
