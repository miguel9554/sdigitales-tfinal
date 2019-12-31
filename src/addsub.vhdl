library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub is
	generic (
		W: integer := 10
	);
	port (
		a, b:	in signed( W - 1 downto 0);
		sigma:	in std_logic;
		output:	out signed( W - 1 downto 0)
	);
end entity addsub;

architecture behavioral of addsub is
begin

	output	<=	a + b when (sigma = '1') else
			a - b;

end architecture behavioral;