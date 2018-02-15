	.file "mod.S"
	.text
.global mod
mod:
	clr r13
	cmp #0,r15 ;;Check if r15 is negative
	jl .changer15
	cmp #0,r14 ;;Check if r14 is negative
	jl .changer14     
.pos: ;;Positive Modulo               
	sub r14, r15       
	cmp r14, r15 
	jge .pos                                       
	ret
.neg: ;;Negative Modulo
	sub r14, r15       
	cmp r14, r15 
	jge .neg
	sub r14,r15                                       
	ret
.changer15: ;;Change negative r15 to positive
	inv r15
	inc r15
	cmp #0,r14 ;;Check if r14 is negative
	jl .r14Nr15
	jnz .neg
.changer14: ;;Change negative r14 to positive
	inv r14
	inc r14
	jnz .neg
.r14Nr15: ;;Only used when r14 and r15 are negative
	inv r14
	inc r14
	jnz .pos
