.module DataMemoryUnit (
    input wire CS,
    input wire WR,
    input wire FunSel,
    input wire clk,
    input wire [15:0] add,
    input wire [7:0] I,

    output reg [15:0] out
);
wire [7:0] outReg;

DataMemory RAM(
    .Address(add),
    .Data(I),
    .WR(WR),
    .CS(~CS),
    .Clock(clk),
    .MemOut(outReg),
);


DataRegister datareg(
    .clk(clk),
    .E(CS),
    .I(outReg),
    .FunSel(FunSel),
    .DROut(out)
);



endmodule