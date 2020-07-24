;
;
;

.include "stdmacros.asm"
.include "time.asm"

.define "writechar c" "set r0,c\n push r0\n call send_uart_char\n subl sp,1"

;.define "writechar c" "set r0,c\n push r0\n call send_uart_char\n subl sp,1\n set r0,5\n push r0\n call delay_ms\n subl sp,1\n sfr_write UARTCON,0x80"
	
	sfr_write	UARTCON,0x80	;timer enabled, no loopback, lo baud

	;set 		r0,0x68	;'h'
	;push 		r0
	;call 		send_uart_char
	;subl		sp,1

	;set 		r0,100
	;push 		r0
	;call 		delay_ms
	;subl 		sp,1
	;sfr_write	TXREG,0x69	;'i'

	;set 		r0,100
	;push 		r0
	;call 		delay_ms
	;subl 		sp,1
	;sfr_write	UARTCON,0x00

	writechar	0x68	;'h'
	writechar	0x65	;'e'
	writechar	0x6c	;'l'
	writechar	0x6c	;'l'
	writechar	0x6f	;'o'

	sfr_write	MODEA,0x01
	set 		r2,250

	blink_loop:
	sfr_write	OUTA,0x01
	push		r2
	call		delay_ms
	subl		sp,1

	sfr_write	OUTA,0x00
	push		r2
	call		delay_ms
	subl		sp,1

	sfr_write	UARTCON,0x00	;disable
	jmp			blink_loop

	end:
	jmp			end	

	

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


