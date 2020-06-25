----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity timer_module is
    Port(
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        tmrcon_sfr, tmrcmp_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        tmrout_sfr : out STD_LOGIC_VECTOR (7 downto 0)
    );
end timer_module;
    
architecture Behavioral of timer_module is

    component dff
    Port ( d,rst,clk : in STD_LOGIC;
           q,qnot : out STD_LOGIC);
    end component;
    
    constant prescale_bits: integer := 4;
    constant prescale_cnt: integer := 2**prescale_bits;
    
    signal d_qnot_loop: std_logic_vector(prescale_cnt-1 downto 0);
    signal prescaler_clks: std_logic_vector(prescale_cnt downto 0);
    signal prescale_sel: std_logic_vector(prescale_bits-1 downto 0);
    signal scaled_clk: std_logic;
    
    --signal timer_cnt: std_logic_vector(7 downto 0) := (others => '0');
    signal tmr_match: std_logic;
    signal tmr_on: std_logic;
begin
    tmr_on <= tmrcon_sfr(7);

    gen_prescaler:
        for i in 0 to prescale_cnt-1 generate
            dffgen: dff port map (
                d => d_qnot_loop(i),
                rst => rst,
                clk => prescaler_clks(i),
                q => prescaler_clks(i+1),
                qnot => d_qnot_loop(i)
            );
    end generate gen_prescaler;
    prescaler_clks(0) <= clk and tmr_on;
    prescale_sel <= tmrcon_sfr(3 downto 0);
    scaled_clk <= prescaler_clks(to_integer(unsigned(prescale_sel)));
    
    process(rst, scaled_clk)
    variable timer_cnt: std_logic_vector(7 downto 0);
    begin
        if(rst='0') then
            timer_cnt := (others => '0');
            tmr_match <= '0';
        else
            if(scaled_clk'event and scaled_clk='1') then
                timer_cnt := std_logic_vector(unsigned(timer_cnt)+1);
                if(timer_cnt = tmrcmp_sfr) then
                    tmr_match <= '1';
                    timer_cnt := (others => '0');
                else
                    tmr_match <= '0';
                end if;
            end if;
        end if;
        
        tmrout_sfr(0) <= tmr_match;
    end process;

end Behavioral;
