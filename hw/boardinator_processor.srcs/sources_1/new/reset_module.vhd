----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity reset_module is
    Port ( ext_rst : in STD_LOGIC;
           stkovf_rst : in STD_LOGIC;
           ilglop_rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           
           rstcon_sfr : in STD_LOGIC_VECTOR (7 downto 0);
           rstcause_sfr : out STD_LOGIC_VECTOR (7 downto 0);
           
           global_rst : out STD_LOGIC);
end reset_module;


architecture Behavioral of reset_module is
    --signal por_rst: std_logic := '0';
    signal global_rst_int, global_rst_int_r, sw_rst: std_logic:= '1';
    
    --signal rst_cnt_en: std_logic := '1';
    --signal rst_cnt: std_logic_vector(3 downto 0) := (others => '0');
    signal rst_source: std_logic_vector(2 downto 0) := (others => '0');
begin
    --global_rst_int <= por_rst and ext_rst and sw_rst and stkovf_rst and ilglop_rst;
    global_rst_int <= ext_rst and sw_rst and stkovf_rst and ilglop_rst;
    --global_rst <= global_rst_int and rst_cnt_en;
    
--    process(rstcon_sfr(7))
--    begin
--        if(rstcon_sfr(7) = '1') then
--            sw_rst <= '0';
--            --rst_source <= "010";
--        else
--            sw_rst <= '1';
--        end if;
--    end process;
    --sw_rst <= '0' when rstcon_sfr(7) = '1' else '1';
    sw_rst <= not(rstcon_sfr(7));
    
    --process(clk, por_rst)
--    process(clk)
--    begin
--        if(rising_edge(clk)) then
--            if(por_rst = '0') then
--                por_rst <= '1';
--            end if;
--        end if;
--    end process;
    
    --if we're in "reset counting" mode, count up until we reach 8, then leave reset counting mode
    --if we're not in reset counting mode, and a previously asserted reset condition is released, enter reset counting mode
    --
    --this only works if 
--    process(rst_cnt_en, global_rst_int, clk)
--    --process(global_rst_int, rst_cnt_en)    --this will be different in hardware, on the rising edge of
--                            --power, en and cnt get reset
--    begin
--        if(rst_cnt_en = '1') then
--            if(global_rst_int'event and global_rst_int='1') then
--                rst_cnt_en <= '0';
--                rst_cnt <= (others => '0');
--            --elsif(global_rst_int'event and global_rst_int='0') then
--            --    por_rst <= '1';
--            end if;
--        else
--            if(clk'event and clk='1') then
--                rst_cnt <= std_logic_vector(unsigned(rst_cnt) + 1);
--                if(unsigned(rst_cnt) >= 8) then
--                    rst_cnt_en <= '1';
--                    --rst_cnt <= (others => '0');
--                end if;
--            end if;
--        end if;
--    end process;

    
    reset_counter : process(clk)
        type rst_state_t is (IDLE, COUNTING);
        variable rst_state: rst_state_t := COUNTING;
        
        variable rst_cnt: natural := 0;
    begin
        if(rising_edge(clk)) then
        
            --global_rst_int_r is already registered in the below process
            
            case rst_state is
            
                when IDLE =>
                    --start counting when all reset conditions are released
                    if(global_rst_int_r='0' and global_rst_int='1') then
                        rst_state := COUNTING;
                        rst_cnt := 0;
                        --global_rst <= '0';
                    elsif(global_rst_int='0') then
                        global_rst <= '0';
                    end if;
                
                when COUNTING =>
                    rst_cnt := rst_cnt + 1;
                    if(rst_cnt >= 8) then
                        rst_state := IDLE;
                        global_rst <= '1';
                    end if;
            end case;
        
        end if;
    end process;
    
    
    
--    process(global_rst_int)
--    begin
--        if(global_rst_int'event and global_rst_int='0') then
--            if(por_rst='0')     then rst_source <= "000";
--            elsif(ext_rst='0')     then rst_source <= "001";
--            elsif(sw_rst='0')      then rst_source <= "010";
--            elsif(stkovf_rst='0')  then rst_source <= "011";
--            elsif(ilglop_rst='0')  then rst_source <= "100";
--            else rst_source <= "111"; end if;
--        end if;
--    end process;

    process(clk)
    begin
        if(rising_edge(clk)) then
            
            --register to detect edges
            global_rst_int_r <= global_rst_int;
            
            if(global_rst_int_r='1' and global_rst_int='0') then
                --if(por_rst='0')     then rst_source <= "000";
                if(ext_rst='0')     then rst_source <= "001";
                elsif(sw_rst='0')      then rst_source <= "010";
                elsif(stkovf_rst='0')  then rst_source <= "011";
                elsif(ilglop_rst='0')  then rst_source <= "100";
                else rst_source <= "111"; end if;
            end if;
        end if;
    end process;
    rstcause_sfr <= "00000" & rst_source;

end Behavioral;
