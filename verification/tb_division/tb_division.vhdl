library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_division is
end entity tb_division;

architecture behavioral of tb_division is

    -- Constants
    constant INTEGER_WIDTH          :   integer := 15;
    constant FRACTIONAL_WIDTH       :   integer := 10;
    constant WIDTH                  :   integer := INTEGER_WIDTH + FRACTIONAL_WIDTH;
    constant SIMULATION_TIME        :   time    := 100 ns; 
    constant CORDIC_SCALE_FACTOR    :   integer := integer(0.607252935*real(2**FRACTIONAL_WIDTH)); -- Cordic scale factor, ~0.607252935

    -- Signals
    signal dividend         :   signed(WIDTH-1 downto 0)    := (others => '0');
    signal divisor          :   signed(WIDTH-1 downto 0)    := (others => '0');
    signal division_buffer  :   signed(2*WIDTH-1 downto 0)  := (others => '0');
    signal result           :   signed(WIDTH-1 downto 0)    := (others => '0');

begin

    -- Scaling
    dividend        <=  to_signed(integer(9.0*real(2**FRACTIONAL_WIDTH)), WIDTH);
    divisor         <=  to_signed(CORDIC_SCALE_FACTOR, WIDTH);
    division_buffer <=  dividend*divisor;
    result          <=  division_buffer(2*WIDTH-INTEGER_WIDTH-1 downto FRACTIONAL_WIDTH);

    stop: process
    begin
        wait for SIMULATION_TIME;
        wait for SIMULATION_TIME;
        assert false report "Fin de la simulacion" severity failure; -- This asserts aborts the simulation
    end process stop;

end architecture behavioral;