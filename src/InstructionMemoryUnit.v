`timescale 1ns / 1ps
module InstructionMemoryUnit(
    input wire [15:0] Address,
    input wire CS,
    input wire LH,
    input wire Clock,

    output reg [15:0] IMUOut,
    output reg [15:0] IROut
);

    wire [7:0] outputROM;
    wire [15:0] outIR;

    InstructionMemory IM(
        .Address(Address),
        .CS(CS),
        .MemOut(outputROM)
    );

    InstructionRegister IR(
        .Write(CS),
        .LH(LH),
        .Clock(Clock),
        .I(outputROM),
        .IROut(outIR)
    );

    always @(*) begin
        IMUOut[7:0] = outIR[7:0];
        IMUOut[15:8] = 8'b0;
        IROut = outIR;
    end

endmodule