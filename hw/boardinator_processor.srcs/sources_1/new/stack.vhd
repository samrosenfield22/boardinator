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
           
           rstcause_sfr, tmrout_sfr, ina_sfr, inb_sfr: in STD_LOGIC_VECTOR (7 downto 0);
           
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           prog_mem_out : out memarray_t);
end prog_mem;

architecture Behavioral of prog_mem is

--type memarray_t is array (1023 downto 0) of std_logic_vector(7 downto 0);
signal prog_mem: memarray_t := (others => "00000000");

signal full_addr: std_logic_vector(9 downto 0);
signal full_addr_num: integer range 0 to 512;
--signal addr_sfr: integer range 0 to (1023 + 512);

begin

    process(rst,clk)
    begin
        if(rst='0') then
            prog_mem <= (others => "00000000");
        elsif(clk'event and clk='1') then
            if(we='1') then
                if( full_addr_num /= RSTCAUSE and
                    full_addr_num /= TMROUT and
                    full_addr_num /= INA and
                    full_addr_num /= INB
                    --full_addr_num /= INA and
                    ) then
                    prog_mem(full_addr_num) <= in_data;
                end if;
            
                
            end if;
            
            --set SFRs that are written to by peripherals
            prog_mem(RSTCAUSE + SFR_REGION_ADDR) <= rstcause_sfr;
            prog_mem(TMROUT + SFR_REGION_ADDR) <= tmrout_sfr;
            prog_mem(INA + SFR_REGION_ADDR) <= ina_sfr;
            prog_mem(INB + SFR_REGION_ADDR) <= inb_sfr;
        end if;
    end process;
    
    
    
    
    full_addr <= region & addr;
    full_addr_num <= to_integer(unsigned(full_addr));
    --addr_sfr <= full_addr_num + SFR_REGION_ADDR;
    
    out_data <= prog_mem(to_integer(unsigned(full_addr)));
    prog_mem_out <= prog_mem;
    
end Behavioral;
