module u_add_wo_carry_tb;

  reg  [4-1:0]i_A;
  reg  [4-1:0]i_B;
  reg  clk;
  wire [4-1:0]o_Z;

  // Instantiate the sign_expander module
  u_add_wo_carry UAWC (
      .clk(clk),
      .i_A(i_A),
      .i_B(i_B),
      .o_Z(o_Z)
  );

  // Test vectors
  initial begin
    //-- Definir el fichero donde volcar los datos
    $dumpfile("u_add_wo_carry_tb.vcd");
    //-- Volcar todos los datos a ese fichero (al finalizar la simulacion)
    $dumpvars(0, u_add_wo_carry_tb);

    $display("---->INICIANDO PRUEBA");
    $monitor("i_A = %b, i_B = %b, o_Z = %b", i_A, i_B, o_Z);

    // Test vectors
    i_A = 4'b0000; #5;
    i_B = 4'b0001; #5;

    i_A = 4'b0011; #5;
    i_B = 4'b0100; #5;

    i_A = 4'b1111; #5;
    i_B = 4'b0100; #5;

    i_A = 4'b0111; #5;
    i_B = 4'b0001; #5;

    i_A = 4'b1110; #5;
    i_B = 4'b0001; #5;

    $display("---->PRUEBA TERMINADA");
    $finish;
  end

  always begin
    #5 clk = 1'b0;
    #5 clk = 1'b1;
  end
endmodule