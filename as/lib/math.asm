;
; math.asm: math and logic functions for various word lengths
;

.include "stdmacros.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (u16,u8) add16(u16 a, u16 b)
;
; adds 2 16-bit numbers
;
; args:
; [arg0:arg1] a, the 1st 16-bit word
; [arg2:arg3] b, the 2nd 16-bit word
;
; return:
; [r0:r1], the sum
; r2, 1 if the addition overflowed, else 0
add16:
	enter

	getarg	r0,0	;a_hi
	getarg	r1,1	;a_lo
	getarg	r2,3	;b_lo
	getarg	r3,2	;b_hi

	;add lower bytes
	add 	r1,r2
	jovf	add16_lo_ovflw
	jmp 	add16_add_hi_bytes

	add16_lo_ovflw:
	addl 	r0,1
	jovf	add16_hi_ovflw_1
	jmp 	add16_add_hi_bytes

	add16_hi_ovflw_1:
	set 	r2,1

	add16_add_hi_bytes:
	add 	r0,r3
	jovf	add16_hi_ovflw_2

	;neither high addition overflowed
	set 	r2,0
	jmp 	add16_exit

	add16_hi_ovflw_2:
	set 	r2,1

	add16_exit:
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; u16 lsl16(u16 n, u8 bits)
;
; left-shifts a 16-bit word by the specified number of bits, filling right-hand bits with zeros
;
; args:
; [arg0:arg1] n, the 16-bit word to shift
; arg2 bits, the number of bits to shift by
;
; return:
; [r0:r1], the shifted word
lsl16:
	enter

	;save some regs
	push 	r2
	push 	r3
	push	r4

	getarg	r0,0
	getarg	r1,1
	getarg	r2,2

	set 	r3,8
	cmp		r2,r3
	jlt		lsl16_shift_less_than_half

	lsl16_shift_half:
	set 	r1,0
	getarg	r0,1
	lsl 	r0,r2
	jmp 	lsl16_exit

	;upper = (upper<<b) | (lower>>(8-b))
	lsl16_shift_less_than_half:
	lsl 	r0,r2
	set 	r3,8
	sub 	r3,r2	;r3 = 8-b
	mov 	r4,r1
	lsr 	r4,r3
	or 		r0,r4

	lsl 	r1,r2

	lsl16_exit:
	pop		r4
	pop		r3
	pop		r2
	leave
	ret
