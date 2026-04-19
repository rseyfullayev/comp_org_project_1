`timescale 1ns / 1ps
module InstructionRegister (
    input wire Write,
    input wire LH,
    input wire Clock,
    input wire [7:0] I,
    output reg [15:0] IROut
);

    always @(posedge Clock) begin
        if (Write) begin
            if (LH)
                IROut[15:8] <= I;
            else
                IROut[7:0] <= I;
        end
    end

endmodule