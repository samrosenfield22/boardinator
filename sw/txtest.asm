;
;
;

.include "stdmacros.asm"

	sfr_write 	TXCON,0x80	;timer enabled, baud lo, not started
	sfr_write	TXREG,0x55
	sfr_write	TXCON,0x81	;start transmission

	;wait until transmission is done
	set 		r1,1
	tx_pending:
	sfr_read	r0,TXSTAT
	and 		r0,r1
	cmpl		r0,1
	jeq			tx_pending

	sfr_write	MODEA,0xFF
	sfr_write	OUTA,0xFF

	end:
	jmp			end
