library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity clock_gen is 
	port (
		clkIn   : in  std_logic;
		clkOut  : out std_logic
	);
end clock_gen;

architecture Behavior of clock_gen is 
	signal count : unsigned(1 downto 0) := "00";
begin
	-- Divide the 100 MHz board clock down to a 25 MHz VGA pixel clock.
	process(clkIn)
	begin
		if rising_edge(clkIn) then	
			count <= count + 1;
        end if;
	end process;

clkOut <= count(1);
		 
end Behavior;
