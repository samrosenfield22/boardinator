

;;;;;;;;;;;;;;;;;;;;;;; macros for stack manipulation ;;;;;;;;;;;;;;;;;;;;;;;

.define "sp" "r6"
.define "bp" "r7"

;.define "push reg" "setm sp,reg,STACK_REGION,0\n addl sp,1"

.define "push reg" "setm sp,reg,STACK_REGION,1"

.define "pop reg" "subl sp,1\n getm reg,sp,STACK_REGION,0"
.define "mklcl n" "addl sp,n"
.define "setlcl n,reg" "addl bp,n\n setm bp,reg,STACK_REGION,0\n subl bp,n"
.define "getlcl reg,n" "addl bp,n\n getm reg,bp,STACK_REGION,0\n subl bp,n"
.define "getarg reg,n" "subl bp,n\n subl bp,4\n getm reg,bp,STACK_REGION,0\n addl bp,4\n addl bp,n"
.define "enter" "push bp\n mov bp,sp"
.define "leave" "mov sp,bp\n pop bp"
;.define "call func" "getpcl r5\n getpch r4\n  addl r5,11\n jovf inc_upper\n  jmp pushret\n inc_upper:\n addl r4,1\n pushret:\n push r4\n push r5\n jmp func"
.define "call func" "getpcl r5\n getpch r4\n  addl r5,9\n jovf inc_upper\n  jmp pushret\n inc_upper:\n addl r4,1\n pushret:\n push r4\n push r5\n jmp func"
.define "ret" "pop r5\n pop r4\n setpc r4,r5"

;;;;;;;;;;;;;;;;;;;;;;;

.define "sfr_write sfr,byte" "set r4,sfr\n set r5,byte\n setm r4,r5,SFR_REGION,0"
.define "sfr_read reg,sfr" "set r4,sfr\n getm reg,r4,SFR_REGION,0"

.define "nop" "addl r0,0"

;;;;;;;;;;;;;;;;;;;;;;; memory regions ;;;;;;;;;;;;;;;;;;;;;;;
.define "STACK_REGION" "0"
.define "SFR_REGION" "1"

;;;;;;;;;;;;;;;;;;;;;;; SFR definitions

.define	"RSTCON" 	"0"
.define "SWRST"		"0x80"

.define "RSTCAUSE"	"1"

.define	"TMRCON"	"2"
.define "TMRON"		"0x80"

.define "TMRCMP"	"3"
.define "TMROUT"	"4"
.define "TMRSTAT"	"5"

.define "UARTCON"	"10"
.define "UARTSTAT"	"11"
.define "TXREG"		"12"
.define "RXREG"		"13"

.define "MODEA" "0x20"
.define "INA" 	"0x21"
.define "OUTA" 	"0x22"
.define "MODEB" "0x23"
.define "INB" 	"0x24"
.define "OUTB" 	"0x25"
.define "MODEC" "0x26"
.define "INC" 	"0x27"
.define "OUTC" 	"0x28"
.define "MODED" "0x29"
.define "IND" 	"0x2A"
.define "OUTD" 	"0x2B"


