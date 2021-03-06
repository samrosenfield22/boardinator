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
;
; comments:
; this function does not create a stack frame, and it uses sp-based offsets
;
	add16:

	subl sp,3
	getm r0,sp,STACK_REGION,0 ;r0 is a_hi (arg0)
	subl sp,1
	getm r1,sp,STACK_REGION,0 ;r1 is a_lo (arg1)
	subl sp,1
	getm r5,sp,STACK_REGION,0 ;r5 is b_hi (arg2)
	subl sp,1
	getm r4,sp,STACK_REGION,0 ;r4 is b_lo (arg3)
	addl sp,6

	;
	set r2,0

	;add lower bytes
	add r1,r4
	jov add16_lo_ovflw
	jmp add16_add_hi_bytes

	add16_lo_ovflw:
	addl r0,1
	jov add16_hi_ovflw_1
	jmp add16_add_hi_bytes

	add16_hi_ovflw_1:
	set r2,1

	add16_add_hi_bytes:
	add r0,r5
	jov add16_hi_ovflw_2
	jmp add16_exit

	add16_hi_ovflw_2:
	set r2,1

	add16_exit:
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
;
; comments:
; this function does not create a stack frame, and it uses sp-based offsets
;
	lsl16:

	push	r2

	subl sp,4
	getm r0,sp,STACK_REGION,0 ;r0 is in_hi (arg0)
	subl sp,1
	getm r1,sp,STACK_REGION,0 ;r1 is in_lo (arg1)
	subl sp,1
	getm r2,sp,STACK_REGION,0 ;r5 is bits (arg2)
	addl sp,6

	cmpl 	r2,8
	jov		lsl16_shift_less_than_half

	lsl16_shift_half:
	mov 	r0,r1
	set 	r1,0
	lsl 	r0,r2
	jmp 	lsl16_exit

	;upper = (upper<<b) | (lower>>(8-b))
	lsl16_shift_less_than_half:
	lsl 	r0,r2	;(upper<<b)
	set 	r5,8
	sub 	r5,r2	;r5 = 8-b
	mov 	r4,r1
	lsr 	r4,r5	;lower>>(8-b)
	or 		r0,r4

	lsl 	r1,r2

	lsl16_exit:
	pop		r2
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; u16 mult8(u8 a, u8 b)
;
; multiplies 2 8-bit numbers using the shift-and-add method
;
; args:
; a and b, the multiplicands
;
; return:
; [r0:r1], the product
;
; note: THIS DOES NOT WORK CORRECTLY! using the less efficient (but correctly working) version below
;
	;mult8:
	;enter

	;;u16 sum=0
	;;u8 mask=1
	;;for(u8 i=0; i<8; i++)
	;;	if(b & mask)
	;;		sum += (a<<i)
	;;	mask<<=1

	;;reserve 3 bytes of locals
	;mklcl 	3

	;;save some regs
	;push 	r2
	;push 	r3

	;;i=0, sum=0, mask=1
	;set 	r2,0	;i = 0	
	;set 	r0,0
	;setlcl	0,r0	;sum (hi) = 0
	;setlcl	1,r0	;sum (lo) = 0
	;set 	r0,1
	;setlcl	2,r0	;mask = 1

	;mult8_loop:

	;;if(i > 7) goto exit
	;cmpl	r2,7
	;jgt 	mult8_exit

	;;if((b & mask) != 0) ...
	;getarg	r1,1	;b
	;getlcl	r3,2	;mask
	;and 	r1,r3
	;cmpl	r1,0
	;jnz		mult8_shift_and_add
	;jmp		mult8_loop_end

	;mult8_shift_and_add:

	;;a<<i
	;set 	r0,0
	;getarg	r1,0	;a
	;push	r2		;shift by i bits
	;push	r1
	;push	r0
	;call	lsl16
	;subl	sp,3

	;;sum += (a<<i)
	;getlcl	r3,0	;sum
	;getlcl	r4,1
	;push	r4
	;push	r3
	;push	r1
	;push	r0
	;mov		r3,r2	;add16 is going to overwrite r2 (i) with the overflow boolean
	;call	add16
	;subl	sp,4
	;setlcl	0,r0
	;setlcl	1,r1
	;mov		r2,r3

	;mult8_loop_end:

	;;mask<<=1
	;getlcl	r0,2
	;set 	r1,1
	;lsl 	r0,r1
	;setlcl	2,r0

	;;i++
	;addl 	r2,1
	;jmp 	mult8_loop

	;mult8_exit:
	;getlcl	r0,0
	;getlcl	r1,1
	;pop 	r3
	;pop		r2
	;leave
	;ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
	mult8:

	subl	sp,3
	getm	r4,sp,STACK_REGION,0
	subl	sp,1
	getm	r5,sp,STACK_REGION,0
	addl	sp,4

	;for(r5=b; r5!=0; r5--) {sum += r4;}
	set 	r0,0
	jmp		mult_loop_cond
	mult_loop:
	add 	r0,r4
	subl	r5,1
	mult_loop_cond:
	cmpl	r5,0
	jnz		mult_loop

	ret

;;;;;;;;;;;;;;;;;;;;;;;
; computes div (in r0) and mod (in r1)
; no stack frame
	
	div8:
	
	push	r2
	
	subl	sp,4
	getm	r1,sp,STACK_REGION,0
	subl	sp,1
	getm	r2,sp,STACK_REGION,0
	addl	sp,5
	
	;no div by 0 pls
	cmpl	r2,0
	jnz	div8_legal
	sfr_write	RSTCON,0x80	;software reset this bad boy
	div8_legal:
	
	;for(; r1>=r2; r1-=r2) {r0++;}
	set		r0,0
	jmp		div8_cond
	div8_loop:
	addl	r0,1
	sub		r1,r2
	div8_cond:
	cmp 	r2,r1
	jov		div8_loop
	jz		div8_loop
	
	pop	r2
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;
	factorial:
	enter

	push	r2
	;push	r3


	factorial_init:
	getarg 	r0,0
	mov 	r2,r0
	jmp		factorial_loop_cond

	factorial_loop:

	;fact *= i
	push	r0
	push	r2
	call	mult8
	subl	sp,2
	

	factorial_loop_cond:
	subl	r2,1
	cmpl	r2,2
	jnov	factorial_loop


	;factorial_init:
	;getarg 	r2,0
	;set		r3,1
	;
	;factorial_loop:
	;cmpl	r2,1
	;jz		factorial_exit
	;
	;;fact *= i
	;push	r3
	;push	r2
	;call	mult8
	;subl	sp,2
	;mov		r3,r0
	;
	;factorial_loop_end:
	;subl	r2,1
	;jmp		factorial_loop
	;
	;factorial_exit:
	
	;mov		r0,r3
	;pop		r3
	pop		r2
	leave
	ret



