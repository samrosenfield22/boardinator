;
;
;

.include "stdmacros.asm"

	;set timer compare value to 215
	set 	r0,TMRCMP
	set 	r1,215
	setmem 	r0,r1,SFR_REGION

	;set timer prescale value to 10 (clk/1024). timer is still off, nothing should happen
	set 	r0,TMRCON
	set 	r1,10
	setmem 	r0,r1,SFR_REGION

	;set TMRON bit, timer should go
	set 	r1,0x8A
	setmem	r0,r1,SFR_REGION

	;read MATCH bit
	set 	r0,5
	set 	r3,0x01

	wait_for_match:
	set 	r1,TMROUT
	getmem	r2,r1,SFR_REGION
	and 	r2,r3
	cmp 	r2,r3	;if(TMROUT & 1) == 1
	jne 	wait_for_match

	;match == 1!
	addl 	r0,1
	nop
	nop
	nop
	jmp 	wait_for_match


	end:
	jmp 	end
