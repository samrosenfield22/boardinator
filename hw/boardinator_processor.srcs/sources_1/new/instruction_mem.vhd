

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity instruction_mem is
    Port ( clk : in STD_LOGIC;
           pc : in STD_LOGIC_VECTOR (9 downto 0);
           instr : out STD_LOGIC_VECTOR (15 downto 0));
end instruction_mem;

architecture Behavioral of instruction_mem is

    type prog_mem_t is array (999 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
    			0 => "0000000010000110",		--	set 	r0,134
		1 => "1010011000001000",		--	setm r6,r0,0,1
		2 => "0000000000001101",		--	set 	r0,13
		3 => "1010011000001000",		--	setm r6,	r0,0,1
		4 => "1011010100000000",		--	getpcl r5
		5 => "1011110000000000",		-- getpch r4
		6 => "0001110100001001",		--  addl r5,9
		7 => "1001100000001001",		-- jovf inc_upper_mangled_tempfile3.asm_12
		8 => "0111000000001010",		--  jmp pushret_mangled_tempfile3.asm_12
		9 => "0001110000000001",		-- addl r4,1
		10 => "1010011000001100",		-- setm r6,r4,0,1
		11 => "1010011000001101",		-- setm r6,r5,0,1
		12 => "0111000000100010",		-- jmp init_timer
		13 => "0010111000000010",		--	subl	r6,2
		14 => "0000000001000000",		--	set 	r0,0x40
		15 => "0000000111111111",		--	set 	r1,0xFF
		16 => "1010000010000001",		--	setm	r0,r1,2,0
		17 => "0000000000000101",		--	set 	r0,5
		18 => "0000001100000001",		--	set 	r3,0x01
		19 => "0000000100000100",		--	set 	r1,4
		20 => "1010101010000001",		--	getm	r2,r1,2,0
		21 => "0100101000000011",		--	and 	r2,r3
		22 => "0110001000000001",		--	cmpl 	r2,1	
		23 => "1000000000010011",		--	jne 	wait_for_match_hi
		24 => "0000000100000100",		--	set 	r1,4
		25 => "1010101010000001",		--	getm	r2,r1,2,0
		26 => "0100101000000011",		--	and 	r2,r3
		27 => "0110001000000000",		--	cmpl 	r2,0	
		28 => "1000000000011000",		--	jne 	wait_for_match_lo
		29 => "0001100000000001",		--	addl 	r0,1
		30 => "0000000101000010",		--	set 	r1,0x42
		31 => "1010000110000000",		--	setm	r1,r0,2,0
		32 => "0111000000010011",		--	jmp 	delay_loop
		33 => "0111000000100001",		--	jmp 	end
		34 => "0010111000000100",		--	subl 	r6,4
		35 => "1010110000000110",		--	getm 	r4,r6,0,0
		36 => "0000010100000011",		--	set 	r5,3
		37 => "1010010110000100",		--	setm	r5,r4,2,0		
		38 => "0001111000000001",		--	addl	r6,1
		39 => "1010110000000110",		--	getm 	r4,r6,0,0	
		40 => "0000010110000000",		--	set 	r5,0x80
		41 => "0101010000000101",		--	or		r4,r5
		42 => "0000010100000010",		--	set 	r5,2
		43 => "1010010110000100",		--	setm	r5,r4,2,0
		44 => "0001111000000011",		--	addl	r6,3
		45 => "0010111000000001",		--	subl r6,1
		46 => "1010110100000110",		-- getm r5,r6,0,0
		47 => "0010111000000001",		-- subl r6,1
		48 => "1010110000000110",		-- getm r4,r6,0,0
		49 => "1100010000000101",		-- setpc r4,r5
		50 => "0010111000000001",		--	subl r6,1
		51 => "1010110100000110",		-- getm r5,r6,0,0
		52 => "0010111000000001",		-- subl r6,1
		53 => "1010110000000110",		-- getm r4,r6,0,0
		54 => "1100010000000101",		-- setpc r4,r5


        others => "0000000000000000"
    );

begin
    process(clk)
    begin
        if(clk'event and clk='1') then
            instr <= prog_rom(to_integer(unsigned(pc)));
        end if;
    end process;
end Behavioral;
