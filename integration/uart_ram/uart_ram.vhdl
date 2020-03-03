library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uart_ram is
    generic(
        constant DATA_WIDTH      : natural := 16;
        constant ADDRESS_WIDTH   : natural := 23
    );
    port(
        clk: in std_logic;
        -- uart
        RsRx: in std_logic;
        RsTx: out std_logic;
        -- inputs
        sw: in std_logic_vector(7 downto 0);
        btn: in std_logic_vector(3 downto 0);
        -- outputs
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0);
        -- to SRAM
        MemOE: out std_logic;
        MemWR: out std_logic;
        RamAdv: out std_logic;
        RamCS: out std_logic;
        RamClk: out std_logic;
        RamCRE: out std_logic;
        RamLB: out std_logic;
        RamUB: out std_logic;
        MemAdr: out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        MemDB: inout std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end uart_ram;

architecture arch of uart_ram is
   
    constant CYCLES_TO_WAIT  : natural := 100;
    constant CYCLES_TO_WAIT_WIDTH : natural := 7;

    signal data_reg: std_logic_vector(7 downto 0);
    signal db_btn: std_logic_vector(3 downto 0);

    signal reset: std_logic := '1';

    -- seven segment
    signal led3, led2, led1, led0: std_logic_vector(7 downto 0);

    -- ram
    signal data_in: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal ready: std_logic;
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);

    -- uart
    signal tx_full, rx_empty: std_logic := '0';
    signal r_data: std_logic_vector(7 downto 0);

    -- state machine
    type state_t is (initial_state, waiting_for_uart, write_sram, waiting_for_sram);
    signal state_current, state_next : state_t := initial_state;
    signal address_current, address_next: unsigned(ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal mem_current, mem_next: std_logic := '0';
    signal rw_current, rw_next: std_logic := '0';
    signal data_in_current, data_in_next: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal rd_uart_current, rd_uart_next: std_logic := '0';
    signal cycles_current, cycles_next: unsigned(CYCLES_TO_WAIT_WIDTH-1 downto 0) := to_unsigned(CYCLES_TO_WAIT, CYCLES_TO_WAIT_WIDTH);

begin

    -- instantiate uart
    uart_unit: entity work.uart(str_arch)
    port map(
        clk =>  clk, reset =>  reset, rd_uart =>  rd_uart_current,
        wr_uart =>  rd_uart_current, rx =>  RsRx, w_data =>  r_data,
        tx_full => tx_full, rx_empty =>  rx_empty,
        r_data =>  r_data, tx =>  RsTx
    );

    -- instantiate ram controller
	sram: entity work.sram_controller
	port map (
		clk => clk,
		reset => reset,
		-- to/from main system
      mem => mem_current, rw => rw_current, address_in => std_logic_vector(address_current), data_in => data_in_current,
      ready => ready, data_out => data_out,
		-- to/from SRAM
		address_to_sram => MemAdr, data_to_sram => MemDB, clk_out => RamClk, adv => RamAdv,
		ce => RamCS, oe => MemOE, we => MemWR, cre => RamCRE, lb => RamLB, ub => RamUB
	);

    -- instantiate four instances of hex decoders
    sseg_unit_0: entity work.hex_to_sseg
        port map(hex=>data_out(3 downto 0), dp =>'1', sseg=>led0);
    sseg_unit_1: entity work.hex_to_sseg
        port map(hex=>data_out(7 downto 4), dp =>'1', sseg=>led1);
    sseg_unit_2: entity work.hex_to_sseg
        port map(hex=>data_out(11 downto 8), dp =>'1', sseg=>led2);
    sseg_unit_3: entity work.hex_to_sseg
        port map(hex=>data_out(15 downto 12), dp =>'1', sseg=>led3);

    -- instantiate 7-seg LED display time-multiplexing module
    disp_unit: entity work.disp_mux
        port map(
            clk=>clk, reset=>'0',
            in0=>led0, in1=>led1, in2=>led2, in3=>led3,
            an=>an, sseg=>sseg);

    -- instantiate 4 debouncers
    debounce_unit0: entity work.debounce
        port map(
            clk=>clk, reset=>reset, sw=>btn(0),
            db_level=>open, db_tick=>db_btn(0)
        );
    debounce_unit1: entity work.debounce
        port map(
            clk=>clk, reset=>reset, sw=>btn(1),
            db_level=>open, db_tick=>db_btn(1));
    debounce_unit2: entity work.debounce
        port map(
            clk=>clk, reset=>reset, sw=>btn(2),
            db_level=>open, db_tick=>db_btn(2));
    debounce_unit3: entity work.debounce
        port map(
            clk=>clk, reset=>reset, sw=>btn(3),
            db_level=>open, db_tick=>db_btn(3));
         
    -- state & data registers
    process(clk)
    begin
    if (clk'event and clk='1') then
        state_current <= state_next;
        address_current <= address_next;
        mem_current <= mem_next;
        rw_current <= rw_next;
        data_in_current <= data_in_next;
        rd_uart_current <= rd_uart_next;
        cycles_current <= cycles_next;
    end if;
    end process;

    -- next state logic
    process(state_current, rx_empty, r_data, address_current, state_current, rw_current,
    data_in_current, address_current, db_btn, cycles_current, reset)
    begin
        mem_next <= '0';
        rd_uart_next <= '0';
        rw_next <= rw_current;
        data_in_next <= data_in_current;
        case state_current is
            when initial_state =>
                if cycles_current = to_unsigned(0, CYCLES_TO_WAIT_WIDTH) then
                    reset <= '0';
                    state_next <= waiting_for_uart;
                else
                    cycles_next <= cycles_current - 1;
                    state_next <= initial_state;
                end if;
            when waiting_for_uart =>
                if rx_empty = '0' then
                    state_next <= write_sram;
                else
                    if db_btn(2) = '1' then
                        mem_next <= '1';
                        rw_next <= '0';
                        address_next <= unsigned("0000000000" & sw);
                        state_next <= waiting_for_sram;
                    else
                    state_next <= waiting_for_uart;
                    end if;
                end if;
            when write_sram =>
                mem_next <= '1';
                rd_uart_next <= '1';
                rw_next <= '1';
                data_in_next <= "00000000" & r_data;
                state_next <= waiting_for_sram;
            when waiting_for_sram =>
                if ready = '1' then
                    address_next <= address_current + 1;
                    rw_next <= '0';
                    state_next <= waiting_for_uart;
                else
                    state_next <= waiting_for_sram;
                end if;
        end case;
    end process;

end arch;