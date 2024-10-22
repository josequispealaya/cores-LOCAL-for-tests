library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ej_9 is
	
	generic ( N : NATURAL := 8);
	port (
		piA, piB : in  STD_LOGIC_VECTOR(N-1 downto 0);
		poMayor  : out STD_LOGIC;
		poIgual  : out STD_LOGIC;
		poMenor  : out STD_LOGIC
	);
	
	
end ej_9;

architecture Arch_ej_9 of ej_9 is

begin

	process (piA, piB)
	
	begin
	
		poMayor <= '0';
		poIgual <= '0';
		poMenor <= '0';
	
		if (unsigned(piA) > unsigned(piB)) then
			poMayor <= '1';
		elsif (unsigned(piA) = unsigned(piB)) then
			poIgual <= '1';
		else
			poMenor <= '1';
		end if;
		
	end process;

end Arch_ej_9;

