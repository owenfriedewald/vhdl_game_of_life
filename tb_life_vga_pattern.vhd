library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

entity tb_life_vga_pattern is
end tb_life_vga_pattern;

architecture sim of tb_life_vga_pattern is
    signal clk100       : std_logic := '0';
    signal reset        : std_logic := '0';
    signal pause        : std_logic := '1';
    signal speed_select : std_logic_vector(2 downto 0) := (others => '0');
    signal seed_select  : std_logic_vector(1 downto 0) := (others => '0');
    signal x            : integer := 0;
    signal y            : integer := 0;
    signal video_on     : std_logic := '0';
    signal red          : std_logic_vector(3 downto 0);
    signal green        : std_logic_vector(3 downto 0);
    signal blue         : std_logic_vector(3 downto 0);
begin
    clk100 <= not clk100 after 5 ns;

    dut : entity work.life_vga_pattern
        port map (
            clk100       => clk100,
            reset        => reset,
            pause        => pause,
            speed_select => speed_select,
            seed_select  => seed_select,
            x            => x,
            y            => y,
            video_on     => video_on,
            red          => red,
            green        => green,
            blue         => blue
        );

    stim : process
        procedure check_rgb(
            constant px       : in integer;
            constant py       : in integer;
            constant active   : in std_logic;
            constant exp_red  : in std_logic_vector(3 downto 0);
            constant exp_grn  : in std_logic_vector(3 downto 0);
            constant exp_blu  : in std_logic_vector(3 downto 0);
            constant label_s  : in string
        ) is
        begin
            x <= px;
            y <= py;
            video_on <= active;
            wait for 1 ns;
            assert red = exp_red and green = exp_grn and blue = exp_blu
                report label_s
                severity error;
        end procedure;
    begin
        reset <= '1';
        wait until rising_edge(clk100);
        reset <= '0';
        wait for 1 ns;

        check_rgb(49, 33, '0', "0000", "0000", "0000",
                  "video_off should force black");
        check_rgb(16, 1, '1', "0010", "0010", "0010",
                  "grid line should be gray");
        check_rgb(49, 33, '1', "0000", "1111", "0110",
                  "seed 0 glider live cell should be green");
        check_rgb(1, 1, '1', "0000", "0000", "0000",
                  "dead non-grid cell should be black");

        seed_select <= "01";
        reset <= '1';
        wait until rising_edge(clk100);
        reset <= '0';
        wait for 1 ns;

        check_rgb(129, 81, '1', "0000", "1111", "0110",
                  "seed 1 oscillator live cell should be green");
        check_rgb(49, 33, '1', "0000", "0000", "0000",
                  "seed 1 should replace seed 0 glider cell");

        report "tb_life_vga_pattern completed successfully";
        stop;
    end process;
end sim;
