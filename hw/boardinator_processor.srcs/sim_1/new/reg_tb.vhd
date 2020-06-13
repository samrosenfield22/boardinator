----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 12:48:19 PM
-- Design Name: 
-- Module Name: reg_tb - Behavioral
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

entity reg_tb is
--  Port ( );
end reg_tb;

architecture Behavioral of reg_tb is
    component reg
    Port ( d : in STD_LOGIC_VECTOR (7 downto 0);
           q : out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
    end component;
    
    signal d : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal q: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal clk: STD_LOGIC := '0';
    signal rst: STD_LOGIC := '0';
    
begin

    uut: reg port map (
        d => d,
        q => q,
        clk => clk,
        rst => rst
    );
    
    main_proc: process
    begin
    wait for 20ns;
    rst <= '1'; --deassert
    wait for 80ns;
    
    --tick clock, nothing happens
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --set input but no clock, nothing changes
    d <= "10100101";
    wait for 100ns;
    
    --tick clock, d goes to q
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --change input, output remains
    d <= "11111111";
    wait for 100ns;
    
    --tick clock, d goes to q
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --assert rst
    rst <= '0';
    wait for 100ns;
    
    end process;

end Behavioral;
