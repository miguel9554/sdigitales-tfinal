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
    constant ANGLES_INTEGER_WIDTH: integer := 6;
    constant ANGLES_FRACTIONAL_WIDTH: integer := 16;
    constant ANGLES_WIDTH: integer := 1 + ANGLES_INTEGER_WIDTH + ANGLES_FRACTIONAL_WIDTH; 

    type state_type is (idle, load_x, load_y, load_z, read_x, read_y, read_z, read_x_result, read_y_result, read_z_result, load_angle);

    type reg_type is record
        state: state_type;
        x: std_logic_vector(COORDS_WIDTH-1 downto 0);
        y: std_logic_vector(COORDS_WIDTH-1 downto 0);
        z: std_logic_vector(COORDS_WIDTH-1 downto 0);
        display_data: std_logic_vector(7 downto 0);
    end record;        

    signal register_current, register_next: reg_type;
    -- debounced button
    signal db_btn: std_logic_vector(3 downto 0);
    -- 7 segment display
    signal led1, led0: std_logic_vector(7 downto 0);
    -- leds
    signal leds: std_logic_vector(7 downto 0) := (others => '0');
    signal rotation_angle: signed(ANGLES_WIDTH-1 downto 0) := (others => '0');

    signal result_x, result_y, result_z: signed(COORDS_WIDTH-1 downto 0);

begin
    
    sequential: process(clk)
    begin
        if (clk'event and clk = '1') then
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
                leds <= "00000000";
                -- con el botón 0 y los primeros tres sw cargamos una coordenada
                if db_btn(0) = '1' then
                    case sw(2 downto 0) is
                        when "001" =>
                            register_next_tmp.state := load_x;
                        when "010" =>
                            register_next_tmp.state := load_y;
                        when "100" =>
                            register_next_tmp.state := load_z;
                        when others =>
                            register_next_tmp.state := idle;
                    end case;
                -- con el botón 1 y los primeros tres sw leemos una coordenada
                elsif db_btn(1) = '1' then
                    case sw(2 downto 0) is
                        when "001" =>
                            register_next_tmp.state := read_x;
                        when "010" =>
                            register_next_tmp.state := read_y;
                        when "100" =>
                            register_next_tmp.state := read_z;
                        when others =>
                            register_next_tmp.state := idle;
                    end case;
                -- con el botón 2 y los primeros tres sw leemos una coordenada
                elsif db_btn(2) = '1' then
                    case sw(2 downto 0) is
                        when "001" =>
                            register_next_tmp.state := read_x_result;
                        when "010" =>
                            register_next_tmp.state := read_y_result;
                        when "100" =>
                            register_next_tmp.state := read_z_result;
                        when others =>
                            register_next_tmp.state := idle;
                    end case;
                -- con el botón 3 cargamos el ángulo
                elsif db_btn(3) = '1' then
                    register_next_tmp.state := load_angle;
                else
                    register_next_tmp.state := idle;
                end if;
            when load_x =>
                leds <= "00000001";
                if db_btn(3) = '1' then
                    register_next_tmp.x := sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_x;
                end if;
            when load_y =>
                leds <= "00000010";
                if db_btn(3) = '1' then
                    register_next_tmp.y := sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_y;
                end if;
            when load_z =>
                leds <= "00000100";
                if db_btn(3) = '1' then
                    register_next_tmp.z := sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_z;
                end if;
            when load_angle =>
                rotation_angle <= signed("0" & sw(ANGLES_INTEGER_WIDTH-1 downto 0) & std_logic_vector(to_unsigned(0, ANGLES_FRACTIONAL_WIDTH)));
                register_next_tmp.state := idle;
            when read_x =>
                leds <= "10000001";
                register_next_tmp.display_data := register_current.x;
                register_next_tmp.state := idle;
            when read_y =>
                leds <= "10000010";
                register_next_tmp.display_data := register_current.y;
                register_next_tmp.state := idle;
            when read_z =>
                leds <= "10000100";
                register_next_tmp.display_data := register_current.z;
                register_next_tmp.state := idle;
            when read_x_result =>
                leds <= "10000001";
                register_next_tmp.display_data := std_logic_vector(result_x);
                register_next_tmp.state := idle;
            when read_y_result =>
                leds <= "10000010";
                register_next_tmp.display_data := std_logic_vector(result_y);
                register_next_tmp.state := idle;
            when read_z_result =>
                leds <= "10000100";
                register_next_tmp.display_data := std_logic_vector(result_z);
                register_next_tmp.state := idle;      
        end case;
        register_next <= register_next_tmp;
    end process combinational;

    led <= leds;

    -- debounce units
    debounce_unit0: entity work.debounce
        port map(
            clk=>clk, reset=>'0', sw=>btn(0),
            db_level=>open, db_tick=>db_btn(0)
        );
    debounce_unit1: entity work.debounce
    port map(
        clk=>clk, reset=>'0', sw=>btn(1),
        db_level=>open, db_tick=>db_btn(1)
    );
    debounce_unit2: entity work.debounce
    port map(
        clk=>clk, reset=>'0', sw=>btn(2),
        db_level=>open, db_tick=>db_btn(2)
    );
    debounce_unit3: entity work.debounce
    port map(
        clk=>clk, reset=>'0', sw=>btn(3),
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
            clk=>clk, reset=>'0',
            in0=>led0, in1=>led1, in2=>(others => '1'), in3=>(others => '1'),
            an=>an, sseg=>sseg);

    -- cordic rotator
    cordic_rotator: entity work.rotator
    generic map(
        COORDS_WIDTH            =>  COORDS_WIDTH,
        ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
        ANGLES_FRACTIONAL_WIDTH =>  ANGLES_FRACTIONAL_WIDTH
    )
    port map(
        clk=>clk,
        X0=>signed(register_current.x), Y0=>signed(register_current.y), Z0=>signed(register_current.z),
        angle_X=>rotation_angle, angle_Y=>rotation_angle, angle_Z=>rotation_angle,
        X=>result_x, Y=>result_y, Z=>result_z);

end behavioral;
