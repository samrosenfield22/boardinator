

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
constant CMPL_OP:    opcode := 12;
constant NOT_OP:    opcode := 13;
constant JMP_OP:    opcode := 14;
constant JEQ_OP:    opcode := 15;
constant JNE_OP:    opcode := 16;
constant JGT_OP:    opcode := 17;
constant JLT_OP:    opcode := 18;
constant JOVF_OP:   opcode := 19;
constant SETM_OP: opcode := 20;
constant GETM_OP: opcode := 21;
constant GETPCL_OP: opcode := 22;
constant GETPCH_OP: opcode := 23;
constant SETPC_OP:  opcode := 24;
--constant _OP:    opcode := 2

--flag bits
constant EF_FLAG:   integer := 0;
constant GLF_FLAG:  integer := 1;
constant OF_FLAG:   integer := 2;

--memory region ids
constant STACK_REGION:  integer := 0;
constant SFR_REGION:    integer := 1;

--
constant STACK_REGION_SIZE: integer := 256;
constant SFR_REGION_SIZE:   integer := 64;

constant STACK_REGION_ADDR: integer := 0;
constant SFR_REGION_ADDR:   integer := STACK_REGION_ADDR + STACK_REGION_SIZE;
constant PROC_MEMORY_END:   integer := SFR_REGION_ADDR + SFR_REGION_SIZE;

--SFRs
constant RSTCON:    integer := 0;
constant RSTCAUSE:  integer := 1;
constant TMRCON:    integer := 2;
constant TMRCMP:    integer := 3;
constant TMROUT:    integer := 4;

constant IOBANK_SFRS_START: integer := 32;
constant MODEA:     integer := IOBANK_SFRS_START+0;
constant INA:       integer := IOBANK_SFRS_START+1;
constant OUTA:      integer := IOBANK_SFRS_START+2;
constant MODEB:     integer := IOBANK_SFRS_START+3;
constant INB:       integer := IOBANK_SFRS_START+4;
constant OUTB:      integer := IOBANK_SFRS_START+5;
constant MODEC:     integer := IOBANK_SFRS_START+6;
constant INC:       integer := IOBANK_SFRS_START+7;
constant OUTC:      integer := IOBANK_SFRS_START+8;
constant MODED:     integer := IOBANK_SFRS_START+9;
constant IND:       integer := IOBANK_SFRS_START+10;
constant OUTD:      integer := IOBANK_SFRS_START+11;



type memarray_t is array (PROC_MEMORY_END downto 0) of std_logic_vector(7 downto 0);


end opcodes;

