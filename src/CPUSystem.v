module CPUSystem(
    input wire Clock,
    input wire Reset,
    input wire [11:0] T // RF_ScrSel
);

    reg [2:0] RF_OutASel, RF_OutBSel;
    reg [1:0] RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [3:0] ALU_FunSel;
    reg ALU_WF;

    reg [1:0] ARF_OutCSel, ARF_FunSel;
    reg [2:0] ARF_RegSel;
    reg ARF_OutDSel;

    reg IMU_CS, IMU_LH;
    reg DMU_WR, DMU_CS, DMU_FunSel;

    reg [1:0] MuxASel, MuxBSel;
    reg MuxCSel;


    wire [15:0] OutA, OutB, OutC, OutD, OutE;
    wire [15:0] ALUOut, MuxAOut, MuxBOut, IROut;
    wire [7:0] MuxCOut;
    wire Z, C, N, O;


    wire [5:0] Opcode;
    wire [1:0] RegSel;
    wire [7:0] Address;
    wire [2:0] DestReg;
    wire [2:0] SrcReg1;
    wire [2:0] SrcReg2;

    assign Opcode  = IROut[15:10];

    assign RegSel  = IROut[9:8];
    assign Address = IROut[7:0];

    assign DestReg = IROut[9:7];
    assign SrcReg1 = IROut[6:4];
    assign SrcReg2 = IROut[3:1];


    ArithmeticLogicUnitSystem ALUSys(
        .RF_OutASel(RF_OutASel),
        .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),
        .ARF_OutCSel(ARF_OutCSel),
        .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),
        .ARF_OutDSel(ARF_OutDSel),
        .IMU_CS(IMU_CS),
        .IMU_LH(IMU_LH),
        .DMU_WR(DMU_WR),
        .DMU_CS(DMU_CS),
        .DMU_FunSel(DMU_FunSel),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .Clock(Clock),

        .OutA(OutA),
        .OutB(OutB),
        .OutC(OutC),
        .OutD(OutD),
        .OutE(OutE),
        .ALUOut(ALUOut),
        .MuxAOut(MuxAOut),
        .MuxBOut(MuxBOut),
        .IROut(IROut),
        .MuxCOut(MuxCOut),
        .Z(Z),
        .C(C),
        .N(N),
        .O(O)
    );


    always @(*) begin

        RF_OutASel  = 3'b000;
        RF_OutBSel  = 3'b000;
        RF_FunSel   = 2'b00;
        RF_RegSel   = 4'b1111;
        RF_ScrSel   = 4'b1111;
        ALU_FunSel  = 4'b0000;
        ALU_WF      = 1'b0;

        ARF_OutCSel = 2'b00;
        ARF_FunSel  = 2'b00;
        ARF_RegSel  = 3'b111;
        ARF_OutDSel = 1'b0;

        IMU_CS      = 1'b0;
        IMU_LH      = 1'b0;
        DMU_WR      = 1'b0;
        DMU_CS      = 1'b0;
        DMU_FunSel  = 1'b0;

        MuxASel     = 2'b00;
        MuxBSel     = 2'b00;
        MuxCSel     = 1'b0;


        if (Reset) begin
            ARF_RegSel = 3'b011;
            ARF_FunSel = 2'b00;
        end
        else begin
            if (T[0]) begin
                ARF_RegSel  = 3'011;
                ARF_FunSel  = 2'b10;
            end
            else if (T[1]) begin
                IMU_LH = 1;
            end
            else if (T[2]) begin
                case(Opcode)
                    6'h00: // BRA

                    6'h01: // BNE
                        if(Z):


                    6'h02: // BEQ

                    6'h03: // BLT
                    6'h04: // BGT
                    6'h05: // BLE
                    6'h06: // BGE
                    6'h07: // INC
                    6'h08: // DEC
                    6'h09: // LSL

                    6'h0A: // LSR
                    6'h0B: // ASR
                    6'h0C: // CSL
                    6'h0D: // CSR
                    6'h0E: // NOT
                    6'h0F: // AND
                    6'h10: // ORR
                    6'h11: // XOR
                    6'h12: // NAND
                    6'h13: // ADD
                    6'h14: // ADC
                    6'h15: // SUB
                    6'h16: // MOV
                    6'h17: // IMM
                endcase
            end
            else if (T[3]) begin
                case(Opcode)
                    6'h00: // BRA

                    6'h01: // BNE
                        if(Z):


                    6'h02: // BEQ

                    6'h03: // BLT
                    6'h04: // BGT
                    6'h05: // BLE
                    6'h06: // BGE
                    6'h07: // INC
                    6'h08: // DEC
                    6'h09: // LSL

                    6'h0A: // LSR
                    6'h0B: // ASR
                    6'h0C: // CSL
                    6'h0D: // CSR
                    6'h0E: // NOT
                    6'h0F: // AND
                    6'h10: // ORR
                    6'h11: // XOR
                    6'h12: // NAND
                    6'h13: // ADD
                    6'h14: // ADC
                    6'h15: // SUB
                    6'h16: // MOV
                    6'h17: // IMM
                endcase
            end
            else if (T[4]) begin
                case(Opcode)
                    6'h00: // BRA

                    6'h01: // BNE
                        if(Z):


                    6'h02: // BEQ

                    6'h03: // BLT
                    6'h04: // BGT
                    6'h05: // BLE
                    6'h06: // BGE
                    6'h07: // INC
                    6'h08: // DEC
                    6'h09: // LSL

                    6'h0A: // LSR
                    6'h0B: // ASR
                    6'h0C: // CSL
                    6'h0D: // CSR
                    6'h0E: // NOT
                    6'h0F: // AND
                    6'h10: // ORR
                    6'h11: // XOR
                    6'h12: // NAND
                    6'h13: // ADD
                    6'h14: // ADC
                    6'h15: // SUB
                    6'h16: // MOV
                    6'h17: // IMM
                endcase
            end
        end
    end
endmodule