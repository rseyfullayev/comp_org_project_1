`timescale 1ns / 1ps

module DataMemory(
    input wire[15:0] Address,
    input wire[7:0] Data,
    input wire WR,
    input wire CS,
    input wire Clock,
    output reg[7:0] MemOut
);
    reg[7:0] RAM_DATA[0:65535];

    initial $readmemh("RAM.mem", RAM_DATA);

    always @(*) MemOut = ~WR && ~CS ? RAM_DATA[Address] : 8'hZ;

    always @(posedge Clock) begin
        if (WR && ~CS) begin
            RAM_DATA[Address] = Data;
        end
    end
endmodule