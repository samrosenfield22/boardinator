----------------------------------------------------------------------------------
--------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

--use work.simple.all;

entity processor_tb is
--  Port ( );
end processor_tb;

architecture Behavioral of processor_tb is
    component processor
    Port ( --temporary_processor_instr_input : in STD_LOGIC_VECTOR(15 downto 0);  --delet
           clk_in : in STD_LOGIC;
           ext_rst : in STD_LOGIC;
           --pc_out : out STD_LOGIC_VECTOR (9 downto 0);
           
           gpio_pins : inout STD_LOGIC_VECTOR(15 downto 0);
           
           tx_pin : out STD_LOGIC;
           rx_pin : in STD_LOGIC
           );
    end component;
    
    --signal instr_input : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal ext_rst: std_logic := '1';
    --signal pc: std_logic_vector(9 downto 0) := "0000000000";
    signal gpio_pins : std_logic_vector(15 downto 0);
    signal tx, rx: std_logic;
    
--    type prog_mem_t is array (999 downto 0) of std_logic_vector(15 downto 0);
--    signal prog_rom: prog_mem_t :=
--    (    
--    	

--        others => "0000000000000000"
--    );
    --signal prog_rom: prog_mem_t := HEXFILE;
begin
    
    uut: processor port map (
        --temporary_processor_instr_input => instr_input,
        clk_in => clk,
        ext_rst => ext_rst,
        --pc_out => pc,
        gpio_pins => gpio_pins,
        tx_pin => tx,
        rx_pin => rx
    );
    
    
    clk_proc: process
        --constant freq_mhz : integer := 50;
        --constant td : integer := 500/freq_mhz;
    begin
        clk <= '1';
        --instr_input <= prog_rom(to_integer(unsigned(pc)));
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process;
    
    main_proc: process
    begin
        ext_rst <= '0';
        wait for 50ns;
        ext_rst <= '1';

        --let the program execute        
        wait for 1000*1000ms;
    end process;
    
    rxtest: process
    begin
        rx <= '1';
        wait for 150ms;
        
        rx <= '0';          --start
        wait for 0.104ms;
        rx <= '0';          --b0
        wait for 0.104ms;
        rx <= '1';          --b1
        wait for 0.104ms;
        rx <= '1';          --b2
        wait for 0.104ms;
        rx <= '0';          --b3
        wait for 0.104ms;
        rx <= '1';          --b4
        wait for 0.104ms;
        rx <= '1';          --b5
        wait for 0.104ms;
        rx <= '0';          --b6
        wait for 0.104ms;
        rx <= '0';          --b7
        wait for 0.104ms;
        rx <= '1';          --stop
        wait for 0.104ms;
        
        wait for 500000ms;
    end process;
    
    gpio_pins(10 downto 8) <= "100";
    
--    switch_test: process
--    begin
--        gpio_pins(10 downto 8) <= "000";
--        wait for 1ms;
--        gpio_pins(10 downto 8) <= "001";
--        wait for 1ms;
--        gpio_pins(10 downto 8) <= "010";
--        wait for 1ms;
--        gpio_pins(10 downto 8) <= "100";
--        wait for 1ms;
--        gpio_pins(10 downto 8) <= "110";
--        wait for 1ms;
        
--    end process;

end Behavioral;
