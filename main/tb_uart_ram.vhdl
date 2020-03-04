-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,
-- You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- Copyright (c) 2014-2020, Lars Asplund lars.anders.asplund@gmail.com

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

entity tb_uart_ram is
  generic (
    runner_cfg : string);
end entity;

architecture tb of tb_uart_ram is
  
    constant baud_rate : integer := 19200; -- bits / s
    constant clk_period : integer := 20; -- ns
    constant ADDRESS_WIDTH : integer := 23;
    constant DATA_WIDTH : integer := 16;
    constant CYCLES_TO_WAIT  : natural := 5;
    constant CYCLES_TO_WAIT_WIDTH : natural := 3;

    constant uart_bfm : uart_master_t := new_uart_master(initial_baud_rate => baud_rate);
    constant uart_stream : stream_master_t := as_stream(uart_bfm);

    signal clk: std_logic := '1';
    signal reset: std_logic := '0';
    -- uart
    signal RsRx: std_logic;
    signal RsTx: std_logic;
    -- inputs
    signal sw: std_logic_vector(7 downto 0) := (others => '0');
    signal btn: std_logic_vector(3 downto 0) := (others => '0');
    -- outputs
    signal an: std_logic_vector(3 downto 0);
    signal sseg: std_logic_vector(7 downto 0);
    -- to SRAM
    signal MemOE: std_logic;
    signal MemWR: std_logic;
    signal RamAdv: std_logic;
    signal RamCS: std_logic;
    signal RamClk: std_logic;
    signal RamCRE: std_logic;
    signal RamLB: std_logic;
    signal RamUB: std_logic;
    signal MemAdr: std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    signal MemDB: std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    main : process
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            reset_checker_stat;
            if run("general_test") then
                wait for 500 ns;
                push_stream(net, uart_stream, "01010110");
                wait for 2025 us;
                push_stream(net, uart_stream, "01011110");
                wait for 2025 us;
            end if;
        end loop;
        test_runner_cleanup(runner);
        wait;
    end process;

    test_runner_watchdog(runner, 20 ms);

    clk <= not clk after (clk_period/2) * 1 ns;

    dut : entity work.uart_ram
    generic map(
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        DATA_WIDTH => DATA_WIDTH,
        CYCLES_TO_WAIT => CYCLES_TO_WAIT,
        CYCLES_TO_WAIT_WIDTH => CYCLES_TO_WAIT_WIDTH        
    )
    port map (
        clk => clk,
        -- uart
        RsRx => RsRx,
        RsTx => RsTx,
        -- inputs
        sw => sw,
        btn => btn,
        -- outputs
        an => an,
        sseg => sseg,
        -- to SRAM
        MemOE => MemOE,
        MemWR => MemWR,
        RamAdv => RamAdv,
        RamCS => RamCS,
        RamClk => RamClk,
        RamCRE => RamCRE,
        RamLB => RamLB,
        RamUB => RamUB,
        MemAdr => MemAdr,
        MemDB => MemDB
    );

  uart_master_bfm : entity vunit_lib.uart_master
    generic map (
      uart => uart_bfm)
    port map (
      tx => RsRx);

end architecture;
