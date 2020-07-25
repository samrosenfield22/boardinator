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
           
           rstcause_sfr, tmrout_sfr, tmrstat_sfr, ina_sfr, inb_sfr,
           uartstat_sfr, rx_byte_sfr:
            in STD_LOGIC_VECTOR (7 downto 0);
           
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           prog_mem_out : out memarray_t;
           
           rxreg_read_sig : out STD_LOGIC
           );
end prog_mem;

architecture Behavioral of prog_mem is

signal prog_mem: memarray_t := (others => "00000000");
signal addr_intgr, full_addr: integer range 0 to PROC_MEMORY_END;

begin

    process(rst,clk)
    begin
        if(rst='0') then
            prog_mem <= (others => "00000000");
        elsif(clk'event and clk='1') then
            if(we='1') then
                if((unsigned(region) /= SFR_REGION) or
                   (addr_intgr /= RSTCAUSE and
                    addr_intgr /= TMROUT and
                    addr_intgr /= TMRSTAT and
                    addr_intgr /= INA and
                    addr_intgr /= INB and
                    addr_intgr /= UARTSTAT and
                    addr_intgr /= RXREG
                    )) then
                    prog_mem(full_addr) <= in_data;
                end if;
            
                
            end if;
            
            --set SFRs that are written to by peripherals
            prog_mem(RSTCAUSE + SFR_REGION_ADDR) <= rstcause_sfr;
            prog_mem(TMROUT + SFR_REGION_ADDR) <= tmrout_sfr;
            prog_mem(TMRSTAT + SFR_REGION_ADDR) <= tmrstat_sfr;
            prog_mem(INA + SFR_REGION_ADDR) <= ina_sfr;
            prog_mem(INB + SFR_REGION_ADDR) <= inb_sfr;
            prog_mem(UARTSTAT + SFR_REGION_ADDR) <= uartstat_sfr;
            prog_mem(RXREG + SFR_REGION_ADDR) <= rx_byte_sfr;
        end if;
    end process;
    
    
    addr_intgr <= to_integer(unsigned(addr));
    
    --full_addr <= region & addr;
    full_addr <= addr_intgr when (unsigned(region)=STACK_REGION) else
    addr_intgr + SFR_REGION_ADDR;
    
    --if we read from certain registers, do thing
    --ok this would need to send a signal back to i.e. the uart module
    process(we, region, addr_intgr)
        variable reading_rxreg: std_logic;
    begin
        reading_rxreg := '0';
        
        if(we='0' and unsigned(region)=SFR_REGION) then
            if(addr_intgr = RXREG) then
                reading_rxreg := '1';
            end if;
        end if;
        
        rxreg_read_sig <= reading_rxreg;
    end process;
    
    
    out_data <= prog_mem(full_addr) when full_addr<=PROC_MEMORY_END else
                (others => '0');
    prog_mem_out <= prog_mem;
    
end Behavioral;
