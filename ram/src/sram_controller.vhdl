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
    type state_type is (idle, read, write);
    signal state_current, state_next: state_type;
    signal data_f2s_current, data_f2s_next: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_s2f_current, data_s2f_next: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal address_current, address_next: std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal we_current, we_next: std_logic;
    signal ce_current, ce_next: std_logic;
    signal tri_current, tri_next: std_logic;
    signal cycles_to_wait_current, cycles_to_wait_next  : unsigned(2 downto 0)  := to_unsigned(CYCLES_TO_WAIT, CYCLES_TO_WAIT_WIDTH);
begin

    -- state & data registers
    process(clk,reset)
    begin
        if (reset='1') then
            state_current <= idle;
            address_current <= (others=>'0');
            data_f2s_current <= (others=>'0');
            data_s2f_current <= (others=>'0');
            tri_current <= '0';
            we_current <= '1';
            ce_current <= '1';
            ready <= '1';
        elsif rising_edge(clk) then
            state_current <= state_next;
            address_current <= address_next;
            data_f2s_current <= data_f2s_next;
            data_s2f_current <= data_s2f_next;
            tri_current <= tri_next;
            we_current <= we_next;
            ce_current <= ce_next;
        end if;
    end process;

   -- next-state logic
    process(all)
    begin
        address_next <= address_current;
        data_f2s_next <= data_f2s_current;
        data_s2f_next <= data_s2f_current;
        ready <= '0';
        tri_next <= tri_current;
        we_next <= we_current;
        ce_next <= ce_current;
        case state_current is
            when idle =>
                ready <= '1';
                if mem = '0' then
                    state_next <= idle;
                    we_next <= '1';
                    ce_next <= '1';
                    tri_next <= '0';
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

end arch;