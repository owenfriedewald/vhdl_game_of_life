library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Top level for the Life-enabled VGA design.
-- Uses the existing clock divider and VGA timing blocks, then replaces the
-- static color pattern with the Game of Life pattern generator.
entity vga_top_life is
    port (
        CLK100MHZ : in  std_logic;
        SW        : in  std_logic_vector(5 downto 0);
        VGA_HS    : out std_logic;
        VGA_VS    : out std_logic;
        VGA_R     : out std_logic_vector(3 downto 0);
        VGA_G     : out std_logic_vector(3 downto 0);
        VGA_B     : out std_logic_vector(3 downto 0)
    );
end vga_top_life;

architecture rtl of vga_top_life is
    signal clk_25mhz : std_logic;
    signal x         : integer range 0 to 639;
    signal y         : integer range 0 to 479;
    signal video_on  : std_logic;

    signal reset_meta  : std_logic := '0';
    signal reset_clean : std_logic := '0';
    signal speed_meta  : std_logic_vector(2 downto 0) := (others => '0');
    signal speed_clean : std_logic_vector(2 downto 0) := (others => '0');
    signal seed_meta   : std_logic_vector(1 downto 0) := (others => '0');
    signal seed_clean  : std_logic_vector(1 downto 0) := (others => '0');
begin
    clock_inst : entity work.clock_gen
        port map (
            clkIn  => CLK100MHZ,
            clkOut => clk_25mhz
        );

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            reset_meta <= SW(3);
            reset_clean <= reset_meta;

            speed_meta <= SW(2 downto 0);
            speed_clean <= speed_meta;

            seed_meta <= SW(5 downto 4);
            seed_clean <= seed_meta;
        end if;
    end process;

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
            reset        => reset_clean,
            speed_select => speed_clean,
            seed_select  => seed_clean,
            x            => x,
            y            => y,
            video_on     => video_on,
            red          => VGA_R,
            green        => VGA_G,
            blue         => VGA_B
        );
end rtl;
