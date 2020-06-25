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
           ext_rst : in STD_LOGIC;
           pc_out : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    signal instr_input : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal ext_rst: std_logic := '1';
    signal pc: std_logic_vector(9 downto 0) := "0000000000";
    
    type prog_mem_t is array (999 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
    			0 => "0000000000000011",		--	set 	r0,3
		1 => "0000000111010111",		--	set 	r1,215
		2 => "1001100010000001",		--	setmem 	r0,r1,2
		3 => "0000000000000010",		--	set 	r0,2
		4 => "0000000100001010",		--	set 	r1,10
		5 => "1001100010000001",		--	setmem 	r0,r1,2
		6 => "0000000110001010",		--	set 	r1,0x84
		7 => "1001100010000001",		--	setmem	r0,r1,2
		8 => "0000000000000101",		--	set 	r0,5
		9 => "0000001100000001",		--	set 	r3,0x01
		10 => "0000000100000100",		--	set 	r1,4
		11 => "1010001010000001",		--	getmem	r2,r1,2
		12 => "0100101000000011",		--	and 	r2,r3
		13 => "0101101000000011",		--	cmp 	r2,r3	
		14 => "0111100000001010",		--	jne 	wait_for_match
		15 => "0001100000000001",		--	addl 	r0,1
		16 => "0001100000000000",		--	addl r0,0
		17 => "0001100000000000",		--	addl r0,0
		18 => "0001100000000000",		--	addl r0,0
		19 => "0110100000001010",		--	jmp 	wait_for_match
		20 => "0110100000010100",		--	jmp 	end


        others => "0000000000000000"
    );
    --signal prog_rom: prog_mem_t := HEXFILE;
begin
    
    uut: processor port map (
        temporary_processor_instr_input => instr_input,
        clk => clk,
        ext_rst => ext_rst,
        pc_out => pc
    );
    
    

    --10MHz
    clk_proc: process
    begin
        clk <= '1';
        instr_input <= prog_rom(to_integer(unsigned(pc)));
        wait for 50ns;
        clk <= '0';
        wait for 50ns;
    end process;
    
--    main_proc: process
--    begin
--        --ext_rst <= '0';
--        --wait for 360ns;
--        --ext_rst <= '1';
--        --wait for 20ns;

--        --let the program execute        
--        wait for 1000*1000ms;
        

--    end process;

end Behavioral;
