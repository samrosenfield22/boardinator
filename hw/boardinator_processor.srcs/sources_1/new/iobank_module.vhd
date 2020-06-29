----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity iobank_module is
    Port (
        mode_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        write_sfr : in STD_LOGIC_VECTOR (7 downto 0);
        read_sfr : out STD_LOGIC_VECTOR (7 downto 0);
        pins : inout STD_LOGIC_VECTOR (7 downto 0)
    );
end iobank_module;

architecture Behavioral of iobank_module is
    component gpio_driver
    Port ( write : in STD_LOGIC;
           mode : in STD_LOGIC;
           read : out STD_LOGIC;
           pin : inout STD_LOGIC);
    end component;
    
begin
    
    gpioport: for i in 0 to 7 generate
        io: gpio_driver port map (
            write => write_sfr(i),
            mode => mode_sfr(i),
            read => read_sfr(i),
            pin => pins(i)
        );
    end generate gpioport;

end Behavioral;
