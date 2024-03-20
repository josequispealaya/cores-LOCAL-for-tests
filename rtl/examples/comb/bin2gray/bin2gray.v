module bin2gray #(
    parameter N = 8
) (
    input [N-1:0] piGray,
    output reg [N-1:0] poBin
);

integer i;

always @(*) begin

    poBin[N-1] <= piGray[N-1];

    for (i = 0; i < (N-1) ; i = i + 1 ) begin
        poBin[N-2-i] <= (poBin[N-2-i+1] ^ piGray[N-2-i]); 
    end 
end

endmodule