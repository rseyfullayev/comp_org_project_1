`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Project Name: BLG222E Project 2 Simulation (LSL ONLY)
//////////////////////////////////////////////////////////////////////////////////

module CPUSystemSimulation();

    reg [11:0] T;
    integer test_no;
    integer clock_count;
    wire clock;
    wire reset;

    wire [5:0] Opcode;
    wire [1:0] RegSel;
    wire [7:0] Address;
    wire [2:0] DestReg;
    wire [2:0] SrcReg1;
    wire [2:0] SrcReg2;

    CrystalOscillator clk();
    ResetGenerator rg();

    CPUSystem CPUSys(
        .Clock(clk.clock),
        .Reset(rg.reset),
        .T(T)
    );

    FileOperation F();

    assign clock = clk.clock;
    assign reset = rg.reset;

    //----------------------------------------
    // TASKS (same as original)
    //----------------------------------------

    task ClearRegisters;
        begin
            clock_count = 0;

            CPUSys.ALUSys.RF.R1.Q = 16'h0;
            CPUSys.ALUSys.RF.R2.Q = 16'h0;
            CPUSys.ALUSys.RF.R3.Q = 16'h0;
            CPUSys.ALUSys.RF.R4.Q = 16'h0;
            CPUSys.ALUSys.RF.S1.Q = 16'h0;
            CPUSys.ALUSys.RF.S2.Q = 16'h0;
            CPUSys.ALUSys.RF.S3.Q = 16'h0;
            CPUSys.ALUSys.RF.S4.Q = 16'h0;
            CPUSys.ALUSys.ARF.PC.Q = 16'h0;
            CPUSys.ALUSys.ARF.AR.Q = 16'h0;
            CPUSys.ALUSys.ARF.SP.Q = 16'h00FF;
            CPUSys.ALUSys.ALU.FlagsOut = 4'b0000;
            CPUSys.ALUSys.DMU.DR.DROut = 16'h0;
            CPUSys.ALUSys.IMU.IR.IROut = 16'h0;
        end
    endtask

    task DisableAll;
        begin
            CPUSys.RF_RegSel = 4'b1111;
            CPUSys.RF_ScrSel = 4'b1111;
            CPUSys.ARF_RegSel = 3'b111;
            CPUSys.ALU_WF = 0;
            CPUSys.IMU_CS = 0;
            CPUSys.DMU_CS = 0;
            CPUSys.T_Reset = 1;
        end
    endtask

    //----------------------------------------
    // SIGNAL OBSERVE
    //----------------------------------------

    assign Opcode  = CPUSys.Opcode;
    assign RegSel  = CPUSys.RegSel;
    assign Address = CPUSys.Address;
    assign DestReg = CPUSys.DestReg;
    assign SrcReg1 = CPUSys.SrcReg1;
    assign SrcReg2 = CPUSys.SrcReg2;

    //----------------------------------------
    // MAIN TEST
    //----------------------------------------

    initial begin
        F.SimulationName = "CPUSystem_LSL";
        F.InitializeSimulation(0);
        clk.clock = 0;
        T = 12'b0000_0000_0000;

        //----------------------------------------
        // LSL TEST ONLY
        //----------------------------------------
        test_no = 1;
        clock_count = 0;

        DisableAll();
        ClearRegisters();

        // Set initial value
        CPUSys.ALUSys.ARF.PC.Q = 16'h0005;

        // Load LSL instruction (same as original)
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2400;

        // Start from T2/T3 stage
        T = 12'b0000_0000_0100;

        // Run until cycle resets
        T = 12'b0000_0000_0100;   // start at T[2]

while (T != 12'b0000_0000_0001 && clock_count <= 15) begin
    clk.Clock();
    clock_count = clock_count + 1;

    if (T == 12'b0001_0000_0000)
        T = 12'b0000_0000_0001;
    else
        T = T << 1;
end

        //----------------------------------------
        // CHECKS (same style)
        //----------------------------------------
        // Note: OutA and ALUOut are combinational wires. By the time this check runs,
        // T has looped back to T[0], which sets OutA and ALUOut to their default 0x0000.
        // Therefore, we only check the PC register, which stores the final result.
        // F.CheckValues(CPUSys.ALUSys.OutA,   16'h0005, test_no, "OutA");
        // F.CheckValues(CPUSys.ALUSys.ALUOut, 16'h000a, test_no, "ALUOut");
        F.CheckValues(CPUSys.ALUSys.ARF.PC.Q,16'h000a, test_no, "PC");




        //----------------------------------------
        // TEST 2: LSR R1, R1
        //----------------------------------------
        test_no = 2;
        clock_count = 0;
        DisableAll();
        ClearRegisters();

        CPUSys.ALUSys.RF.R1.Q = 16'h0005;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2A40; // LSR R1, R1
        T = 12'b0000_0000_0100;

        while (T != 12'b0000_0000_0001 && clock_count <= 15) begin
            clk.Clock();
            clock_count = clock_count + 1;
            if (T == 12'b0001_0000_0000) T = 12'b0000_0000_0001;
            else T = T << 1;
        end

        F.CheckValues(CPUSys.ALUSys.RF.R1.Q, 16'h0002, test_no, "R1");

        //----------------------------------------
        // TEST 3: ASR R2, R2
        //----------------------------------------
        test_no = 3;
        clock_count = 0;
        DisableAll();
        ClearRegisters();

        CPUSys.ALUSys.RF.R2.Q = 16'hFFFE; // -2
        CPUSys.ALUSys.IMU.IR.IROut = 16'h2ED0; // ASR R2, R2
        T = 12'b0000_0000_0100;

        while (T != 12'b0000_0000_0001 && clock_count <= 15) begin
            clk.Clock();
            clock_count = clock_count + 1;
            if (T == 12'b0001_0000_0000) T = 12'b0000_0000_0001;
            else T = T << 1;
        end

        F.CheckValues(CPUSys.ALUSys.RF.R2.Q, 16'hFFFF, test_no, "R2");

        //----------------------------------------
        // TEST 4: CSL AR, AR
        //----------------------------------------
        test_no = 4;
        clock_count = 0;
        DisableAll();
        ClearRegisters();

        CPUSys.ALUSys.ARF.AR.Q = 16'h4005;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h3120; // CSL AR, AR
        T = 12'b0000_0000_0100;

        while (T != 12'b0000_0000_0001 && clock_count <= 15) begin
            clk.Clock();
            clock_count = clock_count + 1;
            if (T == 12'b0001_0000_0000) T = 12'b0000_0000_0001;
            else T = T << 1;
        end

        F.CheckValues(CPUSys.ALUSys.ARF.AR.Q, 16'h800a, test_no, "AR");

        //----------------------------------------
        // TEST 5: CSR SP, SP
        //----------------------------------------
        test_no = 5;
        clock_count = 0;
        DisableAll();
        ClearRegisters();

        CPUSys.ALUSys.ARF.SP.Q = 16'h000A;
        CPUSys.ALUSys.IMU.IR.IROut = 16'h35B0; // CSR SP, SP
        T = 12'b0000_0000_0100;

        while (T != 12'b0000_0000_0001 && clock_count <= 15) begin
            clk.Clock();
            clock_count = clock_count + 1;
            if (T == 12'b0001_0000_0000) T = 12'b0000_0000_0001;
            else T = T << 1;
        end

        F.CheckValues(CPUSys.ALUSys.ARF.SP.Q, 16'h0005, test_no, "SP");

        //----------------------------------------
        F.FinishSimulation();
    end

endmodule