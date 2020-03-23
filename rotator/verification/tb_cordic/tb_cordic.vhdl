library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity tb_cordic is
end entity tb_cordic;

architecture behavioral of tb_cordic is

    -- Constants
    constant COORDS_WIDTH               :   integer := 32;
    constant ANGLES_INTEGER_WIDTH       :   integer := 8;
    constant STAGES                     :   integer := 16;
    constant WAIT_TIME                  :   time    := 50 ns;

    -- UUT (unit under test) declaration
    component cordic is
        generic (
            COORDS_WIDTH            : integer;
            ANGLES_INTEGER_WIDTH    : integer;
            STAGES                  : integer
        );
        port (
            X0, Y0          :   in signed(COORDS_WIDTH-1 downto 0);
            angle           :   in signed(ANGLES_INTEGER_WIDTH-1 downto 0);
            X, Y            :   out signed(COORDS_WIDTH-1 downto 0)
        );
    end component cordic;

    -- Inputs
    signal sX0      :   signed(COORDS_WIDTH-1 downto 0)         := (others => '0');
    signal sY0      :   signed(COORDS_WIDTH-1 downto 0)         := (others => '0');
    signal sAngle   :   signed(ANGLES_INTEGER_WIDTH-1 downto 0) := (others => '0');

    -- Outputs
    signal sExpectedX   :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sActualX     :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sExpectedY   :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal sActualY     :   signed(COORDS_WIDTH-1 downto 0) := (others => '0');

    -- Reporting metrics
    signal stotalReads  :   integer := 0;
    signal sXerrors     :   integer := 0;
    signal sYerrors     :   integer := 0;

begin

    -- UUT (unit under test) instantiation
    uut: cordic
        generic map (
            COORDS_WIDTH            =>  COORDS_WIDTH,
            ANGLES_INTEGER_WIDTH    =>  ANGLES_INTEGER_WIDTH,
            STAGES                  =>  STAGES
        )
        port map (
            X0          =>  sX0,
            Y0          =>  sY0,
            angle       =>  sAngle,
            X           =>  sActualX,
            Y           =>  sActualY
        );

    p_read : process
    
        -- Reading related variables
        file data_file              : text open read_mode is "verification/tb_cordic/stimulus.dat";
        variable text_line          : line;
        variable ok                 : boolean;
        variable c_BUFFER           : character;

        -- Inputs to read from file
        variable fX0        :   integer;
        variable fY0        :   integer;
        variable fAngle     :   integer;

        -- Outputs to read from file
        variable fExpectedX     :   integer;
        variable fExpectedY     :   integer;
    
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

            read(text_line, fAngle, ok); -- Read angle
            assert ok
                report "Read 'angle' failed for line: " & text_line.all
                severity failure;
            sAngle      <=  to_signed(fAngle, sAngle'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;


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

            wait for WAIT_TIME;

            assert (sExpectedX = sActualX)      report "ERROR (X): expected " & integer'image(to_integer(sExpectedX))       & ", got " & integer'image(to_integer(sActualX))        severity ERROR;
            if (sExpectedX /= sActualX) then
                sXerrors    <=  sXerrors + 1;
            end if;         
            
            assert (sExpectedY = sActualY)      report "ERROR (Y): expected " & integer'image(to_integer(sExpectedY))       & ", got " & integer'image(to_integer(sActualY))        severity ERROR;
            if (sExpectedY /= sActualY) then
                sYerrors    <=  sYerrors + 1;
            end if;

        end loop;

        wait for WAIT_TIME; -- This wait has no function, it's here just to avoid the bug of last errors not being accounted

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

        wait for WAIT_TIME; -- This wait has no function, it's here just to avoid the bug of ghdl not saving the last time event to the output waveform

        assert false report -- This asserts aborts the simulation
            "Fin de la simulacion" severity failure;

    end process p_read;

end architecture behavioral;
