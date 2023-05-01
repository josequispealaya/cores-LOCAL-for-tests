library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity and is
	port (
		piA, piB : in STD_LOGIC;
		poZ : out STD_LOGIC
	);

end and;

architecture and_Arch of and is

begin

	poZ <= piA and piB;

end and_Arch;

