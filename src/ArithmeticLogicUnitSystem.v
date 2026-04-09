`timescale 1ns / 1ps
module MuxAB(
    input wire [15:0] A,
    input wire [15:0] B,
    input wire [15:0] C,
    input wire [15:0] D,
    input wire [1:0] sel,
    output reg [15:0] out
);
    always @(*) begin
        case(sel)
            2'b00:  out <= A;
            2'b01:  out <= B;
            2'b10:  out <= C;
            2'b11:  out <= D;
            default: out <= 16'b0;
        endcase
    end
endmodule

module ArithmeticLogicUnitSystem(
    input wire [2:0]  RF_OutASel, RF_OutBSel,
    input wire [1:0]  RF_FunSel,
    input wire [3:0]  RF_RegSel, RF_ScrSel,
    input wire [3:0]  ALU_FunSel,
    input wire        ALU_WF,
    input wire [1:0]  ARF_OutCSel, ARF_FunSel,
    input wire [2:0]  ARF_RegSel,
    input wire        ARF_OutDSel,
    input wire IMU_CS, IMU_LH, DMU_WR, DMU_CS, DMU_FunSel,
    input wire [1:0]  MuxASel, MuxBSel,
    input wire        MuxCSel,
    input wire        Clock,

    output wire [15:0] OutA, OutB, OutC, OutD, OutE,
    output wire [15:0] ALUOut, MuxAOut, MuxBOut, IROut,
    output wire [7:0]  MuxCOut,
    output wire        Z, C, N, O
);

    wire [3:0]  flags;
    wire [15:0] DMUOut;
    wire [15:0] IMUOut;

    assign {Z, C, N, O} = flags;

    assign MuxCOut = (MuxCSel) ? ALUOut[15:8] : ALUOut[7:0];

    ArithmeticLogicUnit ALU(
        .A(OutA),
        .B(OutB),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .Clock(Clock),
        .ALUOut(ALUOut),
        .FlagsOut(flags)
    );

    MuxAB muxA(
        .A(ALUOut),
        .B(OutC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxASel),
        .out(MuxAOut)
    );

    MuxAB muxB(
        .A(ALUOut),
        .B(OutC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxBSel),
        .out(MuxBOut)
    );

    RegisterFile RF(
        .Clock(Clock),
        .I(MuxAOut),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .FunSel(RF_FunSel),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .OutA(OutA),
        .OutB(OutB)
    );

    AddressRegisterFile ARF(
        .Clock(Clock),
        .I(MuxBOut),
        .RegSel(ARF_RegSel),
        .FunSel(ARF_FunSel),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .OutC(OutC),
        .OutD(OutD),
        .OutE(OutE)
    );

    InstructionMemoryUnit IMU(
        .Address(OutE),
        .CS(IMU_CS),
        .LH(IMU_LH),
        .Clock(Clock),
        .IMUOut(IMUOut),
        .IROut(IROut)
    );

    DataMemoryUnit DMU(
        .CS(DMU_CS),
        .WR(DMU_WR),
        .FunSel(DMU_FunSel),
        .Clock(Clock),
        .Address(OutD),
        .I(MuxCOut),
        .DMUOut(DMUOut)
    );

endmodule