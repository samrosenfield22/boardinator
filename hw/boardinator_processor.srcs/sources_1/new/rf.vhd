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
    
    w_addr_split: process(w_addr)
    begin
        for i in 0 to 7 loop
            if(unsigned(w_addr)=i) then dec_sel(i) <= '1'; else dec_sel(i) <= '0'; end if;
        end loop;
    end process;
    
    dec(7) <= clk and we and dec_sel(7);
    dec(6) <= clk and we and dec_sel(6);
    dec(5) <= clk and we and dec_sel(5);
    dec(4) <= clk and we and dec_sel(4);
    dec(3) <= clk and we and dec_sel(3);
    dec(2) <= clk and we and dec_sel(2);
    dec(1) <= clk and we and dec_sel(1);
    dec(0) <= clk and we and dec_sel(0);
    
    
    --main_ins <= (to_integer(unsigned(w_addr)) => in_word, others => "00000000");
    --decoder: process(we, w_addr, clk)
--	 decoder: process(clk)
--    begin
--        if(we='1') then
--            --clock only the reg selected by the write address
--            for i in 0 to 7 loop
--                if(unsigned(w_addr)=i) then dec(i) <= clk;
--                else dec(i) <= '0';
--                end if;
--            end loop;
--        else
--            dec <= (others => '0');
--        end if;
			 
----			 for i in 0 to 7 loop
----				if(unsigned (w_addr)=i) then dec(i) <= clk and we;
----				else dec(i) <= '0'; end if;
----			 end loop;
--    end process;
    
--    incr_ins <= (to_integer(unsigned(b_addr)) => incr_in, others => "00000000");
--    decoder2: process(incr_en, b_addr, clk)
--    begin
--        if(incr_en='1') then
--            --clock only the reg selected by the write address
--            incr_dec <= (to_integer(unsigned(b_addr)) => clk, others => '0');
--        else
--            incr_dec <= (others => '0');
--        end if;
--    end process;
    
--    both_decs <= dec or incr_dec;

--    --set all inputs to the input word
      reg_ins <= (others => in_word);
--    --reg_ins <= main_ins or incr_ins;
--    process(main_ins, incr_ins)
--    begin
--        for i in 0 to 7 loop
--            reg_ins(i) <= main_ins(i) or incr_ins(i);
--        end loop;
--    end process;
    
    --set outputs
    out_a <= reg_outs(to_integer(unsigned(a_addr)));
    out_b <= reg_outs(to_integer(unsigned(b_addr)));

    reg0_out <= reg_outs(0);


end Behavioral;
