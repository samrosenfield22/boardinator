

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

    type prog_mem_t is array (90 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
		  		0 => "0000010000100000",		--	set r4,0x20
		1 => "0000010111111111",		-- set r5,0xFF		
		2 => "1010010001000101",		-- setm r4,r5,1,0		
		3 => "0000001011111111",		--	set 	r2,0xFF
		4 => "0000001111111010",		--	set 	r3,250
		5 => "1010011000001011",		--	setm r6,r3,0,1
		6 => "1011010100000000",		--	getpcl r5
		7 => "1011110000000000",		-- getpch r4
		8 => "0001110100001001",		--  addl r5,9
		9 => "1001100000001011",		-- jovf inc_upper_mangled_tempfile3.asm_35
		10 => "0111000000001100",		--  jmp pushret_mangled_tempfile3.asm_35
		11 => "0001110000000001",		-- addl r4,1
		12 => "1010011000001100",		-- setm r6,r4,0,1
		13 => "1010011000001101",		-- setm r6,r5,0,1
		14 => "0111000000101110",		-- jmp delay_ms
		15 => "1011010100000000",		--	getpcl r5
		16 => "1011110000000000",		-- getpch r4
		17 => "0001110100001001",		--  addl r5,9
		18 => "1001100000010100",		-- jovf inc_upper_mangled_tempfile3.asm_36
		19 => "0111000000010101",		--  jmp pushret_mangled_tempfile3.asm_36
		20 => "0001110000000001",		-- addl r4,1
		21 => "1010011000001100",		-- setm r6,r4,0,1
		22 => "1010011000001101",		-- setm r6,r5,0,1
		23 => "0111000000101110",		-- jmp 	delay_ms
		24 => "0010111000000001",		--	subl	r6,1
		25 => "0000000100100010",		--	set 	r1,0x22
		26 => "1010000101000010",		--	setm	r1,r2,1,0
		27 => "0000010011111111",		--	set 	r4,0xFF
		28 => "0100001000000100",		--	xor		r2,r4
		29 => "0111000000000100",		--	jmp		delay_loop_1
		30 => "0010111000000100",		--	subl 	r6,4
		31 => "1010110000000110",		--	getm 	r4,r6,0,0
		32 => "0000010100000011",		--	set 	r5,3
		33 => "1010010101000100",		--	setm	r5,r4,1,0		
		34 => "0001111000000001",		--	addl	r6,1
		35 => "1010110000000110",		--	getm 	r4,r6,0,0	
		36 => "0000010110000000",		--	set 	r5,0x80
		37 => "0101010000000101",		--	or		r4,r5
		38 => "0000010100000010",		--	set 	r5,2
		39 => "1010010101000100",		--	setm	r5,r4,1,0
		40 => "0001111000000011",		--	addl	r6,3
		41 => "0010111000000001",		--	subl r6,1
		42 => "1010110100000110",		-- getm r5,r6,0,0
		43 => "0010111000000001",		-- subl r6,1
		44 => "1010110000000110",		-- getm r4,r6,0,0
		45 => "1100010000000101",		-- setpc r4,r5
		46 => "1010011000001000",		--	setm r6,	r0,0,1
		47 => "1010011000001001",		--	setm r6,	r1,0,1
		48 => "0010111000000101",		--	subl		r6,5
		49 => "1010100000000110",		--	getm		r0,r6,0,0
		50 => "0001111000000101",		--	addl		r6,5
		51 => "0000010000000010",		--	set r4,2
		52 => "0000010100000000",		-- set r5,0x00		
		53 => "1010010001000101",		-- setm r4,r5,1,0		
		54 => "0000010000000011",		--	set r4,3
		55 => "0000010111000011",		-- set r5,195
		56 => "1010010001000101",		-- setm r4,r5,1,0
		57 => "0000010000000010",		--	set r4,2
		58 => "0000010110000011",		-- set r5,0x83
		59 => "1010010001000101",		-- setm r4,r5,1,0
		60 => "0000010000000101",		--	set 		r4,5
		61 => "0111000001001001",		--	jmp			delay_ms_cond
		62 => "1010100101000100",		--	getm		r1,r4,1,0
		63 => "0000010100000001",		--	set 		r5,1
		64 => "0100100100000101",		--	and			r1,r5
		65 => "0110000100000001",		--	cmpl 		r1,1
		66 => "1000000000111110",		--	jne			delay_ms_loop
		67 => "1010100101000100",		--	getm		r1,r4,1,0
		68 => "0000010100000001",		--	set 		r5,1
		69 => "0100100100000101",		--	and			r1,r5
		70 => "0110000100000001",		--	cmpl 		r1,1
		71 => "0111100001000011",		--	jeq			delay_ms_wait_til_lo
		72 => "0010100000000001",		--	subl		r0,1
		73 => "0110000000000000",		--	cmpl		r0,0
		74 => "1000000000111110",		--	jne			delay_ms_loop
		75 => "0010111000000001",		--	subl r6,1
		76 => "1010100100000110",		-- getm 		r1,r6,0,0
		77 => "0010111000000001",		--	subl r6,1
		78 => "1010100000000110",		-- getm 		r0,r6,0,0
		79 => "0010111000000001",		--	subl r6,1
		80 => "1010110100000110",		-- getm r5,r6,0,0
		81 => "0010111000000001",		-- subl r6,1
		82 => "1010110000000110",		-- getm r4,r6,0,0
		83 => "1100010000000101",		-- setpc r4,r5

        
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
