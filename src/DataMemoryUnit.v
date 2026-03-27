module DataMemoryUnit (
    input wire CS,
    input wire WR,
    input wire FunSel,
    input wire Clock,
    input wire [15:0] Address,
    input wire [7:0] I,
    
    output wire [15:0] DMUOut 
);
    wire [7:0] outReg;

    DataMemory DM(
        .Address(Address),
        .Data(I),
        .WR(WR),
        .CS(CS),
        .Clock(Clock),
        .MemOut(outReg)
    );

    
    DataRegister DR (
        .clk(Clock),
        .E(CS),
        .I(outReg),
        .FunSel(FunSel),
        .DROut(DMUOut)
    );

endmodule