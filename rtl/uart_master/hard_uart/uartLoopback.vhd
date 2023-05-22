library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
        g_divBits : natural := 10
    );
    port (

        CLK : in std_logic;
        RX : in std_logic;
        TX : out std_logic;

        BTN1, BTN2 : in std_logic;
        LED0, LED1, LED2: out std_logic

    );
end entity;

architecture arch_uart of uart is

    signal s_txPulse : std_logic;
    signal s_rxPulse : std_logic;
    signal s_rxSync : std_logic;

    signal s_rst : std_logic;
    signal s_clk : std_logic;
    signal s_txd : std_logic;
    signal s_rxd : std_logic;
    signal s_err : std_logic;

    --signals for loopback
    signal s_ivalid, s_oready : std_logic;
    signal s_ovalid, s_iready : std_logic;
    signal s_idata, s_odata : std_logic_vector(8-1 downto 0);

    --signal for baud divider
    signal s_baudDiv : std_logic_vector(g_divBits-1 downto 0);

    --signal for baud choosing
    signal s_cntr : std_logic_vector(2-1 downto 0);
    signal s_btn : std_logic;

begin

    e_baudDiv : entity work.baudGen(arch_baudGen) 
        generic map(
            g_divBits => g_divBits
        )   
        port map (
            i_clk => s_clk,
            i_rst => s_rst,

            i_rxSync => s_rxSync,
            i_baudDiv => s_baudDiv,
            
            o_rxPulse => s_rxPulse,
            o_txPulse => s_txPulse
        );

    e_uartTx : entity work.uartTx(arch_uartTx)
        port map (
            i_data => s_idata,
            i_valid => s_ivalid,
            o_ready => s_oready,

            i_txPulse => s_txPulse,

            i_clk => s_clk,
            i_rst => s_rst,
            o_txd => s_txd
        );

    e_uartRx : entity work.uartRx(arch_uartRx)
        port map (
            o_data => s_odata,
            o_valid => s_ovalid,
            i_ready => s_iready,

            i_rxPulse => s_rxPulse,
            o_err => s_err,
            o_rxSync => s_rxSync,

            i_clk => s_clk,
            i_rst => s_rst,
            i_rxd => s_rxd
        );

    e_baudChanger : entity work.buttonChanger(arch_buttonChanger)
        port map (
            i_clk => s_clk,
            i_btn => s_btn,
            o_cntr => s_cntr
        );

    s_idata <= s_odata;
    s_ivalid <= s_ovalid;
    s_iready <= s_oready;

    s_clk <= CLK;
    s_rst <= BTN1;
    s_btn <= BTN2;
    TX <= s_txd;
    s_rxd <= RX;

    LED0 <= s_cntr(0);
    LED1 <= s_cntr(1);
    LED2 <= s_err;

    with s_cntr select s_baudDiv <=
        std_logic_vector(to_unsigned(6, g_divBits)) when "00", --115200 baud
        std_logic_vector(to_unsigned(19, g_divBits)) when "01", --38400 baud
        std_logic_vector(to_unsigned(39, g_divBits)) when "10", --19200 baud
        std_logic_vector(to_unsigned(78, g_divBits)) when others; --9600 baud



end architecture;
