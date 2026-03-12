module Register16bit(
    input wire clk,
    input wire E,
    input wire [1:0] FunSel,
    input wire [15:0] I,
    output reg [15:0] Q
);

always @(posedge clk) begin
    if (!E)
        Q <= Q;
    else begin
        case (FunSel)
            2'b00:
                Q <= 16'b0;
            2'b01:
                Q <= I;
            2'b10:
                Q <= Q + 1;
            2'b11:
                Q <= Q - 1;
        endcase
    end
end

endmodule