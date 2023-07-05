library ieee;
use ieee.std_logic_1164.all;

entity cpu is
	port(
		clk: in std_logic;
		pcOut: out std_logic_vector(4 downto 0);
		marOut: out std_logic_vector (4 downto 0);
		irOutput: out std_logic_vector (7 downto 0);
		mdriOutput: out std_logic_vector (7 downto 0);
		mdroOutput: out std_logic_vector (7 downto 0);
		aOut: out std_logic_vector (7 downto 0);
		incrementOut: out std_logic 
	);
end;

architecture behavior of cpu is

component memory_8_by_32 --memory component
	port(
		clk: in std_logic;
		Write_Enable: in std_logic;
		Read_Addr: in std_logic_vector(4 downto 0);
		Data_in: in std_logic_vector(7 downto 0);
		Data_out: out std_logic_vector(7 downto 0)
	);
end component;

component alu --arithmetic logic unit
	port(
		A: in std_logic_vector(7 downto 0);
		B: in std_logic_vector(7 downto 0);
		AluOp: in std_logic_vector(2 downto 0);
		output: out std_logic_vector(7 downto 0)
	);
end component;

component reg --register
	port(
		input : in std_logic_vector(7 downto 0);
		output : out std_logic_vector(7 downto 0);
		clk : in std_logic;
		load : in std_logic
	);
end component;

component ProgramCounter --program counter
	port(
		increment: in std_logic;
		clk: in std_logic;
		output: out std_logic_vector(4 downto 0)
	);
end component;

component MarMux --mux
	port(
		A: in std_logic_vector (4 downto 0);
		B: in std_logic_vector (4 downto 0);
		address: in std_logic;
		output: out std_logic_vector (4 downto 0)
	);
end component;

component sevenseg --seven segment decoder
	port(
	i: in std_logic_vector(3 downto 0);
	o: out std_logic_vector(7 downto 0)
	);
end component;

component ControlUnit
	port(
		OpCode : in std_logic_vector(2 downto 0);
		clk : in std_logic;
		ToALoad : out std_logic;
		ToMarLoad : out std_logic;
		ToIrLoad : out std_logic;
		ToMdriLoad : out std_logic;
		ToMdroLoad : out std_logic;
		ToPcIncrement : out std_logic;
		ToMarMux : out std_logic;
		ToRamWriteEnable : out std_logic;
		ToAluOp : out std_logic_vector(2 downto 0)
	);
end component;

-- Connections
signal ramDataOutToMdri : std_logic_vector(7 downto 0);
-- MAR Multiplexer connections
signal pcToMarMux : std_logic_vector(4 downto 0);
signal muxToMar : std_logic_vector (4 downto 0);
-- RAM connections
signal marToRamReadAddr : std_logic_vector(4 downto 0);
signal mdroToRamDataIn : std_logic_vector(7 downto 0);
-- MDRI connections
signal mdriOut : std_logic_vector(7 downto 0);
-- IR connection
signal irOut : std_logic_vector(7 downto 0);
-- ALU / Accumulator connections
signal aluOut: std_logic_vector(7 downto 0);
signal aToAluB : std_logic_vector(7 downto 0);
-- Control Unit connections
signal cuToALoad : std_logic;
signal cuToMarLoad : std_logic;
signal cuToIrLoad : std_logic;
signal cuToMdriLoad : std_logic;
signal cuToMdroLoad : std_logic;
signal cuToPcIncrement : std_logic;
signal cuToMarMux : std_logic;
signal cuToRamWriteEnable : std_logic;
signal cuToAluOp : std_logic_vector(2 downto 0);

begin
	Map_Memory: memory_8_by_32 port map(
		clk=>clk,
		read_addr=>marToRamReadAddr,
		data_in=>mdroToRamDataIn,
		data_out=>ramDataOutToMdri,
		write_enable=>cuToRamWriteEnable 
	);
	
	-- Accumulator
	Map_Accumulator: reg port map(
		clk => clk,
		load => cuToALoad,
		input => aluOut,
		output => aToaluB
	);
	
	-- ALU
	Map_Alu: alu port map(
		AluOp => cuToAluOp,
		A => mdriOut,
		B => aToAluB,
		output => aluOut
	);
	
	-- Program Counter
	Map_ProgramCounter: ProgramCounter port map(
		output => pcToMarMux,
		clk => clk,
		increment => cuToPcIncrement
	);
	
	-- Instruction Register
	Map_Ir: reg port map(
		clk => clk,
		load => cuToIrLoad,
		input => mdriOut,
		output => irOut
	);
	
	-- MAR mux
	Map_MarMux: MarMux port map(
		A => pcToMarMux,
		B => irOut(4 downto 0),
		address => cuToMarMux,
		output => muxToMar
	);
	
	-- Memory Access Register
	Map_MAR: reg port map(
		clk => clk,
		load => cuToMarLoad,
		input(4 downto 0) => muxToMar,
		output(4 downto 0) => marToRamReadAddr
	);
	
	-- Memory Data Register Input
	Map_MDRI: reg port map(
		clk=>clk,
		input=>ramDataOutToMdri,
		output=>mdriOut,
		load=>cuToMdriLoad 
	);
	
	-- Memory Data Register Output
	Map_MDRO: reg port map(
		clk => clk,
		input => aluOut,
		output => mdroToRamDataIn,
		load => cuToMdroLoad 
	);
	
	-- Control Unit
	Map_ControlUnit: ControlUnit port map (
		OpCode => irOut(7 downto 5),
		clk => clk,
		ToALoad => cuToALoad,
		ToMarLoad => cuToMarLoad,
		ToIrLoad => cuToIrLoad,
		ToMdriLoad => cuToMdriLoad,
		ToMdroLoad => cuToMdroLoad,
		ToPcIncrement => cuToPcIncrement,
		ToMarMux => cuToMarMux,
		ToRamWriteEnable => cuToRamWriteEnable,
		ToAluOp => cuToAluOp
	);
	
	pcOut <= pcToMarMux;
	irOutput <= irOut;
	aOut <= aToAluB;
	marOut <= marToRamReadAddr;
	mdriOutput <= mdriOut;
	mdroOutput <= mdroToRamDataIn;
	incrementOut <= cuToPcIncrement;
end behavior;