library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all;

entity vga_pattern is
    port (
        x           : in integer;
        y           : in integer;
        video_on    : in std_logic;
        red         : out std_logic_vector(3 downto 0);
        green       : out std_logic_vector(3 downto 0);
        blue        : out std_logic_vector(3 downto 0)
    );
end vga_pattern;

architecture Behavioral of vga_pattern is
begin

process(x, y, video_on)
begin
    red <= "0000";
    green <= "0000";
    blue <= "0000";
    
    if video_on = '1' then
        -- Grid lines every 8 pixels
        if (x mod 8 = 0) OR (y mod 8 = 0) then
            red     <= "0000";
            green   <= "0000";
            blue    <= "0000";
        else
            red     <= "1111";
            green   <= "1111";
            blue    <= "1111";
        end if;
    end if;
    
end process;

end Behavioral;
