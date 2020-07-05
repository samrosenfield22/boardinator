

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

    type prog_mem_t is array (99 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
    			0 => "0000000011111111",		--	set		r0,0xFF
		1 => "1010011000001000",		--	setm r6,r0,0,1
		2 => "0000000000000000",		--	set		r0,0
		3 => "1010011000001000",		--	setm r6,r0,0,1
		4 => "1011010100000000",		--	getpcl r5
		5 => "1011110000000000",		-- getpch r4
		6 => "0001110100001001",		--  addl r5,9
		7 => "1001100000001001",		-- jovf inc_upper_mangled_tempfile3.asm_12
		8 => "0111000000001010",		--  jmp pushret_mangled_tempfile3.asm_12
		9 => "0001110000000001",		-- addl r4,1
		10 => "1010011000001100",		-- setm r6,r4,0,1
		11 => "1010011000001101",		-- setm r6,r5,0,1
		12 => "0111000000011101",		-- jmp port_mode
		13 => "0010111000000010",		--	subl	r6,2
		14 => "0000000001010101",		--	set		r0,0x55
		15 => "1010011000001000",		--	setm r6,r0,0,1
		16 => "0000000000000000",		--	set		r0,0
		17 => "1010011000001000",		--	setm r6,r0,0,1
		18 => "1011010100000000",		--	getpcl r5
		19 => "1011110000000000",		-- getpch r4
		20 => "0001110100001001",		--  addl r5,9
		21 => "1001100000010111",		-- jovf inc_upper_mangled_tempfile3.asm_20
		22 => "0111000000011000",		--  jmp pushret_mangled_tempfile3.asm_20
		23 => "0001110000000001",		-- addl r4,1
		24 => "1010011000001100",		-- setm r6,r4,0,1
		25 => "1010011000001101",		-- setm r6,r5,0,1
		26 => "0111000000101110",		-- jmp write_port
		27 => "0010111000000010",		--	subl	r6,2
		28 => "0111000000011100",		--	jmp end
		29 => "0010111000000011",		--	subl	r6,3
		30 => "1010110100000110",		--	getm	r5,r6,0,0
		31 => "0000010000100000",		--	set 	r4,0x20
		32 => "0110010100000000",		--	cmpl	r5,0
		33 => "0111100000100101",		--	jeq		port_mode_got_offset
		34 => "0001110000000011",		--	addl	r4,3
		35 => "0010110100000001",		--	subl	r5,1
		36 => "0111000000100000",		--	jmp		port_mode_offset_loop
		37 => "0010111000000001",		--	subl	r6,1
		38 => "1010110100000110",		--	getm	r5,r6,0,0
		39 => "0001111000000100",		--	addl	r6,4
		40 => "1010010001000101",		--	setm	r4,r5,1,0
		41 => "0010111000000001",		--	subl r6,1
		42 => "1010110100000110",		-- getm r5,r6,0,0
		43 => "0010111000000001",		-- subl r6,1
		44 => "1010110000000110",		-- getm r4,r6,0,0
		45 => "1100010000000101",		-- setpc r4,r5
		46 => "0010111000000011",		--	subl	r6,3
		47 => "1010110100000110",		--	getm	r5,r6,0,0
		48 => "0000010000100010",		--	set 	r4,0x22
		49 => "0110010100000000",		--	cmpl	r5,0
		50 => "0111100000110110",		--	jeq		write_port_got_offset
		51 => "0001110000000011",		--	addl	r4,3
		52 => "0010110100000001",		--	subl	r5,1
		53 => "0111000000110001",		--	jmp		write_port_offset_loop
		54 => "0010111000000001",		--	subl	r6,1
		55 => "1010110100000110",		--	getm	r5,r6,0,0
		56 => "0001111000000100",		--	addl	r6,4
		57 => "1010010001000101",		--	setm	r4,r5,1,0
		58 => "0010111000000001",		--	subl r6,1
		59 => "1010110100000110",		-- getm r5,r6,0,0
		60 => "0010111000000001",		-- subl r6,1
		61 => "1010110000000110",		-- getm r4,r6,0,0
		62 => "1100010000000101",		-- setpc r4,r5
		63 => "0010111000000011",		--	subl	r6,3
		64 => "1010110100000110",		--	getm	r5,r6,0,0
		65 => "0000010000100001",		--	set 	r4,0x21
		66 => "0110010100000000",		--	cmpl	r5,0
		67 => "0111100001000111",		--	jeq		read_port_got_offset
		68 => "0001110000000011",		--	addl	r4,3
		69 => "0010110100000001",		--	subl	r5,1
		70 => "0111000001000010",		--	jmp		read_port_offset_loop
		71 => "0001111000000011",		--	addl	r6,3
		72 => "1010100001000100",		--	getm	r0,r4,1,0
		73 => "0010111000000001",		--	subl r6,1
		74 => "1010110100000110",		-- getm r5,r6,0,0
		75 => "0010111000000001",		-- subl r6,1
		76 => "1010110000000110",		-- getm r4,r6,0,0
		77 => "1100010000000101",		-- setpc r4,r5


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
