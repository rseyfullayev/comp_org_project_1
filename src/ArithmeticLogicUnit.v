module flagReg (
    input wire flagIn
    input wire WF,

    output reg Cin
);

endmodule




module ALU(
    input wire [15:0] input1,
    input wire [15:0] input2,

    input wire [3:0] Funsel,
    input wire Cin,

    output reg [15:0] out,
    output reg [3:0] flagOut
);


always @(posedge clk) begin
    case Funsel
        2'b0000:
            flagOut <= A;
        2'b0001
            flagOut <= B;

    endcase
end

always @(*) begin

end


endmodule