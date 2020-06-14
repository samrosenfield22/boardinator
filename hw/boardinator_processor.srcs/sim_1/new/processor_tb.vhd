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
		1 => "0000011000000000",		--	set 	r6,0	
		2 => "0000011100000000",		--	set 	r7,0	
		3 => "1000011000000001",		--	setstk	r6,r1
		4 => "0000010100000001",		--	set 	r5,1
		5 => "0001011000000101",		--	add 	r6,r5
		6 => "0000010100001010",		--	set 	r5,10
		7 => "1000011000000101",		--	setstk	r6,r5		
		8 => "0000010100000001",		--	set 	r5,1
		9 => "0001011000000101",		--	add 	r6,r5
		10 => "0101100000001110",		--	jmp triangle_func
		11 => "0000010100000010",		--	set 	r5,2
		12 => "0001111000000101",		--	sub 	r6,r5
		13 => "0101100000001101",		--	jmp end
		14 => "1000011000000111",		--	setstk	r6,r7
		15 => "0000010100000001",		--	set 	r5,1
		16 => "0001011000000101",		--	add 	r6,r5
		17 => "0000111100000110",		--	mov 	r7,r6
		18 => "0000010100000010",		--	set 	r5,2
		19 => "0001011000000101",		--	add 	r6,r5
		20 => "0000010000000001",		--	set 	r4,1	
		21 => "0000110100000111",		--	mov		r5,r7
		22 => "0000000000000001",		--	set 	r0,1
		23 => "0001010100000000",		--	add 	r5,r0	
		24 => "1000010100000100",		--	setstk 	r5,r4
		25 => "0000010000000000",		--	set 	r4,0	
		26 => "0000110100000111",		--	mov		r5,r7
		27 => "0000000000000010",		--	set 	r0,2
		28 => "0001010100000000",		--	add 	r5,r0	
		29 => "1000010100000100",		--	setstk 	r5,r4	
		30 => "0000110100000111",		--	mov 	r5,r7
		31 => "0000000000000001",		--	set 	r0,1
		32 => "0001010100000000",		--	add 	r5,r0
		33 => "1000101000000101",		--	getstk 	r2,r5	
		34 => "0000110100000111",		--	mov 	r5,r7
		35 => "0000000000000011",		--	set 	r0,3
		36 => "0001110100000000",		--	sub 	r5,r0							
		37 => "1000101100000101",		--	getstk 	r3,r5	
		38 => "0011101000000011",		--	cmp 	r2,r3
		39 => "0111000000111000",		--	jgt tri_exit
		40 => "0000110100000111",		--	mov 	r5,r7
		41 => "0000000000000010",		--	set 	r0,2
		42 => "0001010100000000",		--	add 	r5,r0
		43 => "1000110000000101",		--	getstk 	r4,r5	
		44 => "0001010000000010",		--	add 	r4,r2
		45 => "0000110100000111",		--	mov 	r5,r7
		46 => "0000000000000010",		--	set 	r0,2
		47 => "0001010100000000",		--	add 	r5,r0
		48 => "1000010100000100",		--	setstk	r5,r4	
		49 => "0000000100000001",		--	set 	r1,1
		50 => "0001001000000001",		--	add 	r2,r1
		51 => "0000110100000111",		--	mov 	r5,r7
		52 => "0000000000000001",		--	set 	r0,1
		53 => "0001010100000000",		--	add 	r5,r0
		54 => "1000010100000010",		--	setstk	r5,r2	
		55 => "0101100000011110",		--	jmp tri_loop
		56 => "0000110100000111",		--	mov 	r5,r7
		57 => "0000000000000010",		--	set 	r0,2
		58 => "0001010100000000",		--	add 	r5,r0
		59 => "1000100000000101",		--	getstk 	r0,r5	
		60 => "0000011000000000",		--	set 	r6,r7
		61 => "0000010100000001",		--	set		r5,1
		62 => "0001111000000101",		--	sub		r6,r5
		63 => "1000111100000110",		--	getstk	r7,r6
		64 => "0101100000001011",		--	jmp after_triangle

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
