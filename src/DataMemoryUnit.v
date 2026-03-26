module DataMemoryUnit (
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
        .MemOut(outReg)
    );

    // Renamed instance from datareg to DR to match ALUSys.DMU.DR.DROut
    DataRegister DR (
        .clk(clk),
        .E(CS),
        .I(outReg),
        .FunSel(FunSel),
        .DROut(out)
    );

endmodule