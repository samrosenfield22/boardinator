;
;	fibonnaci (sic) sequence
;

; init
	set		r0,1
	set		r1,1
	set		r2,1
	set		r7,0	;loop index
	set		r6,5
	set		r5,1

	fib_loop:
	cmp		r7,r6
	jgt		fib_end

	;compute an interation
	add		r1,r2
	mov		r3,r1	;swap r1 and r2 (using r3)
	mov		r1,r2
	mov		r2,r3
	mov		r0,r1	;output value

	add		r7,r5	;r7 += r5
	jmp		fib_loop

	fib_end:
	jmp		fib_end


