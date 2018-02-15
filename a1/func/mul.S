	.file "func/mul.S"
	.text
.global mul
mul:
	clr r13
	cmp #0,r14 ;;Check if r14 is negative
	jl .changer14
.posMain:
	add r15,r13
	dec r14
	jnz .posMain
	mov r13, r15
	ret
.negMain: ;;If r14 is negative
	add r15,r13
	dec r14
	jnz .negMain
	sub r13,r12 ;;Change r14 back to negative
	mov r12, r15
	ret
.changer14: ;;Change r14 to positive, if negative
	inv r14
	inc r14
	jnz .negMain
