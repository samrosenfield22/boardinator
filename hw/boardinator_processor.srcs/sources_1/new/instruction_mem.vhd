

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
    			0 => "0000010000100000",		--	set r4,0x20
		1 => "0000010111111111",		-- set r5,0xFF	
		2 => "1010010001000101",		-- setm r4,r5,1,0	
		3 => "0000010000100011",		--	set r4,0x23
		4 => "0000010100000000",		-- set r5,0x00	
		5 => "1010010001000101",		-- setm r4,r5,1,0	
		6 => "0000010000100010",		--	set r4,0x22
		7 => "0000010100000000",		-- set r5,0x00
		8 => "1010010001000101",		-- setm r4,r5,1,0
		9 => "0000001100000111",		--	set 		r3,0x07		
		10 => "0000010000100100",		--	set r4,0x24
		11 => "1010100001000100",		-- getm r0,r4,1,0
		12 => "0110100000000000",		--	not			r0
		13 => "0100100000000011",		--	and 		r0,r3
		14 => "0000010100000001",		--	set 		r5,1
		15 => "0011010100000000",		--	lsl 		r5,r0
		16 => "0000010000100010",		--	set 		r4,0x22
		17 => "1010010001000101",		--	setm		r4,r5,1,0
		18 => "0111000000001010",		--	jmp			loop

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
