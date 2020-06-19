

;;;;;;;;;;;;;;;;;;;;;;; macros for stack manipulation ;;;;;;;;;;;;;;;;;;;;;;;

.define "sp" "r6"
.define "bp" "r7"

.define "push reg" "setstk sp,reg\n addl sp,1"
.define "pop reg" "subl sp,1\n getstk reg,sp"
.define "mklcl n" "addl sp,n"
.define "setlcl n,reg" "addl bp,n\n setstk bp,reg\n subl bp,n"
.define "getlcl reg,n" "addl bp,n\n getstk reg,bp\n subl bp,n"
.define "getarg reg,n" "subl bp,n\n subl bp,4\n getstk reg,bp\n addl bp,4\n addl bp,n"
.define "enter" "push bp\n mov bp,sp"
.define "leave" "mov sp,bp\n pop bp"


.define "call func" "getpcl r5\n getpch r4\n  addl r5,11\n jovf inc_upper\n  jmp pushret\n inc_upper:\n addl r4,1\n pushret:\n push r4\n push r5\n jmp func"
.define "ret" "pop r5\n pop r4\n setpc r4,r5"

;.define "clean n" "subl sp,n\n subl sp,2"		;clean n arguments off the stack


;;;;;;;;;;;;;;;;;;;;;;; SFR definitions

;.define "RESET" "0"
;etc
