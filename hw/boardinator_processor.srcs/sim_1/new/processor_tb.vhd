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
    			0 => "0000000000101010",		--	set 	r0,0x2A
		1 => "0000000111100001",		--	set 	r1,0xE1
		2 => "0000001010001000",		--	set 	r2,0x88
		3 => "0000001111111111",		--	set 	r3,0xFF
		4 => "1001111000000011",		--setstk r6,r3
		5 => "0001111000000001",		-- addl r6,1
		6 => "1001111000000010",		--setstk r6,r2
		7 => "0001111000000001",		-- addl r6,1
		8 => "1001111000000001",		--setstk r6,r1
		9 => "0001111000000001",		-- addl r6,1
		10 => "1001111000000000",		--setstk r6,r0
		11 => "0001111000000001",		-- addl r6,1
		12 => "1010110100000000",		--getpcl r5
		13 => "1011010000000000",		-- getpch r4
		14 => "0001110100001011",		--  addl r5,11
		15 => "1001000000010001",		-- jovf inc_upper
		16 => "0110100000010010",		--  jmp pushret
		17 => "0001110000000001",		-- addl r4,1
		18 => "1001111000000100",		--setstk r6,r4
		19 => "0001111000000001",		-- addl r6,1
		20 => "1001111000000101",		--setstk r6,r5
		21 => "0001111000000001",		-- addl r6,1
		22 => "0110100000100000",		-- jmp add16
		23 => "0010111000000110",		--	subl	r6,6
		24 => "0000000010000000",		--	set 	r0,0x80
		25 => "0000000100000000",		--	set 	r1,0
		26 => "0000001000000010",		--	set 	r2,2
		27 => "0101100000000001",		--	cmp 	r0,r1
		28 => "0111000000011111",		--	jeq		end
		29 => "0011100000000010",		--	lsr 	r0,r2
		30 => "0110100000011011",		--	jmp 	shift_r_loop
		31 => "0110100000011111",		--	jmp		end
		32 => "1001111000000111",		--setstk r6,r7
		33 => "0001111000000001",		-- addl r6,1
		34 => "0000111100000110",		-- mov r7,r6
		35 => "0010111100000000",		--subl r7,0	
		36 => "0010111100000100",		-- subl r7,4
		37 => "1010000000000111",		-- getstk r0,r7
		38 => "0001111100000100",		-- addl r7,4
		39 => "0001111100000000",		-- addl r7,0	
		40 => "0010111100000001",		--subl r7,1	
		41 => "0010111100000100",		-- subl r7,4
		42 => "1010000100000111",		-- getstk r1,r7
		43 => "0001111100000100",		-- addl r7,4
		44 => "0001111100000001",		-- addl r7,1	
		45 => "0010111100000011",		--subl r7,3	
		46 => "0010111100000100",		-- subl r7,4
		47 => "1010001000000111",		-- getstk r2,r7
		48 => "0001111100000100",		-- addl r7,4
		49 => "0001111100000011",		-- addl r7,3	
		50 => "0010111100000010",		--subl r7,2	
		51 => "0010111100000100",		-- subl r7,4
		52 => "1010001100000111",		-- getstk r3,r7
		53 => "0001111100000100",		-- addl r7,4
		54 => "0001111100000010",		-- addl r7,2	
		55 => "0001000100000010",		--	add 	r1,r2
		56 => "1001000000111010",		--	jovf	add16_lo_ovflw
		57 => "0110100000111110",		--	jmp 	add16_add_hi_bytes
		58 => "0001100000000001",		--	addl 	r0,1
		59 => "1001000000111101",		--	jovf	add16_hi_ovflw_1
		60 => "0110100000111110",		--	jmp 	add16_add_hi_bytes
		61 => "0000001000000001",		--	set 	r2,1
		62 => "0001000000000011",		--	add 	r0,r3
		63 => "1001000001000010",		--	jovf	add16_hi_ovflw_2
		64 => "0000001000000000",		--	set 	r2,0
		65 => "0110100001000011",		--	jmp 	add16_exit
		66 => "0000001000000001",		--	set 	r2,1
		67 => "0000111000000111",		--	mov r6,r7
		68 => "0010111000000001",		--subl r6,1
		69 => "1010011100000110",		-- getstk r7,r6
		70 => "0010111000000001",		--subl r6,1
		71 => "1010010100000110",		-- getstk r5,r6
		72 => "0010111000000001",		--subl r6,1
		73 => "1010010000000110",		-- getstk r4,r6
		74 => "1011110000000101",		-- setpc r4,r5
		75 => "1001111000000111",		--setstk r6,r7
		76 => "0001111000000001",		-- addl r6,1
		77 => "0000111100000110",		-- mov r7,r6
		78 => "0010111100000000",		--subl r7,0
		79 => "0010111100000100",		-- subl r7,4
		80 => "1010000000000111",		-- getstk r0,r7
		81 => "0001111100000100",		-- addl r7,4
		82 => "0001111100000000",		-- addl r7,0
		83 => "0010111100000001",		--subl r7,1
		84 => "0010111100000100",		-- subl r7,4
		85 => "1010000100000111",		-- getstk r1,r7
		86 => "0001111100000100",		-- addl r7,4
		87 => "0001111100000001",		-- addl r7,1
		88 => "0010111100000010",		--subl r7,2
		89 => "0010111100000100",		-- subl r7,4
		90 => "1010001000000111",		-- getstk r2,r7
		91 => "0001111100000100",		-- addl r7,4
		92 => "0001111100000010",		-- addl r7,2
		93 => "0000111000000111",		--	mov r6,r7
		94 => "0010111000000001",		--subl r6,1
		95 => "1010011100000110",		-- getstk r7,r6
		96 => "0010111000000001",		--subl r6,1
		97 => "1010010100000110",		-- getstk r5,r6
		98 => "0010111000000001",		--subl r6,1
		99 => "1010010000000110",		-- getstk r4,r6
		100 => "1011110000000101",		-- setpc r4,r5


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
