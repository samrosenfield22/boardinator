library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity stack is
    Port ( we : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           in_data : in STD_LOGIC_VECTOR (7 downto 0);
           --in_addr : in STD_LOGIC_VECTOR (7 downto 0);
           --out_addr : in STD_LOGIC_VECTOR (7 downto 0);
           addr : in STD_LOGIC_VECTOR (7 downto 0);
           out_data : out STD_LOGIC_VECTOR (7 downto 0);
           ovflw : out STD_LOGIC);
end stack;

architecture Behavioral of stack is

type stack_t is array (255 downto 0) of std_logic_vector(7 downto 0);
signal stack: stack_t := (others => "00000000");
--signal sp, bp: std_logic_vector(7 downto 0);

begin

    process(rst,clk)
    begin
        if(rst='0') then
            stack <= (others => "00000000");
        elsif(we='1' and (clk'event and clk='1')) then
            stack(to_integer(unsigned(addr))) <= in_data;
        end if;
    end process;
    
    out_data <= stack(to_integer(unsigned(addr)));

end Behavioral;
