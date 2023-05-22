library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartRx is

    port (
        --output stream interface
        o_data : out std_logic_vector(8-1 downto 0);
        o_valid : out std_logic;
        i_ready : in std_logic;

        --control signals
        i_clk : in std_logic;
        i_rxd : in std_logic;
        i_rst : in std_logic;

        i_rxPulse : in std_logic;

        o_err : out std_logic;
        o_rxSync : out std_logic
    );

end entity;

architecture arch_uartRx of uartRx is

type t_rxState is (st_idle, st_startRx, st_recvRx, st_endRx, st_errRx);

signal s_sampleCntr : unsigned (2-1 downto 0);
signal s_bitCntr : unsigned(3-1 downto 0);
signal s_bitSignal : std_logic;
signal s_safeBit : std_logic;
signal s_valid : std_logic;

signal r_actState : t_rxState;
signal r_rxDataReg : std_logic_vector (8-1 downto 0);
signal r_samplingReg : std_logic_vector (3-1 downto 0);

signal r_rxdMeta : std_logic;
signal r_rxdRaw : std_logic;

signal r_readyMeta : std_logic;
signal r_readyRaw : std_logic;

begin

    process (i_clk, i_rst)

    begin

        if (i_rst = '1') then

            r_actState <= st_idle;
            s_valid <= '0';

        elsif (rising_edge(i_clk)) then
            
            r_rxdMeta <= i_rxd;
            r_rxdRaw <= r_rxdMeta;

            r_readyMeta <= i_ready;
            r_readyRaw <= r_readyMeta;

            s_bitSignal <= '0';
            o_rxSync <= '0';

            if (i_rxPulse = '1') then
                r_samplingReg(to_integer(s_sampleCntr)) <= r_rxdRaw;
                s_sampleCntr <= s_sampleCntr - to_unsigned(1, 2);
                if (s_sampleCntr = to_unsigned(0, 2)) then
                    case r_samplingReg is
                        when "111" => s_safeBit <= '1';
                        when "110" => s_safeBit <= '1';
                        when "101" => s_safeBit <= '1';
                        when "100" => s_safeBit <= '0';
                        when "011" => s_safeBit <= '1';
                        when "010" => s_safeBit <= '0';
                        when "001" => s_safeBit <= '0';
                        when "000" => s_safeBit <= '0';
                        when others => r_actState <= st_errRx;
                    end case;
                    s_sampleCntr <= to_unsigned(2, 2);
                    s_bitSignal <= '1';
                end if;
            end if;

            case r_actState is

                when st_idle =>
                    if (falling_edge(r_readyRaw)) then
                        s_valid <= '0';
                    end if;
                    if (r_rxdRaw = '0') then
                        r_actState <= st_startRx;
                        o_rxSync <= '1';
                        s_sampleCntr <= to_unsigned(2, 2);
                        s_bitCntr <= to_unsigned(7, 3);
                        r_samplingReg <= (others => '0');
                        s_valid <= '0';
                        o_err <= '0';
                    end if;

                when st_startRx =>
                    if (s_bitSignal = '1') then
                        if (s_safeBit = '0') then
                            r_actState <= st_recvRx;
                        else
                            r_actState <= st_errRx;
                        end if;
                    end if;

                when st_recvRx => 
                    if (s_bitSignal = '1') then
                        r_rxDataReg(to_integer(s_bitCntr)) <= s_safeBit;
                        s_bitCntr <= s_bitCntr - to_unsigned(1, 3);

                        if (s_bitCntr = to_unsigned(0, 2)) then
                            r_actState <= st_endRx;
                        end if;
                    end if;

                when st_endRx =>
                    if (s_bitSignal = '1') then
                        if (s_safeBit = '1') then
                            r_actState <= st_idle;
                            o_data <= r_rxDataReg;
                            s_valid <= '1';
                        else
                            r_actState <= st_errRx;
                        end if;
                    end if;

                when st_errRx =>
                    r_actState <= st_idle;
                    o_err <= '1';


            end case;
        end if;


    end process;

    o_valid <= s_valid;

end architecture;