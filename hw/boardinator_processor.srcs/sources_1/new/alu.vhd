----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 10:33:13 AM
-- Design Name: 
-- Module Name: alu - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           op : in STD_LOGIC_VECTOR (4 downto 0);
           y : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR (1 downto 0));
end alu;

architecture Behavioral of alu is
    signal mux_out:     std_logic_vector(7 downto 0) := (others => '0');
    
    signal adder_out:   std_logic_vector(7 downto 0);
    signal subt_out:    std_logic_vector(7 downto 0);
    signal xor_out:     std_logic_vector(7 downto 0);
    signal and_out:     std_logic_vector(7 downto 0);
    signal or_out:     std_logic_vector(7 downto 0);
    
    signal flags_int:   std_logic_vector(1 downto 0) := (others => '0');
    --etc
begin
    mux_out <=  b when op="00001" else              --mov
                adder_out when op="00010" else      --add
                subt_out when op="00011" else       --sub
                xor_out when op="00100" else        --xor
                and_out when op="00101" else        --and
                or_out when op="00110" else         --or
                "00000000" when op="00111" else     --cmp (only sets flags)
                "00000000";

    adder_out <= std_logic_vector(unsigned(a) + unsigned(b));
    subt_out <= std_logic_vector(unsigned(a) - unsigned(b));
    xor_out <= a XOR b;
    and_out <= a AND b;
    or_out <= a OR b;
    
    --flags
    process(a,b,op)
    begin
        if(op = "00111") then   --cmp
            if(a=b) then
                flags_int(0) <= '1';
            else
                flags_int(0) <= '0';
            end if;
            
            if(a>b) then
                flags_int(1) <= '1';
            else
                flags_int(1) <= '0';
            end if;
            
            --flags <= flags_int;
        end if;
    end process;
    
    --
    y <= mux_out;
    flags <= flags_int;
    

end Behavioral;
