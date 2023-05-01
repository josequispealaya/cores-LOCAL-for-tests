
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ej_2 is

	port(
		piA, piB : in STD_LOGIC;
		poZ : out STD_LOGIC
	);

end entity;

architecture ej_2_Arch of ej_2 is

begin

	poZ <= ((not piA) xor (not piB));

end architecture;

