

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
    			0 => "0000000000000101",		--	set 	r0,5
		1 => "0000000100001100",		--	set 	r1,12
		2 => "0001000000000001",		--	add 	r0,r1
		3 => "0111000000000011",		--	jmp end


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
