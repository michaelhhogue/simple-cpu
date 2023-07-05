library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
	port (
		output: out std_logic_vector(4 downto 0);
		clk: in std_logic;
		increment: in std_logic
	);
end;

architecture behavior of ProgramCounter is
begin
process(clk)

	variable counter: integer := 0;
	
begin
	
	if (clk'event and clk = '1' and increment = '1') then
		counter := counter + 1;
		
		output <= std_logic_vector(to_unsigned(counter, output'length));
	end if;
end process;
end behavior;