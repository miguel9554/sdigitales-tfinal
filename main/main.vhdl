library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    generic(
        constant DATA_WIDTH      : natural := 16;
        constant ADDRESS_WIDTH   : natural := 23;
        constant CYCLES_TO_WAIT  : natural := 4000;
        constant DVSR: integer:= 27;  -- baud rate divisor
                            -- DVSR = 50M/(16*baud rate)
        constant DVSR_BIT: integer:=5; -- # bits of DVSR
        constant COORDS_WIDTH: integer := 32;
        constant ANGLE_WIDTH: integer := 8;
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
end main;

architecture arch of main is

    constant BYTES_TO_RECEIVE: natural := 12*LINES_TO_RECEIVE;
    
    signal data_reg: std_logic_vector(7 downto 0);
    signal db_btn: std_logic_vector(3 downto 0);

    signal reset: std_logic := '1';
    signal data_from_switch: std_logic_vector(7 downto 0) := (others => '0');

    -- vga sync
    signal video_on: std_logic;
    signal pixel_tick: std_logic;
    signal pixel_x, pixel_y: std_logic_vector(9 downto 0);

    signal bitmap_on: std_logic := '0';
    signal pix_x, pix_y: unsigned(9 downto 0);

    -- seven segment
    signal led3, led2, led1, led0: std_logic_vector(7 downto 0);
    signal hex_data_current, hex_data_next: std_logic_vector(15 downto 0);

    -- ram
    signal data_in: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal address_in: std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => '0');
    signal ready: std_logic;
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);

    -- video ram
    signal video_ram_data_in: std_logic_vector(0 downto 0) := (others => '1');
    signal video_ram_data_out: std_logic_vector(0 downto 0);
    signal video_ram_read_address: std_logic_vector(SQUARE_WIDTH_IN_BITS*2-1 downto 0) := (others => '0');
    signal video_ram_write_address: std_logic_vector(SQUARE_WIDTH_IN_BITS*2-1 downto 0) := (others => '0');

    -- uart
    signal tx_full, rx_empty: std_logic := '0';
    signal r_data: std_logic_vector(7 downto 0);

    -- state machine
    type state_t is (initial_state, read_from_sram, waiting_for_uart,
    reading_from_uart, write_sram, waiting_for_sram, uart_end_data_reception,
    waiting_for_sram_data, idle, process_coords, print_coords, read_with_switch);
    signal state_current, state_next : state_t := initial_state;
    signal address_current, address_next: natural := 0;
    signal mem_current, mem_next: std_logic := '0';
    signal rw_current, rw_next: std_logic := '0';
    signal data_in_current, data_in_next: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal rd_uart_current, rd_uart_next: std_logic := '0';
    signal cycles_current, cycles_next: natural := CYCLES_TO_WAIT;
    signal bytes_received_current, bytes_received_next: natural := 0;
    signal leds_current, leds_next: std_logic_vector(7 downto 0) := (others => '0');
    -- Esta variable representa cuantas coordenadas leímos de la SRAM
    signal coords_readed_current, coords_readed_next: natural := 0;
    -- Esta variable representa en que byte estamos de la coordenada, sirve para decodificar si estamos en X, Y o Z
    signal byte_position_current, byte_position_next: natural := 0;
    -- Las coordenadas
    signal X_coord_current, X_coord_next: std_logic_vector(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal Y_coord_current, Y_coord_next: std_logic_vector(COORDS_WIDTH-1 downto 0) := (others => '0');
    signal Z_coord_current, Z_coord_next: std_logic_vector(COORDS_WIDTH-1 downto 0) := (others => '0');
    -- Coordenadas rotadas
    signal X_coord_rotated: signed(COORDS_WIDTH-1 downto 0);
    signal Y_coord_rotated: signed(COORDS_WIDTH-1 downto 0);
    signal Z_coord_rotated: signed(COORDS_WIDTH-1 downto 0);
    -- Coordenadas rotadas y con offset
    signal X_coord_rotated_offset: std_logic_vector(SQUARE_WIDTH_IN_BITS-1 downto 0);
    signal Y_coord_rotated_offset: std_logic_vector(SQUARE_WIDTH_IN_BITS-1 downto 0);
    signal Z_coord_rotated_offset: std_logic_vector(SQUARE_WIDTH_IN_BITS-1 downto 0);
    -- video ram
    signal video_ram_we_current, video_ram_we_next: std_logic := '0';
    signal pixel_current, pixel_next: std_logic_vector(0 downto 0) := (others => '0');


begin
         
    -- state & data registers
    process(clk)
    begin
    if (clk'event and clk='1') then
        state_current <= state_next;
        address_current <= address_next;
        mem_current <= mem_next;
        rw_current <= rw_next;
        data_in_current <= data_in_next;
        rd_uart_current <= rd_uart_next;
        cycles_current <= cycles_next;
        bytes_received_current <= bytes_received_next;
        leds_current <= leds_next;
        coords_readed_current <= coords_readed_next;
        byte_position_current <= byte_position_next;
        X_coord_current <= X_coord_next;
        Y_coord_current <= Y_coord_next;
        Z_coord_current <= Z_coord_next;
        video_ram_we_current <= video_ram_we_next;
        hex_data_current <= hex_data_next;
        if (db_btn(0)='1') then
            data_from_switch <= sw;
        end if;
        if (pixel_tick='1') then
            pixel_current <= pixel_next;
        end if;
    end if;
    end process;

    -- next state logic
    process(rx_empty, r_data, address_current, state_current, rw_current,
    data_in_current, address_current, db_btn, cycles_current, reset, data_from_switch,
    bytes_received_current, leds_current, byte_position_current, coords_readed_current,
    X_coord_current, Y_coord_current, Z_coord_current, video_ram_we_current, ready,
    mem_current, hex_data_current, data_out)
    begin
        -- default values
        mem_next <= '0';
        rd_uart_next <= '0';
        rw_next <= rw_current;
        data_in_next <= data_in_current;
        address_next <= address_current;
        cycles_next <= cycles_current;
        bytes_received_next <= bytes_received_current;
        leds_next <= leds_current;
        coords_readed_next <= coords_readed_current;
        byte_position_next <= byte_position_current;
        X_coord_next <= X_coord_current;
        Y_coord_next <= Y_coord_current;
        Z_coord_next <= Z_coord_current;
        video_ram_we_next <= '0';
        hex_data_next <= hex_data_current;
        case state_current is
            when initial_state =>
                if cycles_current = 0 then
                    reset <= '0';
                    state_next <= waiting_for_uart;
                else
                    cycles_next <= cycles_current - 1;
                    state_next <= initial_state;
                end if;
            when waiting_for_uart =>
                if rx_empty = '0' then
                    rd_uart_next <= '1';
                    state_next <= reading_from_uart;
                elsif bytes_received_current = BYTES_TO_RECEIVE then
                    state_next <= uart_end_data_reception;
                else
                    state_next <= waiting_for_uart;
                end if;
            when reading_from_uart =>
                if (bytes_received_next mod 2) /= 0 then
                    data_in_next <= r_data & "00000000";
                    state_next <= waiting_for_uart;
                else
                    data_in_next <= data_in_current(DATA_WIDTH-1 downto DATA_WIDTH/2) & r_data;
                    state_next <= write_sram;
                end if;
                bytes_received_next <= bytes_received_current + 1;
            when write_sram =>
                mem_next <= '1';
                rw_next <= '0';
                state_next <= waiting_for_sram;
            when waiting_for_sram =>
                if ready = '1' then
                    address_next <= address_current + 1;
                    rw_next <= '0';
                    state_next <= waiting_for_uart;
                else
                    state_next <= waiting_for_sram;
                end if;
            when uart_end_data_reception =>
                state_next <= read_from_sram;
                leds_next <= (others => '1');
                address_next <= 0;
            when read_from_sram =>
                if coords_readed_current = LINES_TO_RECEIVE then
                    state_next <= idle;
                else
                    mem_next <= '1';
                    rw_next <= '1';
                    state_next <= waiting_for_sram_data;
                end if;
            when waiting_for_sram_data =>
                if mem_current = '1' then
                    -- así evitamos el glitch de ready en el primer ciclo de lectura
                    state_next <= waiting_for_sram_data;
                elsif ready = '1' then
                    -- asignamos el valor a la coordenada correspondiente
                    case byte_position_current is
                        when 0 =>
                            X_coord_next <= data_out & "0000000000000000";
                            byte_position_next <= byte_position_current + 1;
                            address_next <= address_current + 1;
                            state_next <= read_from_sram;
                        when 1 =>
                            X_coord_next <= X_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH/2) & data_out;
                            byte_position_next <= byte_position_current + 1;
                            address_next <= address_current + 1;
                            state_next <= read_from_sram;
                        when 2 =>
                            Y_coord_next <= data_out & "0000000000000000";
                            byte_position_next <= byte_position_current + 1;
                            address_next <= address_current + 1;
                            state_next <= read_from_sram;
                        when 3 =>
                            Y_coord_next <= Y_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH/2) & data_out;
                            byte_position_next <= byte_position_current + 1;
                            address_next <= address_current + 1;
                            state_next <= read_from_sram;
                        when 4 =>
                            Z_coord_next <= data_out & "0000000000000000";
                            byte_position_next <= byte_position_current + 1;
                            address_next <= address_current + 1;
                            state_next <= read_from_sram;
                        when 5 =>
                            Z_coord_next <= Z_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH/2) & data_out;
                            byte_position_next <= 0;
                            coords_readed_next <= coords_readed_current + 1;
                            address_next <= address_current + 1;
                            state_next <= process_coords;
                            cycles_next <= CYCLES_TO_WAIT_CORDIC;
                        when others =>
                            hex_data_next <= (others => '1');
                            byte_position_next <= 0;
                            state_next <= idle;
                    end case;
                else
                    state_next <= waiting_for_sram_data;
                end if;
            when process_coords =>
                if cycles_current = 0 then
                    state_next <= print_coords;
                else
                    cycles_next <= cycles_current - 1;
                    state_next <= process_coords;
                end if;
            when print_coords =>
                -- ya estan las coordenadas a escribir cargadas, escribo
                video_ram_we_next <= '1';
                state_next <= read_from_sram;
            when idle =>
                hex_data_next <= "0101" & "0101" & "0101" & "0101";
                state_next <= read_with_switch;
            when read_with_switch =>
                hex_data_next <= data_out;
                address_next <= to_integer(unsigned("0000000000000000" & sw));
                if db_btn(1)='1' then -- write
                    mem_next <= '1';
                    rw_next <= '0';
                    data_in_next <= "00000000" & data_from_switch;
                    state_next <= read_with_switch;
                elsif db_btn(2)='1' then -- read
                    mem_next <= '1';
                    rw_next <= '1';
                    state_next <= read_with_switch;
                elsif db_btn(3)='1' then
                    mem_next <= '0';
                    rw_next <= '1';
                    state_next <= waiting_for_uart;
                else
                    mem_next <= '0';
                    rw_next <= '1';
                    state_next <= read_with_switch;
                end if;
        end case;
    end process;

    -- instantiate uart
    uart_unit: entity work.uart(str_arch)
    generic map(DVSR=>DVSR, DVSR_BIT=>DVSR_BIT)
    port map(
        clk =>  clk, reset =>  reset, rd_uart =>  rd_uart_current,
        wr_uart =>  rd_uart_current, rx =>  RsRx, w_data =>  r_data,
        tx_full => tx_full, rx_empty =>  rx_empty,
        r_data =>  r_data, tx =>  RsTx
    );

    -- instantiate ram controller
	sram: entity work.sram_controller
	port map (
		clk => clk,
		reset => reset,
		-- to/from main system
        mem => mem_current, rw => rw_current, address_in => address_in,
        data_in => data_in_current, ready => ready, data_out => data_out,
		-- to/from SRAM
		address_to_sram => MemAdr, data_to_sram => MemDB, clk_out => RamClk, adv => RamAdv,
		ce => RamCS, oe => MemOE, we => MemWR, cre => RamCRE, lb => RamLB, ub => RamUB
	);

    address_in <= std_logic_vector(to_unsigned(address_current, ADDRESS_WIDTH));

    -- instantiate four instances of hex decoders
    sseg_unit_0: entity work.hex_to_sseg
        port map(hex=>hex_data_current(3 downto 0), dp =>'1', sseg=>led0);
    sseg_unit_1: entity work.hex_to_sseg
        port map(hex=>hex_data_current(7 downto 4), dp =>'1', sseg=>led1);
    sseg_unit_2: entity work.hex_to_sseg
        port map(hex=>hex_data_current(11 downto 8), dp =>'1', sseg=>led2);
    sseg_unit_3: entity work.hex_to_sseg
        port map(hex=>hex_data_current(15 downto 12), dp =>'1', sseg=>led3);

    -- instantiate 7-seg LED display time-multiplexing module
    disp_unit: entity work.disp_mux
        port map(
            clk=>clk, reset=>'0',
            in0=>led0, in1=>led1, in2=>led2, in3=>led3,
            an=>an, sseg=>sseg);

    -- instantiate 4 debouncers
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
    debounce_unit3: entity work.debounce
        port map(
            clk=>clk, reset=>reset, sw=>btn(3),
            db_level=>open, db_tick=>db_btn(3));

    vga_sync_unit: entity work.vga_sync
        port map(
            clk=>clk_vga, reset=>reset,
            hsync=>Hsync, vsync=>Vsync,
            video_on=>video_on, p_tick=>pixel_tick,
            pixel_x=>pixel_x, pixel_y=>pixel_y);

    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);            

    -- defino donde es mi bitmap, donde voy a dibujar el mundo
    bitmap_on <= '1' when (pix_x <= 2**SQUARE_WIDTH_IN_BITS) and (pix_y <= 2**SQUARE_WIDTH_IN_BITS) else '0';
    -- dirección de lectura de la ram de video
    video_ram_read_address <= std_logic_vector(pix_y(SQUARE_WIDTH_IN_BITS-1 downto 0) & pix_x(SQUARE_WIDTH_IN_BITS-1 downto 0));

   -- rgb multiplexing circuit
   process(video_on, bitmap_on, video_ram_data_out)
   begin
      if video_on = '0' then
          pixel_next <= (others => '0');
      else
         if bitmap_on = '1' then
            pixel_next <= video_ram_data_out;
         else
            pixel_next <= (others => '0'); -- black background
         end if;
      end if;
   end process;

    vgaRed <= (pixel_current & pixel_current & pixel_current) when video_on='1' else "000";
    vgaGreen <= (pixel_current & pixel_current & pixel_current) when video_on='1' else "000";
    vgaBlue <= (pixel_current & pixel_current) when video_on='1' else "00";   

   -- instantiate dual port video RAM
    video_ram: entity work.xilinx_dual_port_ram_sync
        generic map(ADDR_WIDTH=>SQUARE_WIDTH_IN_BITS*2, DATA_WIDTH=>1)
        port map(
            clk=>clk, we=>video_ram_we_current,
            addr_a=>video_ram_write_address, addr_b=>video_ram_read_address,
            din_a=>video_ram_data_in, dout_a=>open, dout_b=>video_ram_data_out);

    video_ram_write_address <= Z_coord_rotated_offset & Y_coord_rotated_offset;

    -- leds
    Led <= leds_current;

   -- instantiate rotator
    cordic_rotator: entity work.rotator
    generic map(
        COORDS_WIDTH=>COORDS_WIDTH,
        ANGLES_INTEGER_WIDTH=>ANGLE_WIDTH,
        STAGES=>STAGES
    )
    port map(
        clk=>clk, X0=>signed(X_coord_current), Y0=>signed(Y_coord_current), Z0=>signed(Z_coord_current),
        angle_X=>to_signed(0, ANGLE_WIDTH), angle_Y=>to_signed(0, ANGLE_WIDTH), angle_Z=>to_signed(0, ANGLE_WIDTH),
        X=>X_coord_rotated, Y=>Y_coord_rotated, Z=>Z_coord_rotated
    );

    -- Le aplicamos un offset a las coordenadas para poder trabajarlas como numeros sin signo
    --X_coord_rotated_offset <= std_logic_vector(X_coord_rotated(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));
    --Y_coord_rotated_offset <= std_logic_vector(Y_coord_rotated(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));
    --Z_coord_rotated_offset <= std_logic_vector(Z_coord_rotated(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));
    X_coord_rotated_offset <= std_logic_vector(signed(X_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS)) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));
    Y_coord_rotated_offset <= std_logic_vector(signed(Y_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS)) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));
    Z_coord_rotated_offset <= std_logic_vector(signed(Z_coord_current(COORDS_WIDTH-1 downto COORDS_WIDTH-SQUARE_WIDTH_IN_BITS)) + to_signed(-(2**(SQUARE_WIDTH_IN_BITS-1)), SQUARE_WIDTH_IN_BITS));


end arch;