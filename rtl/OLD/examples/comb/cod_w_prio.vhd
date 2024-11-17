library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ej_3 is

Port ( 
	piI0 : in STD_LOGIC ;
	piI1 : in STD_LOGIC ;
	piI2 : in STD_LOGIC ;
	piI3 : in STD_LOGIC ;
	poG : out STD_LOGIC ;
	poC : out STD_LOGIC_VECTOR (2 -1 downto 0)
	);

end ej_3;

architecture ej_3_Arch of ej_3 is

begin

	poC <= "11" when piI3 = '1'
	  else "10" when piI2 = '1'
	  else "01" when piI1 = '1'
	  else "00";
	
	poG <= not (piI0 or piI1 or piI2 or piI3);

end ej_3_Arch;

