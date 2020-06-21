;
;	test the mult8 function
;

.include "math.asm"
.include "stdmacros.asm"

.define "multiply a,b" "set r0,a\nset r1,b\npush r1\npush r0\ncall mult8\nsubl sp,2\nnop\nnop\nnop"

	;set		r0,0x4A
	;set		r1,0x11

	;push	r1
	;push	r0
	;call	mult8
	;subl	sp,2

	set		r2,0x55
	set		r3,0xAA

	;multiply 0x4A,0x11
	;multiply 0x00,0xFF
	multiply 0xFF,0xFF


	end:
	jmp end
