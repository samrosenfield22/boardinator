

; triangle number calculator using stack

	set		r1,6
	set 	r6,0	;initialize sp
	set 	r7,0	;initialize bp

	;push arg
	setstk	r6,r1
	set 	r5,1
	add 	r6,r5

	;push ret addr
	set 	r5,10
	setstk	r6,r5		;this doesn't actually do anything (other than update the sp), since we can't yet pc = pop()
	set 	r5,1
	add 	r6,r5

	;call triangle
	jmp triangle_func
	after_triangle:

	;restore sp
	set 	r5,2
	sub 	r6,r5

	end:
	jmp end


	;triangle function
	triangle_func:

	;push bp
	setstk	r6,r7
	set 	r5,1
	add 	r6,r5

	;set bp to sp
	mov 	r7,r6

	;make room for 2 local vars
	set 	r5,2
	add 	r6,r5

	;stack: 
	;0	arg (6)
	;1	ret
	;2	bp (0)
	;3	<= bp
	;4			(local "i")
	;5	<= sp	(local "tri")

	;i is at bp+1
	;tri is at bp+2
	;arg is at bp-3
	;ret is at bp-2

	;initialize i
	set 	r4,1	;i=1
	mov		r5,r7
	set 	r0,1
	add 	r5,r0	;i at bp+1
	setstk 	r5,r4

	;initialize tri
	set 	r4,0	;tri=0
	mov		r5,r7
	set 	r0,2
	add 	r5,r0	;tri at bp+2
	setstk 	r5,r4	

	;for(i=1; i<=arg; i++) tri+=i;

	tri_loop:

	;compare i to arg
	mov 	r5,r7
	set 	r0,1
	add 	r5,r0
	getstk 	r2,r5	;r2 now holds i
	mov 	r5,r7
	set 	r0,3
	sub 	r5,r0							;can this do add r5,-3?
	getstk 	r3,r5	;r3 now holds arg (6)

	;if i>arg goto exit
	cmp 	r2,r3
	jgt tri_exit

	;tri += i
	mov 	r5,r7
	set 	r0,2
	add 	r5,r0
	getstk 	r4,r5	;r4 now holds tri
	add 	r4,r2
	mov 	r5,r7
	set 	r0,2
	add 	r5,r0
	setstk	r5,r4	;update tri

	;i++
	set 	r1,1
	add 	r2,r1
	mov 	r5,r7
	set 	r0,1
	add 	r5,r0
	setstk	r5,r2	;update i

	jmp tri_loop

	tri_exit:

	;set r0 to tri
	mov 	r5,r7
	set 	r0,2
	add 	r5,r0
	getstk 	r0,r5	;r0 now holds tri

	;sp-=2
	;set 	r2,2
	;sub 	r6,r2
	;or we do
	set 	r6,r7

	;pop bp
	set		r5,1
	sub		r6,r5
	getstk	r7,r6

	;jmp back to main
	;this should be: pc = pop(). however, we currently can't jmp to a reg.
	;instead we'll just do:
	jmp after_triangle

