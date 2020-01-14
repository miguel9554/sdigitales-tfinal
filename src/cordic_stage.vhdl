library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_stage is

    generic (
        W           : integer := 10;
        ANGLE_W     : integer := 22;
        STEP_W      : integer := 4
    );
    port (
        X0, Y0      :   in signed( W - 1 downto 0);
        Z0          :   in signed( ANGLE_W - 1 downto 0);
        sigma0      :   in std_logic;
        atan        :   in signed( ANGLE_W - 1 downto 0);
        step        :   in unsigned( STEP_W - 1 downto 0);
        X, Y        :   out signed( W - 1 downto 0);
        Z           :   out signed( ANGLE_W - 1 downto 0);
        sigma       :   out std_logic
    );

end entity cordic_stage;

architecture behavioral of cordic_stage is

    -- Adder-substractor declaration
    component addsub is
        generic (
            W       : integer
        );
        port (
            a, b    :   in signed( W - 1 downto 0);
            sigma   :   in std_logic;
            result  :   out signed( W - 1 downto 0)
        );
    end component addsub;

    -- Shifter declaration
    component signed_shifter is
        generic (
            W               :   integer;
            POSITIONS_W     :   integer
        );
        port (
            input_vector    :   in signed( W - 1 downto 0);
            shift_positions :   in unsigned( POSITIONS_W - 1 downto 0 );
            shifted_vector  :   out signed( W - 1 downto 0)
        );
    end component signed_shifter;

    -- Buffer signals
    signal Xshifted     :   signed( W - 1 downto 0)         := ( others => '0');
    signal Yshifted     :   signed( W - 1 downto 0)         := ( others => '0');
    signal sZ           :   signed( ANGLE_W - 1 downto 0)   := ( others => '0');
    signal sNotSigma0   :   std_logic                       := '0';

begin

    sNotSigma0   <=  not sigma0;

    -- Shifter for X component
    Xshifter: signed_shifter
        generic map (
            W               =>  W,
            POSITIONS_W     =>  STEP_W
        )
        port map (
            input_vector    =>  X0,
            shift_positions =>  step,
            shifted_vector  =>  Xshifted
        );

    -- Shifter for Y component
    Yshifter: signed_shifter
        generic map (
            W               =>  W,
            POSITIONS_W     =>  STEP_W
        )
        port map (
            input_vector    =>  Y0,
            shift_positions =>  step,
            shifted_vector  =>  Yshifted
        );

    -- Adder-substractor for X component
    Xaddsub: addsub
        generic map (
            W       =>  W
        )
        port map (
            a       =>  X0,
            b       =>  Yshifted,
            sigma   =>  sigma0,
            result  =>  X
        );

    -- Adder-substractor for Y component
    Yaddsub: addsub
        generic map (
            W       =>  W
        )
        port map (
            a       =>  Y0,
            b       =>  Xshifted,
            sigma   =>  sNotSigma0,
            result  =>  Y
        );

    -- Adder-substractor for Z component
    Zaddsub: addsub
        generic map (
            W       =>  ANGLE_W
        )
        port map (
            a       =>  Z0,
            b       =>  atan,
            sigma   =>  sigma0,
            result  =>  sZ
        );

    Z       <=  sZ;
    sigma   <=  sZ( ANGLE_W - 1 );

end architecture behavioral;