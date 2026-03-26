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
            2'b00: out = A;
            2'b01: out = B;
            2'b10: out = C;
            2'b11: out = D;
            default: out = 16'b0;
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
    output wire       Z, C, N, O
);


    wire [15:0] RF_input;
    wire [15:0] RF_outA;
    wire [15:0] RF_outB;
    wire [15:0] ALUOut;
    wire [3:0]  flags;
    wire [15:0] DMUOut;
    wire [15:0] ARF_input;
    wire [15:0] outC;
    wire [15:0] outD;
    wire [15:0] outE;
    wire [15:0] IMUOut;
    wire [15:0] IROut;
    wire [7:0]  muxCOut;


    assign Z = flags[3];
    assign C = flags[2];
    assign N = flags[1];
    assign O = flags[0];


    assign muxCOut = (MuxCSel) ? ALUOut[15:8] : ALUOut[7:0];


    ArithmeticLogicUnit ALU(
        .A(RF_outA),
        .B(RF_outB),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .Clock(Clock),
        .ALUOut(ALUOut),
        .FlagsOut(flags)
    );

    MuxAB muxA(
        .A(ALUOut),
        .B(outC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxASel),
        .out(RF_input)
    );

    MuxAB muxB(
        .A(ALUOut),
        .B(outC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxBSel),
        .out(ARF_input)
    );

    RegisterFile regFile(
        .clk(Clock),
        .I(RF_input),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .FunSel(RF_FunSel),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .OutA(RF_outA),
        .OutB(RF_outB)
    );

    AddressRegisterFile ARF(
        .clk(Clock),
        .I(ARF_input),
        .RegSel(ARF_RegSel),
        .FunSel(ARF_FunSel),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .OutC(outC),
        .OutD(outD),
        .OutE(outE)
    );

    InstructionMemoryUnit IMU(
        .Address(outE),
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
        .clk(Clock),
        .add(outD),
        .I(muxCOut),
        .out(DMUOut)
    );

endmodule
