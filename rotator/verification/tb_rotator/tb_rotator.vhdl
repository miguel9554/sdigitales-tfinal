library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity tb_rotator is
end entity tb_rotator;

architecture behavioral of tb_rotator is

    -- Constants
    constant COORDS_WIDTH               :   integer := 32;
    constant ANGLES_INTEGER_WIDTH       :   integer := 8;
    constant STAGES                     :   integer := 16;
    constant CLK_PERIOD                 :   time    := 50 ns;

    -- UUT (unit under test) declaration
    component rotator is
        generic (
            COORDS_WIDTH            : integer;
            ANGLES_INTEGER_WIDTH    : integer;
            STAGES                  : integer
        );
        port (
            clk                         :   in std_logic;
            X0, Y0, Z0                  :   in signed(COORDS_WIDTH-1 downto 0);
            angle_X, angle_Y, angle_Z   :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
            X, Y, Z                     :   out signed(COORDS_WIDTH-1 downto 0)
        );
    end component rotator;

    -- Inputs
    signal sClk     :   std_logic                               := '0';
    signal sX0      :   signed(COORDS_WIDTH-1 downto 0)         := (others => '0');
    signal sY0      :   signed(COORDS_WIDTH-1 downto 0)         := (others => '0');
    signal sZ0      :   signed(COORDS_WIDTH-1 downto 0)         := (others => '0');
    signal sAngle_X :   signed(ANGLES_INTEGER_WIDTH-1 downto 0) := (others => '0');
    signal sAngle_Y :   signed(ANGLES_INTEGER_WIDTH-1 downto 0) := (others => '0');
    signal sAngle_Z :   signed(ANGLES_INTEGER_WIDTH-1 downto 0) := (others => '0');

    -- Outputs
    signal sExpectedX   :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sActualX     :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sExpectedY   :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sActualY     :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sExpectedZ   :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sActualZ     :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');    

    -- Reporting metrics
    signal stotalReads  :   integer := 0;
    signal sXerrors     :   integer := 0;
    signal sYerrors     :   integer := 0;
    signal sZerrors     :   integer := 0;

