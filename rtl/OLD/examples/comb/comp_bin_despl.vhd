library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ej_10 is

	generic ( N : NATURAL := 8);
	port (
		piA, piB : in  STD_LOGIC_VECTOR(N-1 downto 0);
		piCtrl   : in  STD_LOGIC;
		poMayor  : out STD_LOGIC;
		poIgual  : out STD_LOGIC;
		poMenor  : out STD_LOGIC
	);

end ej_10;

architecture Arch_ej_10 of ej_10 is

signal sAgtB, sAeqB : STD_LOGIC;
signal sA, sB 		  : STD_LOGIC_VECTOR(N-1 downto 0);

begin

	poMayor <= sAgtB;
	poIgual <= sAeqB;
	poMenor <= not sAgtB and not sAeqB;
	
	sA <= (not (piA(N-1)) & piA(N-2 downto 0)) when piCtrl = '1' else piA;
	sB <= (not (piB(N-1)) & piB(N-2 downto 0)) when piCtrl = '1' else piB;
	
	sAgtB <= '1' when unsigned(sA) > unsigned(sB) else '0';
	sAeqB <= '1' when unsigned(sA) = unsigned(sB) else '0';
	

	

end Arch_ej_10;

