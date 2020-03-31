library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotator_test is
    port(
        clk: in std_logic;
        -- inputs
        sw: in std_logic_vector(7 downto 0);
        btn: in std_logic_vector(3 downto 0);
        -- outputs
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0);
        led: out std_logic_vector(7 downto 0)
    );
end rotator_test;

architecture behavioral of rotator_test is

    constant COORDS_WIDTH: integer := 8;
    constant ANGLES_INTEGER_WIDTH: integer := 7;
    constant COORDS_OFFSET: integer := 2;
    constant STAGES: integer := 8;

    constant LEDS_STATE_IDLE: std_logic_vector(7 downto 0) := "10000001";
    constant LEDS_STATE_LOAD_X: std_logic_vector(7 downto 0) := "00000001";
    constant LEDS_STATE_LOAD_Y: std_logic_vector(7 downto 0) := "00000010";
    constant LEDS_STATE_LOAD_Z: std_logic_vector(7 downto 0) := "00000100";
    constant LEDS_STATE_LOAD_ANGLE: std_logic_vector(7 downto 0) := "00001000";
    constant LEDS_STATE_READ_X: std_logic_vector(7 downto 0) := "00000001";
    constant LEDS_STATE_READ_Y: std_logic_vector(7 downto 0) := "00000010";
    constant LEDS_STATE_READ_Z: std_logic_vector(7 downto 0) := "00000100";
    constant LEDS_STATE_READ_ANGLE: std_logic_vector(7 downto 0) := "00001000";
    constant LEDS_STATE_READ_X_RESULT: std_logic_vector(7 downto 0) := "00000001";
    constant LEDS_STATE_READ_Y_RESULT: std_logic_vector(7 downto 0) := "00000010";
    constant LEDS_STATE_READ_Z_RESULT: std_logic_vector(7 downto 0) := "00000100";

    type state_type is (idle, load_x, load_y, load_z, load_angle, read_x, read_y,
    read_z, read_angle, read_x_result, read_y_result, read_z_result);

    type reg_type is record
        state: state_type;
        x: std_logic_vector(COORDS_WIDTH-1 downto 0);
        y: std_logic_vector(COORDS_WIDTH-1 downto 0);
        z: std_logic_vector(COORDS_WIDTH-1 downto 0);
        display_data: std_logic_vector(7 downto 0);
        leds: std_logic_vector(7 downto 0);
        angle: signed(ANGLES_INTEGER_WIDTH-1 downto 0);
    end record;

    signal register_current, register_next: reg_type := (
        state => idle,
        x => x"cf", y => x"ef", z => x"f3",
        display_data => (others => '0'), leds => LEDS_STATE_IDLE,
        angle => to_signed(13, ANGLES_INTEGER_WIDTH)
    );
    -- debounced button
    signal db_btn: std_logic_vector(3 downto 0);
    -- 7 segment display
    signal led1, led0: std_logic_vector(7 downto 0);

    signal result_x, result_y, result_z: signed(COORDS_WIDTH+COORDS_OFFSET-1 downto 0);

    signal X0, Y0, Z0: signed(COORDS_WIDTH+COORDS_OFFSET-1 downto 0);

    signal clk_25: std_logic;

    COMPONENT dcm
    PORT(
        CLKIN_IN : IN std_logic;
        RST_IN : IN std_logic;          
        CLKDV_OUT : OUT std_logic;
        CLKIN_IBUFG_OUT : OUT std_logic;
        CLK0_OUT : OUT std_logic;
        LOCKED_OUT : OUT std_logic
        );
    END COMPONENT;    

