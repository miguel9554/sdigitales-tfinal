library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rz is

    generic (
        COORDS_WIDTH            : integer := 10;
        ANGLES_INTEGER_WIDTH    : integer := 8;
        STAGES                  : integer := 16
    );
    port (
        X0, Y0, Z0      :   in signed(COORDS_WIDTH-1 downto 0);
        angle           :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
        X, Y, Z         :   out signed(COORDS_WIDTH-1 downto 0)
    );

end entity Rz;

architecture behavioral of Rz is

    -- Cordic declaration
    component cordic is
        generic (
            COORDS_WIDTH            : integer;
            ANGLES_INTEGER_WIDTH    : integer;
            STAGES                  : integer
        );
        port (
            X0, Y0          :   in signed(COORDS_WIDTH-1 downto 0);
            angle           :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
            X, Y            :   out signed(COORDS_WIDTH-1 downto 0)
        );
    end component cordic;

begin
    
    -- Cordic rotation
    cordic_rotator: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  X0,
            Y0          =>  Y0,
            angle       =>  angle,
            X           =>  X,
            Y           =>  Y
        );

    -- Z component stays the same
    Z   <=  Z0;

end architecture behavioral;