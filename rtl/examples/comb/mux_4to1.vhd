library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ej_4 is

port(
	piE 	: 	in  STD_LOGIC_VECTOR(4-1 downto 0);
	piSel :	in  STD_LOGIC_VECTOR(2-1 downto 0);
	poI0	:	out STD_LOGIC_VECTOR(4-1 downto 0);
	poI1	:	out STD_LOGIC_VECTOR(4-1 downto 0);
	poI2	:	out STD_LOGIC_VECTOR(4-1 downto 0);
	poI3	:	out STD_LOGIC_VECTOR(4-1 downto 0)
);

end ej_4;

architecture ej_4_Arch of ej_4 is

begin

process (piE, piSel)

begin

	poI0 <= (others => '0');
	poI1 <= (others => '0');
	poI2 <= (others => '0');
	poI3 <= (others => '0');
	
	case piSel is
	
		when "01" =>
			poI1 <= piE;
		when "10" =>
			poI2 <= piE;
		when "11" =>
			poI3 <= piE;
		when others =>
			poI0 <= piE;
		
	end case;

end process;

end ej_4_Arch;

