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
    signal pause       : std_logic := '0';
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
            pause       => pause,
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

        pause <= '1';
        update_tick <= '1';
        wait until rising_edge(clk);
        update_tick <= '0';
        wait for 1 ns;

        check_cell(19, 13, '1', "paused blinker upper cell should stay alive");
        check_cell(19, 15, '1', "paused blinker lower cell should stay alive");

        report "tb_game_of_life completed successfully";
        stop;
    end process;
end sim;
