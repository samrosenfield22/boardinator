----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 02:03:31 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
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


entity datapath is
    Port ( op : in STD_LOGIC_VECTOR (4 downto 0);
           dst, src: in STD_LOGIC_VECTOR (2 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           lit : in STD_LOGIC_VECTOR (7 downto 0);
           en : in STD_LOGIC;
           
           out_word : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR(1 downto 0));
end datapath;

architecture Behavioral of datapath is

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
     
     component alu
     Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
            b : in STD_LOGIC_VECTOR (7 downto 0);
            op : in STD_LOGIC_VECTOR (4 downto 0);
            y : out STD_LOGIC_VECTOR (7 downto 0);
            flags : out STD_LOGIC_VECTOR (1 downto 0));
     end component;
     
     signal a_sig, b_sig, y_sig, rf_in: std_logic_vector(7 downto 0);
begin
    regfile: rf port map (
        clk => clk,
        we => en,
        rst => rst,
        a_addr => dst,
        b_addr => src,
        w_addr => dst,
        in_word => rf_in,
        out_a => a_sig,
        out_b => b_sig
    );
    
    arithlogic: alu port map (
        a => a_sig,
        b => b_sig,
        op => op,
        y => y_sig,
        flags => flags
    );
    
    --register file input mux (selects between ALU Y and literal
    process(op, lit, y_sig)
    begin
        if(op="00000") then
            rf_in <= lit;
        else
            rf_in <= y_sig;
        end if;
    end process;
    
    out_word <= y_sig;

end Behavioral;
