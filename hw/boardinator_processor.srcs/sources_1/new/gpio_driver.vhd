----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity gpio_driver is
    Port ( write : in STD_LOGIC;
           mode : in STD_LOGIC;
           read : out STD_LOGIC;
           pin : inout STD_LOGIC);
end gpio_driver;

architecture Behavioral of gpio_driver is
begin
    process(write, mode)
    begin
        if(mode = '0') then
            pin <= 'Z';
        else
            pin <= write;
        end if;
    end process;
    
    read <= pin;

end Behavioral;
