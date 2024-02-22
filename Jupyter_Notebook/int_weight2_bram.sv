`timescale 1ns/1ns
module int_weight2_bram (
    input wire clk,
    input wire [6:0] addr,
    output reg [39:0] data
);

reg [39:0] mem[0:31];

initial begin
    mem[0] = 512'hfef301b80155fff5005afe81ff880033fff8007a;
    mem[1] = 512'h00c80065007c0051ff10ffe5ffa20006ffbaff17;
    mem[2] = 512'hffdb0065000c00600044ffda0058ff87fff2004d;
    mem[3] = 512'h00ceff9aff83ff8600f8ff750055010aff0400a9;
    mem[4] = 512'h0013001d0037ffadfea2ff6d020dfeb5ff350029;
    mem[5] = 512'hff8701c7fec8ff03009c000e004bfef70046001f;
    mem[6] = 512'h002b000201b40078ff3700f2ff4700abff00ff91;
    mem[7] = 512'h00faff7d014b00b7fed40168ff37fefc0027ff5c;
    mem[8] = 512'h0075ff2dffe7ffbefff90132ff54ff27ff33ffcd;
    mem[9] = 512'hffe90022000e0027ffa901daffd7ffc7ff13ff19;
    mem[10] = 512'h009f0095ff6e0188fea2ffa4ff7100f800040056;
    mem[11] = 512'hffd40033fe3dfef300190183ffb0014bfed900b9;
    mem[12] = 512'hff4300c500ce002cff30ffebff6900000176ffb2;
    mem[13] = 512'h00b1fec7ffe00039feb100bcff5600e600410012;
    mem[14] = 512'h009afee1ffcfff8300200014ffa8ff74004e01c8;
    mem[15] = 512'hfed30069ff1d00d6ff6affecfeb900f0ff92011e;
    mem[16] = 512'h0004ffd7ff89ffa3002cffbf009d0074002f002e;
    mem[17] = 512'h0064ffad0204014dfebaff0dffbf00b6ff3bfe58;
    mem[18] = 512'hffaffee20023ff11ffe5ff9600c5ff870041ffb9;
    mem[19] = 512'h01bcffad0046ffd50028ff100082ffe90011002f;
    mem[20] = 512'h00e000ee001dff970054ff8bff980098ffcfff9a;
    mem[21] = 512'hffeeff9f00a7ff6500ac006dff59ff310000ffe3;
    mem[22] = 512'hfef700810020009affc50048012bfef50004fec3;
    mem[23] = 512'hfedaff9200320050004ffe7efeca0130fff200f7;
    mem[24] = 512'hfea9ff93fea300b501c8ffdfff91fea2ffca000b;
    mem[25] = 512'hff4e005cff7dffdeff6400dc007eff9d00b7ff49;
    mem[26] = 512'h0091fdb1ffdfff36019c004900c200d4ff9dffe8;
    mem[27] = 512'h0022fffe0056ff9c00770012004d0054ffd4fee3;
    mem[28] = 512'hfff3ffbdff43ff8bffd6007cff4d0027008b0043;
    mem[29] = 512'h005f0064ffb5ff4e00b5ff6a0059006000caffdd;
    mem[30] = 512'hffeb0042003c0100ff11003b009e0128ff88ff89;
    mem[31] = 512'h00eaffdd0065003fffd5006b0093fe650186ffe5;
end

always @(posedge clk) begin
    data <= mem[addr];
end

endmodule
