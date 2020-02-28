-- Listing 7.5
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_test is
    port(
        clk, reset: in std_logic;
        rx: in std_logic;
        tx: out std_logic
    );
end uart_test;

architecture arch of uart_test is

    signal tx_full, rx_empty: std_logic := '0';
    signal data_buffer: std_logic_vector(7 downto 0) := (others => '0');
    signal send_data : std_logic := '0';

begin
    -- instantiate uart
    uart_unit: entity work.uart(str_arch)
        port map(
            clk         =>  clk,
            reset       =>  reset,
            rd_uart     =>  send_data,
            wr_uart     =>  send_data,
            rx          =>  rx,
            w_data      =>  data_buffer,
            tx_full     =>  tx_full,
            rx_empty    =>  rx_empty,
            r_data      =>  data_buffer,
            tx          =>  tx
        );
    
    -- Write back data
    send_data     <= not rx_empty;

end arch;
