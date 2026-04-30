library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Conway's Game of Life core for a 40 x 30 visible grid.
--
-- Coordinates are unsigned vectors instead of integer ports because unsigned
-- ports are usually easier to connect to pixel counters and top-level logic in
-- Vivado. Values outside the legal grid range simply read as dead.
entity game_of_life is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        update_tick : in  std_logic;
        pause       : in  std_logic;
        cell_x      : in  unsigned(5 downto 0); -- 0 to 39 used
        cell_y      : in  unsigned(4 downto 0); -- 0 to 29 used
        cell_alive  : out std_logic
    );
end game_of_life;

architecture rtl of game_of_life is
    constant GRID_COLS : integer := 40;
    constant GRID_ROWS : integer := 30;

    type grid_t is array (0 to GRID_ROWS - 1, 0 to GRID_COLS - 1) of std_logic;

    function seed_grid return grid_t is
        variable seed : grid_t := (others => (others => '0'));
    begin
        -- Glider near the upper-left area.
        seed(2, 3) := '1';
        seed(3, 4) := '1';
        seed(4, 2) := '1';
        seed(4, 3) := '1';
        seed(4, 4) := '1';

        -- Horizontal blinker near the center.
        seed(14, 18) := '1';
        seed(14, 19) := '1';
        seed(14, 20) := '1';

        -- Small block still life.
        seed(22, 30) := '1';
        seed(22, 31) := '1';
        seed(23, 30) := '1';
        seed(23, 31) := '1';

        -- Lightweight spaceship-ish pattern. It will interact visibly before
        -- reaching the dead border.
        seed(8, 27) := '1';
        seed(8, 30) := '1';
        seed(9, 31) := '1';
        seed(10, 27) := '1';
        seed(10, 31) := '1';
        seed(11, 28) := '1';
        seed(11, 29) := '1';
        seed(11, 30) := '1';
        seed(11, 31) := '1';

        return seed;
    end function;

    signal current_grid : grid_t := seed_grid;
begin
    process(clk)
        variable next_grid : grid_t;
        variable neighbors : integer range 0 to 8;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_grid <= seed_grid;
            elsif update_tick = '1' and pause = '0' then
                next_grid := (others => (others => '0'));

                for y in 0 to GRID_ROWS - 1 loop
                    for x in 0 to GRID_COLS - 1 loop
                        neighbors := 0;

                        -- Count each in-bounds neighbor. Out-of-bounds cells
                        -- are dead, so no wraparound is used.
                        if y > 0 and x > 0 then
                            if current_grid(y - 1, x - 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if y > 0 then
                            if current_grid(y - 1, x) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if y > 0 and x < GRID_COLS - 1 then
                            if current_grid(y - 1, x + 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if x > 0 then
                            if current_grid(y, x - 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if x < GRID_COLS - 1 then
                            if current_grid(y, x + 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if y < GRID_ROWS - 1 and x > 0 then
                            if current_grid(y + 1, x - 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if y < GRID_ROWS - 1 then
                            if current_grid(y + 1, x) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if y < GRID_ROWS - 1 and x < GRID_COLS - 1 then
                            if current_grid(y + 1, x + 1) = '1' then
                                neighbors := neighbors + 1;
                            end if;
                        end if;

                        if current_grid(y, x) = '1' then
                            if neighbors = 2 or neighbors = 3 then
                                next_grid(y, x) := '1';
                            else
                                next_grid(y, x) := '0';
                            end if;
                        else
                            if neighbors = 3 then
                                next_grid(y, x) := '1';
                            else
                                next_grid(y, x) := '0';
                            end if;
                        end if;
                    end loop;
                end loop;

                current_grid <= next_grid;
            end if;
        end if;
    end process;

    process(current_grid, cell_x, cell_y)
        variable x_index : integer range 0 to 63;
        variable y_index : integer range 0 to 31;
    begin
        x_index := to_integer(cell_x);
        y_index := to_integer(cell_y);

        if x_index < GRID_COLS and y_index < GRID_ROWS then
            cell_alive <= current_grid(y_index, x_index);
        else
            cell_alive <= '0';
        end if;
    end process;
end rtl;
