
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mynxor is

	port(
		piA, piB : in STD_LOGIC;
		poZ : out STD_LOGIC
	);

end entity;

architecture mynxor_Arch of mynxor is

begin

	poZ <= not( piA xor piB );

end architecture;

