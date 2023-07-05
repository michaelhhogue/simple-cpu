library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity memory_8_by_32 is 
	port (
		clk: in std_logic;
		read_addr: in std_logic_vector(4 downto 0);
		data_in: in std_logic_vector(7 downto 0);
		write_enable: in std_logic;
		data_out: out std_logic_vector(7 downto 0)
	);
end memory_8_by_32;

architecture behavior of memory_8_by_32 is 
type ram_type is array (0 to 31) of std_logic_vector(7 downto 0);

signal mem: ram_type := ("00000101", "00100011", "01000111", "00000111", "00101000", "00000110", "00010100", "01010101", "00000001", others => "11111111");

begin
	process(clk, write_enable)
	begin
		if (clk'event and clk = '1' and write_enable = '0') then
			data_out <= mem(conv_integer(read_addr));
			
		elsif (clk'event and clk = '1' and write_enable = '1') then
			mem(conv_integer(read_addr)) <= data_in;
		end if;
	end process;
end behavior;