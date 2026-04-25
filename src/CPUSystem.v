`timescale 1ns / 1ps

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);


    wire [5:0] Opcode;
    wire [1:0] RegSel;
    wire [7:0] Address;
    wire [2:0] DestReg, SrcReg1, SrcReg2;


    reg [2:0] RF_OutASel, RF_OutBSel;
    reg [1:0] RF_FunSel;
    reg [3:0] RF_RegSel, RF_ScrSel;


    reg [3:0] ALU_FunSel;
    reg       ALU_WF;


    reg [1:0] ARF_OutCSel;
    reg       ARF_OutDSel;
    reg [1:0] ARF_FunSel;
    reg [2:0] ARF_RegSel;


    reg IMU_CS, IMU_LH;
    reg DMU_WR, DMU_CS, DMU_FunSel;


    reg [1:0] MuxASel, MuxBSel;
    reg       MuxCSel;


    wire [15:0] OutA, OutB, OutC, OutD, OutE;
    wire [15:0] ALUOut, IROut, MuxAOut, MuxBOut;
    wire [7:0]  MuxCOut;
    wire Z, C, N, O;


    ArithmeticLogicUnitSystem ALUSys(
        .RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel),  .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF),
        .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel),
        .ARF_FunSel(ARF_FunSel),   .ARF_RegSel(ARF_RegSel),
        .IMU_CS(IMU_CS), .IMU_LH(IMU_LH),
        .DMU_WR(DMU_WR), .DMU_CS(DMU_CS), .DMU_FunSel(DMU_FunSel),
        .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel),
        .Clock(Clock),
        .OutA(OutA), .OutB(OutB), .OutC(OutC),
        .OutD(OutD), .OutE(OutE),
        .ALUOut(ALUOut), .IROut(IROut),
        .MuxAOut(MuxAOut), .MuxBOut(MuxBOut),
        .MuxCOut(MuxCOut),
        .Z(Z), .C(C), .N(N), .O(O)
    );

    // Instruction Decode

    assign Opcode  = IROut[15:10];
    assign RegSel  = IROut[9:8];
    assign Address = IROut[7:0];
    assign DestReg = IROut[9:7];
    assign SrcReg1 = IROut[6:4];
    assign SrcReg2 = IROut[3:1];



    reg T_Reset;        // counter
    reg cond_branch;
    function [3:0] rf_enable_mask;
        input [1:0] idx;
        begin
            case (idx)
                2'd0: rf_enable_mask = 4'b0111;
                2'd1: rf_enable_mask = 4'b1011;
                2'd2: rf_enable_mask = 4'b1101;
                2'd3: rf_enable_mask = 4'b1110;
            endcase
        end
    endfunction

    function [2:0] arf_enable_mask;
        input [1:0] idx;
        begin
            case (idx)
                2'd0, 2'd1: arf_enable_mask = 3'b011;   // PC
                2'd2:       arf_enable_mask = 3'b110;   // AR
                2'd3:       arf_enable_mask = 3'b101;   // SP
            endcase
        end
    endfunction

    function [2:0] rf_out_index;
        input [2:0] regcode;
        begin
            case (regcode)
                3'b100:  rf_out_index = 3'd0;
                3'b101:  rf_out_index = 3'd1;
                3'b110:  rf_out_index = 3'd2;
                3'b111:  rf_out_index = 3'd3;
                default: rf_out_index = 3'd0;
            endcase
        end
    endfunction

    always @(posedge Clock) begin
        if (~Reset || T_Reset)
            T <= 12'b0000_0000_0001;
        else
            T <= {T[10:0], T[11]};
    end

    always @(*) begin
        RF_OutASel  = rf_out_index(SrcReg1);
        RF_OutBSel  = rf_out_index(SrcReg2);
        RF_FunSel   = 2'b00;
        RF_RegSel   = 4'b1111;
        RF_ScrSel   = 4'b1111;
        ALU_FunSel  = Opcode[3:0];
        ALU_WF      = 1'b0;
        ARF_OutCSel = 2'b00;
        ARF_OutDSel = 1'b0;
        ARF_FunSel  = 2'b00;
        ARF_RegSel  = 3'b111;
        IMU_CS      = 1'b0;
        IMU_LH      = 1'b0;
        DMU_WR      = 1'b0;
        DMU_CS      = 1'b0;
        DMU_FunSel  = 1'b0;
        MuxASel     = 2'b00;
        MuxBSel     = 2'b00;
        MuxCSel     = 1'b0;
        T_Reset   = 1'b0;
        cond_branch = 1'b0;

        case (Opcode)
            6'h00:   cond_branch = 1'b1;
            6'h01:   cond_branch = (Z == 1'b0);
            6'h02:   cond_branch = (Z == 1'b1);
            6'h03:   cond_branch = (N != O);
            6'h04:   cond_branch = (N == O && Z == 1'b0);
            6'h05:   cond_branch = (N != O || Z == 1'b1);
            6'h06:   cond_branch = (N == O);
            default: cond_branch = 1'b0;
        endcase

        // ALU funsel
        case (Opcode)
            6'h09: ALU_FunSel = 4'b1011;   // LSL
            6'h0A: ALU_FunSel = 4'b1100;   // LSR
            6'h0B: ALU_FunSel = 4'b1101;   // ASR
            6'h0C: ALU_FunSel = 4'b1110;   // CSL
            6'h0D: ALU_FunSel = 4'b1111;   // CSR
            6'h0E: ALU_FunSel = 4'b0010;   // NOT
            6'h0F: ALU_FunSel = 4'b0111;   // AND
            6'h10: ALU_FunSel = 4'b1000;   // ORR
            6'h11: ALU_FunSel = 4'b1001;   // XOR
            6'h12: ALU_FunSel = 4'b1010;   // NAND
            6'h13: ALU_FunSel = 4'b0100;   // ADD
            6'h14: ALU_FunSel = 4'b0101;   // ADC
            6'h15: ALU_FunSel = 4'b0110;   // SUB
            6'h16: ALU_FunSel = 4'b0000;   // MOV
            default: ALU_FunSel = 4'b0000;
        endcase

        if (T[0]) begin
            ARF_RegSel = 3'b011;
            ARF_FunSel = 2'b10;
            IMU_CS     = 1'b1;
            IMU_LH     = 1'b0;


        end else if (T[1]) begin
            ARF_RegSel = 3'b011;
            ARF_FunSel = 2'b10;
            IMU_CS     = 1'b1;
            IMU_LH     = 1'b1;

        end else begin

            if (Opcode >= 6'h00 && Opcode <= 6'h06) begin
                if (T[2]) begin
                    if (cond_branch) begin
                        MuxBSel    = 2'b11;
                        ARF_RegSel = 3'b011;
                        ARF_FunSel = 2'b01;
                    end
                    T_Reset = 1'b1;
                end

            // immediate
            end else if (Opcode == 6'h17) begin
                if (T[2]) begin
                    MuxASel   = 2'b11;
                    RF_RegSel = rf_enable_mask(RegSel);
                    RF_FunSel = 2'b01;
                    T_Reset = 1'b1;
                end


            end else if (Opcode == 6'h07 || Opcode == 6'h08) begin
                if (T[2]) begin
                    if (SrcReg1[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg1[1:0];
                        MuxASel     = 2'b01;
                    end else begin
                        RF_OutASel  = rf_out_index(SrcReg1);
                        MuxASel     = 2'b00;
                    end
                    RF_ScrSel   = 4'b0111;
                    RF_FunSel   = 2'b01;
                    ALU_FunSel  = 4'b0000;

                end else if (T[3]) begin
                    RF_ScrSel = 4'b0111;
                    RF_FunSel = (Opcode == 6'h07) ? 2'b10 : 2'b11;

                end else if (T[4]) begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 4'b0000;
                    ALU_WF     = 1'b1;
                    if (DestReg[2] == 1'b0) begin
                        MuxBSel    = 2'b00;
                        ARF_RegSel = arf_enable_mask(DestReg[1:0]);
                        ARF_FunSel = 2'b01;
                    end else begin
                        MuxASel   = 2'b00;
                        RF_RegSel = rf_enable_mask(DestReg[1:0]);
                        RF_FunSel = 2'b01;
                    end
                    T_Reset = 1'b1;
                end

            // unary operations
            end else if ((Opcode >= 6'h09 && Opcode <= 6'h0E) || Opcode == 6'h16) begin
                if (T[2]) begin

                    if (SrcReg1[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg1[1:0];
                        MuxASel     = 2'b01;
                    end else begin
                        RF_OutASel  = rf_out_index(SrcReg1);
                        MuxASel     = 2'b00;
                    end
                    RF_ScrSel  = 4'b0111;
                    RF_FunSel  = 2'b01;
                    ALU_FunSel = 4'b0000;

                end else if (T[3]) begin

                    RF_OutASel = 3'b100;
                    if (Opcode != 6'h16) ALU_WF = 1'b1;
                    if (DestReg[2] == 1'b0) begin
                        MuxBSel    = 2'b00;
                        ARF_RegSel = arf_enable_mask(DestReg[1:0]);
                        ARF_FunSel = 2'b01;
                    end else begin
                        MuxASel   = 2'b00;
                        RF_RegSel = rf_enable_mask(DestReg[1:0]);
                        RF_FunSel = 2'b01;
                    end
                    T_Reset = 1'b1;
                end

            // binary operations
            end else if (Opcode >= 6'h0F && Opcode <= 6'h15) begin
                if (T[2]) begin
                    // first to s1
                    if (SrcReg1[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg1[1:0];
                        MuxASel     = 2'b01;
                    end else begin
                        RF_OutASel  = rf_out_index(SrcReg1);
                        MuxASel     = 2'b00;
                    end
                    RF_ScrSel  = 4'b0111;
                    RF_FunSel  = 2'b01;
                    ALU_FunSel = 4'b0000;

                end else if (T[3]) begin
                    // second to s2
                    if (SrcReg2[2] == 1'b0) begin
                        ARF_OutCSel = SrcReg2[1:0];
                        MuxASel     = 2'b01;
                    end else begin
                        RF_OutASel  = rf_out_index(SrcReg2);
                        MuxASel     = 2'b00;
                    end
                    RF_ScrSel  = 4'b1011;
                    RF_FunSel  = 2'b01;
                    ALU_FunSel = 4'b0000;

                end else if (T[4]) begin
                    RF_OutASel = 3'b100;
                    RF_OutBSel = 3'b101;
                    ALU_WF     = 1'b1;
                    if (DestReg[2] == 1'b0) begin
                        MuxBSel    = 2'b00;
                        ARF_RegSel = arf_enable_mask(DestReg[1:0]);
                        ARF_FunSel = 2'b01;
                    end else begin
                        MuxASel   = 2'b00;
                        RF_RegSel = rf_enable_mask(DestReg[1:0]);
                        RF_FunSel = 2'b01;
                    end
                    T_Reset = 1'b1;
                end
            end
        end

        if (~Reset) begin
            RF_FunSel  = 2'b00;
            RF_RegSel  = 4'b0000;
            RF_ScrSel  = 4'b0000;
            ARF_FunSel = 2'b00;
            ARF_RegSel = 3'b000;
        end
    end

endmodule