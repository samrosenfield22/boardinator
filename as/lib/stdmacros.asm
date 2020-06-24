

;;;;;;;;;;;;;;;;;;;;;;; macros for stack manipulation ;;;;;;;;;;;;;;;;;;;;;;;

.define "sp" "r6"
.define "bp" "r7"

.define "push reg" "setmem sp,reg,0\n addl sp,1"
.define "pop reg" "subl sp,1\n getmem reg,sp,0"
.define "mklcl n" "addl sp,n"
.define "setlcl n,reg" "addl bp,n\n setmem bp,reg,0\n subl bp,n"
.define "getlcl reg,n" "addl bp,n\n getmem reg,bp,0\n subl bp,n"
.define "getarg reg,n" "subl bp,n\n subl bp,4\n getmem reg,bp,0\n addl bp,4\n addl bp,n"
.define "enter" "push bp\n mov bp,sp"
.define "leave" "mov sp,bp\n pop bp"
.define "call func" "getpcl r5\n getpch r4\n  addl r5,11\n jovf inc_upper\n  jmp pushret\n inc_upper:\n addl r4,1\n pushret:\n push r4\n push r5\n jmp func"
.define "ret" "pop r5\n pop r4\n setpc r4,r5"

.define "nop" "addl r0,0"

;;;;;;;;;;;;;;;;;;;;;;; memory regions ;;;;;;;;;;;;;;;;;;;;;;;
.define "STACK_REGION" "0"
;bss?
.define "SFR_REGION" "2"

;;;;;;;;;;;;;;;;;;;;;;; SFR definitions

.define	"RSTCON" "0"
.define	"TMRCON" "1"
.define "TMRCMP" "2"
.define "TMROUT" "3"

