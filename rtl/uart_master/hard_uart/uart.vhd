library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
        g_divBits : natural := 10
    );
    port (

        --control signals
        i_clk : in std_logic;
        i_rxd : in std_logic;
        i_rst : in std_logic;

        o_err : out std_logic;
        o_txd : out std_logic;

        i_baudDiv : in std_logic_vector (g_divBits-1 downto 0);

        --input stream interface
        i_data : in std_logic_vector (8-1 downto 0);
        i_valid : in std_logic;
        o_ready : out std_logic;

        --output stream interface
        o_data : out std_logic_vector(8-1 downto 0);
        o_valid : out std_logic;
        i_ready : in std_logic

    );
end entity;

architecture arch_uart of uart is

    signal s_txPulse : std_logic;
    signal s_rxPulse : std_logic;
    signal s_rxSync : std_logic;


begin

    e_baudDiv : entity work.baudGen(arch_baudGen) 
        generic map(
            g_divBits => g_divBits
        )   
        port map (
            i_clk => i_clk,
            i_rst => i_rst,

            i_rxSync => s_rxSync,
            i_baudDiv => i_baudDiv,
            
            o_rxPulse => s_rxPulse,
            o_txPulse => s_txPulse
        );

    e_uartTx : entity work.uartTx(arch_uartTx)
        generic map(
            g_divBits => g_divBits
        )
        port map (
            i_data => i_data,
            i_valid => i_valid,
            o_ready => o_ready,

            i_clk => i_clk,
            i_rst => i_rst,
            o_txd => o_txd
        );

    e_uartRx : entity work.uartRx(arch_uartRx)
        generic map (
            g_divBits => g_divBits
        )
        port map (
            o_data => o_data,
            o_valid => o_valid,
            i_ready => i_ready,

            i_clk => i_clk,
            i_rst => i_rst,
            i_rxd => i_rxd
        );

end architecture;
