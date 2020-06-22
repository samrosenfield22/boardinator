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
           global_rst : out STD_LOGIC);
end reset_module;


architecture Behavioral of reset_module is
    signal por_rst: std_logic := '0';
    signal global_rst_int, sw_rst: std_logic;
    
    signal rst_cnt_en: std_logic := '0';
    signal rst_cnt: std_logic_vector(3 downto 0) := (others => '0');
    signal rst_source: std_logic_vector(2 downto 0) := (others => '0');
begin
    global_rst_int <= por_rst and ext_rst and sw_rst and stkovf_rst and ilglop_rst;
    global_rst <= global_rst_int and rst_cnt_en;
    
    process(rstcon_sfr(7))
    begin
        if(rstcon_sfr(7) = '1') then
            sw_rst <= '0';
            --rst_source <= "010";
        else
            sw_rst <= '1';
        end if;
    end process;
    
    process(global_rst_int, clk)    --this will be different in hardware, on the rising edge of
                            --power, en and cnt get reset
    begin
        if(global_rst_int'event and global_rst_int='0') then
            rst_cnt_en <= '0';
        elsif(rst_cnt_en = '0') then
            rst_cnt <= std_logic_vector(unsigned(rst_cnt) + 1);
            if(unsigned(rst_cnt) > 8) then
                rst_cnt_en <= '1';
                por_rst <= '1';
                rst_cnt <= (others => '0');
                --rstcon_sfr(2 downto 0) <= rst_source;
            --else
            --    por_rst <= '0';
            end if;
        --else
            --por_rst <= '1';
            --rst_cnt <= (others => '0');
        end if;
    end process;
    
    
    rst_source <=   "000" when por_rst='0' else
                    "001" when ext_rst='0' else
                    "010" when sw_rst='0' else
                    "011" when stkovf_rst='0' else
                    "100" when ilglop_rst='0';
  

end Behavioral;
