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
		1 => "1000011000000001",		--setstk	r6,r1
		2 => "0001111000000001",		--addl	r6,1
		3 => "0000010100001011",		--	set 	r5,11
		4 => "1000011000000101",		--setstk	r6,r5
		5 => "0001111000000001",		--addl	r6,1
		6 => "0101100000001010",		--	jmp triangle_func
		7 => "0000010100000010",		--	set 	r5,2
		8 => "0010011000000101",		--	sub 	r6,r5
		9 => "0101100000001001",		--	jmp end
		10 => "1000011000000111",		--setstk	r6,r7
		11 => "0001111000000001",		--addl	r6,1
		12 => "0000111100000110",		--mov	r7,r6
		13 => "0001111000000010",		--addl	r6,2
		14 => "0000010000000001",		--	set 	r4,1
		15 => "0001111100000001",		--addl	r7,1
		16 => "1000011100000100",		--setstk	r7,r4
		17 => "0010111100000001",		--subl	r7,1
		18 => "0000010000000000",		--	set 	r4,0
		19 => "0001111100000010",		--addl	r7,2
		20 => "1000011100000100",		--setstk	r7,r4
		21 => "0010111100000010",		--subl	r7,2
		22 => "0001111100000001",		--addl	r7,1
		23 => "1000101000000111",		--getstk	r2,r7
		24 => "0010111100000001",		--subl	r7,1
		25 => "0010111100000011",		--subl	r7,3
		26 => "1000101100000111",		--getstk	r3,r7
		27 => "0001111100000011",		--addl	r7,3
		28 => "0100101000000011",		--	cmp 	r2,r3
		29 => "0111000000101010",		--	jgt tri_exit
		30 => "0001111100000010",		--addl	r7,2
		31 => "1000110000000111",		--getstk	r4,r7
		32 => "0010111100000010",		--subl	r7,2
		33 => "0001010000000010",		--	add 	r4,r2
		34 => "0001111100000010",		--addl	r7,2
		35 => "1000011100000100",		--setstk	r7,r4
		36 => "0010111100000010",		--subl	r7,2
		37 => "0001101000000001",		--	addl	r2,1
		38 => "0001111100000001",		--addl	r7,1
		39 => "1000011100000010",		--setstk	r7,r2
		40 => "0010111100000001",		--subl	r7,1
		41 => "0101100000010110",		--	jmp tri_loop
		42 => "0001111100000010",		--addl	r7,2
		43 => "1000100000000111",		--getstk	r0,r7
		44 => "0010111100000010",		--subl	r7,2
		45 => "0000111000000111",		--mov	r6,r7
		46 => "0010111000000001",		--subl	r6,1
		47 => "0000011100000000",		--set	r7,r6
		48 => "0101100000000111",		--	jmp after_triangle

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
