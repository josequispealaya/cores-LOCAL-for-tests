library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudGen is

    generic (
        g_divBits : natural := 10
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_baudDiv : in std_logic_vector(g_divBits-1 downto 0);

        i_rxSync : in std_logic;
        
        o_txPulse : out std_logic;
        o_rxPulse : out std_logic
    );

end entity;

architecture arch_baudGen of baudGen is 

signal s_clkDiv : unsigned (g_divBits-1 downto 0);
signal s_clkDivResync: unsigned (g_divBits-1 downto 0);
signal s_baudTxCntr : unsigned (4-1 downto 0);
signal s_baudRxCntr : unsigned (4-1 downto 0);
signal r_baudDiv : std_logic_vector(g_divBits-1 downto 0);

begin

    process (i_clk, i_rst, i_baudDiv, i_rxSync)

    begin

        if (i_rst = '1') then
            r_baudDiv <= (others => '0');
            s_clkDiv <= to_unsigned(0, g_divBits);
            s_clkDivResync <= to_unsigned(0, g_divBits);
            s_baudTxCntr <= to_unsigned(0, 4);
            s_baudRxCntr <= to_unsigned(0, 4);
        elsif (rising_edge(i_clk)) then
            
            r_baudDiv <= i_baudDiv;
            o_txPulse <= '0';
            o_rxPulse <= '0';

            --podria incluirse un enable y me ahorro esta comparativa
            if (unsigned(r_baudDiv) /= 0) then
                s_clkDiv <= s_clkDiv + to_unsigned(1, g_divBits);
                s_clkDivResync <= s_clkDivResync + to_unsigned(1, g_divBits);
                if (s_clkDiv >= unsigned(r_baudDiv)) then
                    s_clkDiv <= to_unsigned(0, g_divBits);
                    s_baudTxCntr <= s_baudTxCntr + to_unsigned(1, 4);
                    if (s_baudTxCntr >= to_unsigned(15, 4)) then
                        o_txPulse <= '1';
                    end if;
                end if;
                if (s_clkDivResync >= unsigned(r_baudDiv)) then
                    s_clkDivResync <= to_unsigned(0, g_divBits);
                    s_baudRxCntr <= s_baudRxCntr + to_unsigned(1, 4);
                    if (s_baudRxCntr >= to_unsigned(5, 4) and s_baudRxCntr <= to_unsigned(7, 4)) then
                        o_rxPulse <= '1';
                    end if;
                end if;
            end if;
            if (i_rxSync = '1') then
                s_baudRxCntr <= to_unsigned(0, 4);
                s_clkDivResync <= to_unsigned(0, g_divBits);
            end if;
        end if;

    end process;

end architecture;