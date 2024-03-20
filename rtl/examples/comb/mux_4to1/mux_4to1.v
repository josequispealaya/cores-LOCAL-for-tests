module mux_4to1 (
    input [3:0] piE,
    input [1:0] piSel,
    output [3:0] poI0,
    output [3:0] poI1,
    output [3:0] poI2,
    output [3:0] poI3
);

reg [3:0] poI0 = 0;
reg [3:0] poI1 = 0;
reg [3:0] poI2 = 0;
reg [3:0] poI3 = 0;

always @(*) begin
    
    case (piSel)
        2'b01: poI1 <= piE;
        2'b10: poI2 <= piE;
        2'b11: poI3 <= piE; 
        2'b00: poI0 <= piE;
    endcase

end

endmodule