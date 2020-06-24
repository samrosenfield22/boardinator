----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity dff is
    Port ( d,rst,clk : in STD_LOGIC;
           q,qnot : out STD_LOGIC);
end dff;

architecture Behavioral of dff is
    signal q_int: std_logic;
begin
    process(rst,clk)
    begin
        if(rst='0') then
            q_int <= '0';
        else
            if(clk'event and clk='1') then
                q_int <= d;
            end if;
        end if;
    end process;
    
    q <= q_int;
    qnot <= not(q_int);

end Behavioral;
