LIBRARY ieee;
USE ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

entity tb_addsub is
end entity tb_addsub;

architecture behavioral of tb_addsub is

	-- Constants
	constant WIDTH		:	integer						:= 10;
	constant WAIT_TIME	:	time						:= 50 ns;

	-- UUT (unit under test) declaration
	component addsub is
		generic (
			W			:	integer
		);
		port (
			a, b		:	in signed( W - 1 downto 0);
			sigma		:	in std_logic;
			output		:	out signed( W - 1 downto 0)
		);
	end component addsub;

	-- Inputs
	signal a			:	signed( WIDTH - 1 downto 0)	:= ( others => '0');
	signal b			:	signed( WIDTH - 1 downto 0)	:= ( others => '0');
	signal sigma		:	std_logic 					:= '0';

	-- Outputs
	signal actual_output:	signed( WIDTH - 1 downto 0)	:= ( others => '0');

begin

	-- UUT (unit under test) instantiation
	uut: addsub
		generic map (
			W			=>	WIDTH
		)
		port map (
			a			=>	a,
			b 			=>	b,
			sigma		=>	sigma,
			output		=>	actual_output
		);

	p_read : process
		file data_file				: text open read_mode is "verification/tb_addsub/stimulus.txt";
		variable text_line			: line;
		variable ok					: boolean;
		variable c_BUFFER			: character;
		variable sign				: character;
		variable first_operand		: integer;
		variable second_operand		: integer;
		variable expected_output	: integer;
	begin

		while not endfile(data_file) loop 
			
			readline(data_file, text_line);

			read(text_line, sign, ok); -- Read sign
			assert ok
				report "Read 'sign' failed for line: " & text_line.all
				severity failure;

			if (sign = '+') then
				sigma	<=	'1';
			elsif (sign = '-') then
				sigma	<=	'0';
			else
				report "Bad sign for line: " & text_line.all
				severity failure;
			end if;

			read(text_line, c_BUFFER, ok); -- Skip expected space
			assert ok
				report "Read space separator failed for line: " & text_line.all
				severity failure;
			 
			read(text_line, first_operand, ok); -- Read first operand
			assert ok
				report "Read 'first_operand' failed for line: " & text_line.all
				severity failure;
			a		<=	to_signed(first_operand, WIDTH);

			read(text_line, c_BUFFER, ok); -- Skip expected space
			assert ok
				report "Read space separator failed for line: " & text_line.all
				severity failure;

			read(text_line, second_operand, ok); -- Read second operand
			assert ok
				report "Read 'second_operand' failed for line: " & text_line.all
				severity failure;
			b		<=	to_signed(second_operand, WIDTH);

			read(text_line, c_BUFFER, ok); -- Skip expected space
			assert ok
				report "Read space separator failed for line: " & text_line.all
				severity failure;

			read(text_line, expected_output, ok); -- Read expected output
			assert ok
				report "Read 'expected_output' failed for line: " & text_line.all
				severity failure;

			wait for WAIT_TIME;

			assert (expected_output = actual_output) report "ERROR" severity ERROR;

			read(text_line, c_BUFFER, ok); -- Skip expected newline
		end loop;

		write(text_line,string'("                                ")); writeline(output,text_line);
		write(text_line,string'("################################")); writeline(output,text_line);
		write(text_line,string'("#                              #")); writeline(output,text_line);
		write(text_line,string'("#  ++====    ++\ ++    ++=\\   #")); writeline(output,text_line);
		write(text_line,string'("#  ||        ||\\||    ||  \\  #")); writeline(output,text_line);
		write(text_line,string'("#  ++===     ++ \++    ++  ||  #")); writeline(output,text_line);
		write(text_line,string'("#  ||        ||  ||    ||  //  #")); writeline(output,text_line);
		write(text_line,string'("#  ++====    ++  ++    ++=//   #")); writeline(output,text_line);
		write(text_line,string'("#                              #")); writeline(output,text_line);
		write(text_line,string'("################################")); writeline(output,text_line);
		write(text_line,string'("                                ")); writeline(output,text_line);	 

	end process p_read;
	assert false report -- este assert se pone para abortar la simulacion
		"Fin de la simulacion" severity failure;


end architecture behavioral;