library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- This is an integration sketch, not a complete Nexys 4 DDR top level.
-- Rename the VGA timing/color signals to match the final top-level design.
entity gol_vga_integration_example is
    port (
        clk100       : in  std_logic;
        reset        : in  std_logic;
        pause        : in  std_logic;
        sw_speed     : in  unsigned(2 downto 0);
        pixel_x      : in  unsigned(9 downto 0); -- 0 to 639 from VGA driver
        pixel_y      : in  unsigned(9 downto 0); -- 0 to 479 from VGA driver
        video_active : in  std_logic;
        vga_r        : out std_logic_vector(3 downto 0);
        vga_g        : out std_logic_vector(3 downto 0);
        vga_b        : out std_logic_vector(3 downto 0)
    );
end gol_vga_integration_example;

architecture example of gol_vga_integration_example is
    signal update_tick : std_logic;
    signal cell_x      : unsigned(5 downto 0);
    signal cell_y      : unsigned(4 downto 0);
    signal cell_alive  : std_logic;
    signal grid_line   : std_logic;
begin
    -- 16 pixels per cell means divide pixel coordinates by 16, which is just
    -- selecting the upper bits of a 10-bit 640x480 pixel coordinate.
    cell_x <= pixel_x(9 downto 4);
    cell_y <= pixel_y(8 downto 4);

    grid_line <= '1' when pixel_x(3 downto 0) = "0000" or
                          pixel_y(3 downto 0) = "0000" else
                 '0';

    tick_inst : entity work.tick_generator
        port map (
            clk          => clk100,
            reset        => reset,
            speed_select => sw_speed,
            update_tick  => update_tick
        );

    life_inst : entity work.game_of_life
        port map (
            clk         => clk100,
            reset       => reset,
            update_tick => update_tick,
            pause       => pause,
            seed_select => "00",
            cell_x      => cell_x,
            cell_y      => cell_y,
            cell_alive  => cell_alive
        );

    process(video_active, cell_alive, grid_line)
    begin
        if video_active = '0' then
            vga_r <= "0000";
            vga_g <= "0000";
            vga_b <= "0000";
        elsif grid_line = '1' then
            vga_r <= "0010";
            vga_g <= "0010";
            vga_b <= "0010";
        elsif cell_alive = '1' then
            vga_r <= "0000";
            vga_g <= "1111";
            vga_b <= "0110";
        else
            vga_r <= "0000";
            vga_g <= "0000";
            vga_b <= "0000";
        end if;
    end process;
end example;
