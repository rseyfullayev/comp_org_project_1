module InstructionRegister (
    input wire CS,
    input wire LH,
    input wire Clock,
    input wire [7:0] I,
    output reg [15:0] IROut // Changed from 'Out' to 'IROut'
);

    always @(posedge Clock) begin
        if (CS) begin
            if (LH) 
                IROut[15:8] <= I;
            else 
                IROut[7:0] <= I;
        end
    end

endmodule