begin

    -- UUT (unit under test) instantiation
    uut: rotator
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            clk         =>  sClk,
            X0          =>  sX0,
            Y0          =>  sY0,
            Z0          =>  sZ0,
            angle_X     =>  sAngle_X,
            angle_Y     =>  sAngle_Y,
            angle_Z     =>  sAngle_Z,
            X           =>  sActualX,
            Y           =>  sActualY,
            Z           =>  sActualZ
        );
    
    sClk <= not sClk after CLK_PERIOD/2;

    p_read : process

        variable waiting: natural := 1;
    
        -- Reading related variables
        file data_file              : text open read_mode is "verification/tb_rotator/stimulus.dat";
        variable text_line          : line;
        variable ok                 : boolean;
        variable c_BUFFER           : character;

        -- Inputs to read from file
        variable fX0        :   integer;
        variable fY0        :   integer;
        variable fZ0        :   integer;
        variable fAngle_X   :   integer;
        variable fAngle_Y   :   integer;
        variable fAngle_Z   :   integer;

        -- Outputs to read from file
        variable fExpectedX     :   integer;
        variable fExpectedY     :   integer;
        variable fExpectedZ     :   integer;
    
    begin

        while not endfile(data_file) loop
            
            readline(data_file, text_line);

            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;

            report "Reading line: " & text_line.all;
            stotalReads <=  stotalReads + 1;


            -- READ INPUTS


            read(text_line, fX0, ok); -- Read X0
            assert ok
                report "Read 'X0' failed for line: " & text_line.all
                severity failure;
            sX0     <=  to_signed(fX0, sX0'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fY0, ok); -- Read Y0
            assert ok
                report "Read 'Y0' failed for line: " & text_line.all
                severity failure;
            sY0     <=  to_signed(fY0, sY0'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fZ0, ok); -- Read Z0
            assert ok
                report "Read 'Z0' failed for line: " & text_line.all
                severity failure;
            sZ0     <=  to_signed(fZ0, sZ0'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fAngle_X, ok); -- Read Angle_X
            assert ok
                report "Read 'Angle_X' failed for line: " & text_line.all
                severity failure;
            sAngle_X    <=  to_signed(fAngle_X, sAngle_X'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fAngle_Y, ok); -- Read Angle_Y
            assert ok
                report "Read 'Angle_Y' failed for line: " & text_line.all
                severity failure;
            sAngle_Y    <=  to_signed(fAngle_Y, sAngle_Y'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fAngle_Z, ok); -- Read Angle_Z
            assert ok
                report "Read 'Angle_Z' failed for line: " & text_line.all
                severity failure;
            sAngle_Z    <=  to_signed(fAngle_Z, sAngle_Z'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            
            wait for CLK_PERIOD*10;


            -- READ OUTPUTS


            read(text_line, fExpectedX, ok); -- Read X
            assert ok
                report "Read 'ExpectedX' failed for line: " & text_line.all
                severity failure;
            sExpectedX      <=  to_signed(fExpectedX, sExpectedX'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fExpectedY, ok); -- Read Y
            assert ok
                report "Read 'ExpectedY' failed for line: " & text_line.all
                severity failure;
            sExpectedY      <=  to_signed(fExpectedY, sExpectedY'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fExpectedZ, ok); -- Read Z
            assert ok
                report "Read 'ExpectedZ' failed for line: " & text_line.all
                severity failure;
            sExpectedZ      <=  to_signed(fExpectedZ, sExpectedZ'length);

            assert (sExpectedX = sActualX)      report "ERROR (X): expected " & integer'image(to_integer(sExpectedX))       & ", got " & integer'image(to_integer(sActualX))        severity ERROR;
            if (sExpectedX /= sActualX) then
                sXerrors    <=  sXerrors + 1;
            end if;         
            
            assert (sExpectedY = sActualY)      report "ERROR (Y): expected " & integer'image(to_integer(sExpectedY))       & ", got " & integer'image(to_integer(sActualY))        severity ERROR;
            if (sExpectedY /= sActualY) then
                sYerrors    <=  sYerrors + 1;
            end if;

            assert (sExpectedZ = sActualZ)      report "ERROR (Z): expected " & integer'image(to_integer(sExpectedY))       & ", got " & integer'image(to_integer(sActualY))        severity ERROR;
            if (sExpectedZ /= sActualZ) then
                sZerrors    <=  sZerrors + 1;
            end if;

            wait for CLK_PERIOD/2;

        end loop;

        wait for CLK_PERIOD; -- This wait has no function, it's here just to avoid the bug of last errors not being accounted

        write(text_line, string'("                                ")); writeline(output, text_line);
        write(text_line, string'("################################")); writeline(output, text_line);
        write(text_line, string'("#                              #")); writeline(output, text_line);
        write(text_line, string'("#  ++====    ++  ++    ++=\\   #")); writeline(output, text_line);
        write(text_line, string'("#  ||        ||\\||    ||  \\  #")); writeline(output, text_line);
        write(text_line, string'("#  ++===     ++ \++    ++  ||  #")); writeline(output, text_line);
        write(text_line, string'("#  ||        ||  ||    ||  //  #")); writeline(output, text_line);
        write(text_line, string'("#  ++====    ++  ++    ++=//   #")); writeline(output, text_line);
        write(text_line, string'("#                              #")); writeline(output, text_line);
        write(text_line, string'("################################")); writeline(output, text_line);
        write(text_line, string'("                                ")); writeline(output, text_line);

        report "Total lines processed: " & integer'image(stotalReads);
        report "X errors: " & integer'image(sXerrors);
        report "Y errors: " & integer'image(sYerrors);
        report "Z errors: " & integer'image(sYerrors);

        wait for CLK_PERIOD; -- This wait has no function, it's here just to avoid the bug of ghdl not saving the last time event to the output waveform

        assert false report -- This asserts aborts the simulation
            "Fin de la simulacion" severity failure;

    end process p_read;

end architecture behavioral;
