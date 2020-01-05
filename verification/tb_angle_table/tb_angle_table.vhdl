library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity tb_angle_table is
end entity tb_angle_table;

architecture behavioral of tb_angle_table is

	-- Constants
	constant ADDR_WIDTH:	integer	:= 4;
	constant DATA_WIDTH:	integer	:= 22;
	constant WAIT_TIME	:	time	:= 50 ns;

	-- UUT (unit under test) declaration
	component angle_table is
		generic (
			ADDR_WIDTH	:	integer;
			DATA_WIDTH	:	integer
		);
		port (
			step		:	in unsigned(ADDR_WIDTH-1 downto 0);
			angle		:	out unsigned(DATA_WIDTH-1 downto 0)
		);
	end component angle_table;

	-- Inputs
	signal sStep			:	unsigned( ADDR_WIDTH-1 downto 0)	:= ( others => '0');

	-- Outputs
	signal sExpected_output	:	unsigned( DATA_WIDTH-1 downto 0)	:= ( others => '0');
	signal sActual_output	:	unsigned( DATA_WIDTH-1 downto 0)	:= ( others => '0');

begin

	-- UUT (unit under test) instantiation
	uut: angle_table
		generic map (
			ADDR_WIDTH	=>	ADDR_WIDTH,
			DATA_WIDTH	=>	DATA_WIDTH
		)
		port map (
			step		=>	sStep,
			angle 		=>	sActual_output
		);

	p_read : process
	
		-- Process variables
		file data_file				: text open read_mode is "verification/tb_angle_table/stimulus.dat";
		variable text_line			: line;
		variable ok					: boolean;
		variable c_BUFFER			: character;
		variable fStep				: integer;
		variable fExpected_output	: std_logic_vector( DATA_WIDTH-1 downto 0)	:= ( others => '0');
	
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
