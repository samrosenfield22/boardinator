;
;
;

.include "stdmacros.asm"

	sfr_write 	UARTCON,0x84	;timer enabled, loopback enabled, baud lo, not started
	sfr_write	TXREG,0x55
	sfr_write	UARTCON,0x85	;start transmission

	;wait until transmission is done
	set 		r1,1
	tx_pending:
	sfr_read	r0,UARTSTAT
	and 		r0,r1
	cmpl		r0,1
	jeq			tx_pending

	sfr_write	MODEA,0xFF
	sfr_write	OUTA,0xFF

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	
	sfr_read	r2,RXREG

	end:
	jmp			end
