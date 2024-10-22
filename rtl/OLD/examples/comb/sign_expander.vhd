library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ej_5 is

	port (
		piE	:	in		STD_LOGIC_VECTOR(4-1 downto 0);
		poS	:	out	STD_LOGIC_VECTOR(8-1 downto 0)  
	);

end ej_5;

architecture Arch_ej_5 of ej_5 is

begin
	
	poS(4-1 downto 0) <= piE;
	poS(8-1 downto 4) <= (others => piE(3));

end Arch_ej_5;

