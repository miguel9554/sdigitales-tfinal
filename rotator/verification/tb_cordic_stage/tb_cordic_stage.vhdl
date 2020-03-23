library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;

entity tb_cordic_stage is
end entity tb_cordic_stage;

architecture behavioral of tb_cordic_stage is

    -- Constants
    constant WIDTH          :   integer := 10;
    constant ANGLE_WIDTH    :   integer := 23;
    constant STEP_WIDTH     :   integer := 4;
    constant WAIT_TIME      :   time    := 50 ns;

    -- UUT (unit under test) declaration
    component cordic_stage is
        generic (
            COORDS_WIDTH    : integer;
            ANGLE_WIDTH     : integer;
            STEP_WIDTH      : integer
        );
        port (
            X0, Y0      :   in signed(COORDS_WIDTH-1 downto 0);
            Z0          :   in signed(ANGLE_WIDTH-1 downto 0);
            atan        :   in signed(ANGLE_WIDTH-1 downto 0);
            step        :   in unsigned(STEP_WIDTH-1 downto 0);
            X, Y        :   out signed(COORDS_WIDTH-1 downto 0);
            Z           :   out signed(ANGLE_WIDTH-1 downto 0)
        );
    end component cordic_stage;

    -- Inputs
    signal sX0      :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sY0      :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sZ0      :   signed( ANGLE_WIDTH - 1 downto 0)   := (others => '0');
    signal sAtan    :   signed( ANGLE_WIDTH - 1 downto 0)   := (others => '0');
    signal sStep    :   unsigned( STEP_WIDTH - 1 downto 0)  := (others => '0');

    -- Outputs
    signal sExpectedX       :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sActualX         :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sExpectedY       :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sActualY         :   signed( WIDTH - 1 downto 0)         := (others => '0');
    signal sExpectedZ       :   signed( ANGLE_WIDTH - 1 downto 0)   := (others => '0');
    signal sActualZ         :   signed( ANGLE_WIDTH - 1 downto 0)   := (others => '0');

    -- Reporting metrics
    signal stotalReads  :   integer := 0;
    signal sXerrors     :   integer := 0;
    signal sYerrors     :   integer := 0;
    signal sZerrors     :   integer := 0;

begin

    -- UUT (unit under test) instantiation
    uut: cordic_stage
        generic map (
            COORDS_WIDTH    =>  WIDTH,
            ANGLE_WIDTH     =>  ANGLE_WIDTH,
            STEP_WIDTH      =>  STEP_WIDTH
        )
        port map (
            X0          =>  sX0,
            Y0          =>  sY0,
            Z0          =>  sZ0,
            atan        =>  sAtan,
            step        =>  sStep,
            X           =>  sActualX,
            Y           =>  sActualY,
            Z           =>  sActualZ
        );

    p_read : process
    
        -- Reading related variables
        file data_file              : text open read_mode is "verification/tb_cordic_stage/stimulus.dat";
        variable text_line          : line;
        variable ok                 : boolean;
        variable c_BUFFER           : character;

        -- Inputs to read from file
        variable fX0        :   integer;
        variable fY0        :   integer;
        variable fZ0        :   integer;
        variable fAtan      :   integer;
        variable fStep      :   integer;

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

            read(text_line, fAtan, ok); -- Read Atan
            assert ok
                report "Read 'Atan' failed for line: " & text_line.all
                severity failure;
            sAtan       <=  to_signed(fAtan, sAtan'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fStep, ok); -- Read Step
            assert ok
                report "Read 'Step' failed for line: " & text_line.all
                severity failure;
            sStep       <=  to_unsigned(fStep, sStep'length);               

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

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fExpectedZ, ok); -- Read Z
            assert ok
                report "Read 'ExpectedZ' failed for line: " & text_line.all
                severity failure;
            sExpectedZ      <=  to_signed(fExpectedZ, sExpectedZ'length);

            wait for WAIT_TIME;

            assert (sExpectedX      = sActualX)     report "ERROR (X): expected " & integer'image(to_integer(sExpectedX))       & ", got " & integer'image(to_integer(sActualX))        severity ERROR;
            if (sExpectedX /= sActualX) then
                sXerrors    <=  sXerrors + 1;
            end if;
            assert (sExpectedY      = sActualY)     report "ERROR (Y): expected " & integer'image(to_integer(sExpectedY))       & ", got " & integer'image(to_integer(sActualY))        severity ERROR;
            if (sExpectedY /= sActualY) then
                sYerrors    <=  sYerrors + 1;
            end if;
            assert (sExpectedZ      = sActualZ)     report "ERROR (Z): expected " & integer'image(to_integer(sExpectedZ))       & ", got " & integer'image(to_integer(sActualZ))        severity ERROR;
            if (sExpectedZ /= sActualZ) then
                sZerrors    <=  sZerrors + 1;
            end if;

            read(text_line, c_BUFFER, ok); -- Skip expected newline

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
        report "Z errors: " & integer'image(sZerrors);

        wait for WAIT_TIME; -- este wait no tiene funcion, pero si no está, pero lo ponemos porque en el waveform de salida no aparece el último time event

        assert false report -- este assert se pone para abortar la simulacion
            "Fin de la simulacion" severity failure;

    end process p_read;

end architecture behavioral;
