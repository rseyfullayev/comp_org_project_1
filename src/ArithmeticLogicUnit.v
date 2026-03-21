module flagReg (

    input wire [3:0] flagIn,
    input wire [3:0] WF,
    input wire clk,

    output wire Cin
);

    reg [3:0] flag;

    always @(posedge clk) begin
        flag <= (flag & ~WF) | (flagIn & WF); // Using WF as a mask.
    end

    assign Cin = flag[2];

endmodule


module ALU(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire clk,

    input wire [3:0] Funsel,
    input wire Cin,

    output reg [3:0] WF,
    output reg [3:0] flagOut,
    output reg [15:0] ALUOut,
);


always @(posedge clk) begin
    case (Funsel)
        4'b0000:
            ALUOut <= A;
            WF <= 2'1010;
        4'b0001:
            ALUOu <= B;
        4'b0010:
            ALUOut <= ~A;
        4'b0011:
            ALUOut <= ~B;
        4'b0100:
            ALUOut <= A+B;

        4'b0101:

        4'b0110:

        4'b0010:

    endcase
end


endmodule