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
		1 => "1000111000000001",		--	setstk r6,r1
		2 => "0001111000000001",		-- addl r6,1
		3 => "0000010100001011",		--	set 	r5,11
		4 => "1000111000000101",		--	setstk r6,r5
		5 => "0001111000000001",		-- addl r6,1
		6 => "0101100000001100",		--	jmp triangle_func
		7 => "0000010100000010",		--	set 	r5,2
		8 => "0010011000000101",		--	sub 	r6,r5
		9 => "1001110100000000",		--	getpcl	r5
		10 => "1010010000000000",		--	getpch	r4
		11 => "0101100000001011",		--	jmp end
		12 => "1000111000000111",		--	setstk r6,r7
		13 => "0001111000000001",		-- addl r6,1
		14 => "0000111100000110",		-- mov r7,r6
		15 => "0001111000000010",		--	addl r6,2
		16 => "0000010000000001",		--	set 	r4,1
		17 => "0001111100000001",		--	addl r7,	1
		18 => "1000111100000100",		-- setstk r7,r4
		19 => "0010111100000001",		-- subl r7,	1
		20 => "0000010000000000",		--	set 	r4,0
		21 => "0001111100000010",		--	addl r7,2
		22 => "1000111100000100",		-- setstk r7,r4
		23 => "0010111100000010",		-- subl r7,2
		24 => "0001111100000001",		--	addl r7,1
		25 => "1001001000000111",		-- getstk r2,r7
		26 => "0010111100000001",		-- subl r7,1
		27 => "0010111100000000",		--	subl r7,0
		28 => "0010111100000011",		-- subl r7,3
		29 => "1001001100000111",		-- getstk r3,r7
		30 => "0001111100000011",		-- addl r7,3
		31 => "0001111100000000",		-- addl r7,0
		32 => "0100101000000011",		--	cmp 	r2,r3
		33 => "0111000000101110",		--	jgt tri_exit
		34 => "0001111100000010",		--	addl r7,2
		35 => "1001010000000111",		-- getstk r4,r7
		36 => "0010111100000010",		-- subl r7,2
		37 => "0001010000000010",		--	add 	r4,r2
		38 => "0001111100000010",		--	addl r7,2
		39 => "1000111100000100",		-- setstk r7,r4
		40 => "0010111100000010",		-- subl r7,2
		41 => "0001101000000001",		--	addl	r2,1
		42 => "0001111100000001",		--	addl r7,1
		43 => "1000111100000010",		-- setstk r7,r2
		44 => "0010111100000001",		-- subl r7,1
		45 => "0101100000011000",		--	jmp tri_loop
		46 => "0001111100000010",		--	addl r7,2
		47 => "1001000000000111",		-- getstk r0,r7
		48 => "0010111100000010",		-- subl r7,2
		49 => "0000111000000111",		--	mov r6,r7
		50 => "0010111000000001",		-- subl r6,1
		51 => "0000011100000000",		-- set r7,r6
		52 => "0101100000000111",		--	jmp after_triangle

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
