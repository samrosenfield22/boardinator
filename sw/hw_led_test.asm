;
;
;

.include "io.asm"

	;set port 0 to all outputs
	set		r0,0xFF
	push	r0
	set		r0,0
	push	r0
	call	port_mode
	subl	sp,2

	;write pattern 0x55 to the port
	set		r0,0x55
	push	r0
	set		r0,0
	push	r0
	call	write_port
	subl	sp,2

	end:
	jmp end
	