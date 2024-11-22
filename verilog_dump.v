module cocotb_icarus_dump();
//PRUEBA

reg clk;
reg reset;
reg uartrx;  // <--- Asegúrate de que esté declarado aquí
wire [7:0] data_out;

// Instancia del módulo bajo prueba
uart_rx uut (
    .clk(clk),
    .reset(reset),
    .uartrx(uartrx),  // <--- Conecta correctamente la señal
    .data_out(data_out)
);

// FIN DE PRUEBA

initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, REPLACE_WITH_MODULE_NAME);
end
endmodule
