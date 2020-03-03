library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sram_controller is
    generic(
        DATA_WIDTH      : natural := 16;
        ADDRESS_WIDTH   : natural := 23;
        CYCLES_TO_WAIT  : natural := 5;
        CYCLES_TO_WAIT_WIDTH : natural := 3
    );
    port(
        clk, reset  : in std_logic;
        -- to/from main system
        mem         : in std_logic;
        rw          : in std_logic;
        address_in  : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        data_in    : in std_logic_vector(DATA_WIDTH-1 downto 0);
        ready       : out std_logic;
        data_out    : out std_logic_vector(DATA_WIDTH-1 downto 0);
        -- to/from SRAM
        address_to_sram                         : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        data_to_sram                            : inout std_logic_vector(DATA_WIDTH-1 downto 0);
        clk_out, adv, ce, oe, we, cre, lb, ub   : out std_logic
    );
end sram_controller;

architecture arch of sram_controller is
    
    constant init_time_const : integer := (15100);

    type state_type is (init, idle, read, write);

    signal state_current, state_next: state_type := init;
    signal data_f2s_current, data_f2s_next: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_s2f_current, data_s2f_next: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal address_current, address_next: std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal ready_current, ready_next: std_logic := '1';
    signal we_current, we_next: std_logic := '1';
    signal ce_current, ce_next: std_logic := '1';
    signal tri_current, tri_next: std_logic := '0';
    signal cycles_to_wait_current, cycles_to_wait_next  : unsigned(CYCLES_TO_WAIT_WIDTH-1 downto 0)  := to_unsigned(CYCLES_TO_WAIT, CYCLES_TO_WAIT_WIDTH);
    signal count_current, count_next : integer range 0 to init_time_const := 0;
begin

    -- state & data registers
    process(reset, clk)
    begin
        if (reset='1') then
            state_current <= idle;
            address_current <= (others=>'0');
            data_f2s_current <= (others=>'0');
            data_s2f_current <= (others=>'0');
            cycles_to_wait_current <= (others=>'0');
            tri_current <= '0';
            we_current <= '1';
            ce_current <= '1';
            ready_current <= '1';
            count_current <= 0;
        elsif (clk'event and clk='1') then
            state_current <= state_next;
            address_current <= address_next;
            data_f2s_current <= data_f2s_next;
            data_s2f_current <= data_s2f_next;
            tri_current <= tri_next;
            we_current <= we_next;
            ce_current <= ce_next;
            ready_current <= ready_next;
            cycles_to_wait_current <= cycles_to_wait_next;
            count_current <= count_next;
        end if;
    end process;

   -- next-state logic
    process(state_current, data_f2s_current, data_s2f_current,
    address_current, ready_current, we_current, ce_current, tri_current, cycles_to_wait_current,
    mem, rw, address_in, data_in, count_current)
    begin
        address_next <= address_current;
        data_f2s_next <= data_f2s_current;
        data_s2f_next <= data_s2f_current;
        ready_next <= '0';
        cycles_to_wait_next <= cycles_to_wait_current;
        tri_next <= tri_current;
        we_next <= we_current;
        ce_next <= ce_current;
        count_next <= count_current;
        case state_current is
            when init =>
                if count_current >= init_time_const then
                    state_next <= idle;
                else
                    count_next <= count_current + 1;
                    state_next <= init;
                end if;
            when idle =>
                if mem = '0' then
                    state_next <= idle;
                    we_next <= '1';
                    ce_next <= '1';
                    tri_next <= '0';
                    ready_next <= '1';
                else
                    address_next <= address_in;
                    cycles_to_wait_next <= to_unsigned(CYCLES_TO_WAIT, CYCLES_TO_WAIT_WIDTH);
                    if rw = '0' then
                        state_next <= write;
                        data_f2s_next <= data_in;
                        we_next <= '0';
                        ce_next <= '0';
                        tri_next <= '1';
                    else
                        state_next <= read;
                        we_next <= '1';
                        ce_next <= '0';
                        tri_next <= '0';
                    end if;
                end if;
            when read =>
                cycles_to_wait_next <= cycles_to_wait_current-1;
                if cycles_to_wait_next = to_unsigned(0, CYCLES_TO_WAIT_WIDTH) then
                    data_s2f_next   <= data_to_sram;
                    state_next      <= idle;
                    we_next <= '1';
                    ce_next <= '1';
                    tri_next <= '0';
                    ready_next <= '1';
                else
                    state_next  <=  read;
                end if;
            when write =>
                cycles_to_wait_next <= cycles_to_wait_current-1;
                if cycles_to_wait_next = to_unsigned(0, CYCLES_TO_WAIT_WIDTH) then
                    state_next      <= idle;
                    we_next <= '1';
                    ce_next <= '1';
                    tri_next <= '0';
                    ready_next <= '1';
                else
                    state_next  <=  write;
                end if;
        end case;
    end process;

    -- to main system
    data_out <= data_s2f_current;
    -- to sram
    ce      <=  ce_current;
    we      <=  we_current;
    clk_out <= '0';
    adv     <= '0';
    oe      <= '0';
    cre     <= '0';
    lb      <= '0';
    ub      <= '0';
    data_to_sram    <= data_f2s_current when tri_current = '1' else (others => 'Z');
    address_to_sram <= address_current;
    ready <= ready_current;

end arch;