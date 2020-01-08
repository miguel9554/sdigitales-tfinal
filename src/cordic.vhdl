library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic is

	generic (
		COORDS_WIDTH			: integer := 10;
		ANGLES_INTEGER_WIDTH	: integer := 6;
		ANGLES_FRACTIONAL_WIDTH	: integer := 16;
		STAGES					: integer := 16
	);
	port (
		X0, Y0			:	in signed(COORDS_WIDTH-1 downto 0);
		angle			:	in signed(ANGLES_FRACTIONAL_WIDTH+ANGLES_INTEGER_WIDTH downto 0);
		X, Y			:	out signed(COORDS_WIDTH-1 downto 0)
	);

end entity cordic;

architecture behavioral of cordic is

	-- Constants
	constant STEP_WIDTH 	: 	integer := 4;
	constant ANGLES_WIDTH 	:	integer := ANGLES_INTEGER_WIDTH+ANGLES_FRACTIONAL_WIDTH+1; 

	-- Types
	type rom_type is array (0 to STAGES-1) of signed(ANGLES_WIDTH-1 downto 0);
	type coordinates_array is array (0 to STAGES-1) of signed(COORDS_WIDTH-1 downto 0);
	type angles_array is array (0 to STAGES-1) of signed(ANGLES_WIDTH-1 downto 0);
	type signs_array is array (0 to STAGES-1) of std_logic;

	-- Adder-substractor declaration
	component addsub is
		generic (
			W		: integer
		);
		port (
			a, b	:	in signed( W - 1 downto 0);
			sigma	:	in std_logic;
			result	:	out signed( W - 1 downto 0)
		);
	end component addsub;

	-- Cordic stage declaration
	component cordic_stage is
		generic (
			W			: integer;
			ANGLE_W		: integer;
			STEP_W      : integer
		);
		port (
			X0, Y0		:	in signed( W - 1 downto 0);
			Z0			:	in signed( ANGLE_W downto 0);
			sigma0		:	in std_logic;
			atan		:	in signed( ANGLE_W downto 0);
			step		:	in unsigned( STEP_W - 1 downto 0);
			X, Y		:	out signed( W - 1 downto 0);
			Z			:	out signed( ANGLE_W downto 0);
			sigma		:	out std_logic
		);
	end component cordic_stage;

	-- Angles "ROM"
	constant STEP2ANGLE_ROM: rom_type := (
		"01011010000000000000000",	-- 45°
		"00110101001000010100111",	-- 26.565051177078°
		"00011100000100101000111",	-- 14.0362434679265°
		"00001110010000000000001",	-- 7.1250163489018°
		"00000111001001110001010",	-- 3.57633437499735°
		"00000011100101000110111",	-- 1.78991060824607°
		"00000001110010100101010",	-- 0.895173710211074°
		"00000000111001010010110",	-- 0.447614170860553°
		"00000000011100101001011",	-- 0.223810500368538°
		"00000000001110010100101",	-- 0.111905677066207°
		"00000000000111001010010",	-- 0.055952891893804°
		"00000000000011100101001",	-- 0.027976452617004°
		"00000000000001110010100",	-- 0.013988227142265°
		"00000000000000111001010",	-- 0.006994113675353°
		"00000000000000011100101",	-- 0.003497056850704°
		"00000000000000001110010"	-- 0.00174852842698°
	);

	-- Buffer signals
	signal sX_array		:	coordinates_array	:= (others => to_signed(0,COORDS_WIDTH));
	signal sY_array		:	coordinates_array	:= (others => to_signed(0,COORDS_WIDTH));
	signal sZ_array		:	angles_array		:= (others => to_signed(0,ANGLES_WIDTH));
	signal sSigma_array	:	signs_array			:= (others => '0');

begin

	-- Adder-substractor for first stage X component
	Xaddsub: addsub
		generic map (
			W		=>	COORDS_WIDTH
		)
		port map (
			a		=>	X0,
			b 		=>	Y0,
			sigma	=>	'0',
			result	=>	sX_array(0)
		);

	-- Adder-substractor for first stage Y component
	Yaddsub: addsub
		generic map (
			W		=>	COORDS_WIDTH
		)
		port map (
			a		=>	Y0,
			b 		=>	X0,
			sigma	=>	'1',
			result	=>	sY_array(0)
		);

	-- Adder-substractor for first stage Z component
	Zaddsub: addsub
		generic map (
			W		=>	ANGLES_WIDTH
		)
		port map (
			a 		=>	angle,
			b		=>	STEP2ANGLE_ROM(0),
			sigma	=>	'0',
			result	=>	sZ_array(0)
		);

	sSigma_array(0)	<=	not sZ_array(0)(ANGLES_WIDTH-1);

	stages_instantiation: for i in 1 to STAGES-1 generate

		current_cordic_stage: cordic_stage
			generic map (
				W			=>	COORDS_WIDTH,
				ANGLE_W		=>	ANGLES_WIDTH-1,
				STEP_W		=>	STEP_WIDTH
			)
			port map (
				X0			=>	sX_array(i-1),
				Y0			=>	sY_array(i-1),
				Z0			=>	sZ_array(i-1),
				sigma0 		=>	sSigma_array(i-1),
				atan		=>	STEP2ANGLE_ROM(i),
				step		=>	to_unsigned(i, STEP_WIDTH),
				X			=>	sX_array(i),
				Y			=>	sY_array(i),
				Z			=>	sZ_array(i),
				sigma 		=>	sSigma_array(i)
			);
		
	end generate stages_instantiation;

	X	<=	sX_array(STAGES-1);
	Y	<=	sY_array(STAGES-1);

end architecture behavioral;