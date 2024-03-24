module xor_and_not_tb;

    reg a, b, clk;
    wire z;

    // Instantiate the xor_and_not module
    xor_and_not XO1 (
        .clk(clk),
        .a(a),
        .b(b),
        .z(z)
    );

    //-- Generador de reloj. Periodo 2 unidades
    always #1 clk = ~clk;

    // Test vectors
    initial begin
		//-- Definir el fichero donde volcar los datos
	    $dumpfile("xor_and_not_tb.vcd");
		//-- Volcar todos los datos a ese fichero (al finalizar la simulacion)
		$dumpvars(0, xor_and_not_tb);

		$display("---->INICIANDO PRUEBA");
        $monitor("a = %b, b = %b, z = %b", a, b, z);

        // Test all possible input combinations
        clk = 1;
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
		a = 1; b = 1; #10;
		$display("---->PRUEBA TERMINADA");
        $finish;
    end

endmodule