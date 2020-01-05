library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity tb_angle_table is
end entity tb_angle_table;

architecture behavioral of tb_angle_table is

	-- Constants
	constant WIDTH		:	integer	:= 16;
	constant WAIT_TIME	:	time	:= 50 ns;

	-- UUT (unit under test) declaration
	component angle_table is
		port (
			step	:	in unsigned( 3 downto 0);
			angle	:	out unsigned( 21 downto 0)
		);
	end component angle_table;

	-- Inputs
	signal sStep			:	unsigned( 3 downto 0)	:= ( others => '0');

	-- Outputs
	signal sExpected_output	:	unsigned( 21 downto 0)	:= ( others => '0');
	signal sActual_output	:	unsigned( 21 downto 0)	:= ( others => '0');

begin

	-- UUT (unit under test) instantiation
	uut: angle_table
		port map (
			step	=>	sStep,
			angle 	=>	sActual_output
		);

	p_read : process
	
		-- Process variables
		file data_file				: text open read_mode is "verification/tb_angle_table/stimulus.dat";
		variable text_line			: line;
		variable ok					: boolean;
		variable c_BUFFER			: character;
		variable fStep				: integer;
		variable fExpected_output	: std_logic_vector( 21 downto 0)	:= ( others => '0');
	
	begin

		while not endfile(data_file) loop
			
			readline(data_file, text_line);
			 
			read(text_line, fStep, ok); -- Read input vector
			assert ok
				report "Read 'step' failed for line: " & text_line.all
				severity failure;
			sStep		<=	to_unsigned(fStep, 4);

			read(text_line, c_BUFFER, ok); -- Skip expected space
			assert ok
				report "Read space separator failed for line: " & text_line.all
				severity failure;

			read(text_line, fExpected_output, ok); -- Read expected output
			assert ok
				report "Read 'expected_output' failed for line: " & text_line.all
				severity failure;
			sExpected_output		<=	unsigned(fExpected_output);

			wait for WAIT_TIME;

			assert (sExpected_output = sActual_output) report "ERROR: expected " & integer'image(to_integer(sExpected_output)) & ", got " & integer'image(to_integer(sActual_output)) severity ERROR;

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

		wait for WAIT_TIME;

		assert false report -- este assert se pone para abortar la simulacion
			"Fin de la simulacion" severity failure;

	end process p_read;

end architecture behavioral;
