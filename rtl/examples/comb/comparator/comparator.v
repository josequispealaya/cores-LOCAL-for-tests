module comparator #(
    parameter N = 8
) (
    input wire [N-1:0] piA,
    input wire [N-1:0] piB,
    output reg poMayor,
    output reg poMenor,
    output reg poIgual
);

always @(*) begin
  
    if(piA > piB) begin
        poMayor <= 1;
        poMenor <= 0;
        poIgual <= 0;
    end
    else if(piA < piB) begin
        poMayor <= 0;
        poMenor <= 1;
        poIgual <= 0;
    end
    else begin
        poMayor <= 0;
        poMenor <= 0;
        poIgual <= 1;
    end


end

endmodule