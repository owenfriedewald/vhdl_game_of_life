--------------------------------
-- Thomas Joswiak
-- ECE4250 Final Project
-- VGA Test System
--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_top is
	port (
		CLK100MHZ         : in  std_logic;
		
		VGA_HS            : out std_logic;
		VGA_VS            : out std_logic;
		
		VGA_R             : out std_logic_vector (3 downto 0);
		VGA_G             : out std_logic_vector (3 downto 0);
		VGA_B             : out std_logic_vector (3 downto 0)
	);
end vga_top;

architecture Behavioral of vga_top is
    -- Clock
    signal clk_25mhz : std_logic;

    component clock_gen
        port (
            clkIn  : in std_logic;
            clkOut : out std_logic
        );
    end component;
    
    -- VGA Timing
    signal x, y     : integer;
    signal video_on  : std_logic;
    
    component vga_timing
        port(
            clk       : in  STD_LOGIC;  -- 25 MHz clock
            hsync     : out STD_LOGIC;
            vsync     : out STD_LOGIC;
            video_on  : out STD_LOGIC;
            x         : out INTEGER range 0 to 639;
            y         : out INTEGER range 0 to 479
        );
    end component;
    
    component vga_pattern
        port(
            x           : in integer;
            y           : in integer;
            video_on    : in std_logic;
            red         : out std_logic_vector(3 downto 0);
            green       : out std_logic_vector(3 downto 0);
            blue        : out std_logic_vector(3 downto 0)
        );
    end component;
    
begin

    -- Clock generator
    U1 : clock_gen
        port map (
            clkIn  => CLK100MHZ,
            clkOut => clk_25mhz
        );
    
    -- VGA Timing
    U2 : vga_timing
        port map (
            clk         => clk_25mhz,
            hsync       => VGA_HS,
            vsync       => VGA_VS,
            video_on    => video_on,
            x           => x,
            y           => y
        );
        
    -- VGA grid pattern
    U3 : vga_pattern
        port map (
            x           => x,
            y           => y,
            video_on    => video_on,
            red         => VGA_R,
            green       => VGA_G,
            blue        => VGA_B
        );        
    
end Behavioral;
