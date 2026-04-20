`timescale 1ns / 1ps

module ArithmeticLogicUnit (
input wire [15:0] A,
input wire [15:0] B,
input wire [3:0] FunSel,
input wire WF,
input wire Clock,
output reg [15:0] ALUOut,
output reg [3:0] FlagsOut
);

reg [3:0] current_mask;
reg c_val, o_val;

always @(*) begin
    ALUOut = 16'h0;
    current_mask = 4'b0000;
    c_val = 1'b0;
    o_val = 1'b0;

    case (FunSel)
        4'b0000: begin ALUOut = A; current_mask = 4'b1010; end
        4'b0001: begin ALUOut = B; current_mask = 4'b1010; end 
        4'b0010: begin ALUOut = ~A; current_mask = 4'b1010; end 
        4'b0011: begin ALUOut = ~B; current_mask = 4'b1010; end
        
        4'b0100: begin
            {c_val, ALUOut} = A + B;
            o_val = (A[15] == B[15]) && (ALUOut[15] != A[15]);
            current_mask = 4'b1111;
        end
        
        4'b0101: begin
            {c_val, ALUOut} = A + B + FlagsOut[2]; 
            o_val = (A[15] == B[15]) && (ALUOut[15] != A[15]);
            current_mask = 4'b1111;
        end

        4'b0110: begin
            {c_val, ALUOut} = A + (~B + 1);
            o_val = (A[15] != B[15]) && (ALUOut[15] != A[15]);
            current_mask = 4'b1111;
        end

        4'b0111: begin ALUOut = A & B; current_mask = 4'b1010; end 
        4'b1000: begin ALUOut = A | B; current_mask = 4'b1010; end 
        4'b1001: begin ALUOut = A ^ B; current_mask = 4'b1010; end 
        4'b1010: begin ALUOut = ~(A & B); current_mask = 4'b1010; end 

        4'b1011: begin 
            c_val = A[15];
            ALUOut = A << 1;
            current_mask = 4'b1110; 
        end

        4'b1100: begin 
            c_val = A[0];
            ALUOut = A >> 1;
            current_mask = 4'b1110;
        end

        4'b1101: begin
            ALUOut = $signed(A) >>> 1;
            current_mask = 4'b1000; 
        end

        4'b1110: begin 
            ALUOut  = {A[14:0], FlagsOut[2]};
            c_val = A[15];
            current_mask = 4'b1110;
        end

        4'b1111: begin 
            ALUOut = {FlagsOut[2], A[15:1]};
            c_val = A[0];
            current_mask = 4'b1110;
        end
        
        default: begin ALUOut = 16'h0; current_mask = 4'b0000; end
    endcase
end

initial begin
    FlagsOut = 4'b0000;
end

always @(posedge Clock) begin
    if (WF) begin
        if (current_mask[3]) FlagsOut[3] <= (ALUOut == 16'h0000);
        if (current_mask[2]) FlagsOut[2] <= c_val;
        if (current_mask[1]) FlagsOut[1] <= ALUOut[15];
        if (current_mask[0]) FlagsOut[0] <= o_val;
    end
end
endmodule