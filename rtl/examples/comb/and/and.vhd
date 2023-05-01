library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity myAnd is
	port (
		piA, piB : in STD_LOGIC;
		poZ : out STD_LOGIC
	);

end myAnd;

architecture arch_myAnd of myAnd is

begin

	poZ <= piA and piB;

end arch_myAnd;

