library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ej_11 is

	generic ( N : NATURAL := 8);
	port (
		piGray : in  STD_LOGIC_VECTOR(N-1 downto 0);
		poBin  : out STD_LOGIC_VECTOR(N-1 downto 0)
	);

end ej_11;

architecture Arch_ej_11 of ej_11 is

signal sAux : STD_LOGIC_VECTOR(N-1 downto 0);

begin

	sAux(N-1) <= piGray(N-1);
	sAux(N-2 downto 0) <= piGray(N-2 downto 0) xor sAux(N-1 downto 1);
	poBin <= sAux;

end Arch_ej_11;

-- Conversion binario a gray:
-- b_n+1 = 0    g_i = b_i ^ b_i+1

-- conversion gray a binaria:
-- g_n = b_n    b_i = g_i ^ b_i+1
--
-- b4 = g4
-- b3 = g3 xor b4
-- b2 = g2 xor b3
-- b1 = g1 xor b2
-- b0 = g0 xor b1