module CPUSystem(
    input wire Clock,
    input wire Reset,
    input wire [11:0] T // RF_ScrSel
);

    reg T_Reset;

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

        T_Reset     = 1'b0;

        if (Reset) begin
            ARF_RegSel = 3'b000;
            ARF_FunSel = 2'b00;
        end
        else begin
            if (T[0]) begin
                IMU_CS = 1'b1;
                IMU_LH = 1'b0;
                ARF_RegSel = 3'b011;
                ARF_FunSel = 2'b10;
            end
            else if (T[1]) begin
                IMU_CS = 1'b1;
                IMU_LH = 1'b1;
                ARF_RegSel = 3'b011;
                ARF_FunSel = 2'b10;
            end
            else if (T[2]) begin
                case (Opcode)
                    6'h00: begin end // BRA

                    6'h01: begin // BNE
                        if (Z) begin
                        end
                    end

                    6'h02: begin end // BEQ
                    6'h03: begin end // BLT
                    6'h04: begin end // BGT
                    6'h05: begin end // BLE
                    6'h06: begin end // BGE
                    6'h07: begin end // INC
                    6'h08: begin end // DEC

                    6'h09: begin // LSL
                        if (!SrcReg1[2]) begin
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 2'b01;
                        end
                    end

                    6'h0A: begin
                        if (!SrcReg1[2]) begin
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 2'b01;
                        end
                    end // LSR
                    6'h0B: begin
                        if (!SrcReg1[2]) begin
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 2'b01;
                        end
                    end // ASR
                    6'h0C: begin
                        if (!SrcReg1[2]) begin
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 2'b01;
                        end
                    end // CSL
                    6'h0D: begin
                        if (!SrcReg1[2]) begin
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b0111;
                            RF_FunSel = 2'b01;
                        end
                    end // CSR
                    6'h0E: begin end // NOT
                    6'h0F: begin
                        wire [1:0] x = {SrcReg1[2], SrcReg2[2]};

                        case(x)
                            2'00 begin
                                OutCSel = SrcReg1[1:0];
                                MuxASel = 2'b01;
                                RF_ScrSel = 4'b0111;
                                RF_FunSel = 2'b01;
                            end
                            2'01 begin
                                OutCSel = SrcReg1[1:0];
                                MuxASel = 2'b01;
                                RF_ScrSel = 4'b0111;
                                RF_FunSel = 2'b01;
                            end
                            2'10 begin
                                OutCSel = SrcReg2[1:0];
                                MuxASel = 2'b01;
                                RF_ScrSel = 4'b0111;
                                RF_FunSel = 2'b01;
                            end

                        endcase
                    end // AND

                    6'h10: begin end // ORR
                    6'h11: begin end // XOR
                    6'h12: begin end // NAND
                    6'h13: begin end // ADD
                    6'h14: begin end // ADC
                    6'h15: begin end // SUB
                    6'h16: begin end // MOV
                    6'h17: begin end // IMM
                endcase
            end
            else if (T[3]) begin
                case (Opcode)
                    6'h00: begin end // BRA

                    6'h01: begin // BNE
                        if (Z) begin
                        end
                    end

                    6'h02: begin end // BEQ
                    6'h03: begin end // BLT
                    6'h04: begin end // BGT
                    6'h05: begin end // BLE
                    6'h06: begin end // BGE
                    6'h07: begin end // INC
                    6'h08: begin end // DEC

                    6'h09: begin // LSL
                        if(SrcReg1[2]) begin
                            RF_OutASel[2] = ~SrcReg1[2];
                            RF_OutASel[1:0] = SrcReg1[1:0];
                        end
                        else
                            RF_OutASel = 3'b100;

                        if (DestReg[2]) begin
                            MuxASel = 2'b00;
                            RF_RegSel = ~(4'b1000 >> DestReg[1:0]);
                            RF_FunSel = 2'b01;
                        end
                        else begin
                            MuxBSel = 2'b00;
                            case(DestReg[1:0])
                                2'b00, 2'b01: ARF_RegSel = 3'b011;
                                2'b10:        ARF_RegSel = 3'b110;
                                2'b11:        ARF_RegSel = 3'b101;
                            endcase
                            ARF_FunSel = 2'b01;
                        end
                        ALU_FunSel = 4'b1011;
                        ALU_WF = 1'b1;
                        T_Reset = 1'b1;

                    end

                    6'h0A: begin
                        if(SrcReg1[2]) begin
                            RF_OutASel[2] = ~SrcReg1[2];
                            RF_OutASel[1:0] = SrcReg1[1:0];
                        end
                        else
                            RF_OutASel = 3'b100;

                        if (DestReg[2]) begin
                            MuxASel = 2'b00;
                            RF_RegSel = ~(4'b1000 >> DestReg[1:0]);
                            RF_FunSel = 2'b01;
                        end
                        else begin
                            MuxBSel = 2'b00;
                            case(DestReg[1:0])
                                2'b00, 2'b01: ARF_RegSel = 3'b011;
                                2'b10:        ARF_RegSel = 3'b110;
                                2'b11:        ARF_RegSel = 3'b101;
                            endcase
                            ARF_FunSel = 2'b01;
                        end
                        ALU_FunSel = 4'b1100;
                        ALU_WF = 1'b1;
                        T_Reset = 1'b1;
                    end // LSR

                    6'h0B: begin
                        if(SrcReg1[2]) begin
                            RF_OutASel[2] = ~SrcReg1[2];
                            RF_OutASel[1:0] = SrcReg1[1:0];
                        end
                        else
                            RF_OutASel = 3'b100;

                        if (DestReg[2]) begin
                            MuxASel = 2'b00;
                            RF_RegSel = ~(4'b1000 >> DestReg[1:0]);
                            RF_FunSel = 2'b01;
                        end
                        else begin
                            MuxBSel = 2'b00;
                            case(DestReg[1:0])
                                2'b00, 2'b01: ARF_RegSel = 3'b011;
                                2'b10:        ARF_RegSel = 3'b110;
                                2'b11:        ARF_RegSel = 3'b101;
                            endcase
                            ARF_FunSel = 2'b01;
                        end
                        ALU_FunSel = 4'b1101;
                        ALU_WF = 1'b1;
                        T_Reset = 1'b1;
                    end // ASR
                    6'h0C: begin
                        if(SrcReg1[2]) begin
                            RF_OutASel[2] = ~SrcReg1[2];
                            RF_OutASel[1:0] = SrcReg1[1:0];
                        end
                        else
                            RF_OutASel = 3'b100;

                        if (DestReg[2]) begin
                            MuxASel = 2'b00;
                            RF_RegSel = ~(4'b1000 >> DestReg[1:0]);
                            RF_FunSel = 2'b01;
                        end
                        else begin
                            MuxBSel = 2'b00;
                            case(DestReg[1:0])
                                2'b00, 2'b01: ARF_RegSel = 3'b011;
                                2'b10:        ARF_RegSel = 3'b110;
                                2'b11:        ARF_RegSel = 3'b101;
                            endcase
                            ARF_FunSel = 2'b01;
                        end
                        ALU_FunSel = 4'b1110;
                        ALU_WF = 1'b1;
                        T_Reset = 1'b1;
                    end // CSL
                    6'h0D: begin
                        if(SrcReg1[2]) begin
                            RF_OutASel[2] = ~SrcReg1[2];
                            RF_OutASel[1:0] = SrcReg1[1:0];
                        end
                        else
                            RF_OutASel = 3'b100;

                        if (DestReg[2]) begin
                            MuxASel = 2'b00;
                            RF_RegSel = ~(4'b1000 >> DestReg[1:0]);
                            RF_FunSel = 2'b01;
                        end
                        else begin
                            MuxBSel = 2'b00;
                            case(DestReg[1:0])
                                2'b00, 2'b01: ARF_RegSel = 3'b011;
                                2'b10:        ARF_RegSel = 3'b110;
                                2'b11:        ARF_RegSel = 3'b101;
                            endcase
                            ARF_FunSel = 2'b01;
                        end
                        ALU_FunSel = 4'b1111;
                        ALU_WF = 1'b1;
                        T_Reset = 1'b1;
                    end // CSR
                    6'h0E: begin end // NOT
                    6'h0F: begin end // AND

                    6'h10: begin end // ORR
                    6'h11: begin end // XOR
                    6'h12: begin end // NAND
                    6'h13: begin end // ADD
                    6'h14: begin end // ADC
                    6'h15: begin end // SUB
                    6'h16: begin end // MOV
                    6'h17: begin end // IMM
                endcase
            end
            else if (T[4]) begin
                case (Opcode)
                    6'h00: begin end // BRA

                    6'h01: begin // BNE
                        if (Z) begin
                        end
                    end

                    6'h02: begin end // BEQ
                    6'h03: begin end // BLT
                    6'h04: begin end // BGT
                    6'h05: begin end // BLE
                    6'h06: begin end // BGE
                    6'h07: begin end // INC
                    6'h08: begin end // DEC
                    6'h09: begin end // LSL

                    6'h0A: begin end // LSR
                    6'h0B: begin end // ASR
                    6'h0C: begin end // CSL
                    6'h0D: begin end // CSR
                    6'h0E: begin end // NOT
                    6'h0F: begin end // AND
                    6'h10: begin end // ORR
                    6'h11: begin end // XOR
                    6'h12: begin end // NAND
                    6'h13: begin end // ADD
                    6'h14: begin end // ADC
                    6'h15: begin end // SUB
                    6'h16: begin end // MOV
                    6'h17: begin end // IMM
                endcase
            end
        end
    end

endmodule