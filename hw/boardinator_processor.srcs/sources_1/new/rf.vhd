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
           
           --incr_in : in STD_LOGIC_VECTOR(7 downto 0);
           --incr_en : in STD_LOGIC;
           
           in_word : in STD_LOGIC_VECTOR (7 downto 0);
           out_a : out STD_LOGIC_VECTOR (7 downto 0);
           out_b : out STD_LOGIC_VECTOR (7 downto 0);
			  reg0_out: out STD_LOGIC_VECTOR (7 downto 0)
		);
           
end rf;

architecture Behavioral of rf is
    type wordarray is array (7 downto 0) of std_logic_vector(7 downto 0);
    signal reg_ins, reg_outs: wordarray;
    --signal reg_ins, main_ins, incr_ins, reg_outs: wordarray;
    
    signal dec, dec_sel: std_logic_vector(7 downto 0) := (others => '0');
    --signal dec, incr_dec, both_decs: std_logic_vector(7 downto 0);
    
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
        --clk => both_decs(i),
        clk => dec(i),
        rst => rst
    );
    end generate gen_regs;
    
    
    dec(7) <= (clk and we) when unsigned(w_addr)=7 else '0';
    dec(6) <= (clk and we) when unsigned(w_addr)=6 else '0';
    dec(5) <= (clk and we) when unsigned(w_addr)=5 else '0';
    dec(4) <= (clk and we) when unsigned(w_addr)=4 else '0';
    dec(3) <= (clk and we) when unsigned(w_addr)=3 else '0';
    dec(2) <= (clk and we) when unsigned(w_addr)=2 else '0';
    dec(1) <= (clk and we) when unsigned(w_addr)=1 else '0';
    dec(0) <= (clk and we) when unsigned(w_addr)=0 else '0';
    

--    --set all inputs to the input word
      reg_ins <= (others => in_word);
    
    --set outputs
    out_a <= reg_outs(to_integer(unsigned(a_addr)));
    out_b <= reg_outs(to_integer(unsigned(b_addr)));

    reg0_out <= reg_outs(0);


end Behavioral;
