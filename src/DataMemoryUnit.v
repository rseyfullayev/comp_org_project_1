`timescale 1ns / 1ps
module DataMemoryUnit (
    input wire CS,
    input wire WR,
    input wire FunSel,
    input wire Clock,
    input wire [15:0] Address,
    input wire [7:0] I,

    output wire [15:0] DMUOut
);
    wire [7:0] MemOut;

    DataMemory DM (
        .Address(Address),
        .Data(I),
        .WR(WR),
        .CS(~CS),
        .Clock(Clock),
        .MemOut(MemOut)
    );


    DataRegister DR (
        .Clock(Clock),
        .E(CS), // TODO: @Raimbek please add WR input here. I forgot ( WR or ~WR)
        .I(MemOut),
        .FunSel(FunSel),
        .DROut(DMUOut)
    );

endmodule