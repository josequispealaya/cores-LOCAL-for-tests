library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buttonChanger is
    port (
        i_clk : in std_logic;
        i_btn : in std_logic;
        o_cntr : out std_logic_vector (2-1 downto 0)
    );
end entity;

architecture arch_buttonChanger of buttonChanger is 

    signal counter : unsigned (2-1 downto 0) := (others => '0');
    signal btnState : std_logic;

begin

    process (i_clk, i_btn, btnState)

    begin

        if (rising_edge(i_clk)) then
            if(i_btn = '0' and btnState /= i_btn) then
                counter <= counter + 1;
                btnState <= '0';
            elsif (i_btn = '1' and btnState /= i_btn) then
                btnState <= '1';
            end if;
            
        end if;

    end process;

    o_cntr <= std_logic_vector(counter);

end architecture;