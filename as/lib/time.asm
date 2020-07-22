;
; time.asm
;

.include "stdmacros.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void init_timer(u8 prescale, u8 compare)
;
; initializes the timer peripheral using the given clock prescaler and compare settings. assumes a (50/32)MHz sysclk.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;clk is (50/32)MHz
.define "MS_TMRCMP"	"195"
.define "MS_TMRCON"	"0x83"	;0x80 | prescale
	delay_ms:

	push		r0
	push		r1

	subl		sp,5
	getm		r0,sp,STACK_REGION,0
	addl		sp,5

	sfr_write	TMRCON,0x00		;turn off timer to reset counter
	sfr_write	TMRCMP,MS_TMRCMP
	sfr_write	TMRCON,MS_TMRCON

	set 		r4,TMRSTAT
	jmp			delay_ms_cond

	;while((TMRSTAT & 1) != 1) {}
	delay_ms_loop:
	getm		r1,r4,SFR_REGION,0
	set 		r5,1
	and			r1,r5
	cmpl 		r1,1
	jne			delay_ms_loop

	;while((TMRSTAT & 1) == 1) {}
	delay_ms_wait_til_lo:
	getm		r1,r4,SFR_REGION,0
	set 		r5,1
	and			r1,r5
	cmpl 		r1,1
	jeq			delay_ms_wait_til_lo

	subl		r0,1

	delay_ms_cond:
	cmpl		r0,0
	jne			delay_ms_loop
	
	pop			r1
	pop			r0
	ret

