;
;
;

.include "stdmacros.asm"

	set 	r0,2
	set 	r1,0x20
	setmem 	r0,r1,2

	set 	r0,1
	set 	r1,0x04
	setmem 	r0,r1,2

	end:
	jmp 	end
