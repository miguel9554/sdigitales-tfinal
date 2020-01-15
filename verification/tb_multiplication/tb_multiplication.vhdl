library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiplication is
end entity tb_multiplication;

architecture behavioral of tb_multiplication is

    -- Constants
    constant INTEGER_WIDTH          :   integer := 15;
    constant FRACTIONAL_WIDTH       :   integer := 10;
    constant WIDTH                  :   integer := INTEGER_WIDTH + FRACTIONAL_WIDTH;
    constant SIMULATION_TIME        :   time    := 100 ns; 
    constant CORDIC_SCALE_FACTOR    :   integer := integer(0.607252935*real(2**WIDTH)); -- Cordic scale factor, ~0.607252935

    -- Signals
    signal first_operand            :   signed(WIDTH-1 downto 0)                := (others => '0');
    signal second_operand           :   signed(WIDTH-1 downto 0)                := (others => '0');
    signal multiplication_buffer    :   signed(2*WIDTH-1 downto 0)              := (others => '0');
    signal result_integer           :   signed(2*INTEGER_WIDTH-1 downto 0)      := (others => '0');
    signal result_fraction          :   signed(2*FRACTIONAL_WIDTH-1 downto 0)   := (others => '0');

begin

    -- Scaling
    first_operand           <=  to_signed(integer(12.23*real(2**FRACTIONAL_WIDTH)), WIDTH);
    second_operand          <=  to_signed(integer(-5.98*real(2**FRACTIONAL_WIDTH)), WIDTH);
    multiplication_buffer   <=  first_operand*second_operand;
    result_integer          <=  multiplication_buffer(2*WIDTH-1 downto 2*FRACTIONAL_WIDTH);
    result_fraction         <=  multiplication_buffer(2*FRACTIONAL_WIDTH-1 downto 0);

    stop: process
    begin
        wait for SIMULATION_TIME;
        wait for SIMULATION_TIME;
        assert false report "Fin de la simulacion" severity failure; -- This asserts aborts the simulation
    end process stop;

end architecture behavioral;