module cod_w_prio (
    input piI0,
    input piI1,
    input piI2,
    input piI3,
    output reg [2-1:0] poC,
    output reg poG
);
    
always @(*) begin

    if(piI3 == 1) poC <= 2'b11;
    else if(piI2 == 1) poC <= 2'b10;
    else if(piI1 == 1) poC <= 2'b01;
    else if(piI0 == 1) poC <= 2'b00;
    else poC <= 2'b00;

    poG <= ~(piI0 | piI1 | piI2 | piI3);

end


endmodule