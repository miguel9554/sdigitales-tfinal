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
    signal X_rotator_X0     :   signed(COORDS_WIDTH-1 downto 0);
    signal X_rotator_Y0     :   signed(COORDS_WIDTH-1 downto 0);
    signal X_angle          :   signed(ANGLES_INTEGER_WIDTH-1 downto 0);
    signal X_rotator_X      :   signed(COORDS_WIDTH-1 downto 0);
    signal X_rotator_Y      :   signed(COORDS_WIDTH-1 downto 0);

    signal y_rotator_X0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Y_rotator_Y0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Y_angle          :   signed(ANGLES_INTEGER_WIDTH-1 downto 0);
    signal Y_rotator_X      :   signed(COORDS_WIDTH-1 downto 0);
    signal Y_rotator_Y      :   signed(COORDS_WIDTH-1 downto 0);

    signal Z_rotator_X0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Z_rotator_Y0     :   signed(COORDS_WIDTH-1 downto 0);
    signal Z_angle          :   signed(ANGLES_INTEGER_WIDTH-1 downto 0);
    signal Z_rotator_X      :   signed(COORDS_WIDTH-1 downto 0);
    signal Z_rotator_Y      :   signed(COORDS_WIDTH-1 downto 0);

begin

    process(clk)
    begin
        if (clk'event and clk='1') then
            
            X_rotator_X0 <= Y0;
            X_rotator_Y0 <= Z0;
            X_angle <= angle_X;

            Y_rotator_X0 <= X_rotator_Y;
            Y_rotator_Y0 <= X0;
            Y_angle <= angle_Y;

            Z_rotator_X0 <= Y_rotator_Y;
            Z_rotator_Y0 <= X_rotator_X;
            Z_angle <= angle_Z;

            X <= Z_rotator_X;
            Y <= Z_rotator_Y;
            Z <= Y_rotator_X;

        end if;
    end process;    

    -- X rotator instantiation
    x_rotator: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  X_rotator_X0,
            Y0          =>  X_rotator_Y0,
            angle       =>  X_angle,
            X           =>  X_rotator_X,
            Y           =>  X_rotator_Y
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
            Y0          =>  Y_rotator_Y0,
            angle       =>  Y_angle,
            X           =>  Y_rotator_X,
            Y           =>  Y_rotator_Y
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
            angle       =>  Z_angle,
            X           =>  Z_rotator_X,
            Y           =>  Z_rotator_Y
        );

end architecture behavioral;
