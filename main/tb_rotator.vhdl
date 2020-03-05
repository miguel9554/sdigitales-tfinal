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

entity tb_rotator is
  generic (
    runner_cfg : string);
end entity;

architecture tb of tb_rotator is
  
    constant clk_period                 : integer := 20; -- ns
    constant COORDS_WIDTH               :   integer := 32;
    constant ANGLES_INTEGER_WIDTH       :   integer := 6;
    constant ANGLES_FRACTIONAL_WIDTH    :   integer := 16;
    constant ANGLES_WIDTH               :   integer := ANGLES_FRACTIONAL_WIDTH+ANGLES_INTEGER_WIDTH+1;
    constant STAGES                     :   integer := 16;

    signal clk: std_logic := '1';

    signal X0, Y0, Z0: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal angle_X, angle_Y, angle_Z: signed(ANGLES_WIDTH-1 downto 0) := (others => '0');
    signal X, Y, Z: signed(COORDS_WIDTH-1 downto 0);

    signal rxX0, rxY0, rxZ0: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal rxAngle: signed(ANGLES_WIDTH-1 downto 0) := (others => '0');
    signal rxX, rxY, rxZ: signed(COORDS_WIDTH-1 downto 0);

    signal ryX0, ryY0, ryZ0: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal ryAngle: signed(ANGLES_WIDTH-1 downto 0) := (others => '0');
    signal ryX, ryY, ryZ: signed(COORDS_WIDTH-1 downto 0);

    signal rzX0, rzY0, rzZ0: signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal rzAngle: signed(ANGLES_WIDTH-1 downto 0) := (others => '0');
    signal rzX, rzY, rzZ: signed(COORDS_WIDTH-1 downto 0);    

begin

    main : process
    begin
        test_runner_setup(runner, runner_cfg);

        while test_suite loop
            reset_checker_stat;
            if run("test_rotator") then

                wait for 200 ns;

                X0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                Y0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                Z0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                angle_X <= (others => '0');
                angle_Y <= (others => '0');
                angle_Z <= (others => '0');

                wait for 200 ns;

            elsif run("test_rx") then

                wait for 200 ns;

                rxX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rxY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rxZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rxAngle <= (others => '0');

                wait for 200 ns;
                
            elsif run("test_ry") then

                wait for 200 ns;

                ryX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                ryY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                ryZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                ryAngle <= (others => '0');

                wait for 200 ns;
                
            elsif run("test_rz") then

                wait for 200 ns;

                rzX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rzY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rzZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-1)), COORDS_WIDTH);
                rzAngle <= (others => '0');

                wait for 200 ns;

            elsif run("test_all") then

                wait for 200 ns;

                rxX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rxY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rxZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rxAngle <= (others => '0');

                ryX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                ryY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                ryZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                ryAngle <= (others => '0');
                
                rzX0 <= to_signed(integer(0.3779969228*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rzY0 <= to_signed(integer(0.4348357180*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rzZ0 <= to_signed(integer(0.8173348302*2**(COORDS_WIDTH-3)), COORDS_WIDTH);
                rzAngle <= (others => '0');                

                wait for 200 ns;     
                
            end if;
        end loop;
        test_runner_cleanup(runner);
        wait;
    end process;

    test_runner_watchdog(runner, 20 ms);

    clk <= not clk after (clk_period/2) * 1 ns;

    dut: entity work.rotator
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            ANGLES_FRACTIONAL_WIDTH =>  ANGLES_FRACTIONAL_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            clk         =>  clk,
            X0          =>  X0,
            Y0          =>  Y0,
            Z0          =>  Z0,
            angle_X     =>  angle_X,
            angle_Y     =>  angle_Y,
            angle_Z     =>  angle_Z,
            X           =>  X,
            Y           =>  Y,
            Z           =>  Z
        );
    
    x_rotator: entity work.rx
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            ANGLES_FRACTIONAL_WIDTH =>  ANGLES_FRACTIONAL_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  rxX0,
            Y0          =>  rxY0,
            Z0          =>  rxZ0,
            angle       =>  rxAngle,
            X           =>  rxX,
            Y           =>  rxY,
            Z           =>  rxZ
        );

    y_rotator: entity work.ry
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            ANGLES_FRACTIONAL_WIDTH =>  ANGLES_FRACTIONAL_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  ryX0,
            Y0          =>  ryY0,
            Z0          =>  ryZ0,
            angle       =>  ryAngle,
            X           =>  ryX,
            Y           =>  ryY,
            Z           =>  ryZ
        );
    
    z_rotator: entity work.rz
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            ANGLES_FRACTIONAL_WIDTH =>  ANGLES_FRACTIONAL_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  rzX0,
            Y0          =>  rzY0,
            Z0          =>  rzZ0,
            angle       =>  rzAngle,
            X           =>  rzX,
            Y           =>  rzY,
            Z           =>  rzZ
        );

end architecture;
