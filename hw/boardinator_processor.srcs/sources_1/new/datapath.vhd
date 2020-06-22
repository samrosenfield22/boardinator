----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;


entity datapath is
    Port ( op : in STD_LOGIC_VECTOR (4 downto 0);
           dst, src: in STD_LOGIC_VECTOR (2 downto 0);
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           lit : in STD_LOGIC_VECTOR (7 downto 0);
           en : in STD_LOGIC;
           
           stack_we : in STD_LOGIC;
           stack_data_out : in STD_LOGIC_VECTOR(7 downto 0);
           
           out_word : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR(2 downto 0);
           
           a_readback : out STD_LOGIC_VECTOR(7 downto 0);
           b_readback : out STD_LOGIC_VECTOR(7 downto 0);
           
           stkovflw : out STD_LOGIC);
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
            clk : in STD_LOGIC;
            y : out STD_LOGIC_VECTOR (7 downto 0);
            flags : out STD_LOGIC_VECTOR (2 downto 0));
     end component;
     
     signal a_sig, b_sig, y_sig, rf_in, stack_addr: std_logic_vector(7 downto 0);
     signal alu_b_in: std_logic_vector(7 downto 0);
     signal operand: unsigned(4 downto 0);
     signal flags_sig: std_logic_vector(2 downto 0);
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
        clk => clk,
        y => y_sig,
        flags => flags_sig
    );
    
    
    --alu b input is a literal for instructions:
    --set, addl, subl, getpcl, getpch
    process(operand, lit, b_sig)
    begin
        if(operand=SET_OP or operand=ADDL_OP or operand=SUBL_OP or operand=GETPCL_OP or operand=GETPCH_OP) then
        --if(op="00000" or op="00011" or op="00101" or op="10011" or op="10100") then
        --if(operand=SET_OP or operand=ADDL_OP or op="00101" or op="10011" or op="10100") then
            alu_b_in <= lit;
        else
            alu_b_in <= b_sig;
        end if;
    end process;
    
    --register file input mux (selects between ALU Y and stack output
    process(op, y_sig, stack_data_out)
    begin
        --if(op="10001" or op="10010") then
        if(operand=SETMEM_OP or operand=GETMEM_OP) then
            rf_in <= stack_data_out;
        else
            rf_in <= y_sig;
        end if;
    end process;
    
    --stack address selector
--    process(stack_we, a_sig, b_sig)
--    begin
--        if(stack_we = '1') then
--            stack_addr <= a_sig;
--        else
--            stack_addr <= b_sig;
--        end if;
--    end process;
    
    --
    process(flags_sig)
    begin
        if((flags_sig(OF_FLAG)='1') and 
        (dst="110" or dst="111") and
        (operand=ADD_OP or operand=ADDL_OP or operand=SUB_OP or operand=SUBL_OP)
        ) then
            stkovflw <= '0';
        else
            stkovflw <= '1';
        end if;
    end process;
    
    out_word <= y_sig;
    
    a_readback <= a_sig;
    b_readback <= b_sig;
    
    flags <= flags_sig;
    
    operand <= unsigned(op);

end Behavioral;
