library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ledtest is 
    port(
        CLK : in std_logic;
        LED0, LED1, LED2, LED3 : out std_logic
    );
end entity;

architecture arch_ledtest of ledtest is

signal counter : unsigned (24-1 downto 0);
signal counter_2 : unsigned (4-1 downto 0);
constant max_counter : unsigned := to_unsigned(120000000, 24);

begin

process (CLK)

    begin

    if (rising_edge(CLK)) then
        if (counter = max_counter) then
            counter <= (others => '0');
            counter_2 <= counter_2 + to_unsigned(1, 4);
        else
            counter <= counter + to_unsigned(1, 24);
        end if;
    end if;

end process;

LED0 <= counter_2(3);
LED1 <= counter_2(2);
LED2 <= counter_2(1);
LED3 <= counter_2(0);

end architecture;