;
;	fibonnaci (sic) sequence
;	we don't have loops yet (no jmp in the processor) so do it a fixed number of iterations
;

; init
	set		r0,1
	set		r1,1
	set		r2,1

; do the thing
	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	

