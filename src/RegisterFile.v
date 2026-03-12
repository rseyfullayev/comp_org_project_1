module RegisterFile(
    input wire clk,
    input wire [15:0] I,
    input wire [3:0] RegSel,
    input wire [3:0] ScrSel,
    input wire [1:0] FunSel,
    input wire [2:0] OutASel,
    input wire [2:0] OutBSel,

    output reg [15:0] OutA,
    output reg [15:0] OutB
);
    wire [15:0] R1_out;
    wire [15:0] R2_out;
    wire [15:0] R3_out;
    wire [15:0] R4_out;

    wire [15:0] S1_out;
    wire [15:0] S2_out;
    wire [15:0] S3_out;
    wire [15:0] S4_out;

    Register16bit R1(
        .clk(clk),
        .E(~RegSel[0]),
        .FunSel(FunSel),
        .I(I),
        .Q(R1_out)
    );

    Register16bit R2(
        .clk(clk),
        .E(~RegSel[1]),
        .FunSel(FunSel),
        .I(I),
        .Q(R2_out)
    );

    Register16bit R3(
        .clk(clk),
        .E(~RegSel[2]),
        .FunSel(FunSel),
        .I(I),
        .Q(R3_out)
    );

    Register16bit R4(
        .clk(clk),
        .E(~RegSel[3]),
        .FunSel(FunSel),
        .I(I),
        .Q(R4_out)
    );

    Register16bit S1(
        .clk(clk),
        .E(~ScrSel[0]),
        .FunSel(FunSel),
        .I(I),
        .Q(S1_out)
    );

    Register16bit S2(
        .clk(clk),
        .E(~ScrSel[1]),
        .FunSel(FunSel),
        .I(I),
        .Q(S2_out)
    );

    Register16bit S3(
        .clk(clk),
        .E(~ScrSel[2]),
        .FunSel(FunSel),
        .I(I),
        .Q(S3_out)
    );

    Register16bit S4(
        .clk(clk),
        .E(~ScrSel[3]),
        .FunSel(FunSel),
        .I(I),
        .Q(S4_out)
    );



always @(*) begin
    case(OutASel)
        3'b000:
            OutA = R1_out;
        3'b001:
            OutA = R2_out;
        3'b010:
            OutA = R3_out;
        3'b011:
            OutA = R4_out;
        3'b100:
            OutA = S1_out;
        3'b101:
            OutA = S2_out;
        3'b110:
            OutA = S3_out;
        3'b111:
            OutA = S4_out;
        default:
            OutA = 0;
    endcase

    case(OutBSel)
        3'b000:
            OutB = R1_out;
        3'b001:
            OutB = R2_out;
        3'b010:
            OutB = R3_out;
        3'b011:
            OutB = R4_out;
        3'b100:
            OutB = S1_out;
        3'b101:
            OutB = S2_out;
        3'b110:
            OutB = S3_out;
        3'b111:
            OutB = S4_out;
        default:
            OutB = 0;
    endcase

end


endmodule