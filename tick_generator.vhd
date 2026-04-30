library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Generates a one-clock-cycle update pulse from the 100 MHz board clock.
-- speed_select chooses a human-visible Game of Life update rate.
entity tick_generator is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        speed_select : in  unsigned(2 downto 0);
        update_tick  : out std_logic
    );
end tick_generator;

architecture rtl of tick_generator is
    signal counter : unsigned(31 downto 0) := (others => '0');

    function tick_limit(speed : unsigned(2 downto 0)) return unsigned is
        variable limit_value : integer;
    begin
        case to_integer(speed) is
            when 0      => limit_value := 100000000 - 1; -- 1 Hz
            when 1      => limit_value :=  50000000 - 1; -- 2 Hz
            when 2      => limit_value :=  25000000 - 1; -- 4 Hz
            when 3      => limit_value :=  12500000 - 1; -- 8 Hz
            when 4      => limit_value := 200000000 - 1; -- 0.5 Hz
            when 5      => limit_value := 400000000 - 1; -- 0.25 Hz
            when 6      => limit_value :=   6250000 - 1; -- 16 Hz
            when others => limit_value := 100000000 - 1; -- 1 Hz
        end case;

        return to_unsigned(limit_value, 32);
    end function;
begin
    process(clk)
        variable selected_limit : unsigned(31 downto 0);
    begin
        if rising_edge(clk) then
            selected_limit := tick_limit(speed_select);

            if reset = '1' then
                counter     <= (others => '0');
                update_tick <= '0';
            elsif counter >= selected_limit then
                counter     <= (others => '0');
                update_tick <= '1';
            else
                counter     <= counter + 1;
                update_tick <= '0';
            end if;
        end if;
    end process;
end rtl;
