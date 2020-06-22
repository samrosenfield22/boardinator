library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;

entity prog_mem is
    Port ( we : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           in_data : in STD_LOGIC_VECTOR (7 downto 0);
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           region : in STD_LOGIC_VECTOR (1 downto 0);
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           prog_mem_out : out memarray_t);
end prog_mem;

architecture Behavioral of prog_mem is

--type memarray_t is array (1023 downto 0) of std_logic_vector(7 downto 0);
signal prog_mem: memarray_t := (others => "00000000");

signal full_addr: std_logic_vector(9 downto 0);

begin

    process(rst,clk)
    begin
        if(rst='0') then
            prog_mem <= (others => "00000000");
        elsif(we='1' and (clk'event and clk='1')) then
            --prog_mem(to_integer(unsigned(addr))) <= in_data;
            prog_mem(to_integer(unsigned(full_addr))) <= in_data;
        end if;
    end process;
    
    
    full_addr <= region & addr;
    out_data <= prog_mem(to_integer(unsigned(addr)));
    prog_mem_out <= prog_mem;
    
end Behavioral;
