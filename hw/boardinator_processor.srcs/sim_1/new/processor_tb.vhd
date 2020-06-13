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
    		0 => "0000001000000010",		--	set		r2,2
		1 => "0000010000000001",		--	set		r4,1
		2 => "0101100000001000",		--	jmp check_prime_sub
		3 => "0011100100000100",		--	cmp 	r1,r4
		4 => "0110100000000110",		--	jne		main_incr
		5 => "0000100000000010",		--	mov		r0,r2	
		6 => "0001001000000100",		--	add		r2,r4
		7 => "0101100000000010",		--	jmp		main_loop
		8 => "0000011100000010",		--	set		r7,2
		9 => "0000011000000001",		--	set		r6,1
		10 => "0011111100000010",		--	cmp		r7,r2
		11 => "0110000000010111",		--	jeq		is_prime	
		12 => "0111000000010111",		--	jgt		is_prime
		13 => "0000101100000010",		--	mov		r3,r2
		14 => "0011101100000111",		--	cmp		r3,r7
		15 => "0110000000010101",		--	jeq		not_prime	
		16 => "0111100000010011",		--	jlt		prime_incr	
		17 => "0001101100000111",		--	sub		r3,r7
		18 => "0101100000001110",		--	jmp		mod_loop
		19 => "0001011100000110",		--	add		r7,r6
		20 => "0101100000001010",		--	jmp		prime_loop
		21 => "0000000100000000",		--	set		r1,0
		22 => "0101100000000011",		--	jmp		after_sub_call
		23 => "0000000100000001",		--	set		r1,1
		24 => "0101100000000011",		--	jmp after_sub_call

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
