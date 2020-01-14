library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_shifter is

    generic (
        W                   :   integer := 10;
        POSITIONS_W         :   integer := 4
    );
    port (
        input_vector        :   in signed( W - 1 downto 0 );
        shift_positions     :   in unsigned( POSITIONS_W - 1 downto 0 );
        shifted_vector      :   out signed( W - 1 downto 0 )
    );

end entity signed_shifter;

architecture behavioral of signed_shifter is
begin

    shifted_vector  <=  shift_right(input_vector, to_integer(shift_positions));

end architecture behavioral;
