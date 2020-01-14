library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity tb_addsub is
end entity tb_addsub;

architecture behavioral of tb_addsub is

    -- Constants
    constant WIDTH      :   integer := 10;
    constant WAIT_TIME  :   time    := 50 ns;

    -- UUT (unit under test) declaration
    component addsub is
        generic (
            W       :   integer
        );
        port (
            a, b    :   in signed( W - 1 downto 0);
            sigma   :   in std_logic;
            result  :   out signed( W - 1 downto 0)
        );
    end component addsub;

    -- Inputs
    signal sFirst_operand   :   signed( WIDTH - 1 downto 0) := ( others => '0');
    signal sSecond_operand  :   signed( WIDTH - 1 downto 0) := ( others => '0');
    signal sSigma           :   std_logic                   := '0';

    -- Outputs
    signal sExpected_output :   signed( WIDTH - 1 downto 0) := ( others => '0');
    signal sActual_output   :   signed( WIDTH - 1 downto 0) := ( others => '0');

    -- Reporting metrics
    signal stotalReads  :   integer := 0;
    signal sErrors      :   integer := 0;    

begin

    -- UUT (unit under test) instantiation
    uut: addsub
        generic map (
            W       =>  WIDTH
        )
        port map (
            a       =>  sFirst_operand,
            b       =>  sSecond_operand,
            sigma   =>  sSigma,
            result  =>  sActual_output
        );

    p_read : process
    
        -- Process variables
        file data_file              : text open read_mode is "verification/tb_addsub/stimulus.dat";
        variable text_line          : line;
        variable ok                 : boolean;
        variable c_BUFFER           : character;
        variable fSign              : character;
        variable fFirst_operand     : integer;
        variable fSecond_operand    : integer;
        variable fExpected_output   : integer;
    
    begin

        while not endfile(data_file) loop
            
            readline(data_file, text_line);

            -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;

            report "Reading line: " & text_line.all;
            stotalReads <=  stotalReads + 1;

            read(text_line, fSign, ok); -- Read sign
            assert ok
                report "Read 'sign' failed for line: " & text_line.all
                severity failure;

            if (fSign = '+') then
                sSigma  <=  '1';
            elsif (fSign = '-') then
                sSigma  <=  '0';
            else
                report "Bad sign for line: " & text_line.all
                severity failure;
            end if;

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;
             
            read(text_line, fFirst_operand, ok); -- Read first operand
            assert ok
                report "Read 'first_operand' failed for line: " & text_line.all
                severity failure;
            sFirst_operand      <=  to_signed(fFirst_operand, WIDTH);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fSecond_operand, ok); -- Read second operand
            assert ok
                report "Read 'second_operand' failed for line: " & text_line.all
                severity failure;
            sSecond_operand     <=  to_signed(fSecond_operand, WIDTH);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fExpected_output, ok); -- Read expected output
            assert ok
                report "Read 'expected_output' failed for line: " & text_line.all
                severity failure;
            sExpected_output        <=  to_signed(fExpected_output, WIDTH);

            wait for WAIT_TIME;

            assert (sExpected_output = sActual_output) report "ERROR: expected " & integer'image(to_integer(sExpected_output)) & ", got " & integer'image(to_integer(sActual_output)) severity ERROR;

            if (sExpected_output /= sActual_output) then
                sErrors    <=  sErrors + 1;
            end if;

        end loop;

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
        report "Errors: " & integer'image(sErrors);

        wait for WAIT_TIME;

        assert false report -- este assert se pone para abortar la simulacion
            "Fin de la simulacion" severity failure;

    end process p_read;

end architecture behavioral;
