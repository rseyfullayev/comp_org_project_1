module InstructionRegister(
    input wire CS,
    input wire LH,
    input wire [7:0] I,
    input wire Clock,

    output reg [15:0] Out
);

    always @(posedge Clock) begin
        if(CS) begin
            if(LH)
                Out[15:8] <= I;
            else
                Out[7:0] <= I;
        end
    end

endmodule