library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity tb_signed_shifter is
end entity tb_signed_shifter;

architecture behavioral of tb_signed_shifter is

    -- Constants
    constant WIDTH              :   integer := 10;
    constant POSITIONS_WIDTH    :   integer := 4;
    constant WAIT_TIME          :   time    := 50 ns;

    -- UUT (unit under test) declaration
    component signed_shifter is
        generic (
            W               :   integer;
            POSITIONS_W     :   integer
        );
        port (
            input_vector    :   in signed( W - 1 downto 0 );
            shift_positions :   in unsigned( POSITIONS_W - 1 downto 0 );
            shifted_vector  :   out signed( W - 1 downto 0 )
        );
    end component signed_shifter;

    -- Inputs
    signal sInput_vector    :   signed( WIDTH - 1 downto 0)             := ( others => '0');
    signal sShift_positions :   unsigned( POSITIONS_WIDTH - 1 downto 0) := ( others => '0');

    -- Outputs
    signal sExpected_output :   signed( WIDTH - 1 downto 0) := ( others => '0');
    signal sActual_output   :   signed( WIDTH - 1 downto 0) := ( others => '0');

    -- Error counting
    signal sError_count     :   integer := 0;

begin

    -- UUT (unit under test) instantiation
    uut: signed_shifter
        generic map (
            W               =>  WIDTH,
            POSITIONS_W     =>  POSITIONS_WIDTH
        )
        port map (
            input_vector    =>  sInput_vector,
            shift_positions =>  sShift_positions,
            shifted_vector  =>  sActual_output
        );

    p_read : process
    
        -- Process variables
        file data_file              :   text open read_mode is "verification/tb_signed_shifter/stimulus.dat";
        variable text_line          :   line;
        variable ok                 :   boolean;
        variable c_BUFFER           :   character;
        variable fInput_vector      :   integer;
        variable fShift_positions   :   integer;
        variable fExpected_output   :   integer;
    
    begin

        while not endfile(data_file) loop
            
            readline(data_file, text_line);

              -- Skip empty lines and single-line comments
            if text_line.all'length = 0 or text_line.all(1) = '#' then
                next;
            end if;

            report "Reading line: " & text_line.all;            
             
            read(text_line, fInput_vector, ok); -- Read input vector
            assert ok
                report "Read 'input_vector' failed for line: " & text_line.all
                severity failure;
            sInput_vector       <=  to_signed(fInput_vector, sInput_vector'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;

            read(text_line, fShift_positions, ok); -- Read number of shifts
            assert ok
                report "Read 'input_vector' failed for line: " & text_line.all
                severity failure;
            sShift_positions    <=  to_unsigned(fShift_positions, sShift_positions'length);

            read(text_line, c_BUFFER, ok); -- Skip expected space
            assert ok
                report "Read space separator failed for line: " & text_line.all
                severity failure;               

            read(text_line, fExpected_output, ok); -- Read expected output
            assert ok
                report "Read 'expected_output' failed for line: " & text_line.all
                severity failure;
            sExpected_output        <=  to_signed(fExpected_output, sExpected_output'length);

            wait for WAIT_TIME;

            assert (sExpected_output = sActual_output) report "ERROR: expected " & integer'image(to_integer(sExpected_output)) & ", got " & integer'image(to_integer(sActual_output)) severity ERROR;
            if (sExpected_output /= sActual_output) then
                sError_count    <=  sError_count + 1;
            end if;

            read(text_line, c_BUFFER, ok); -- Skip expected newline

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

        report "Total errors: " & integer'image(sError_count);

        wait for WAIT_TIME;

        assert false report -- este assert se pone para abortar la simulacion
            "Fin de la simulacion" severity failure;

    end process p_read;

end architecture behavioral;
