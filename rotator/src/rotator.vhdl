library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotator is

    generic (
        COORDS_WIDTH            : integer := 10;
        ANGLES_INTEGER_WIDTH    : integer := 6;
        STAGES                  : integer := 16
    );
    port (
        clk                         :   in std_logic;
        X0, Y0, Z0                  :   in signed(COORDS_WIDTH-1 downto 0);
        angle_X, angle_Y, angle_Z   :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
        X, Y, Z                     :   out signed(COORDS_WIDTH-1 downto 0)
    );

end entity rotator;

architecture behavioral of rotator is

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


    -- Buffer signal
    signal Y_rotator_X0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Z_rotator_X0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Z_rotator_Y0     :   signed(COORDS_WIDTH-1 downto 0);

    -- Outputs
    signal buffer_X          :   signed(COORDS_WIDTH-1 downto 0);
    signal buffer_Y          :   signed(COORDS_WIDTH-1 downto 0);
    signal buffer_Z          :   signed(COORDS_WIDTH-1 downto 0);

begin
    
    -- X rotator instantiation
    x_rotator: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  Y0,
            Y0          =>  Z0,
            angle       =>  angle_X,
            X           =>  Z_rotator_Y0,
            Y           =>  Y_rotator_X0
        );


    -- Y rotator instantiation
    y_rotator: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  Y_rotator_X0,
            Y0          =>  X0,
            angle       =>  angle_Y,
            X           =>  buffer_Z,
            Y           =>  Z_rotator_X0
        );


    -- Z rotator instantiation
    z_rotator: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  Z_rotator_X0,
            Y0          =>  Z_rotator_Y0,
            angle       =>  angle_Z,
            X           =>  buffer_X,
            Y           =>  buffer_Y
        );


    output_assignement: process(clk)
    begin
        if (clk'event and clk = '1') then
            X   <=  buffer_X;
            Y   <=  buffer_Y;
            Z   <=  buffer_Z;
        end if;
    end process;

end architecture behavioral;