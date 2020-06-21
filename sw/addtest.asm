;
; let's test the add16 function
;

.include "math.asm"
.include "stdmacros.asm"

	set 	r0,0x2A
	set 	r1,0xE1

	set 	r2,0x88
	set 	r3,0xFF

	push	r3
	push	r2
	push	r1
	push	r0
	call	add16
	subl	sp,4

	;shift_r_test:
	;set 	r0,0x80
	;set 	r1,0
	;set 	r2,2
	;shift_r_loop:
	;cmp 	r0,r1
	;jeq		end
	;lsr 	r0,r2
	;jmp 	shift_r_loop


	set 	r0,0
	set 	r1,1
	set 	r2,0
	set 	r3,1
	shift_loop:
	push	r3
	push	r1
	push	r0
	call	lsl16
	subl	sp,3
	cmp 	r0,r2
	jne 	shift_loop
	cmp 	r1,r2
	jne 	shift_loop


	end:
	jmp		end
