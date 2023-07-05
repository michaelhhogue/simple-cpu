library ieee;
use ieee.std_logic_1164.all;

entity MarMux is 
	port (
		A: in std_logic_vector(4 downto 0);
		B: in std_logic_vector(4 downto 0);
		address: in std_logic;
		output: out std_logic_vector(4 downto 0)
	);
end MarMux;

architecture behavior of MarMux is 
begin 
	
	process(A, B, address)
	begin
	
		if (address = '0') then output <= A;
		elsif (address = '1') then output <= B;
		end if;
	
	end process;
end behavior;