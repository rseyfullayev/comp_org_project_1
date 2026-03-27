module flagReg (
    input wire [3:0] flagIn,
    input wire WF,
    input wire clk,
    input wire [3:0] mask,
    output wire Cin
);
    reg [3:0] flag;
    always @(posedge clk) begin
        if(WF)
            flag <= (mask & flagIn) | (~mask & flag);
    end
    assign Cin = flag[2];
endmodule


module LogicUnit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [3:0] Funsel,
    input wire Cin,
    output reg [3:0] flagOut,
    output reg [15:0] ALUOut,
    output reg [3:0] mask
);
    reg [16:0] temp;

    always @(*) begin

        flagOut[2] = 1'b0;
        flagOut[0] = 1'b0;
        temp       = 17'b0;
        mask       = 4'b0000;
        ALUOut     = 16'b0;

        case (Funsel)
            4'b0000: begin
                ALUOut = A;
                mask   = 4'b1010;
            end
            4'b0001: begin
                ALUOut = B;
                mask   = 4'b1010;
            end
            4'b0010: begin
                ALUOut = ~A;
                mask   = 4'b1010;
            end
            4'b0011: begin
                ALUOut = ~B;
                mask   = 4'b1010;
            end
            4'b0100: begin
                temp       = {1'b0, A} + {1'b0, B};
                ALUOut     = temp[15:0];
                flagOut[2] = temp[16];
                flagOut[0] = (~A[15] & ~B[15] & temp[15]) |
                             ( A[15] &  B[15] & ~temp[15]);
                mask       = 4'b1111;
            end
            4'b0101: begin
                temp       = {1'b0, A} + {1'b0, B} + Cin;
                ALUOut     = temp[15:0];
                flagOut[2] = temp[16];
                flagOut[0] = (~A[15] & ~B[15] & temp[15]) |
                             ( A[15] &  B[15] & ~temp[15]);
                mask       = 4'b1111;
            end
            4'b0110: begin
                temp       = {1'b0, A} - {1'b0, B};
                ALUOut     = temp[15:0];
                flagOut[2] = temp[16];
                flagOut[0] = (~A[15] &  B[15] &  temp[15]) |
                             ( A[15] & ~B[15] & ~temp[15]);
                mask       = 4'b1111;
            end
            4'b0111: begin
                ALUOut = A & B;
                mask   = 4'b1010;
            end
            4'b1000: begin
                ALUOut = A | B;
                mask   = 4'b1010;
            end
            4'b1001: begin
                ALUOut = A ^ B;
                mask   = 4'b1010;
            end
            4'b1010: begin
                ALUOut = ~(A & B);
                mask   = 4'b1010;
            end
            4'b1011: begin
                ALUOut     = A << 1;
                flagOut[2] = A[15];
                mask       = 4'b1110;
            end
            4'b1100: begin
                ALUOut     = A >> 1;
                flagOut[2] = A[0];
                mask       = 4'b1110;
            end
            4'b1101: begin
                ALUOut = $signed(A) >>> 1;
                mask   = 4'b1000;
            end
            4'b1110: begin
                ALUOut     = {A[14:0], A[15]};
                flagOut[2] = A[15];
                mask       = 4'b1110;
            end
            4'b1111: begin
                ALUOut     = {A[0], A[15:1]};
                flagOut[2] = A[0];
                mask       = 4'b1110;
            end
        endcase
    end


    always @(*) begin
        flagOut[3] = (ALUOut == 16'b0) ? 1'b1 : 1'b0;
        flagOut[1] = ALUOut[15];
    end

endmodule


module ArithmeticLogicUnit(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [3:0]  FunSel,
    input wire WF,
    input wire Clock,

    output wire [15:0] ALUOut,
    output reg [3:0]  FlagsOut
);
    wire [3:0] mask;
    wire [3:0] flagOut_internal;
    wire Cin;

    LogicUnit alu(
        .A(A),
        .B(B),
        .Funsel(FunSel),
        .Cin(Cin),
        .flagOut(flagOut_internal),
        .ALUOut(ALUOut),
        .mask(mask)
    );

    flagReg flag(
        .flagIn(flagOut_internal),
        .WF(WF),
        .clk(Clock),
        .mask(mask),
        .Cin(Cin)
    );
    always @(*)
        FlagsOut = flagOut_internal;
endmodule