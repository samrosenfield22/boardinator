;
;
;

.include "math.asm"
.include "stdmacros.asm"

	set		r0,5

	push	r0
	call	factorial
	subl	sp,1

	;
	set 	r2,0
	set 	r3,0x80
	setmem	r2,r3,2
	nop

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
	set		r4,1
	cmp		r2,r4
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
	;subl	sp,0x20		;should underflow the stack
	mov		r0,r3
	pop		r3
	pop		r2
	leave
	ret

