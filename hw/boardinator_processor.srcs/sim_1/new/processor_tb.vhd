----------------------------------------------------------------------------------
--------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--use work.simple.all;

entity processor_tb is
--  Port ( );
end processor_tb;

architecture Behavioral of processor_tb is
    component processor
    Port ( temporary_processor_instr_input : in STD_LOGIC_VECTOR(15 downto 0);  --delet
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           pc_out : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    signal instr_input : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal rst: std_logic := '1';
    signal pc: std_logic_vector(9 downto 0) := "0000000000";
    
    type prog_mem_t is array (999 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
        		0 => "0000000000000001",		--	set
	1 => "0000000100000001",		--	set
	2 => "0000001000000001",		--	set
	3 => "0001000100000010",		--	add
	4 => "0000101100000001",		--	mov
	5 => "0000100100000010",		--	mov
	6 => "0000101000000011",		--	mov
	7 => "0000100000000001",		--	mov
	8 => "0001000100000010",		--	add
	9 => "0000101100000001",		--	mov
	10 => "0000100100000010",		--	mov
	11 => "0000101000000011",		--	mov
	12 => "0000100000000001",		--	mov
	13 => "0001000100000010",		--	add
	14 => "0000101100000001",		--	mov
	15 => "0000100100000010",		--	mov
	16 => "0000101000000011",		--	mov
	17 => "0000100000000001",		--	mov
	18 => "0001000100000010",		--	add
	19 => "0000101100000001",		--	mov
	20 => "0000100100000010",		--	mov
	21 => "0000101000000011",		--	mov
	22 => "0000100000000001",		--	mov
	23 => "0001000100000010",		--	add
	24 => "0000101100000001",		--	mov
	25 => "0000100100000010",		--	mov
	26 => "0000101000000011",		--	mov
	27 => "0000100000000001",		--	mov
	28 => "0001000100000010",		--	add
	29 => "0000101100000001",		--	mov
	30 => "0000100100000010",		--	mov
	31 => "0000101000000011",		--	mov
	32 => "0000100000000001",		--	mov
	33 => "0001000100000010",		--	add
	34 => "0000101100000001",		--	mov
	35 => "0000100100000010",		--	mov
	36 => "0000101000000011",		--	mov
	37 => "0000100000000001",		--	mov
	38 => "0001000100000010",		--	add
	39 => "0000101100000001",		--	mov
	40 => "0000100100000010",		--	mov
	41 => "0000101000000011",		--	mov
	42 => "0000100000000001",		--	mov

        others => "0000000000000000"
    );
    --signal prog_rom: prog_mem_t := HEXFILE;
begin
    
    uut: processor port map (
        temporary_processor_instr_input => instr_input,
        clk => clk,
        rst => rst,
        pc_out => pc
    );
    
    

    clk_proc: process
    begin
        clk <= '1';
        instr_input <= prog_rom(to_integer(unsigned(pc)));
        wait for 50ns;
        clk <= '0';
        wait for 50ns;
    end process;
    
    main_proc: process
    begin
        rst <= '0';
        wait for 360ns;
        rst <= '1';
        wait for 20ns;

        --let the program execute        
        wait for 100us;
        

    end process;

end Behavioral;
