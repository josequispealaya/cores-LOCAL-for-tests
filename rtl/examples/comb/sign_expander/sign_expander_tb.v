module sign_expander_tb;

  reg  [3:0]i_A;
  reg  clk;
  wire [7:0]o_Z;

  // Instantiate the sign_expander module
  sign_expander SE1 (
      .clk(clk),
      .i_A(i_A),
      .o_Z(o_Z)
  );

  //-- Generador de reloj. Periodo 2 unidades
  // always #1 clk = ~clk;

  // Test vectors
  initial begin
    //-- Definir el fichero donde volcar los datos
    $dumpfile("sign_expander_tb.vcd");
    //-- Volcar todos los datos a ese fichero (al finalizar la simulacion)
    $dumpvars(0, sign_expander_tb);

    $display("---->INICIANDO PRUEBA");
    $monitor("i_A = %b, o_Z = %b", i_A, o_Z);

    // Test vectors
    i_A = 4'b0000; #10;
    i_A = 4'b0001; #10;
    i_A = 4'b0010; #10;
    i_A = 4'b0011; #10;
    i_A = 4'b0100; #10;
    i_A = 4'b0101; #10;
    i_A = 4'b0110; #10;
    i_A = 4'b0111; #10;
    i_A = 4'b1000; #10;
    i_A = 4'b1001; #10;
    i_A = 4'b1010; #10;
    i_A = 4'b1011; #10;
    i_A = 4'b1100; #10;
    i_A = 4'b1101; #10;
    i_A = 4'b1110; #10;
    i_A = 4'b1111; #10;

    $display("---->PRUEBA TERMINADA");
    $finish;
  end

  always begin
    #5 clk = 1'b0;
    #5 clk = 1'b1;
  end
endmodule

/*
module ej_5_tb;

  reg [3:0] i_A;
  reg clk;
  wire [7:0] poS;

  ej_5 uut (
    .i_A(i_A),
    .clk(clk),
    .poS(poS)
  );

  initial begin
    $monitor("i_A = %b, poS = %b", i_A, poS);


endmodule
*/