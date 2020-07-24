;
;
;

.include "stdmacros.asm"
.include "time.asm"

.define "writechar c" "set r0,c\n push r0\n call send_uart_char\n subl sp,1"

	sfr_write	MODEA,0xFF
	sfr_write	OUTA,0x01
	sfr_write	UARTCON,0x80	;timer enabled, no loopback, lo baud

	writechar	0x68	;'h'
	writechar	0x65	;'e'
	writechar	0x6c	;'l'
	writechar	0x6c	;'l'
	writechar	0x6f	;'o'

	sfr_write	OUTA,0x02

	wait_for_rx:
	set 		r1,0x04		;RXAVAIL bit
	sfr_read	r0,UARTSTAT
	and			r0,r1
	cmpl		r0,0
	jeq 		wait_for_rx

	;set 		r1,0x02		;RXBUSY bit
	;sfr_read	r0,UARTSTAT
	;and			r0,r1
	;cmpl		r0,0
	;jne 		wait_for_rx

	;sfr_write	OUTA,0x04
	;end:
	;jmp 		end

	

	;sfr_read 	r0,RXREG
	;set 		r1,TXREG
	;setm 		r1,r0,SFR_REGION,0
	;push		r1
	;call		send_uart_char
	;subl		sp,1

	sfr_read	r0,RXREG
	subl		r0,0x30		;'0'
	set 		r1,OUTA
	setm 		r1,r0,SFR_REGION,0

	jmp			wait_for_rx

	

;arg is the char
send_uart_char:
	
	subl		sp,3
	getm		r4,sp,STACK_REGION,0
	addl		sp,3

	set 		r5,TXREG
	setm 		r5,r4,SFR_REGION,0

	sfr_write	UARTCON,0x81

	;while((UARTSTAT & 1) == 1) {}
	send_loop:
	sfr_read	r1,UARTSTAT
	set 		r5,1
	and 		r1,r5
	cmpl		r1,1
	jeq 		send_loop

	sfr_write	UARTCON,0x80
	ret


