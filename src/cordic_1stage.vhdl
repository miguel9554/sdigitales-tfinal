library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_stage is

	generic (
		W			: integer := 10
	);
	port (
		X0, Y0, Z0	:	in signed( W - 1 downto 0);
		sigma0		:	in std_logic;
		X, Y, Z		:	out signed( W - 1 downto 0);
		sigma		:	out std_logic
	);

end entity cordic_stage;

architecture behavioral of cordic_stage is

	-- Adder-substractor declaration
	component addsub is
		generic (
			W		: integer := 10
		);
		port (
			a, b	:	in signed( W - 1 downto 0);
			sigma	:	in std_logic;
			result	:	out signed( W - 1 downto 0)
		);
	end component addsub;

	-- Shifter declaration
	component signed_shifter is
		generic (
			W				:	integer := 10
		);
		port (
			input_vector	:	in signed( W - 1 downto 0);
			shifted_vector	:	out signed( W - 1 downto 0)
		);
	end component signed_shifter;

	-- Buffer signals
	signal Xshifted		:	signed( W - 1 downto 0);
	signal Yshifted		:	signed( W - 1 downto 0);

begin

	-- Shifter for X component
	Xshifter: signed_shifter
		generic map (
			W				=>	W
		)
		port map (
			input_vector	=>	X0,
			shifted_vector 	=>	Xshifted
		);

	-- Shifter for Y component
	Yshifter: signed_shifter
		generic map (
			W				=>	W
		)
		port map (
			input_vector	=>	Y0,
			shifted_vector 	=>	Yshifted
		);

	-- Adder-substractor for X component
	Xaddsub: addsub
		generic map (
			W		=>	W
		)
		port map (
			a		=>	X0,
			b 		=>	Xshifted,
			sigma	=>	sigma,
			result	=>	X
		);

	-- Adder-substractor for Y component
	Yaddsub: addsub
		generic map (
			W		=>	W
		)
		port map (
			a		=>	Y0,
			b 		=>	Yshifted,
			sigma	=>	sigma,
			result	=>	Y
		);

end architecture behavioral;