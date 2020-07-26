;
;
;

.include "stdmacros.asm"
.include "math.asm"

;arg is the char
;no return value
send_uart_char:
	
	subl		sp,3
	getm		r4,sp,STACK_REGION,0
	addl		sp,3

	set 		r5,TXREG
	setm 		r5,r4,SFR_REGION,0

	sfr_write	UARTCON,0x83

	;while((UARTSTAT & 1) == 1) {}
	send_loop:
	sfr_read	r1,UARTSTAT
	;set 		r5,1
	;and 		r1,r5
	;andl		r1,0x01
	;cmpl		r1,1
	;jz 			send_loop
	testl		r1,0x01
	jnz			send_loop
	

	sfr_write	UARTCON,0x82
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;arg0 is the number
;arg1 is the base
;
;[n,digit] = div(n,base)
;putchar(numtoascii(digit))

	uart_print_u8:
	enter
	
	push	r2
	push	r3
	set 	r3,0	;count the number of chars
	
	;get args into r0, r2
	subl	bp,4
	getm	r0,bp,STACK_REGION,0
	subl	bp,1
	getm	r2,bp,STACK_REGION,0
	addl	bp,5
	
	uart_print_u8_loop:
	push	r2
	push	r0
	call	div8
	subl	sp,2
	
	;convert r1 to ascii
	cmpl	r1,10
	jov		uart_print_u8_numeric_char
	addl	r1,0x37		;'A'-10
	jmp		uart_print_u8_char_converted
	uart_print_u8_numeric_char:
	addl	r1,0x30		;'0'
	uart_print_u8_char_converted:
	
	;print the char
	;push	r1
	;call	send_uart_char
	;subl	sp,1

	;push the digit on the stack (to reverse the order)
	push	r1
	addl	r3,1
	
	cmpl	r0,0
	jnz	uart_print_u8_loop

	;pop each digit off the stack, print it
	jmp		uart_print_u8_rev_cond
	uart_print_u8_rev_loop:
	call	send_uart_char
	subl	sp,1
	subl	r3,1
	uart_print_u8_rev_cond:
	cmpl	r3,0
	jnz		uart_print_u8_rev_loop	
	
	pop		r3
	pop 	r2
	
	leave
	ret
	


