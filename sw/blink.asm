;
;
;

.include "stdmacros.asm"

	;set bank a to outputs
	set		r1,MODEA
	set		r2,0xFF
	setm	r1,r2,SFR_REGION,0


	;set up timer 0 (500ms delay given a 50/32 MHz clk freq)
	set 	r1,TMRCMP
	set 	r2,191
	setm	r1,r2,SFR_REGION,0
	set 	r1,TMRCON
	set 	r2,0x8D		;on (7)=1, prescale (3:0)=13
	setm	r1,r2,SFR_REGION,0

	;blink
	
	set 	r2,0xFF

	delay_loop_1:
	set 	r1,TMROUT
	getm 	r0,r1,SFR_REGION,0
	set 	r3,1
	and 	r0,r3
	cmpl 	r0,1
	jne		delay_loop_1
	delay_loop_2:
	getm 	r0,r1,SFR_REGION,0
	and 	r0,r3
	cmpl 	r0,0
	jne		delay_loop_2
	
	;
	set 	r1,OUTA
	setm	r1,r2,SFR_REGION,0

	cmpl	r2,0
	jne		set_r2_hi
	set 	r2,0xFF
	jmp 	delay_loop_1
	set_r2_hi:
	set 	r2,0
	jmp 	delay_loop_1





