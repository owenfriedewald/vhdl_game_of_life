library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_timing is
    Port (
        clk       : in  STD_LOGIC;  -- 25 MHz clock
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        video_on  : out STD_LOGIC;
        x         : out INTEGER range 0 to 639;
        y         : out INTEGER range 0 to 479
    );
end vga_timing;

architecture Behavioral of vga_timing is

    -- Horizontal timing constants
    constant H_VISIBLE   : integer := 640;
    constant H_FRONT     : integer := 16;
    constant H_SYNC      : integer := 96;
    constant H_BACK      : integer := 48;
    constant H_TOTAL     : integer := 800;

    -- Vertical timing constants
    constant V_VISIBLE   : integer := 480;
    constant V_FRONT     : integer := 10;
    constant V_SYNC      : integer := 2;
    constant V_BACK      : integer := 33;
    constant V_TOTAL     : integer := 525;

    -- Counters
    signal h_count : integer range 0 to H_TOTAL-1 := 0;
    signal v_count : integer range 0 to V_TOTAL-1 := 0;

begin
    -- Horizontal & Vertical Counters
    process(clk)
    begin
        if rising_edge(clk) then
            if h_count = H_TOTAL - 1 then
                h_count <= 0;

                if v_count = V_TOTAL - 1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;

            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;

    -- Sync Signals (active low)
    hsync <= '0' when (h_count >= (H_VISIBLE + H_FRONT) and
                       h_count <  (H_VISIBLE + H_FRONT + H_SYNC))
             else '1';

    vsync <= '0' when (v_count >= (V_VISIBLE + V_FRONT) and
                       v_count <  (V_VISIBLE + V_FRONT + V_SYNC))
             else '1';

    -- Video On
    video_on <= '1' when (h_count < H_VISIBLE and v_count < V_VISIBLE) else '0';

    ----------------------------------------------------------------
    -- Pixel Coordinates
    ----------------------------------------------------------------
    -- x and y are only active-area coordinates. During blanking they are held
    -- at 0 so downstream drawing logic never sees porch/sync coordinates.
    x <= h_count when h_count < H_VISIBLE else 0;
    y <= v_count when v_count < V_VISIBLE else 0;
    
end Behavioral;
