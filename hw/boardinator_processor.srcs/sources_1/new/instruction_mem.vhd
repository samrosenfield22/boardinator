

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

    type prog_mem_t is array (40 downto 0) of std_logic_vector(15 downto 0);
    signal prog_rom: prog_mem_t :=
    (    
    			0 => "0000000100100000",		--	set		r1,0x20
		1 => "0000001011111111",		--	set		r2,0xFF
		2 => "1010000101000010",		--	setm	r1,r2,1,0
		3 => "0000000100000011",		--	set 	r1,3
		4 => "0000001010111111",		--	set 	r2,191
		5 => "1010000101000010",		--	setm	r1,r2,1,0
		6 => "0000000100000010",		--	set 	r1,2
		7 => "0000001010001101",		--	set 	r2,0x8D		
		8 => "1010000101000010",		--	setm	r1,r2,1,0
		9 => "0000001011111111",		--	set 	r2,0xFF
		10 => "0000000100000100",		--	set 	r1,4
		11 => "1010100001000001",		--	getm 	r0,r1,1,0
		12 => "0000001100000001",		--	set 	r3,1
		13 => "0100100000000011",		--	and 	r0,r3
		14 => "0110000000000001",		--	cmpl 	r0,1
		15 => "1000000000001010",		--	jne		delay_loop_1
		16 => "1010100001000001",		--	getm 	r0,r1,1,0
		17 => "0100100000000011",		--	and 	r0,r3
		18 => "0110000000000000",		--	cmpl 	r0,0
		19 => "1000000000010000",		--	jne		delay_loop_2
		20 => "0000000100100010",		--	set 	r1,0x22
		21 => "1010000101000010",		--	setm	r1,r2,1,0
		22 => "0110001000000000",		--	cmpl	r2,0
		23 => "1000000000011010",		--	jne		set_r2_hi
		24 => "0000001011111111",		--	set 	r2,0xFF
		25 => "0111000000001010",		--	jmp 	delay_loop_1
		26 => "0000001000000000",		--	set 	r2,0
		27 => "0111000000001010",		--	jmp 	delay_loop_1


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
