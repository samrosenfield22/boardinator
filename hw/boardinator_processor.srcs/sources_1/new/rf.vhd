----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 10:33:13 AM
-- Design Name: 
-- Module Name: rf - Behavioral
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

entity rf is
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           rst : in STD_LOGIC;
           a_addr : in STD_LOGIC_VECTOR (2 downto 0);
           b_addr : in STD_LOGIC_VECTOR (2 downto 0);
           w_addr : in STD_LOGIC_VECTOR (2 downto 0);
           
           in_word : in STD_LOGIC_VECTOR (7 downto 0);
           out_a : out STD_LOGIC_VECTOR (7 downto 0);
           out_b : out STD_LOGIC_VECTOR (7 downto 0));
           
end rf;

architecture Behavioral of rf is
    type wordarray is array (7 downto 0) of std_logic_vector(7 downto 0);
    signal reg_ins, reg_outs: wordarray;
    
    signal dec: std_logic_vector(7 downto 0);
    
    --use register instances
    component reg
    Port ( d : in STD_LOGIC_VECTOR (7 downto 0);
           q : out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
    end component;
begin

    gen_regs:
    for i in 0 to 7 generate
        reg_x: reg port map (
        d => reg_ins(i),
        q => reg_outs(i),
        clk => dec(i),
        rst => rst
    );
    end generate gen_regs;
    
    decoder: process(we, w_addr, clk)
    begin
        if(we='1') then
            if(w_addr="000") then dec(0)<=clk; else dec(0)<='0'; end if;
            if(w_addr="001") then dec(1)<=clk; else dec(1)<='0'; end if;
            if(w_addr="010") then dec(2)<=clk; else dec(2)<='0'; end if;
            if(w_addr="011") then dec(3)<=clk; else dec(3)<='0'; end if;
            if(w_addr="100") then dec(4)<=clk; else dec(4)<='0'; end if;
            if(w_addr="101") then dec(5)<=clk; else dec(5)<='0'; end if;
            if(w_addr="110") then dec(6)<=clk; else dec(6)<='0'; end if;
            if(w_addr="111") then dec(7)<=clk; else dec(7)<='0'; end if;
            
            --dec(0) <= '1' when w_addr = "000" else '0';
        else
            dec <= "00000000";
        end if;
    end process;

    reg_ins <= (others => in_word);
    
    --set output a
--    out_a <=    reg_outs(0) when a_addr="000" else
--                reg_outs(1) when a_addr="001" else
--                reg_outs(2) when a_addr="010" else
--                reg_outs(3) when a_addr="011" else
--                reg_outs(4) when a_addr="100" else
--                reg_outs(5) when a_addr="101" else
--                reg_outs(6) when a_addr="110" else
--                reg_outs(7);
    process(reg_outs, a_addr)
    begin
        if(a_addr="000") then out_a <= reg_outs(0);
        elsif(a_addr="001") then out_a <= reg_outs(1);
        elsif(a_addr="010") then out_a <= reg_outs(2);
        elsif(a_addr="011") then out_a <= reg_outs(3);
        elsif(a_addr="100") then out_a <= reg_outs(4);
        elsif(a_addr="101") then out_a <= reg_outs(5);
        elsif(a_addr="110") then out_a <= reg_outs(6);
        else out_a <= reg_outs(7);
        end if;
    end process;

    --set output b
    out_b <=    reg_outs(0) when b_addr="000" else
                reg_outs(1) when b_addr="001" else
                reg_outs(2) when b_addr="010" else
                reg_outs(3) when b_addr="011" else
                reg_outs(4) when b_addr="100" else
                reg_outs(5) when b_addr="101" else
                reg_outs(6) when b_addr="110" else
                reg_outs(7);


end Behavioral;
