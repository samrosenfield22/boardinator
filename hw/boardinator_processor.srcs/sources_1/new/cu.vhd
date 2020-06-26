----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;

entity cu is
    Port (  instr_in : in STD_LOGIC_VECTOR (15 downto 0);
            rst : in STD_LOGIC;
            clk : in STD_LOGIC;
            flags : in STD_LOGIC_VECTOR(2 downto 0);
            a_readback : in STD_LOGIC_VECTOR(7 downto 0);
            b_readback : in STD_LOGIC_VECTOR(7 downto 0);
            
            op : out STD_LOGIC_VECTOR (4 downto 0);
            dst, src : out STD_LOGIC_VECTOR (2 downto 0);
            lit : out STD_LOGIC_VECTOR (7 downto 0);
            mem_region : out STD_LOGIC_VECTOR(1 downto 0);
            data_en : out STD_LOGIC;
            pc_out : out STD_LOGIC_VECTOR (9 downto 0);
            
            ilgl_op : out STD_LOGIC;
            stack_we : out STD_LOGIC);
end cu;

architecture Behavioral of cu is

type cu_state_t is (fetch, execute);
signal cu_state: cu_state_t := fetch;

signal ir: std_logic_vector(15 downto 0);
signal pc, saved_pc: std_logic_vector(9 downto 0);
signal op_int: std_logic_vector(4 downto 0);
signal addr_sig: std_logic_vector(9 downto 0);
signal jmp_condition: std_logic;

signal operand: unsigned(4 downto 0);

begin
    
    fsm: process(rst, clk)
    begin
        if(rst='0') then
            cu_state <= fetch;
            ir <= "0000000000000000";
            pc <= "0000000000";
            data_en <= '0';
            stack_we <= '0';
            ilgl_op <= '1';
        else
            if(clk'event and clk='0') then
                case cu_state is
                    when fetch =>
                        --get instruction from program memory into IR
                        ir <= instr_in;
                        data_en <= '0';
                        stack_we <= '0';
                        cu_state <= execute;
                   
                    when execute =>
                        if(operand < CMP_OP) then  --ALU operation
                            data_en <= '1';
                            pc <= std_logic_vector(unsigned(pc) + 1);
                        elsif(operand = CMP_OP) then
                            data_en <= '0';
                            pc <= std_logic_vector(unsigned(pc) + 1);
                        elsif(operand <= JOVF_OP) then    --jmp operations
                            data_en <= '0';
                            
                            if(operand = JMP_OP) then --jmp
                                pc <= addr_sig;
                            elsif(operand = JEQ_OP) then  --jeq
                                if(flags(EF_FLAG)='1') then pc <= addr_sig;
                                else pc <= std_logic_vector(unsigned(pc) + 1); end if;
                            elsif(operand = JNE_OP) then  --jne
                                if(flags(EF_FLAG)='0') then pc <= addr_sig;
                                else pc <= std_logic_vector(unsigned(pc) + 1); end if;
                            elsif(operand = JGT_OP) then  --jgt
                                if(flags(GLF_FLAG)='1' and flags(EF_FLAG)='0') then pc <= addr_sig;
                                else pc <= std_logic_vector(unsigned(pc) + 1); end if;
                            elsif(operand = JLT_OP) then  --jlt
                                if(flags(GLF_FLAG)='0' and flags(EF_FLAG)='0') then pc <= addr_sig;
                                else pc <= std_logic_vector(unsigned(pc) + 1); end if;
                            elsif(operand = JOVF_OP) then  --jovf
                                if(flags(OF_FLAG)='1') then pc <= addr_sig;
                                else pc <= std_logic_vector(unsigned(pc) + 1); end if;
                            end if;

                        elsif((operand = SETM_OP) or (operand = GETM_OP)) then
                            
                            pc <= std_logic_vector(unsigned(pc) + 1);
                            if(operand = SETM_OP) then
                                stack_we <= '1';
                                data_en <= '1';     --
                            else    --getm
                                stack_we <= '0';
                                data_en <= '1';
                            end if;
                        elsif((operand = GETPCL_OP) or (operand = GETPCH_OP)) then
                            data_en <= '1';
                            saved_pc <= pc;
                            pc <= std_logic_vector(unsigned(pc) + 1);
                        elsif(operand = SETPC_OP) then
                            data_en <= '0';
                            pc <= a_readback(1 downto 0) & b_readback;
                        else
                            ilgl_op <= '0';
                        
                        end if;
                        
                        cu_state <= fetch;
                    when others =>
                        --ruh roh
                end case;
            end if;
        end if;
    end process;
    
    --decoder
    op_int <= ir(15 downto 11);
    dst <= ir(10 downto 8);
    src <= ir(2 downto 0);
    --lit <= ir(7 downto 0);
    lit <=  saved_pc(7 downto 0) when operand = GETPCL_OP else
            "000000" & saved_pc(9 downto 8) when operand = GETPCH_OP else
            "00000000" when operand = SETM_OP and ir(4 downto 3)="00" else
            "00000001" when operand = SETM_OP and ir(4 downto 3)="01" else
            "11111111" when operand = SETM_OP and ir(4 downto 3)="11" else
            ir(7 downto 0);
    mem_region <= ir(7 downto 6);
    
    addr_sig <= ir(9 downto 0);
    
    pc_out <= pc;
    op <= op_int;
    
    --
    operand <= unsigned(op_int);
    

end Behavioral;
