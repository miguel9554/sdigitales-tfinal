library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity sram_controller_simple_test is
   generic(
		constant DATA_WIDTH      : natural := 16;
		constant ADDRESS_WIDTH   : natural := 23
	);
	port(      
		clk: in std_logic;
		-- inputs
      sw: in std_logic_vector(7 downto 0);
		btn: in std_logic_vector(2 downto 0);
      -- outputs
		an: out std_logic_vector(3 downto 0);
      sseg: out std_logic_vector(7 downto 0);
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
		MemDB: inout std_logic_vector(DATA_WIDTH-1 downto 0)
   );
end sram_controller_simple_test;

architecture arch of sram_controller_simple_test is
   
	constant CYCLES_TO_WAIT  : natural := 5;
	constant CYCLES_TO_WAIT_WIDTH : natural := 3;
	
	signal data_reg: std_logic_vector(7 downto 0);
   signal db_btn: std_logic_vector(2 downto 0);
	
	signal led3, led2, led1, led0: std_logic_vector(7 downto 0);
	
	signal reset: std_logic := '0';
	signal mem: std_logic := '0';
	signal rw: std_logic := '1';
	signal address_in: std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => '0');
	signal data_in: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	signal ready: std_logic;
	signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);
	
	
begin
   -- instantiate ram
	sram: entity work.sram_controller
	port map (
		clk => clk,
		reset => reset,
		-- to/from main system
		mem => mem,
		rw => rw,
		address_in => address_in,
		data_in => data_in,
		ready => ready,
		data_out => data_out,
		-- to/from SRAM
		address_to_sram => MemAdr,
		data_to_sram => MemDB,
		clk_out => RamClk,
		adv => RamAdv,
		ce => RamCS,
		oe => MemOE,
		we => MemWR,
		cre => RamCRE,
		lb => RamLB,
		ub => RamUB
	);

   -- instantiate four instances of hex decoders
   -- instance for 4 LSBs of input
   sseg_unit_0: entity work.hex_to_sseg
      port map(hex=>data_out(3 downto 0), dp =>'1', sseg=>led0);
   -- instance for 4 MSBs of input
   sseg_unit_1: entity work.hex_to_sseg
      port map(hex=>data_out(7 downto 4), dp =>'1', sseg=>led1);
   -- instance for 4 LSBs of incremented value
   sseg_unit_2: entity work.hex_to_sseg
      port map(hex=>data_out(11 downto 8), dp =>'1', sseg=>led2);
   -- instance for 4 MSBs of incremented value
   sseg_unit_3: entity work.hex_to_sseg
      port map(hex=>data_out(15 downto 12), dp =>'1', sseg=>led3);

   -- instantiate 7-seg LED display time-multiplexing module
   disp_unit: entity work.disp_mux
      port map(
         clk=>clk, reset=>'0',
         in0=>led0, in1=>led1, in2=>led2, in3=>led3,
         an=>an, sseg=>sseg);
			
	debounce_unit0: entity work.debounce
		port map(
			clk=>clk, reset=>reset, sw=>btn(0),
			db_level=>open, db_tick=>db_btn(0)
		);
    debounce_unit1: entity work.debounce
       port map(
          clk=>clk, reset=>reset, sw=>btn(1),
          db_level=>open, db_tick=>db_btn(1));
    debounce_unit2: entity work.debounce
       port map(
          clk=>clk, reset=>reset, sw=>btn(2),
          db_level=>open, db_tick=>db_btn(2));

   --data registers
   process(clk)
   begin
      if (clk'event and clk='1') then
         if (db_btn(0)='1') then
            data_reg <= sw;
         end if;
     end if;
   end process;
   -- address
   address_in <= "0000000000" & sw;
   --
   process(db_btn,data_reg)
   begin
     data_in <= (others=>'0');
     if db_btn(1)='1' then -- write
        mem <= '1';
        rw <= '0';
        data_in <= "00000000" & data_reg;
     elsif db_btn(2)='1' then -- read
        mem <= '1';
        rw <= '1';
     else
        mem <= '0';
        rw <= '1';
      end if;
   end process;
end arch;