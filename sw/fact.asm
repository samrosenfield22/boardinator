;
;
;

.include "math.asm"
.include "stdmacros.asm"

	;
	;set 	r2,RSTCAUSE
	;getm 	r0,r2,SFR_REGION
	;set 	r3,0	;POR reset
	;cmp 	r3,r0
	;jeq 	main
	;set 	r3,1	;ext reset
	;cmp 	r3,r0
	;jeq 	main
	;bad_reset:
	;jmp 	bad_reset

	main:
	;set 
	set		r0,5

	push	r0
	call	factorial
	subl	sp,1

	;set the SWRST bit of RSTCON
	;set 	r2,RSTCON
	;set 	r3,SWRST
	;setmem	r2,r3,SFR_REGION
	;nop

	end:
	jmp		end


;;;;;;;;;;;;;;;;;;;;;;;;;
	factorial:
	enter

	push	r2
	push	r3

	factorial_init:
	getarg 	r2,0
	set		r3,1

	factorial_loop:
	cmpl	r2,1
	jeq		factorial_exit

	;fact *= i
	push	r3
	push	r2
	call	mult8
	subl	sp,2
	mov		r3,r1

	factorial_loop_end:
	subl	r2,1
	jmp		factorial_loop

	factorial_exit:
	mov		r0,r3
	pop		r3
	pop		r2
	leave
	ret

