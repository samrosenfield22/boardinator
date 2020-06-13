----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 10:45:36 AM
-- Design Name: 
-- Module Name: alu_tb - Behavioral
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

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
    component alu
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           op : in STD_LOGIC_VECTOR (4 downto 0);
           y : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR (1 downto 0));
    end component;
    
    signal a : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal b : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal op : STD_LOGIC_VECTOR (4 downto 0) := "00000";
    signal y : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal flags : STD_LOGIC_VECTOR (1 downto 0) := "00";
    
    constant tdelay: time := 100ns;
    
begin

    uut: alu port map (
        a => a,
        b => b,
        op => op,
        y => y,
        flags => flags
    );
    
    main_proc: process
    begin
    
        a <= "00010111";
        b <= "01000010";
        
        op <= "00000";
        wait for tdelay;
        
        op <= "00001";
        wait for tdelay;
        
        op <= "00010";
        wait for tdelay;
        
        op <= "00011";
        wait for tdelay;
        
        op <= "00100";
        wait for tdelay;
        
        --compare
        op <= "00101";
        wait for tdelay;
        a <= "01000010";
        wait for tdelay;
        b <= "00000001";
        wait for tdelay;
    
    end process;
    

end Behavioral;
