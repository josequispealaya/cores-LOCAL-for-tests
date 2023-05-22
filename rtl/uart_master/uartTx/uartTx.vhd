library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartTx is 

    port (
        --input stream interface
        i_data : in std_logic_vector (8-1 downto 0);
        i_valid : in std_logic;
        o_ready : out std_logic;

        --control signals
        i_clk : in std_logic;
        i_rst : in std_logic;

        i_txPulse : in std_logic;

        o_txd : out std_logic
    );

end entity;

architecture arch_uartTx of uartTx is
    
    type t_txState is (st_idle, st_sync, st_txStart, st_txData, st_txStop);

    signal s_baudClk : std_logic;
    signal s_intRst : std_logic;
    signal s_bitCnt : unsigned (3-1 downto 0);
    signal s_nextCnt : unsigned (3-1 downto 0);

    signal s_dut : std_logic;

    signal r_tx_dataReg : std_logic_vector(8-1 downto 0);
    signal r_actState : t_txState;


begin

    process (i_clk, s_intRst)

    begin

        if (s_intRst = '1') then

            r_actState <= st_idle;
            s_bitCnt <= to_unsigned(0, 3);
            r_tx_dataReg <= (others => '0');
            o_ready <= '0';
        
        elsif (rising_edge(i_clk)) then

            o_txd <= '1';
            o_ready <= '0';

            case r_actState is

                when st_idle =>
                o_ready <= '1';
                r_tx_dataReg <= (others => '0');
                if (i_valid = '1') then
                    r_tx_dataReg <= i_data;
                    r_actState <= st_sync;
                    o_ready <= '0';
                end if;
            
                when st_sync =>
                    if (i_txPulse = '1') then
                        s_bitCnt <= to_unsigned(7, 3);
                        r_actState <= st_txStart;
                    end if;

                when st_txStart =>
                    o_txd <= '0';
                    if (i_txPulse = '1') then
                        r_actState <= st_txData;
                    end if;

                when st_txData =>
                    o_txd <= r_tx_dataReg(to_integer(s_bitCnt));
                    if (i_txPulse = '1') then
                        if (s_bitCnt > to_unsigned(0, 3)) then
                            s_bitCnt <= s_bitCnt - to_unsigned(1, 3);
                        else
                            r_actState <= st_txStop;
                        end if;
                    end if;
                
                when st_txStop =>
                    if (i_txPulse = '1') then
                        r_actState <= st_idle;
                    end if;
                    
                when others =>
                    r_actState <= st_idle;


            end case;

        end if;


    end process;

    s_intRst <= i_rst;

end architecture;