library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ej_1 is
	port (
		piA, piB : in STD_LOGIC;
		poZ : out STD_LOGIC
	);

end ej_1;

architecture ej_1_Arch of ej_1 is

begin

	poZ <= piA and piB;

end ej_1_Arch;

