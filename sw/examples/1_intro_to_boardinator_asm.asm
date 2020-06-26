;
;	Example 1 -- intro to Boardinator assembly
;	In this example, we'll compute the triangle function: tri(n) = 1+2+3+...+n.
;	This will be performed with a loop, which will demonstrate the use of conditional branching.
;	tri(8) = 36
;
;	Equivalent c code:
;	
;	uint8_t sum=0;
;	for(uint8_t i=8; i!=0; i--)
;	{
;		sum += i;
;	}
;

	;initialize the registers we need. r1 will be our index, and r0 will accumulate the results of the computation.
	;r2 will be used to compare the index to it (so we know when to break out of the loop)
	set		r1,8	;i=8
	set 	r0,0	;sum=0
	set 	r2,0

	tri_loop:		;label we can jump to

	;if(i == 0) goto end
	cmp 	r1,r2
	jeq 	end

	add 	r0,r1	;sum += i
	subl	r1,1	;i--
	jmp 	tri_loop

	;we're done! r0 now holds the value of our triangle function, 36 (0x24)

	end:
	jmp 	end



