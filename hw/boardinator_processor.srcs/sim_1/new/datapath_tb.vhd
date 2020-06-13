----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 02:15:49 PM
-- Design Name: 
-- Module Name: datapath_tb - Behavioral
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

entity datapath_tb is
--  Port ( );
end datapath_tb;

architecture Behavioral of datapath_tb is
    component datapath
    Port ( op : in STD_LOGIC_VECTOR (4 downto 0);
           dst, src: in STD_LOGIC_VECTOR (2 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           lit : in STD_LOGIC_VECTOR (7 downto 0);
           
           out_word : out STD_LOGIC_VECTOR (7 downto 0));
     end component;
     
     signal op: STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
     signal dst, src: STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
     signal rst: STD_LOGIC := '1';
     signal clk: STD_LOGIC := '0';
     signal lit: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin
    uut: datapath port map (
        op => op,
        dst => dst,
        src => src,
        rst => rst,
        clk => clk,
        lit => lit
    );
    
    main_proc: process
    begin
    
    wait for 50ns;
    rst <= '0';
    wait for 50ns;
    rst <= '1';
    wait for 100ns;
    
    --"set" opcode, set r3 to 10010001
    op <= "00000";
    wait for 50ns;
    dst <= "011";
    wait for 50ns;
    lit <= "10010001";
    wait for 50ns;
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --"set" opcode, set r4 to 00000011
    op <= "00000";
    wait for 50ns;
    dst <= "100";
    wait for 50ns;
    lit <= "00000011";
    wait for 50ns;
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --"add" opcode, r4 += r3
    op <= "00010";
    wait for 50ns;
    dst <= "100";
    wait for 50ns;
    src <= "011";
    wait for 50ns;
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    --"mov" opcode, r7 = r4
    op <= "00001";
    wait for 50ns;
    dst <= "111";
    wait for 50ns;
    src <= "100";
    wait for 50ns;
    clk <= '1';
    wait for 50ns;
    clk <= '0';
    wait for 50ns;
    
    end process;

end Behavioral;
