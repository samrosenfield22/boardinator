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
            flags : in STD_LOGIC_VECTOR(1 downto 0);
            
            op : out STD_LOGIC_VECTOR (4 downto 0);
            dst, src : out STD_LOGIC_VECTOR (2 downto 0);
            lit : out STD_LOGIC_VECTOR (7 downto 0);
            data_en : out STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR (9 downto 0));
end cu;

architecture Behavioral of cu is

type cu_state_t is (fetch, decode, pause, load_next, execute);
signal cu_state: cu_state_t := fetch;

signal ir: std_logic_vector(15 downto 0);
signal pc, next_pc: std_logic_vector(9 downto 0);
signal op_int: std_logic_vector(4 downto 0);
signal addr_sig: std_logic_vector(9 downto 0);
signal jmp_condition: std_logic;

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
                        op_int <= ir(15 downto 11);
                        dst <= ir(10 downto 8);
                        src <= ir(2 downto 0);
                        lit <= ir(7 downto 0);
                        addr_sig <= ir(9 downto 0);
                        cu_state <= pause;
                    when pause =>
                        if(unsigned(op_int) < 7) then  --ALU operation
                            data_en <= '1';
                            next_pc <= std_logic_vector(unsigned(pc) + 1);
                            jmp_condition <= '0';
                        elsif(unsigned(op_int) = 7) then     --cmp
                            data_en <= '0';
                            next_pc <= std_logic_vector(unsigned(pc) + 1);
                            jmp_condition <= '0';
                        else    --jmp operations
                            data_en <= '0';
                            
                            if(op_int="01011") then --jmp
                                jmp_condition <= '1';
                            elsif(op_int="01100") then  --jeq
                                if(flags(0)='1') then jmp_condition <= '1';
                                else jmp_condition <= '0'; end if;
                            elsif(op_int="01101") then  --jne
                                if(flags(0)='0') then jmp_condition <= '1';
                                else jmp_condition <= '0'; end if;
                            elsif(op_int="01110") then  --jgt
                                if(flags(1)='1' and flags(0)='0') then jmp_condition <= '1';
                                else jmp_condition <= '0'; end if;
                            elsif(op_int="01111") then  --jlt
                                if(flags(1)='0' and flags(0)='0') then jmp_condition <= '1';
                                else jmp_condition <= '0'; end if;
                            end if;
                            
--                            if(jmp_condition = '1') then
--                                next_pc <= addr_sig;
--                            else
--                                next_pc <= std_logic_vector(unsigned(pc) + 1);
--                            end if;
                        end if;
                        
                        cu_state <= load_next;
                    when load_next =>
                        if(jmp_condition = '1') then
                            --next_pc <= addr_sig;
                            pc <= addr_sig;
                        else
                            --next_pc <= std_logic_vector(unsigned(pc) + 1);
                            pc <= std_logic_vector(unsigned(pc) + 1);
                        end if;
                        data_en <= '0';
                        cu_state <= fetch;
                    when execute =>
                        pc <= next_pc;
                        data_en <= '0';
                        cu_state <= fetch;
                    when others =>
                        --ruh roh
                    
                end case;
            end if;
        end if;
    end process;
    
    pc_out <= pc;
    op <= op_int;

end Behavioral;
