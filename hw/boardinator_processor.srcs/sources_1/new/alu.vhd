----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;

entity alu is
    Port ( a : in STD_LOGIC_VECTOR (7 downto 0);
           b : in STD_LOGIC_VECTOR (7 downto 0);
           op : in STD_LOGIC_VECTOR (4 downto 0);
           clk : in STD_LOGIC;
           y : out STD_LOGIC_VECTOR (7 downto 0);
           flags : out STD_LOGIC_VECTOR (2 downto 0));
end alu;

architecture Behavioral of alu is
    signal mux_out:     std_logic_vector(7 downto 0) := (others => '0');
    
    signal adder_out, subt_out, xor_out, and_out, or_out: std_logic_vector(7 downto 0);
    signal lsl_out, lsr_out: std_logic_vector(7 downto 0);
    
    signal flags_int:   std_logic_vector(2 downto 0) := (others => '0');
    signal operand: unsigned(4 downto 0);
    
begin
    mux_out <=  b when operand=SET_OP else
                b when operand=MOV_OP else
                adder_out when operand=ADD_OP else
                adder_out when operand=ADDL_OP else
                subt_out when operand=SUB_OP else
                subt_out when operand=SUBL_OP else
                lsl_out when operand=LSL_OP else
                lsr_out when operand=LSR_OP else
                xor_out when operand=XOR_OP else
                and_out when operand=AND_OP else
                or_out when operand=OR_OP else
                --lsl_out when op="xxxxx" else
                --lsr_out when op="xxxxx" else
                "00000000" when operand=CMP_OP else
                --...
                b when operand=GETPCL_OP else
                b when operand=GETPCH_OP else
                "00000000";

    adder_out <= std_logic_vector(unsigned(a) + unsigned(b));
    subt_out <= std_logic_vector(unsigned(a) - unsigned(b));
    lsl_out <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b))));
    lsr_out <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b))));
    xor_out <= a XOR b;
    and_out <= a AND b;
    or_out <= a OR b;
    
    --flags
    process(a,b,op,clk)
    begin
        if(clk'event and clk='1') then
            if(operand=CMP_OP) then
                if(a=b) then
                    flags_int(EF_FLAG) <= '1';
                else
                    flags_int(EF_FLAG) <= '0';
                end if;
                
                if(a>b) then
                    flags_int(GLF_FLAG) <= '1';
                else
                    flags_int(GLF_FLAG) <= '0';
                end if;
                
                --flags <= flags_int;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if(clk'event and clk='1') then
            if(operand=ADD_OP or operand=ADDL_OP) then
                if(unsigned(adder_out) < unsigned(a)) then  --overflow
                    flags_int(OF_FLAG) <= '1';
                else
                    flags_int(OF_FLAG) <= '0';
                end if;
            elsif(operand=SUB_OP or operand=SUBL_OP) then
                if(unsigned(subt_out) > unsigned(a)) then  --underflow
                    flags_int(OF_FLAG) <= '1';
                else
                    flags_int(OF_FLAG) <= '0';
                end if;
            end if;
        end if;
    end process;
    
    --
    y <= mux_out;
    flags <= flags_int;
    
    operand <= unsigned(op);

end Behavioral;
