/*brief: Este módulo compara dos números binarios de N bits y proporciona 
*señales que indican si uno es mayor, menor o igual al otro. Permite un 
*desplazamiento opcional de los bits de entrada bajo la señal de control i_Ctrl.
*/
module comp_bin_despl #(
  parameter N = 8
) (
  input  [N-1:0] i_A,
  input  [N-1:0] i_B,
  input          i_Clk,
  input          i_Ctrl,
  output reg     o_Mayor,
  output reg     o_Igual,
  output reg     o_Menor
);

  logic sAgtB, sAeqB;
  logic [N-1:0] sA, sB;

  always @(posedge clk) begin
	  poMayor  = sAgtB;
	  poIgual  = sAeqB;
	  poMenor  = ~sAgtB & ~sAeqB;

	  sA       = (i_Ctrl) ? ~(i_A[N-1]) & i_A[N-2:0] : i_A;
	  sB       = (i_Ctrl) ? ~(i_B[N-1]) & i_B[N-2:0] : i_B;

	  sAgtB    = unsigned'(sA) > unsigned'(sB);
	  sAeqB    = unsigned'(sA) == unsigned'(sB);
  end
endmodule