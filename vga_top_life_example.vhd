library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Example top-level wiring using the existing VGA timing modules and the
-- Game of Life color-pattern block.
--
-- This is deliberately a new entity so it does not overwrite vga_top.vhd.
entity vga_top_life_example is
    port (
        CLK100MHZ : in  std_logic;
        A         : in  std_logic_vector(3 downto 0);
        Ci        : in  std_logic;
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic;
        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0)
    );
end vga_top_life_example;

architecture rtl of vga_top_life_example is
    signal clk_25mhz : std_logic;
    signal x         : integer range 0 to 639;
    signal y         : integer range 0 to 479;
    signal video_on  : std_logic;
begin
    clock_inst : entity work.clock_gen
        port map (
            clkIn  => CLK100MHZ,
            clkOut => clk_25mhz
        );

    timing_inst : entity work.vga_timing
        port map (
            clk      => clk_25mhz,
            hsync    => VGA_HS,
            vsync    => VGA_VS,
            video_on => video_on,
            x        => x,
            y        => y
        );

    life_pattern_inst : entity work.life_vga_pattern
        port map (
            clk100       => CLK100MHZ,
            reset        => Ci,
            pause        => A(3),
            speed_select => A(2 downto 0),
            x            => x,
            y            => y,
            video_on     => video_on,
            red          => VGA_R,
            green        => VGA_G,
            blue         => VGA_B
        );
end rtl;
