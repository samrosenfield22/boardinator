----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 10:33:13 AM
-- Design Name: 
-- Module Name: prog_rom - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity prog_rom is
    Port (  r_addr: in STD_LOGIC_VECTOR(9 downto 0);
            clk: in STD_LOGIC;
            
            instr_out: out STD_LOGIC_VECTOR(15 downto 0)
         );
end prog_rom;

architecture Behavioral of prog_rom is

type prog_mem_t is array (9 downto 0) of std_logic_vector(15 downto 0);
signal prog_mem: prog_mem_t;

begin

--    process(clk)
--    begin
--        if(clk'event and clk='1') then
--            instr_out <= 
--        end if;
--    end process;


end Behavioral;
