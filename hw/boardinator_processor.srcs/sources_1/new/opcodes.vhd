

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

package opcodes is

--subtype opcode is STD_LOGIC_VECTOR(4 downto 0);
subtype opcode is integer;
constant SET_OP:    opcode := 0;
constant MOV_OP:    opcode := 1;
constant ADD_OP:    opcode := 2;
constant ADDL_OP:   opcode := 3;
constant SUB_OP:    opcode := 4;
constant SUBL_OP:   opcode := 5;
constant LSL_OP:    opcode := 6;
constant LSR_OP:    opcode := 7;
constant XOR_OP:    opcode := 8;
constant AND_OP:    opcode := 9;
constant OR_OP:     opcode := 10;
constant CMP_OP:    opcode := 11;
constant NOT_OP:    opcode := 12;
constant JMP_OP:    opcode := 13;
constant JEQ_OP:    opcode := 14;
constant JNE_OP:    opcode := 15;
constant JGT_OP:    opcode := 16;
constant JLT_OP:    opcode := 17;
constant JOVF_OP:   opcode := 18;
constant SETM_OP: opcode := 19;
constant GETM_OP: opcode := 20;
constant GETPCL_OP: opcode := 21;
constant GETPCH_OP: opcode := 22;
constant SETPC_OP:  opcode := 23;
--constant _OP:    opcode := 2

--memory regions
constant STACK_REGION:  integer := 0;
constant UNDEF_REGION:  integer := 1;
constant SFR_REGION:    integer := 2;

--flag bits
constant EF_FLAG:   integer := 0;
constant GLF_FLAG:  integer := 1;
constant OF_FLAG:   integer := 2;

--SFRs
constant RSTCON:    integer := 0;
constant RSTCAUSE:  integer := 1;
constant TMRCON:    integer := 2;
constant TMRCMP:    integer := 3;
constant TMROUT:    integer := 4;


type memarray_t is array (1023 downto 0) of std_logic_vector(7 downto 0);


end opcodes;

