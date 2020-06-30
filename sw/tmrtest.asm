;
;
;

.include "stdmacros.asm"
.include "time.asm"	
	
	set 	r0,134
	push	r0
	set 	r0,13
	push 	r0
	call init_timer
	subl	sp,2

	set 	r0,MODEA
	set 	r1,0xFF
	setm	r0,r1,SFR_REGION,0



	set 	r0,5
	set 	r3,0x01
	
	delay_loop:

	wait_for_match_hi:
	set 	r1,TMROUT
	getm	r2,r1,SFR_REGION,0
	and 	r2,r3
	cmpl 	r2,1	;if(TMROUT & 1) == 1
	jne 	wait_for_match_hi

	wait_for_match_lo:
	set 	r1,TMROUT
	getm	r2,r1,SFR_REGION,0
	and 	r2,r3
	cmpl 	r2,0	;if(TMROUT & 1) == 1
	jne 	wait_for_match_lo

	;match == 1
	addl 	r0,1
	set 	r1,OUTA
	setm	r1,r0,SFR_REGION,0
	jmp 	delay_loop


	end:
	jmp 	end
