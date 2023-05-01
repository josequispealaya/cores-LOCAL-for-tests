library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ej_7 is
	
	port (
		piA, piB : in  STD_LOGIC_VECTOR(4-1 downto 0);
		poZ		: out STD_LOGIC_VECTOR(4-1 downto 0)
	);

end ej_7;

architecture Arch_ej_7 of ej_7 is

begin

	poZ <= std_logic_vector(unsigned(piA) + unsigned(piB));


end Arch_ej_7;

