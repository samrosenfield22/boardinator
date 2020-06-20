----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

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
            --clock only the reg selected by the write address
            dec <= (to_integer(unsigned(w_addr)) => clk, others => '0');
        else
            dec <= (others => '0');
        end if;
    end process;

    --set all inputs to the input word
    reg_ins <= (others => in_word);
    
    --set outputs
    out_a <= reg_outs(to_integer(unsigned(a_addr)));
    out_b <= reg_outs(to_integer(unsigned(b_addr)));

    


end Behavioral;
