

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
    			0 => "0000010000001010",		--	set r4,	10
		1 => "0000010110000100",		-- set r5,0x84	
		2 => "1010010001000101",		-- setm r4,r5,1,0	
		3 => "0000010000001100",		--	set r4,12
		4 => "0000010101010101",		-- set r5,0x55
		5 => "1010010001000101",		-- setm r4,r5,1,0
		6 => "0000010000001010",		--	set r4,10
		7 => "0000010110000101",		-- set r5,0x85	
		8 => "1010010001000101",		-- setm r4,r5,1,0	
		9 => "0000000100000001",		--	set 		r1,1
		10 => "0000010000001011",		--	set r4,11
		11 => "1010100001000100",		-- getm r0,r4,1,0
		12 => "0100100000000001",		--	and 		r0,r1
		13 => "0110000000000001",		--	cmpl		r0,1
		14 => "0111100000001010",		--	jeq			tx_pending
		15 => "0000010000100000",		--	set r4,0x20
		16 => "0000010111111111",		-- set r5,0xFF
		17 => "1010010001000101",		-- setm r4,r5,1,0
		18 => "0000010000100010",		--	set r4,0x22
		19 => "0000010111111111",		-- set r5,0xFF
		20 => "1010010001000101",		-- setm r4,r5,1,0
		21 => "0001100000000000",		--	addl r0,0
		22 => "0001100000000000",		--	addl r0,0
		23 => "0001100000000000",		--	addl r0,0
		24 => "0001100000000000",		--	addl r0,0
		25 => "0001100000000000",		--	addl r0,0
		26 => "0001100000000000",		--	addl r0,0
		27 => "0001100000000000",		--	addl r0,0
		28 => "0000010000001101",		--	set r4,13
		--29 => "1010101001000100",		-- getm r2,r4,1,0
		29 => "0111000000011101",		--	jmp			end

        
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
