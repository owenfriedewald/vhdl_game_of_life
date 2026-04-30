library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

entity tb_game_of_life is
end tb_game_of_life;

architecture sim of tb_game_of_life is
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal update_tick : std_logic := '0';
    signal seed_select : unsigned(1 downto 0) := (others => '0');
    signal cell_x      : unsigned(5 downto 0) := (others => '0');
    signal cell_y      : unsigned(4 downto 0) := (others => '0');
    signal cell_alive  : std_logic;
begin
    clk <= not clk after 5 ns;

    dut : entity work.game_of_life
        port map (
            clk         => clk,
            reset       => reset,
            update_tick => update_tick,
            seed_select => seed_select,
            cell_x      => cell_x,
            cell_y      => cell_y,
            cell_alive  => cell_alive
        );

    stim : process
        procedure check_cell(
            constant x        : in natural;
            constant y        : in natural;
            constant expected : in std_logic;
            constant label_s  : in string
        ) is
        begin
            cell_x <= to_unsigned(x, cell_x'length);
            cell_y <= to_unsigned(y, cell_y'length);
            wait for 1 ns;
            assert cell_alive = expected
                report label_s
                severity error;
        end procedure;
    begin
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        wait for 1 ns;

        check_cell(18, 14, '1', "seed blinker left cell should be alive");
        check_cell(19, 14, '1', "seed blinker center cell should be alive");
        check_cell(20, 14, '1', "seed blinker right cell should be alive");
        check_cell(19, 13, '0', "seed blinker upper cell should be dead");
        check_cell(19, 15, '0', "seed blinker lower cell should be dead");

        update_tick <= '1';
        wait until rising_edge(clk);
        update_tick <= '0';
        wait for 1 ns;

        check_cell(18, 14, '0', "updated blinker left cell should be dead");
        check_cell(19, 13, '1', "updated blinker upper cell should be alive");
        check_cell(19, 14, '1', "updated blinker center cell should stay alive");
        check_cell(19, 15, '1', "updated blinker lower cell should be alive");
        check_cell(20, 14, '0', "updated blinker right cell should be dead");

        check_cell(3, 2, '0', "updated glider old head should be dead");
        check_cell(2, 3, '1', "updated glider new left cell should be alive");
        check_cell(4, 3, '1', "updated glider right cell should stay alive");
        check_cell(3, 4, '1', "updated glider lower-left cell should stay alive");
        check_cell(4, 4, '1', "updated glider lower-right cell should stay alive");
        check_cell(3, 5, '1', "updated glider new lower cell should be alive");

        check_cell(30, 22, '1', "block still life upper-left should stay alive");
        check_cell(31, 22, '1', "block still life upper-right should stay alive");
        check_cell(30, 23, '1', "block still life lower-left should stay alive");
        check_cell(31, 23, '1', "block still life lower-right should stay alive");
        check_cell(29, 22, '0', "block still life left neighbor should stay dead");
        check_cell(32, 23, '0', "block still life right neighbor should stay dead");

        check_cell(40, 0, '0', "out-of-range x coordinate should read dead");
        check_cell(0, 30, '0', "out-of-range y coordinate should read dead");

        seed_select <= "01";
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        wait for 1 ns;

        check_cell(8, 5, '1', "seed 1 horizontal oscillator left cell should be alive");
        check_cell(9, 5, '1', "seed 1 horizontal oscillator center cell should be alive");
        check_cell(10, 5, '1', "seed 1 horizontal oscillator right cell should be alive");
        check_cell(18, 14, '0', "seed 1 should replace seed 0 blinker pattern");

        seed_select <= "10";
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        wait for 1 ns;

        check_cell(6, 3, '1', "seed 2 soup cell should be alive");
        check_cell(22, 10, '1', "seed 2 soup cluster cell should be alive");
        check_cell(8, 5, '0', "seed 2 should replace seed 1 oscillator pattern");

        seed_select <= "11";
        reset <= '1';
        wait until rising_edge(clk);
        reset <= '0';
        wait for 1 ns;

        check_cell(32, 7, '1', "seed 3 glider cell should be alive");
        check_cell(25, 24, '1', "seed 3 lower glider cell should be alive");
        check_cell(6, 3, '0', "seed 3 should replace seed 2 soup pattern");

        report "tb_game_of_life completed successfully";
        stop;
    end process;
end sim;
