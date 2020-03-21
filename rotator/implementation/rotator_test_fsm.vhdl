library ieee;
use ieee.std_logic_1164.all;

package rotator_test_fsm_comp is
    
    type rotator_test_in_type is record
        sw: in std_logic_vector(7 downto 0);
        btn: in std_logic_vector(3 downto 0);
    end;

    type rotator_test_out_type is record
        led0: out std_logic_vector(3 downto 0);
        led1: out std_logic_vector(3 downto 0);
        led: out std_logic_vector(7 downto 0);
    end;

    component rotator_test_fsm
        clk: in std_logic;
        d: in rotator_test_in_type;
        q: in rotator_test_out_type;
    end component;

end package rotator_test_fsm_comp;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rotator_test_fsm_comp.all;

entity rotator_test_fsm is
    port(
        clk: in std_logic;
        -- inputs
        d: in rotator_test_in_type;
        -- outputs
        q: out rotator_test_out_type;
    );
end rotator_test_fsm;

architecture behavioral of rotator_test_fsm is

    type state_type is (idle, load_x, load_y, load_z, read_x, read_y, read_z);

    type reg_type is record
        state: state_type;
        x: std_logic_vector(7 downto 0);
        y: std_logic_vector(7 downto 0);
        z: std_logic_vector(7 downto 0);
    end record;        

    signal register_current, register_next: reg_type;

begin
    
    sequential: process(clk)
    begin
        if (clk'event and clk = '1') then
            register_current <= register_next;
        end if;
    end process sequential;

    combinational: process(register_current, d)
        variable register_next_tmp: reg_type;
    begin
        -- default value
        register_next_tmp := register_current;
        case register_current.state is
            when idle =>
                q.led <= "00000000";
                -- con el botón 0 y los primeros dos sw cargamos una coordenada
                if d.btn(0) = '1' then
                    case d.sw(1 downto 0) is
                        when "00" =>
                            register_next_tmp.state := load_x;
                        when "01" =>
                            register_next_tmp.state := load_y;
                        when "10" =>
                            register_next_tmp.state := load_z;
                        when others =>
                            register_next_tmp.state := idle;
                    end case;
                -- con el botón 1 y los primeros dos sw leemos una coordenada
                elsif d.btn(1) = '1' then
                    case d.sw(1 downto 0) is
                        when "00" =>
                            register_next_tmp.state := read_x;
                        when "01" =>
                            register_next_tmp.state := read_y;
                        when "10" =>
                            register_next_tmp.state := read_z;
                        when others =>
                            register_next_tmp.state := idle;
                    end case;
                else
                    register_next_tmp.state := idle;
                end if;
            when load_x =>
                q.led <= "00000001";
                if d.btn(3) = '1' then
                    register_next_tmp.x := d.sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_x;
                end if;
            when load_y =>
                q.led <= "00000010";
                if d.btn(3) = '1' then
                    register_next_tmp.y := d.sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_y;
                end if;
            when load_z =>
                q.led <= "00000011";
                if d.btn(3) = '1' then
                    register_next_tmp.z := d.sw;
                    register_next_tmp.state := idle;
                else
                    register_next_tmp.state := load_z;
                end if;
            when read_x =>
                q.led <= "00000100";
                q.led0 <= register_current.x(3 downto 0);
                q.led1 <= register_current.x(7 downto 4);
                register_next_tmp.state := idle;
            when read_y =>
                q.led <= "00000101";
                q.led0 <= register_current.y(3 downto 0);
                q.led1 <= register_current.y(7 downto 4);
                register_next_tmp.state := idle;
            when read_z =>
                q.led <= "00000110";
                q.led0 <= register_current.z(3 downto 0);
                q.led1 <= register_current.z(7 downto 4);
                register_next_tmp.state := idle;
        end case;
    
        register_next <= register_next_tmp;
    
    end process combinational;

end behavioral;
