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
    // Added outputs so the testbench can access them directly
    output wire [15:0] OutA, OutB, OutC, OutD, OutE,
    output wire [15:0] ALUOut, MuxAOut, MuxBOut, IROut,
    output wire [7:0]  MuxCOut,
    output wire        Z, C, N, O
);

    wire [3:0]  flags;
    wire [15:0] DMUOut;
    wire [15:0] IMUOut;

    // Flag assignments
    assign {Z, C, N, O} = flags;

    // MuxC Logic
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

    // Renamed from RF_input to MuxAOut to match simulation naming
    MuxAB muxA(
        .A(ALUOut),
        .B(OutC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxASel),
        .out(MuxAOut)
    );

    // Renamed from ARF_input to MuxBOut to match simulation naming
    MuxAB muxB(
        .A(ALUOut),
        .B(OutC),
        .C(DMUOut),
        .D(IMUOut),
        .sel(MuxBSel),
        .out(MuxBOut)
    );

    RegisterFile RF(
        .clk(Clock),
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
        .clk(Clock),
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
        .clk(Clock),
        .add(OutD),
        .I(MuxCOut),
        .out(DMUOut)
    );

endmodule