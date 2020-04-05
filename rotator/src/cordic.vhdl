library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is
    generic (
        COORDS_WIDTH            : integer := 10;
        ANGLES_INTEGER_WIDTH    : integer := 8;
        STAGES                  : integer := 16
    );
    port (
        X0, Y0          :   in signed(COORDS_WIDTH-1 downto 0);
        angle           :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
        X, Y            :   out signed(COORDS_WIDTH-1 downto 0)
    );
end entity cordic;

architecture behavioral of cordic is

    -- Constants
    constant STEP_WIDTH             :   integer := 4;
    constant ANGLES_FRACTIONAL_WIDTH : integer := 16;
    constant ANGLES_WIDTH           :   integer := ANGLES_INTEGER_WIDTH+ANGLES_FRACTIONAL_WIDTH;
    constant CORDIC_SCALE_FACTOR    :   real    := 0.607252935;
    constant MAX_STAGES: natural := 16;

    -- Types
    type rom_type is array (0 to MAX_STAGES-1) of signed(ANGLES_WIDTH-1 downto 0);
    type coordinates_array is array (0 to STAGES) of signed(COORDS_WIDTH-1 downto 0);
    type angles_array is array (0 to STAGES) of signed(ANGLES_WIDTH-1 downto 0);

    -- Cordic stage declaration
    component cordic_stage is
        generic (
            COORDS_WIDTH    : integer;
            ANGLE_WIDTH     : integer;
            STEP_WIDTH      : integer
        );
        port (
            X0, Y0      :   in signed(COORDS_WIDTH-1 downto 0);
            Z0          :   in signed(ANGLE_WIDTH-1 downto 0);
            atan        :   in signed(ANGLE_WIDTH-1 downto 0);
            step        :   in unsigned(STEP_WIDTH-1 downto 0);
            X, Y        :   out signed(COORDS_WIDTH-1 downto 0);
            Z           :   out signed(ANGLE_WIDTH-1 downto 0)
        );
    end component cordic_stage;

    -- Angles "ROM"
    constant STEP2ANGLE_ROM: rom_type := (
        to_signed(integer(45.0              *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(26.565051177078   *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(14.0362434679265  *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(7.1250163489018   *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(3.57633437499735  *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(1.78991060824607  *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.895173710211074 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.447614170860553 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.223810500368538 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.111905677066207 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.055952891893804 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.027976452617004 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.013988227142265 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.006994113675353 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.003497056850704 *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH),
        to_signed(integer(0.00174852842698  *   real(2**ANGLES_FRACTIONAL_WIDTH)), ANGLES_WIDTH)
    );

    -- Signal arrays
    signal sX_array     :   coordinates_array   := (others => to_signed(0,COORDS_WIDTH));
    signal sY_array     :   coordinates_array   := (others => to_signed(0,COORDS_WIDTH));
    signal sZ_array     :   angles_array        := (others => to_signed(0,ANGLES_WIDTH));

    -- Buffer signals
    signal sX_multiplication_buffer     :   signed(2*COORDS_WIDTH-1 downto 0)   := (others => '0');
    signal sY_multiplication_buffer     :   signed(2*COORDS_WIDTH-1 downto 0)   := (others => '0');

    -- 
    signal Xt: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal Yt: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal anglet: signed(ANGLES_INTEGER_WIDTH-1 downto 0) := (others => '0');

    -- Cordic scale factor
    signal sCordic_scale_factor :   signed(COORDS_WIDTH-1 downto 0) := to_signed(integer(CORDIC_SCALE_FACTOR*real(2**(COORDS_WIDTH-1))), COORDS_WIDTH);

begin
    
    -- Inputs initialization
    sX_array(0)     <=  X0;
    sY_array(0)     <=  Y0;
    sZ_array(0)     <=  signed(std_logic_vector(anglet) & std_logic_vector(to_unsigned(0, ANGLES_FRACTIONAL_WIDTH)));

    stages_instantiation: for i in 0 to STAGES-1 generate

        current_cordic_stage: cordic_stage
            generic map (
                COORDS_WIDTH    =>  COORDS_WIDTH,
                ANGLE_WIDTH     =>  ANGLES_WIDTH,
                STEP_WIDTH      =>  STEP_WIDTH
            )
            port map (
                X0          =>  sX_array(i),
                Y0          =>  sY_array(i),
                Z0          =>  sZ_array(i),
                atan        =>  STEP2ANGLE_ROM(i),
                step        =>  to_unsigned(i, STEP_WIDTH),
                X           =>  sX_array(i+1),
                Y           =>  sY_array(i+1),
                Z           =>  sZ_array(i+1)
            );

    end generate stages_instantiation;

    -- Scaling
    sX_multiplication_buffer <=  sX_array(STAGES)*sCordic_scale_factor;
    sY_multiplication_buffer <=  sY_array(STAGES)*sCordic_scale_factor;

    -- Outputs assignement
    -- Buffer has 2 bits for integer part, we only want one and the rest of fractional bits we can fit
    Xt    <=  sX_multiplication_buffer(2*COORDS_WIDTH-2 downto COORDS_WIDTH-1);
    Yt    <=  sY_multiplication_buffer(2*COORDS_WIDTH-2 downto COORDS_WIDTH-1);

    angle_decode: process(angle, Xt, Yt)
    begin
        if angle < to_signed(-90, angle'length) then
            anglet <= angle + to_signed(90, angle'length);
            X <= -Yt;
            Y <= Xt;
        elsif angle > to_signed(90, angle'length) then
            anglet <= angle - to_signed(90, angle'length);
            X <= -Yt;
            Y <= Xt;
        else
            anglet <= angle;
            X <= Xt;
            Y <= Yt;
        end if;            
    end process;

end architecture behavioral;