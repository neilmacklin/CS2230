#include <msp430.h>

#define SP r1				; you can define things in .S files
							; as well as use words like WDTPW

;------------------------------------------------------------------------------
; PROGRAM DATA
		.section .rodata	; this should be placed in ROM
;------------------------------------------------------------------------------
FORMAT:	.string "%s\n\r"
OFF:	.string "OFF"
RED:	.string "RED"
GREEN:	.string "GREEN"
YELLOW:	.string "YELLOW"
BLUE:	.string "BLUE"
PURPLE:	.string "PURPLE"
CYAN:	.string "CYAN"
WHITE:	.string "WHITE"



		.p2align 1,0
ARRAY:	.word OFF
	.word RED
	.word GREEN
	.word YELLOW
	.word BLUE
	.word PURPLE
	.word CYAN
	.word WHITE

;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
        .text				; this section is for instructions
	.global MAIN
;------------------------------------------------------------------------------
MAIN:
        ; disable watchdog and run at 1Mhz
        mov     #WDTPW|WDTHOLD, &WDTCTL
        mov.b   &CALBC1_1MHZ,   &BCSCTL1
        mov.b   &CALDCO_1MHZ,   &DCOCTL

        ; initialize stack pointer
        mov     #0x400, SP

		; initialize serial communication
	mov	#9600, r15
	call	#serial_init
	
	mov.b   #0x10, &P1DIR   ; P1.4 as output, all other pins inputs
        bis.b   #0x08, &P1REN   ; enable resistor for P1.3
        mov.b   #0x08, &P1OUT   ; select pull-UP, also turn P1.4 off
        bis.b   #0x08, &P1IE    ; enable P1.3 to cause a PORT1_VECTOR interrupt
        bis.b   #0x08, &P1IES   ; select the FALLING edge to cause interrupt
        bic.b   #0x08, &P1IFG   ; clear flag because we are scared
        eint                    ; enable GLOBAL interrupts

	mov	#ARRAY, r11 ; pointer to array in r11
	mov.b	#0x07, &P2DIR		
	clr	r7

.Lloop:
	mov.b	r7, &P2OUT	
	mov     #1500, r15      ; wait for 1.5s
        call    #delay_ms
	cmp	#7, r7		
	jz	restartLoop
	inc 	r7		; change the color
	incd	r11		; change the word to match the color
	jmp	.Lloop	
	
restartLoop:
	clr 	r7
	mov	#ARRAY, r11
	jmp	.Lloop
;------------------------------------------------------------------------------
; DELAY_MS FUNCTION
;------------------------------------------------------------------------------
delay_ms:
		mov		r15, r14
1:		mov		#245, r15
2:		dec		r15
		tst		r15
		jnz		2b
		dec		r14
		jnz		1b
		ret

;------------------------------------------------------------------------------
; UNEXPECTED INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
UNEXPECTED_ISR:
        reti

;------------------------------------------------------------------------------
; BUTTON INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
BUTTON_ISR:
	mov	r15, r9		; move r15 to r9 temporarily
	mov	r14, r8		; move r14 to r8 temporarily
	push	@r11		; push value r11 is pointing at
	push	#FORMAT		; push address of FORMAT
	call	#cio_printf 	; call cio_printf("%s\n\r", *r11)
	add	#4, SP		; move SP back 4 bytes or	
Ldebounce:
	bit.b	#0x08, &P1IN
	jz	Ldebounce
	mov	#120, r15
	call	#delay_ms
	mov	r9, r15		; move back r9 to r15
	mov	r8, r14		; move back r8 to r14
	bic.b	#0x08, &P1IFG	; clears flag
        reti

;------------------------------------------------------------------------------
; INTERRUPT VECTORS
;------------------------------------------------------------------------------
        .section ".vectors", "ax", @progbits
        .word UNEXPECTED_ISR    ;0xffe0 
        .word UNEXPECTED_ISR    ;0xffe2 
        .word BUTTON_ISR	;0xffe4 (PORT1_VECTOR)
        .word UNEXPECTED_ISR    ;0xffe6 (PORT2_VECTOR)
        .word UNEXPECTED_ISR    ;0xffe8 
        .word UNEXPECTED_ISR    ;0xffea (ADC10_VECTOR)
        .word UNEXPECTED_ISR    ;0xffec (USCIAB0TX_VECTOR) 
        .word UNEXPECTED_ISR    ;0xffee (USCIAB0RX_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff0 (TIMER0_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff2 (TIMER0_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff4 (WDT_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff6 (COMPARATORA_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff8 (TIMER1_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffa (TIMER1_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffc (NMI_VECTOR)
        .word MAIN              ;0xfffe (RESET_VECTOR)
        .end

