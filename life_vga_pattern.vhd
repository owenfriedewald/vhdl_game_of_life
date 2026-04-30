library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Optional adapter for an existing VGA renderer.
--
-- This module is intentionally shaped like a color-pattern block. It does not
-- generate VGA timing or sync. Feed it the current pixel x/y and video_on from
-- the existing VGA timing module, and it returns RGB values based on the Game
-- of Life state.
entity life_vga_pattern is
    port (
        clk100       : in  std_logic;
        reset        : in  std_logic;
        pause        : in  std_logic;
        speed_select : in  std_logic_vector(2 downto 0);
        x            : in  integer;
        y            : in  integer;
        video_on     : in  std_logic;
        red          : out std_logic_vector(3 downto 0);
        green        : out std_logic_vector(3 downto 0);
        blue         : out std_logic_vector(3 downto 0)
    );
end life_vga_pattern;

architecture rtl of life_vga_pattern is
    signal update_tick : std_logic;
    signal cell_x      : unsigned(5 downto 0) := (others => '0');
    signal cell_y      : unsigned(4 downto 0) := (others => '0');
    signal cell_alive  : std_logic;
    signal grid_line   : std_logic;
begin
    tick_inst : entity work.tick_generator
        port map (
            clk          => clk100,
            reset        => reset,
            speed_select => unsigned(speed_select),
            update_tick  => update_tick
        );

    life_inst : entity work.game_of_life
        port map (
            clk         => clk100,
            reset       => reset,
            update_tick => update_tick,
            pause       => pause,
            cell_x      => cell_x,
            cell_y      => cell_y,
            cell_alive  => cell_alive
        );

    process(x, y, video_on)
    begin
        cell_x    <= (others => '0');
        cell_y    <= (others => '0');
        grid_line <= '0';

        if video_on = '1' and x >= 0 and x < 640 and y >= 0 and y < 480 then
            cell_x <= to_unsigned(x / 16, cell_x'length);
            cell_y <= to_unsigned(y / 16, cell_y'length);

            if (x mod 16 = 0) or (y mod 16 = 0) then
                grid_line <= '1';
            end if;
        end if;
    end process;

    process(video_on, cell_alive, grid_line)
    begin
        red   <= "0000";
        green <= "0000";
        blue  <= "0000";

        if video_on = '1' then
            if grid_line = '1' then
                red   <= "0010";
                green <= "0010";
                blue  <= "0010";
            elsif cell_alive = '1' then
                red   <= "0000";
                green <= "1111";
                blue  <= "0110";
            end if;
        end if;
    end process;
end rtl;
