

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package simple is

type prog_mem_t is array (9 downto 0) of std_logic_vector(15 downto 0);
constant HEXFILE: prog_mem_t :=
(
	0 => "0000001100001111", --00000 011 00001111     set r3 to literal 00001111
        1 => "0000100000000011", --00001 000 00000011     mov r3 to r0
        2 => "0001000000000011", --00010 000 00000011     add r0 <= r3
        3 => "0001000000000000", --add r0 to r0
        others => "0000000000000000"
);

end simple;