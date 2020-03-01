library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

entity tb_sram is
    generic (
        runner_cfg : string
    );
end entity;

architecture tb of tb_sram is
    
    -- constants
    constant clk_period : integer := 20; -- ns
    constant DATA_WIDTH      : natural := 16;
    constant ADDRESS_WIDTH   : natural := 23;
    constant CYCLES_TO_WAIT  : natural := 5;
    constant CYCLES_TO_WAIT_WIDTH : natural := 3;

    -- signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    -- to/from main system
    signal mem : std_logic := '0';
    signal rw : std_logic := '0';
    signal address_in : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal data_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ready : std_logic;
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- to/from main SRAM
    signal address_to_sram : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal data_to_sram : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal clk_out : std_logic;
    signal adv : std_logic;
    signal ce : std_logic;
    signal oe : std_logic;
    signal we : std_logic;
    signal cre : std_logic;
    signal lb : std_logic;
    signal ub : std_logic;

begin

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            reset_checker_stat;
            if run("test_ready_high_at_start") then
                wait until ready = '1' for 200 ns;
                check_equal(ready, '1');
            elsif run("test_read") then
                -- ponemos las entradas correspondientes
                mem <= '1';
                rw <= '1';
                address_in <= std_logic_vector(to_unsigned(8, ADDRESS_WIDTH));
                data_to_sram <= std_logic_vector(to_unsigned(25, DATA_WIDTH));
                wait for clk_period * 1 ns;
                -- verificamos que las señales para interfacear con la memoria sean correctas
                mem <= '0';
                check_equal(ready, '0');
                check_equal(ce, '0');
                check_equal(we, '1');
                wait until ready = '1' for clk_period * 8 * 1 ns;
                -- verificamos que lo devuelto sea correcto, y las señales de la sram
                check_equal(we, '1');
                check_equal(ce, '1');
                check_equal(ready, '1');
                check_equal(data_out, std_logic_vector(to_unsigned(25, DATA_WIDTH)));
            elsif run("test_write") then
                -- ponemos las entradas correspondientes
                mem <= '1';
                rw <= '0';
                address_in <= std_logic_vector(to_unsigned(8, ADDRESS_WIDTH));
                data_in <= std_logic_vector(to_unsigned(33, DATA_WIDTH));
                data_to_sram <= (others => 'Z');
                wait for clk_period * 1 ns;
                -- verificamos que las señales para interfacear con la memoria sean correctas
                mem <= '0';
                check_equal(ready, '0');
                check_equal(ce, '0');
                check_equal(we, '0');
                wait until ready = '1' for clk_period * 30 * 1 ns;
                -- verificamos que lo devuelto sea correcto, y las señales de la sram
                check_equal(we, '1');
                check_equal(ce, '1');
                check_equal(ready, '1');
                check_equal(data_to_sram, std_logic_vector(to_unsigned(33, DATA_WIDTH)));
            end if;
        end loop;

        test_runner_cleanup(runner);
        wait;
    end process;
    
    clk <= not clk after (clk_period/2) * 1 ns;

    dut : entity work.sram_controller
        generic map (
            DATA_WIDTH  => DATA_WIDTH,
            ADDRESS_WIDTH   => ADDRESS_WIDTH,
            CYCLES_TO_WAIT  => CYCLES_TO_WAIT,
            CYCLES_TO_WAIT_WIDTH    => CYCLES_TO_WAIT_WIDTH
        )
        port map (
            clk => clk,
            reset => reset,
            -- to/from main system
            mem => mem,
            rw => rw,
            address_in => address_in,
            data_in => data_in,
            ready => ready,
            data_out => data_out,
            -- to/from SRAM
            address_to_sram => address_to_sram,
            data_to_sram => data_to_sram,
            clk_out => clk_out,
            adv => adv,
            ce => ce,
            oe => oe,
            we => we,
            cre => cre,
            lb => lb,
            ub => ub
        );

end architecture;