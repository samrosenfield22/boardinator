----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 01:28:25 PM
-- Design Name: 
-- Module Name: rf_tb - Behavioral
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

entity rf_tb is
--  Port ( );
end rf_tb;

architecture Behavioral of rf_tb is
    component rf
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           --wl : in STD_LOGIC;
           rst : in STD_LOGIC;
           a_addr : in STD_LOGIC_VECTOR (2 downto 0);
           b_addr : in STD_LOGIC_VECTOR (2 downto 0);
           w_addr : in STD_LOGIC_VECTOR (2 downto 0);
           
           in_word : in STD_LOGIC_VECTOR (7 downto 0);
           out_a : out STD_LOGIC_VECTOR (7 downto 0);
           out_b : out STD_LOGIC_VECTOR (7 downto 0));
     end component;
     
     signal clk : STD_LOGIC := '0';
     signal we : STD_LOGIC := '0';
     signal rst : STD_LOGIC := '1';
     signal a_addr : STD_LOGIC_VECTOR (2 downto 0) := "000";
     signal b_addr : STD_LOGIC_VECTOR (2 downto 0) := "000";
     signal w_addr : STD_LOGIC_VECTOR (2 downto 0) := "000"; 
     signal in_word : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
     signal out_a : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
     signal out_b : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
     
begin
    
    uut: rf port map (
        clk => clk,
        we => we,
        rst => rst,
        a_addr => a_addr,
        b_addr => b_addr,
        w_addr => w_addr,
        in_word => in_word,
        out_a => out_a,
        out_b => out_b
    );
    
    clk_proc: process
    begin
        clk <= '1';
        wait for 10ns;
        clk <= '0';
        wait for 10ns;
    end process;
    
    main_proc: process
    begin
    
    wait for 20ns;
    rst <= '0';
    wait for 20ns;
    rst <= '1';
    wait for 60ns;
    
    w_addr <= "011";
    wait for 50ns;
    in_word <= "10100101";
    wait for 50ns;
    we <= '1';
    wait for 50ns;
    we <= '0';
    wait for 50ns;
    
    w_addr <= "101";
    wait for 50ns;
    in_word <= "11110000";
    wait for 50ns;
    we <= '1';
    wait for 50ns;
    we <= '0';
    wait for 50ns;
    
    --now let's read some outputs
    a_addr <= "011";
    wait for 50ns;
    b_addr <= "101";
    wait for 150ns;
    
    
    
    end process;


end Behavioral;
