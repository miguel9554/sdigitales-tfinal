-- Listing 7.5
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_test is
   port(
      clk, reset: in std_logic;
      btn: in std_logic;
      rx: in std_logic;
      tx: out std_logic;
      led: out std_logic_vector(7 downto 0);
      sseg: out std_logic_vector(7 downto 0);
      an: out std_logic_vector(3 downto 0)
   );
end uart_test;

architecture arch of uart_test is
   signal tx_full, rx_empty: std_logic := '0';
   signal rec_data,rec_data1: std_logic_vector(7 downto 0) := (others => '0');
   signal btn_tick: std_logic := '0';
begin
   -- instantiate uart
   uart_unit: entity work.uart(str_arch)
      port map(clk=>clk, reset=>reset, rd_uart=>btn_tick,
               wr_uart=>btn_tick, rx=>rx, w_data=>rec_data1,
               tx_full=>tx_full, rx_empty=>rx_empty,
               r_data=>rec_data, tx=>tx);
   -- instantiate debounce circuit
   btn_db_unit: entity work.debounce(fsmd_arch)
      port map(clk=>clk, reset=>reset, sw=>btn,
               db_level=>open, db_tick=>btn_tick);
   -- incremented data loop back
   rec_data1 <= std_logic_vector(unsigned(rec_data));
   --  led display
   led <= rec_data;
   an <= "1110";
   sseg <= '1' & (not tx_full) & "11" & (not rx_empty) & "111"; -- tx full es a, y rx empty es d
end arch;
