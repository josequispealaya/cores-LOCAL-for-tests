
module ledtest #(parameter SECUENCIA = 2600000)(
    input i_clk,
    input i_sw,
    output reg [3:0] o_leds
);

reg [31:0] contador = SECUENCIA;        

reg r_der = 1;
reg r_izq = 1;
reg [5:0] r_aux = 1'b000001;

wire [3:0] w_led;

assign w_led[0] = (r_aux[0]);
assign w_led[1] = (r_aux[1] | r_aux[5]);
assign w_led[2] = (r_aux[2] | r_aux[4]);
//assign w_led[3] = (r_aux[3]);
assign w_led[3] = (i_sw==1'b1) ? 1'b1 : 1'b0;

always @(posedge i_clk) begin
    if(contador <= 0)begin
        if(r_aux == (6'h20)) begin
            r_aux = 1'b1;
        end
        else begin
            r_aux = r_aux<<1;
        end
        
        contador = SECUENCIA;
    end
    else if (contador > 0) begin
        contador = contador - 1;
    end
    
    o_leds = w_led;
end

endmodule
