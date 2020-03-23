library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_stage is

    generic (
        COORDS_WIDTH    : integer := 10;
        ANGLE_WIDTH     : integer := 22;
        STEP_WIDTH      : integer := 4
    );
    port (
        X0, Y0      :   in signed(COORDS_WIDTH-1 downto 0);
        Z0          :   in signed(ANGLE_WIDTH-1 downto 0);
        atan        :   in signed(ANGLE_WIDTH-1 downto 0);
        step        :   in unsigned(STEP_WIDTH-1 downto 0);
        X, Y        :   out signed(COORDS_WIDTH-1 downto 0);
        Z           :   out signed(ANGLE_WIDTH-1 downto 0)
    );

end entity cordic_stage;

architecture behavioral of cordic_stage is

    -- Buffer signals
    signal Xshifted: signed(COORDS_WIDTH-1 downto 0) := ( others => '0');
    signal Yshifted: signed(COORDS_WIDTH-1 downto 0) := ( others => '0');
    signal sigma: std_logic := '0';

begin

    Xshifted <= shift_right(X0, to_integer(step));
    Yshifted <= shift_right(Y0, to_integer(step));
    sigma <= Z0(ANGLE_WIDTH-1);

    X <=    X0 - Yshifted   when sigma = '0' else   -- si el ángulo es mayor a cero
            X0 + Yshifted;                          -- si el ángulo es menor a cero
    Y <=    Y0 + Xshifted   when sigma = '0' else   -- si el ángulo es mayor a cero
            Y0 - Xshifted;                          -- si el ángulo es menor a cero
    Z <=    Z0 - atan       when sigma = '0' else   -- si el ángulo es mayor a cero
            Z0 + atan;                              -- si el ángulo es menor a cero

end architecture behavioral;