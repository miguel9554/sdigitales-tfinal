library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main_inst is
    generic(
        constant DATA_WIDTH      : natural := 16;
        constant ADDRESS_WIDTH   : natural := 23;
        constant CYCLES_TO_WAIT  : natural := 4000;
        constant DVSR: integer:= 14;  -- baud rate divisor
                            -- DVSR = 25M/(16*baud rate) (está dividido el clock)
        constant DVSR_BIT: integer:=5; -- # bits of DVSR
        constant COORDS_WIDTH: integer := 32;
        constant ANGLE_WIDTH: integer := 10;
        -- ancho del cuadrado donde mostramos el mundo
        constant SQUARE_WIDTH_IN_BITS: integer := 9;
        constant LINES_TO_RECEIVE: natural := 11946;
        constant STAGES: integer := 8;
        constant CYCLES_TO_WAIT_CORDIC: natural := 20
    );
    port(
        clk: in std_logic;
        clk_vga: in std_logic;
        -- uart
        RsRx: in std_logic;
        RsTx: out std_logic;
        -- inputs
        sw: in std_logic_vector(7 downto 0);
        btn: in std_logic_vector(3 downto 0);
        -- outputs
        an: out std_logic_vector(3 downto 0);
        sseg: out std_logic_vector(7 downto 0);
        Led: out std_logic_vector(7 downto 0);
        -- to SRAM
        MemOE: out std_logic;
        MemWR: out std_logic;
        RamAdv: out std_logic;
        RamCS: out std_logic;
        RamClk: out std_logic;
        RamCRE: out std_logic;
        RamLB: out std_logic;
        RamUB: out std_logic;
        MemAdr: out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        MemDB: inout std_logic_vector(DATA_WIDTH-1 downto 0);
        -- VGA
        Hsync, Vsync: out  std_logic;
        vgaRed: out std_logic_vector(2 downto 0);
        vgaGreen: out std_logic_vector(2 downto 0);
        vgaBlue: out std_logic_vector(1 downto 0)
    );
end main_inst;

architecture arch of main_inst is
    
    COMPONENT dcm
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKDV_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
    END COMPONENT;
    
    signal clk_divided: std_logic;
    signal clk0: std_logic;

begin

    Inst_dcm: dcm PORT MAP(
		CLKIN_IN => clk,
		RST_IN => '0',
		CLKDV_OUT => clk_divided,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => clk0,
		LOCKED_OUT => open
	);
   
    -- instantiate main
    main_module: entity work.main
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        CYCLES_TO_WAIT => CYCLES_TO_WAIT,
        DVSR => DVSR,
        DVSR_BIT => DVSR_BIT,
        COORDS_WIDTH => COORDS_WIDTH,
        ANGLE_WIDTH => ANGLE_WIDTH,
        SQUARE_WIDTH_IN_BITS => SQUARE_WIDTH_IN_BITS,
        LINES_TO_RECEIVE => LINES_TO_RECEIVE,
        STAGES => STAGES,
        CYCLES_TO_WAIT_CORDIC => CYCLES_TO_WAIT_CORDIC
    )
    port map(
        clk => clk_divided,
        clk_vga => clk0,
        RsRx => RsRx,
        RsTx => RsTx,
        sw => sw,
        btn => btn,
        an => an,
        sseg => sseg,
        Led => Led,
        MemOE => MemOE,
        MemWR => MemWR,
        RamAdv => RamAdv,
        RamCS => RamCS,
        RamClk => RamClk,
        RamCRE => RamCRE,
        RamLB => RamLB,
        RamUB => RamUB,
        MemAdr => MemAdr,
        MemDB => MemDB,
        Hsync => Hsync,
        Vsync => Vsync,
        vgaRed => vgaRed,
        vgaGreen => vgaGreen,
        vgaBlue => vgaBlue
    );

end arch;