begin

    Inst_dcm: dcm PORT MAP(
        CLKIN_IN => clk,
        RST_IN => '0',
        CLKDV_OUT => clk_25,
        CLKIN_IBUFG_OUT => open,
        CLK0_OUT => open,
        LOCKED_OUT => open
    );
    
    sequential: process(clk_25)
    begin
        if (clk_25'event and clk_25 = '1') then
            register_current <= register_next;
        end if;
    end process sequential;

    combinational: process(register_current, db_btn, sw, result_x, result_y, result_z)
        variable register_next_tmp: reg_type;
    begin
        -- default value
        register_next_tmp := register_current;
        case register_current.state is
            when idle =>
                -- con el botón 0 y los primeros cuatro sw cargamos una coordenada o el ángulo
                if db_btn(0) = '1' then
                    case sw(3 downto 0) is
                        when "0001" =>
                            register_next_tmp.state := load_x;
                            register_next_tmp.leds := LEDS_STATE_LOAD_X;
                        when "0010" =>
                            register_next_tmp.state := load_y;
                            register_next_tmp.leds := LEDS_STATE_LOAD_Y;
                        when "0100" =>
                            register_next_tmp.state := load_z;
                            register_next_tmp.leds := LEDS_STATE_LOAD_Z;
                        when "1000" =>
                            register_next_tmp.state := load_angle;
                            register_next_tmp.leds := LEDS_STATE_LOAD_ANGLE;
                        when others =>
                            register_next_tmp.state := idle;
                            register_next_tmp.leds := LEDS_STATE_IDLE;
                    end case;
                -- con el botón 1 y los primeros cuatro sw leemos una coordenada o el ángulo
                elsif db_btn(1) = '1' then
                    case sw(3 downto 0) is
                        when "0001" =>
                            register_next_tmp.state := read_x;
                            register_next_tmp.leds := LEDS_STATE_READ_X;
                        when "0010" =>
                            register_next_tmp.state := read_y;
                            register_next_tmp.leds := LEDS_STATE_READ_Y;
                        when "0100" =>
                            register_next_tmp.state := read_z;
                            register_next_tmp.leds := LEDS_STATE_READ_Z;
                        when "1000" =>
                            register_next_tmp.state := read_angle;
                            register_next_tmp.leds := LEDS_STATE_READ_ANGLE;
                        when others =>
                            register_next_tmp.state := idle;
                            register_next_tmp.leds := LEDS_STATE_IDLE;
                    end case;
                -- con el botón 2 y los primeros cuatro sw leemos el resultado
                elsif db_btn(2) = '1' then
                    case sw(2 downto 0) is
                        when "001" =>
                            register_next_tmp.state := read_x_result;
                            register_next_tmp.leds := LEDS_STATE_READ_X_RESULT;
                        when "010" =>
                            register_next_tmp.state := read_y_result;
                            register_next_tmp.leds := LEDS_STATE_READ_Y_RESULT;
                        when "100" =>
                            register_next_tmp.state := read_z_result;
                            register_next_tmp.leds := LEDS_STATE_READ_Z_RESULT;
                        when others =>
                            register_next_tmp.state := idle;
                            register_next_tmp.leds := LEDS_STATE_IDLE;
                    end case;
                else
                    register_next_tmp.state := idle;
                    -- dejamos el led anterior, que es el valor que se cargó
                end if;
            when load_x =>
                if db_btn(3) = '1' then
                    register_next_tmp.x := sw;
                    register_next_tmp.state := idle;
                    register_next_tmp.leds := sw;
                else
                    register_next_tmp.state := load_x;
                end if;
            when load_y =>
                if db_btn(3) = '1' then
                    register_next_tmp.y := sw;
                    register_next_tmp.state := idle;
                    register_next_tmp.leds := sw;
                else
                    register_next_tmp.state := load_y;
                end if;
            when load_z =>
                if db_btn(3) = '1' then
                    register_next_tmp.z := sw;
                    register_next_tmp.state := idle;
                    register_next_tmp.leds := sw;
                else
                    register_next_tmp.state := load_z;
                end if;
            when load_angle =>
                if db_btn(3) = '1' then
                    register_next_tmp.angle := signed(sw(ANGLES_INTEGER_WIDTH-1 downto 0));
                    register_next_tmp.state := idle;
                    register_next_tmp.leds := std_logic_vector(to_unsigned(0, 8-ANGLES_INTEGER_WIDTH)) & sw(ANGLES_INTEGER_WIDTH-1 downto 0);
                else
                    register_next_tmp.state := load_angle;
                end if;
            when read_x =>
                register_next_tmp.display_data := register_current.x;
                register_next_tmp.state := idle;
                register_next_tmp.leds := register_current.x;
            when read_y =>
                register_next_tmp.display_data := register_current.y;
                register_next_tmp.state := idle;
                register_next_tmp.leds := register_current.y;
            when read_z =>
                register_next_tmp.display_data := register_current.z;
                register_next_tmp.state := idle;
                register_next_tmp.leds := register_current.z;
            when read_angle =>
                register_next_tmp.display_data := std_logic_vector(to_unsigned(0, 8-ANGLES_INTEGER_WIDTH)) & std_logic_vector(register_current.angle);
                register_next_tmp.state := idle;
                register_next_tmp.leds := std_logic_vector(to_unsigned(0, 8-ANGLES_INTEGER_WIDTH)) & std_logic_vector(register_current.angle);
            when read_x_result =>
                register_next_tmp.display_data := std_logic_vector(result_x(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
                register_next_tmp.state := idle;
                register_next_tmp.leds := std_logic_vector(result_x(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
            when read_y_result =>
                register_next_tmp.display_data := std_logic_vector(result_y(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
                register_next_tmp.state := idle;
                register_next_tmp.leds := std_logic_vector(result_y(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
            when read_z_result =>
                register_next_tmp.display_data := std_logic_vector(result_z(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
                register_next_tmp.state := idle;
                register_next_tmp.leds := std_logic_vector(result_z(COORDS_WIDTH+COORDS_OFFSET-1 downto COORDS_OFFSET));
        end case;
        register_next <= register_next_tmp;
    end process combinational;

    led <= register_current.leds;

    -- debounce units
    debounce_unit0: entity work.debounce
        port map(
            clk=>clk_25, reset=>'0', sw=>btn(0),
            db_level=>open, db_tick=>db_btn(0)
        );
    debounce_unit1: entity work.debounce
    port map(
        clk=>clk_25, reset=>'0', sw=>btn(1),
        db_level=>open, db_tick=>db_btn(1)
    );
    debounce_unit2: entity work.debounce
    port map(
        clk=>clk_25, reset=>'0', sw=>btn(2),
        db_level=>open, db_tick=>db_btn(2)
    );
    debounce_unit3: entity work.debounce
    port map(
        clk=>clk_25, reset=>'0', sw=>btn(3),
        db_level=>open, db_tick=>db_btn(3)
    );

    -- hex decoders
    sseg_unit_0: entity work.hex_to_sseg
        port map(hex=>register_current.display_data(3 downto 0), dp =>'1', sseg=>led0);
    sseg_unit_1: entity work.hex_to_sseg
        port map(hex=>register_current.display_data(7 downto 4), dp =>'1', sseg=>led1);

    -- instantiate 7-seg LED display time-multiplexing module
    disp_unit: entity work.disp_mux
        port map(
            clk=>clk_25, reset=>'0',
            in0=>led0, in1=>led1, in2=>(others => '1'), in3=>(others => '1'),
            an=>an, sseg=>sseg);

    X0 <= signed(register_current.x & std_logic_vector(to_unsigned(0, COORDS_OFFSET)));
    Y0 <= signed(register_current.y & std_logic_vector(to_unsigned(0, COORDS_OFFSET)));
    Z0 <= signed(register_current.z & std_logic_vector(to_unsigned(0, COORDS_OFFSET)));
            -- cordic rotator
    cordic_rotator: entity work.rotator
    generic map(
        COORDS_WIDTH            =>  COORDS_WIDTH+COORDS_OFFSET,
        ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
        STAGES                  =>  STAGES
    )
    port map(
        clk=>clk_25,
        X0=>X0, Y0=>Y0, Z0=>Z0,
        angle_X=>register_current.angle, angle_Y=>register_current.angle, angle_Z=>register_current.angle,
        X=>result_x, Y=>result_y, Z=>result_z);

end behavioral;
