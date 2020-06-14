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
    			0 => "0000000000010100",		--set	r0,20				
		1 => "0000000101000000",		--set	r1,64				
		2 => "0000001000000001",		--set r2,1
		3 => "1000000100000000",		--setstk	r1,r0	
		4 => "0001000100000010",		--add r1,r2
		5 => "0001000000000010",		--add r0,r2
		6 => "1000000100000000",		--setstk	r1,r0
		7 => "0001000100000010",		--add r1,r2
		8 => "0001000000000010",		--add r0,r2
		9 => "1000000100000000",		--setstk	r1,r0
		10 => "0000000101000000",		--set r1,64
		11 => "1000110100000001",		--getstk	r5,r1	
		12 => "0001000100000010",		--add r1,r2
		13 => "1000111000000001",		--getstk	r6,r1
		14 => "0001000100000010",		--add r1,r2
		15 => "1000111100000001",		--getstk	r7,r1


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
        wait for 10000us;
        

    end process;

end Behavioral;
