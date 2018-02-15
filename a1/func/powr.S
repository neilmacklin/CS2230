	.file "func/powr.S"
	.text
.global powr
powr: 
	cmp #0,r14
	jz .zero
	cmp #1,r14
	jz .one
	clr r13
	mov r15,r11
	mov r15,r12
	dec r14
.loop: ;;Inner loop to add, is multiplying essentially
	add r11,r13
	dec r12
	jnz .loop	
.powerloop: ;;Outer loop to decrement and increase r11 which is what its 
	    	;;adding in the inner loop by
	mov r15,r12
	mov r13,r11
	clr r13		
	dec r14
	jnz .loop
.zero:
	clr r15
	mov #1,r15
	ret
.one:
	ret
.end:
	mov r11,r15
	ret
