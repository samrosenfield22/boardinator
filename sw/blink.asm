;
;
;

.include "stdmacros.asm"
.include "time.asm"


	;set up sfrs
	sfr_write	MODEA,0xFF		;PORT A all outputs
	;sfr_write	TMRCMP,191		;set up timer 0 (500ms delay given a 50/32 MHz clk freq)
	;sfr_write	TMRCON,0x8C

	set 	r2,0xFF

	;blink

	;while((TMRSTAT & 1)!=1) {} 
	delay_loop_1:
	;sfr_read	r0,TMRSTAT
	;set 	r3,1
	;and 	r0,r3
	;cmpl 	r0,1
	;jne		delay_loop_1

	;while((TMRSTAT & 1)!=0) {}
	;delay_loop_2:
	;sfr_read	r0,TMRSTAT
	;and 	r0,r3
	;cmpl 	r0,0
	;jne		delay_loop_2

	set 	r3,250
	push	r3
	call	delay_ms
	call 	delay_ms
	subl	sp,1
	
	;OUTA = r2
	set 	r1,OUTA
	setm	r1,r2,SFR_REGION,0

	;r2 ^= 0xFF
	set 	r4,0xFF
	xor		r2,r4
	jmp		delay_loop_1




