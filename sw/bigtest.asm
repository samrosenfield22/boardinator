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

	;read RXREG, make sure it's correct
	sfr_read	r0,RXREG
	push		r0
	call		send_uart_char
	subl		sp,1
	subl		r0,0x30
	
	;r0 = factorial(RXREG);
	;push		r0
	;call		factorial
	;subl		sp,1

	;let's make sure factorial is computing correctly...
	set 		r2,OUTA
	setm		r2,r0,SFR_REGION,0
	set 		r2,250
	push 		r2
	call		delay_ms
	call		delay_ms
	call		delay_ms
	call		delay_ms
	subl		sp,1
	
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
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;arg0 is the number
;arg1 is the base
;
;[n,digit] = div(n,base)
;putchar(numtoascii(digit))

	uart_print_u8:
	enter
	
	push	r2
	
	;get args into r0, r2
	subl	bp,4
	getm	r0,bp,STACK_REGION,0
	subl	bp,1
	getm	r1,bp,STACK_REGION,0
	addl	bp,5
	
	;
	push	r2
	uart_print_u8_loop:
	push	r0
	call	div8
	subl	sp,1	;leave r2 on the stack
	
	;convert r1 to ascii
	cmpl	r1,10
	jlt		uart_print_u8_numeric_char
	addl	r1,0x41		;'A'
	jmp		uart_print_u8_char_converted
	uart_print_u8_numeric_char:
	addl	r1,0x30		;'0'
	uart_print_u8_char_converted:
	
	;print the char
	push	r1
	call	send_uart_char
	subl	sp,1
	
	cmpl	r0,0
	jne	uart_print_u8_loop
	
	;restore sp from previous 
	subl	sp,1
	
	pop	r2
	
	leave
	ret
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;
	factorial:
	enter

	push	r1
	push	r2
	push	r3

	factorial_init:
	getarg 	r2,0
	set		r3,1

	factorial_loop:
	cmpl	r2,1
	jeq		factorial_exit

	;fact *= i
	push	r3
	push	r2
	call	mult8
	subl	sp,2
	mov		r3,r1

	factorial_loop_end:
	subl	r2,1
	jmp		factorial_loop

	factorial_exit:
	mov		r0,r3
	pop		r3
	pop		r2
	pop 	r1
	leave
	ret



