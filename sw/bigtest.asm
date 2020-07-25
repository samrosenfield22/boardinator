;
; tests everything so far!
; (uart tx/rx, gpio i/o, timer, computation)
;
; read number in from rx => factorial => print result to tx
; led 0 blinks, delay is set by lower 2 switches
;

.include "stdmacros.asm"
.include "math.asm"
.include "time.asm"
.include "io.asm"


	;init sfrs
	sfr_write	MODEA,0xFF
	sfr_write	MODEB,0x00
	sfr_write	OUTA,0x00
	sfr_write	UARTCON,0x80	;i think? timer on, no loopback, lo baud, don't convert yet
	
	set		r3,0x00		;led value
	
	main_loop:
	
	;blink led according to button input (only the lower 2 buttons)
	sfr_read	r0,INB
	not		r0
	set		r2,0x03
	and		r0,r2
	
	cmpl r0,0
	jeq case_a
	cmpl r0,1
	jeq case_b
	cmpl r0,2
	jeq case_c
	cmpl r0,3
	jeq case_d
	;default
	jmp switch_end
	case_a:
	set		r0,250
	jmp switch_end
	case_b:
	set		r0,150
	jmp switch_end
	case_c:
	set		r0,75
	jmp switch_end
	case_d:
	set		r0,40
	jmp switch_end
	switch_end:
	
	set			r2,OUTA
	setm		r2,r3,SFR_REGION,0
	push		r0
	call		delay_ms
	subl		sp,1
	set			r2,0x01
	xor			r3,r2
	
	;if((UARTSTAT & 0x04)==0) goto main_loop;
	sfr_read	r0,UARTSTAT
	;testl		r0,0x04
	;jz		rx_loop
	set		r2,0x04
	and		r0,r2
	cmpl		r0,0
	jeq		main_loop

	;read RXREG, echo it to tx
	sfr_read	r0,RXREG
	push		r0
	call		send_uart_char
	subl		sp,1
	subl		r0,0x30
	
	;r0 = factorial(r0);
	push		r0
	call		factorial
	subl		sp,1

	;push		r0
	;push		r0
	;call		badmult8
	;subl		sp,2
	;mov			r0,r1

	;add			r0,r0
	;add			r0,r0
	;add			r0,r0

	;let's make sure factorial is computing correctly...
	;set 		r2,OUTA
	;setm		r2,r0,SFR_REGION,0
	;set 		r2,250
	;push 		r2
	;call		delay_ms
	;call		delay_ms
	;call		delay_ms
	;call		delay_ms
	;subl		sp,1
	
	;printf("%d\n", r2);
	set		r2,10
	push		r2
	push		r0
	call		uart_print_u8
	subl		sp,2
	set		r2,0x0A		;'\n'
	push		r2
	call		send_uart_char
	subl		sp,1
	
	jmp		main_loop
	

	

;;;;;;;;;;;;;;;;;;;;;;

	

