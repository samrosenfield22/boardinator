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

	subl	sp,6

	end:
	jmp		end
	