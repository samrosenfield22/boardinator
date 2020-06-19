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
    			0 => "0000000100000110",		--	set		r1,6
		1 => "1000111000000001",		--setstk r6,r1
		2 => "0001111000000001",		-- addl r6,1
		3 => "1001110100000000",		--getpcl r5
		4 => "1010010000000000",		-- getpch r4
		5 => "0001110100001011",		--  addl r5,11
		6 => "1000000000001000",		-- jovf inc_upper
		7 => "0101100000001001",		--  jmp pushret
		8 => "0001110000000001",		-- addl r4,1
		9 => "1000111000000100",		--setstk r6,r4
		10 => "0001111000000001",		-- addl r6,1
		11 => "1000111000000101",		--setstk r6,r5
		12 => "0001111000000001",		-- addl r6,1
		13 => "0101100000010010",		-- jmp triangle_func
		14 => "0010111000000011",		--	subl	r6,3	
		15 => "1001110100000000",		--	getpcl	r5
		16 => "1010010000000000",		--	getpch	r4
		17 => "0101100000010001",		--	jmp end
		18 => "1000111000000111",		--setstk r6,r7
		19 => "0001111000000001",		-- addl r6,1
		20 => "0000111100000110",		-- mov r7,r6
		21 => "0001111000000010",		--addl r6,2
		22 => "0000010000000001",		--	set 	r4,1
		23 => "0001111100000001",		--addl r7,	1
		24 => "1000111100000100",		-- setstk r7,r4
		25 => "0010111100000001",		-- subl r7,	1
		26 => "0000010000000000",		--	set 	r4,0
		27 => "0001111100000010",		--addl r7,2
		28 => "1000111100000100",		-- setstk r7,r4
		29 => "0010111100000010",		-- subl r7,2
		30 => "0001111100000001",		--addl r7,1
		31 => "1001001000000111",		-- getstk r2,r7
		32 => "0010111100000001",		-- subl r7,1
		33 => "0010111100000000",		--subl r7,0
		34 => "0010111100000100",		-- subl r7,4
		35 => "1001001100000111",		-- getstk r3,r7
		36 => "0001111100000100",		-- addl r7,4
		37 => "0001111100000000",		-- addl r7,0
		38 => "0100101000000011",		--	cmp 	r2,r3
		39 => "0111000000110100",		--	jgt tri_exit
		40 => "0001111100000010",		--addl r7,2
		41 => "1001010000000111",		-- getstk r4,r7
		42 => "0010111100000010",		-- subl r7,2
		43 => "0001010000000010",		--	add 	r4,r2
		44 => "0001111100000010",		--addl r7,2
		45 => "1000111100000100",		-- setstk r7,r4
		46 => "0010111100000010",		-- subl r7,2
		47 => "0001101000000001",		--	addl	r2,1
		48 => "0001111100000001",		--addl r7,1
		49 => "1000111100000010",		-- setstk r7,r2
		50 => "0010111100000001",		-- subl r7,1
		51 => "0101100000011110",		--	jmp tri_loop
		52 => "0001111100000010",		--addl r7,2
		53 => "1001000000000111",		-- getstk r0,r7
		54 => "0010111100000010",		-- subl r7,2
		55 => "0000111000000111",		--	mov r6,r7
		56 => "0010111000000001",		--subl r6,1
		57 => "1001011100000110",		-- getstk r7,r6
		58 => "0101100000001110",		--	jmp after_triangle

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
