module AddressRegisterFile(
    input wire clk,
    input wire [15:0] I,
    input wire [2:0] RegSel,
    input wire [1:0] FunSel,
    input wire [1:0] OutCSel,
    input wire OutDSel,
    
    output reg [15:0] OutC,
    output reg [15:0] OutD,
    output reg [15:0] OutE
);
    wire [15:0] PC_out, SP_out, AR_out;
    reg E_PC, E_SP, E_AR;
    
always @(*) begin
    //Choosing the address registers to enable
    case (RegSel)
        3'b000: {E_PC, E_SP, E_AR} = 3'b111; // All enabled
        3'b001: {E_PC, E_SP, E_AR} = 3'b110; // PC and SP
        3'b010: {E_PC, E_SP, E_AR} = 3'b101; // PC and AR
        3'b011: {E_PC, E_SP, E_AR} = 3'b011; // SP and AR
        3'b100: {E_PC, E_SP, E_AR} = 3'b011; // SP and AR
        3'b101: {E_PC, E_SP, E_AR} = 3'b010; // Only SP
        3'b110: {E_PC, E_SP, E_AR} = 3'b001; // Only AR
        3'b111: {E_PC, E_SP, E_AR} = 3'b000; // None
        default: {E_PC, E_SP, E_AR} = 3'b000; //None
    endcase
    
    //Output C
    case (OutCSel)
        2'b00: OutC = PC_out;
        2'b01: OutC = PC_out;
        2'b10: OutC = AR_out;
        2'b11: OutC = SP_out;
    endcase
    
    //Output D
    if (OutDSel) OutD = SP_out;
    else OutD = AR_out;
    
    //Output E
    OutE = PC_out;
end
    
    //Instantiating the registers
    Register16bit PC(
        .clk(clk),
        .E(E_PC),
        .FunSel(FunSel),
        .I(I),
        .Q(PC_out)
    );
    
    Register16bit SP(
        .clk(clk),
        .E(E_SP),
        .FunSel(FunSel),
        .I(I),
        .Q(SP_out)
    );
    
    Register16bit AR(
        .clk(clk),
        .E(E_AR),
        .FunSel(FunSel),
        .I(I),
        .Q(AR_out)
    );
endmodule