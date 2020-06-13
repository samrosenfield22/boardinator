;
;	find prime numbers
;

;
	main:
	set		r2,2
	set		r4,1

	;"call" the function
	main_loop:
	jmp check_prime_sub
	after_sub_call:
	cmp 	r1,r4
	jne		main_incr
	mov		r0,r2	;"display" the prime

	main_incr:
	add		r2,r4
	jmp		main_loop


; check if a number (r2) is prime
; if it is, set r1 to 1. if not, set it to 0.
	check_prime_sub:
	set		r7,2
	set		r6,1

	prime_loop:
	cmp		r7,r2
	jeq		is_prime	;r2 is prime
	jgt		is_prime

	;r2 mod r7
	mov		r3,r2
	mod_loop:
	cmp		r3,r7
	jeq		not_prime	;divisible
	jlt		prime_incr	;not divisible
	sub		r3,r7
	jmp		mod_loop

	prime_incr:
	add		r7,r6
	jmp		prime_loop

	not_prime:
	set		r1,0
	jmp		after_sub_call

	is_prime:
	set		r1,1
	jmp after_sub_call
