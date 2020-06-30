;
;
;

.include "stdmacros.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void init_timer(u8 prescale, u8 compare)
;
; initializes the timer peripheral using the given clock prescaler and compare settings. assumes a 50MHz sysclk.
; use the SFR calculator (docs/sfr_calcluators.xlsx) to generate these values.
;
; args:
; prescale, the 4-bit setting for the clock prescaler (1x to 32768x)
; compare, the 8-bit compare value
;
; return: void
;
; comments:
; this function does not create a stack frame, and it uses sp-based offsets
;
	init_timer:

	;read compare arg, write it to SFR
	subl 	sp,4
	getm 	r4,sp,STACK_REGION,0
	set 	r5,TMRCMP
	setm	r5,r4,SFR_REGION,0		;if we had "orl", we could do a decrement setm here, then below we wouldn't need set r5,TMRCON

	addl	sp,1
	getm 	r4,sp,STACK_REGION,0	;prescale
	set 	r5,TMRON
	or		r4,r5
	set 	r5,TMRCON
	setm	r5,r4,SFR_REGION,0
	addl	sp,3

	ret


	delay:


	ret

