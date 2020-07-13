;
;
;

;.include "io.asm"

	;set port 0 to all outputs
	;set		r0,0xFF
	;;push	r0
	;set		r0,0
	;push	r0
	;call	port_mode
	;subl	sp,2

	;write pattern 0x55 to the port
	;set		r0,0x55
	;push	r0
	;set		r0,0
	;push	r0
	;call	write_port
	;subl	sp,2

	;set 	r0,0xFF
	;set 	r1,MODA
	;setm	r1,r0,SFR_REGION,0

	;set 	r0,0xDB
	;set 	r1,OUTA
	;setm	r1,r0,SFR_REGION,0

	set 	r0,5
	set 	r1,12
	add 	r0,r1


	end:
	jmp end
	