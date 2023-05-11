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
constant max_counter : unsigned := to_unsigned(120000000, 24);

begin

process (CLK)

    begin

    if (rising_edge(CLK)) then
        if (counter = max_counter) then
            counter <= (others => '0');
        else
            counter <= counter + to_unsigned(1, 24);
        end if;
    end if;

end process;

LED0 <= counter(23);
LED1 <= counter(22);
LED2 <= counter(21);
LED3 <= counter(20);

end architecture;