----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/12/2020 10:33:13 AM
-- Design Name: 
-- Module Name: cu - Behavioral
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

entity cu is
    Port (  instr_in : in STD_LOGIC_VECTOR (15 downto 0);
            rst : in STD_LOGIC;
            clk : in STD_LOGIC;
            
            op : out STD_LOGIC_VECTOR (4 downto 0);
            dst, src : out STD_LOGIC_VECTOR (2 downto 0);
            lit : out STD_LOGIC_VECTOR (7 downto 0);
            data_en : out STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR (9 downto 0));
end cu;

architecture Behavioral of cu is

type cu_state_t is (fetch, decode, pause, execute);
signal cu_state: cu_state_t := fetch;

signal ir: std_logic_vector(15 downto 0);
signal pc: std_logic_vector(9 downto 0);

begin
    
    fsm: process(rst, clk)
    begin
        if(rst='0') then
            cu_state <= fetch;
            ir <= "0000000000000000";
            pc <= "0000000000";
            data_en <= '0';
        else
            if(clk'event and clk='0') then
                case cu_state is
                    when fetch =>
                        --get instruction from program memory into IR
                        ir <= instr_in;
                        cu_state <= decode;
                    when decode =>
                        op <= ir(15 downto 11);
                        dst <= ir(10 downto 8);
                        src <= ir(2 downto 0);
                        lit <= ir(7 downto 0);
                        cu_state <= pause;
                    when pause =>
                        data_en <= '1';
                        cu_state <= execute;
                    when execute =>
                        pc <= std_logic_vector(unsigned(pc) + 1);
                        data_en <= '0';
                        cu_state <= fetch;
                    when others =>
                        --ruh roh
                    
                end case;
            end if;
        end if;
    end process;
    
    pc_out <= pc;

end Behavioral;
