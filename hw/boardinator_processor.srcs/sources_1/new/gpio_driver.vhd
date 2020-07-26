
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gpio_driver is
    Port ( write : in STD_LOGIC;
           mode : in STD_LOGIC;
           read : out STD_LOGIC;
           pin : inout STD_LOGIC);
end gpio_driver;

architecture Behavioral of gpio_driver is
begin

    pin <= 'Z' when mode = '0' else write;
    read <= pin;

end Behavioral;
