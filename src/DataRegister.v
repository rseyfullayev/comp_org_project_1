module DataRegister(
    input wire clk,
    input wire E,
    input wire [7:0] I,
    input wire FunSel,

    output reg[15:0] DROut
);

always @( posedge clk) begin

    if(E) begin
        if(!FunSel)
            DROut[7:0] <= I; // LSB
        else
            DROut[15:8] <= I; // MSB
    end


end

endmodule