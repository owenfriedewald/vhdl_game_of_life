library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

entity tb_vga_timing is
end tb_vga_timing;

architecture sim of tb_vga_timing is
    signal clk      : std_logic := '0';
    signal hsync    : std_logic;
    signal vsync    : std_logic;
    signal video_on : std_logic;
    signal x        : integer range 0 to 639;
    signal y        : integer range 0 to 479;
begin
    clk <= not clk after 5 ns;

    dut : entity work.vga_timing
        port map (
            clk      => clk,
            hsync    => hsync,
            vsync    => vsync,
            video_on => video_on,
            x        => x,
            y        => y
        );

    stim : process
    begin
        wait for 1 ns;
        assert x = 0 and y = 0 and video_on = '1'
            report "initial visible pixel should be (0,0)"
            severity error;

        for i in 1 to 639 loop
            wait until rising_edge(clk);
        end loop;
        wait for 1 ns;
        assert x = 639 and y = 0 and video_on = '1'
            report "last visible pixel of first row should be (639,0)"
            severity error;

        wait until rising_edge(clk);
        wait for 1 ns;
        assert x = 0 and y = 0 and video_on = '0'
            report "horizontal blanking should force x to 0 and video_on low"
            severity error;

        for i in 1 to 160 loop
            wait until rising_edge(clk);
        end loop;
        wait for 1 ns;
        assert x = 0 and y = 1 and video_on = '1'
            report "first visible pixel of second row should be (0,1)"
            severity error;

        for row in 2 to 479 loop
            for col in 1 to 800 loop
                wait until rising_edge(clk);
            end loop;
        end loop;
        wait for 1 ns;
        assert x = 0 and y = 479 and video_on = '1'
            report "first visible pixel of final visible row should be (0,479)"
            severity error;

        for col in 1 to 640 loop
            wait until rising_edge(clk);
        end loop;
        wait for 1 ns;
        assert x = 0 and y = 479 and video_on = '0'
            report "vertical blanking should force video_on low while y remains in range"
            severity error;

        report "tb_vga_timing completed successfully";
        stop;
    end process;
end sim;
