----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

use work.opcodes.all;

entity timer_module is
    Port(
        rst : in STD_LOGIC;
        clk : in STD_LOGIC;
        tmrcon_sfr, tmrcmp_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        tmrout_sfr, tmrstat_sfr : out STD_LOGIC_VECTOR (7 downto 0)
    );
end timer_module;
    
architecture Behavioral of timer_module is

    component dff
    Port ( d,rst,clk : in STD_LOGIC;
           q,qnot : out STD_LOGIC);
    end component;
    
    constant PRESCALE_BITS: integer := 4;
    constant PRESCALE_CNT: integer := 2**PRESCALE_BITS;
    
    constant TMRON_BIT:     integer := 7;
    constant TMRMODE_BIT:   integer := 6;
    
    signal d_qnot_loop: std_logic_vector(PRESCALE_CNT-1 downto 0);
    signal prescaler_clks: std_logic_vector(PRESCALE_CNT downto 0);
    signal prescale_sel: std_logic_vector(PRESCALE_BITS-1 downto 0);
    signal scaled_clk, scaled_clk_r: std_logic := '0';
    
    signal tmr_cnt: std_logic_vector(7 downto 0);
    signal tmr_match, tmr_mode, tmr_cnt_en: std_logic;
    signal tmr_on: std_logic;
begin
    tmr_on <= tmrcon_sfr(TMRON_BIT);

    gen_prescaler:
        for i in 0 to PRESCALE_CNT-1 generate
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
    
    --if we're in one-shot mode (1) and the match already occurred, or if the timer is off, disable the counter
    tmr_mode <= tmrcon_sfr(TMRMODE_BIT);
    --tmr_cnt_en <= (tmr_mode and tmr_match) or not(tmr_on);
    --tmr_cnt_en <= tmr_match or not(tmr_on);
    
    --if we're using one-shot mode, we need a functionality where turning the timer off resets the counter
    --this should probably go in the process below, though (so we don't get multiple drivers)
--    process(tmr_on)
--    begin
--        if(tmr_on'event and tmr_on='0') then
            
--        end if;
--    end process;
    
    process(rst, scaled_clk)
    variable tmr_cnt_v: std_logic_vector(7 downto 0) := (others => '0');
    begin
        if((rst='0') or (tmr_on='0')) then
            tmr_cnt_v := (others => '0');
        else
            --if(tmr_cnt_en = '0') then
                if(scaled_clk'event and scaled_clk='1') then
                    if(tmr_match='1') then
                        tmr_cnt_v := (others => '0');
                    else
                        tmr_cnt_v := std_logic_vector(unsigned(tmr_cnt_v)+1);
                    end if;
                end if;
            --end if;
        end if;
        
        tmr_cnt <= tmr_cnt_v;
    end process;
    
    --this should be a synchronous version of the above process, but it doesn't work. not sure why.
--    process(clk)
--        variable tmr_cnt_v: std_logic_vector(7 downto 0) := (others => '0');
--    begin
--        if(rising_edge(clk)) then
        
--            --register signal to detect edge
--            scaled_clk_r <= scaled_clk;
        
--            if(rst='0' or tmr_on='0') then
--                tmr_cnt_v := (others => '0');
--            elsif(scaled_clk_r='0' and scaled_clk='1') then
--                if(tmr_match='1') then
--                    tmr_cnt_v := (others => '0');
--                else
--                    tmr_cnt_v := std_logic_vector(unsigned(tmr_cnt_v)+1);
--                end if;
--            end if;
            
--            tmr_cnt <= tmr_cnt_v;
--        end if;
--    end process;
    
    tmrout_sfr <= tmr_cnt;
    
    tmr_match <= '1' when (tmr_cnt = tmrcmp_sfr) else '0';
    tmrstat_sfr(0) <= tmr_match;
    tmrstat_sfr(7 downto 1) <= (others => '0');

end Behavioral;
