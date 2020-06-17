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
    			0 => "0000001001100100",		--	set 	r2,100
		1 => "0000001110011011",		--	set		r3,155
		2 => "0001001000000011",		--	add 	r2,r3
		3 => "1000000000001101",		--	jovf shouldnt_happen
		4 => "0001101010100000",		--	addl	r2,160
		5 => "1000000000001111",		--	jovf should_happen
		6 => "0001101100110010",		--	addl	r3,50
		7 => "0010001000000011",		--	sub		r2,r3
		8 => "1000000000010001",		--	jovf	should_also_happen
		9 => "0000001000010100",		--	set		r2,20
		10 => "0010101000010100",		--	subl	r2,20
		11 => "1000000000010011",		--	jovf	nope
		12 => "0101100000001100",		--	jmp end
		13 => "0000000000000001",		--	set		r0,1
		14 => "0101100000000100",		--	jmp		ct1
		15 => "0000000000010000",		--	set		r0,16
		16 => "0101100000000110",		--	jmp 	ct2
		17 => "0000000000100000",		--	set		r0,32
		18 => "0101100000001001",		--	jmp		ct3
		19 => "0000000000000010",		--	set		r0,2
		20 => "0101100000001100",		--	jmp		end

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
