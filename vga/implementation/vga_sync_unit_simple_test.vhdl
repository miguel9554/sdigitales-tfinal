library ieee;
use ieee.std_logic_1164.all;

entity vga_test is
    port (
        clk, reset: in std_logic;
        sw: in std_logic_vector(2 downto 0);
        Hsync, Vsync: out  std_logic;
        vgaRed: out std_logic_vector(2 downto 0);
        vgaGreen: out std_logic_vector(2 downto 0);
        vgaBlue: out std_logic_vector(1 downto 0)
    );
end vga_test;

architecture arch of vga_test is
    signal rgb_reg: std_logic_vector(2 downto 0);
    signal video_on: std_logic;
begin
    -- instantiate VGA sync circuit
    vga_sync_unit: entity work.vga_sync
        port map(clk=>clk, reset=>reset, hsync=>Hsync,
                vsync=>Vsync, video_on=>video_on,
                p_tick=>open, pixel_x=>open, pixel_y=>open);
    -- rgb buffer
    process (clk,reset)
    begin
        if reset='1' then
            rgb_reg <= (others=>'0');
        elsif (clk'event and clk='1') then
            rgb_reg <= sw;
        end if;
    end process;

    vgaRed <= (rgb_reg(2) & rgb_reg(2) & rgb_reg(2)) when video_on='1' else "000";
    vgaGreen <= (rgb_reg(1) & rgb_reg(1) & rgb_reg(1)) when video_on='1' else "000";
    vgaBlue <= (rgb_reg(0) & rgb_reg(0)) when video_on='1' else "00";

end arch;