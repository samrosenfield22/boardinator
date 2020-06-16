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
           
           stack_we : in STD_LOGIC;
           --stack_addr_reg : in STD_LOGIC_VECTOR(2 downto 0);
           
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
     
     component stack
     Port ( we : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           in_data : in STD_LOGIC_VECTOR (7 downto 0);
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           ovflw : out STD_LOGIC);
     end component;
     
     signal a_sig, b_sig, y_sig, rf_in, stack_addr, stack_output: std_logic_vector(7 downto 0);
     signal alu_b_in: std_logic_vector(7 downto 0);
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
        b => alu_b_in,
        op => op,
        y => y_sig,
        flags => flags
    );
    
    exec_stack: stack port map (
    we => stack_we,
    rst => rst,
    clk => clk,
    in_data => b_sig,
    addr => stack_addr,
    out_data => stack_output,
    ovflw => open
    );
    
    --register file input mux (selects between ALU Y and literal
--    process(op, lit, y_sig, stack_output)
--    begin
--        if(op="00000") then
--            rf_in <= lit;
--        elsif(op="01110" or op="01111") then
--            rf_in <= stack_output;
--        else
--            rf_in <= y_sig;
--        end if;
--    end process;

    --alu b input
    process(op, lit, b_sig)
    begin
        if(op="00000" or op="00011" or op="00101") then
            alu_b_in <= lit;
            --alu_b_in <= "00000000";
        else
            alu_b_in <= b_sig;
            --alu_b_in <= b_sig;
        end if;
    end process;
    
    --register file input mux (selects between ALU Y and stack output
    process(op, y_sig, stack_output)
    begin
        if(op="10000" or op="10001") then
            rf_in <= stack_output;
        else
            rf_in <= y_sig;
        end if;
    end process;
    
    --stack address selector
    process(stack_we, a_sig, b_sig)
    begin
        if(stack_we = '1') then
            stack_addr <= a_sig;
        else
            stack_addr <= b_sig;
        end if;
    end process;
    
    out_word <= y_sig;

end Behavioral;
