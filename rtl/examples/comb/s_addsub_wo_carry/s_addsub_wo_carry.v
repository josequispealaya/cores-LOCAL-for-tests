module s_addsub_wo_carry #(
    parameter N = 4
)(
    input [N-1:0] piA,
    input [N-1:0] piB,
    input piOp,
    output reg [N-1:0] poZ
);
    
always @(*) begin
    if(piOp == 0) poZ <= piA + piB;
    else poZ <= piA - piB;
end

endmodule