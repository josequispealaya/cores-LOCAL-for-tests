library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ej_8 is

	generic ( N : NATURAL := 4);
	port (
		piA, piB : in  STD_LOGIC_VECTOR(N-1 downto 0);
		piOp		: in	STD_LOGIC;
		poZ		: out STD_LOGIC_VECTOR(N-1 downto 0)
	);


end ej_8;

-- Ojo, es un sumador /restador de ENTEROS!!

architecture Arch_ej_8 of ej_8 is

begin

	with piOp select
		poZ <= std_logic_vector(signed(piA) - signed(piB)) when '1',
				 std_logic_vector(signed(piA) + signed(piB)) when others;

end Arch_ej_8;

