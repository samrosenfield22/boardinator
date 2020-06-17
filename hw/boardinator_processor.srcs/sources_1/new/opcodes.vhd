
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

package opcodes is

subtype opcode is STD_LOGIC_VECTOR(4 downto 0);
constant set:   opcode := "00000";
constant mov:   opcode := "00001";
constant add:   opcode := "00010";
constant addl:  opcode := "00011";
constant sub:   opcode := "00100";
constant subl:  opcode := "00101";
constant xor_i: opcode := "00110";
constant and_i: opcode := "00111";
constant or_i:  opcode := "01000";
constant cmp:   opcode := "01001";

end opcodes;


--type opcode is (set, mov, add, addl, sub, subl, xor_i, and_i, or_i, cmp);
--function "<"(L: STD_LOGIC_VECTOR; R: opcode) return boolean;
--end opcodes;

--package body opcodes is
--    function "<"(L: STD_LOGIC_VECTOR; R: opcode) return boolean is
--    variable result: boolean;
--    begin
--        result := (L < STD_LOGIC_VECTOR(integer(opcode'pos(R)))); return result;
--    end;
--end opcodes;