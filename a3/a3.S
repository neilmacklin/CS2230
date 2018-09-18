#include <msp430.h>

#define PC r0
#define SP r1
#define SR r2
#define CG r3

;------------------------------------------------------------------------------
; PROGRAM DATA
		.section .rodata	; this should be placed in ROM
;------------------------------------------------------------------------------
; is anything needed here?

;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
		.text				; this section is for instructions
		.global MAIN
;------------------------------------------------------------------------------
MAIN:
		; disable watchdog and run at 1Mhz
		mov		#WDTPW|WDTHOLD, &WDTCTL
		mov.b		&CALBC1_1MHZ,	&BCSCTL1
		mov.b		&CALDCO_1MHZ,	&DCOCTL		
		
		; initialize stack pointer
		mov		#0x400, SP		

		;inintalize
		bis.b	#BIT0|BIT6|BIT1, &P1DIR	
	        bis.b   #0x08, &P1REN   ; enable resistor for P1.3
	        mov.b   #0x08, &P1OUT   ; select pull-UP, also turn P1.4 off
	        bis.b   #0x08, &P1IE    ; enable P1.3 to cause a PORT1_VECTOR interrupt
	        bis.b   #0x08, &P1IES   ; select the FALLING edge to cause interrupt
	        bic.b   #0x08, &P1IFG   ; clear flag because we are scared
		
		;BLUE INTIALIZERS
		bis	#TASSEL_2|MC_1|ID_3, &TA0CTL
		mov	#31250, &TA0CCR0		
		bis	#OUTMOD_4, &TA0CCTL1
		bic.b	#BIT6, &P1SEL
		;BLUE INITIALIZERS

		;GREEN INITAILIZERS		
		;mov.b 	#0,&P1OUT
		bis	#TASSEL_2|MC_0|ID_3, &TA1CTL
		bis	#CCIE, &TA1CCTL0	
		bis.b	#BIT1, &P1DIR
		mov	#41666, &TA1CCR0		;interupt
		mov	#41666, &TA1CCR1
		;GREEN INITAILIZERS
		
		eint		
		mov	#0, r11
		
.Lloop:
;cmp's and jz's here for turning off the lights that aren't suppsoed to be on
		cmp	#4, r11
		jz	.Lloop
		cmp 	#3, r11
		jz 	.Lloop
		cmp 	#2, r11	
		jz 	.Lloop		
;turning on on off the red light 1/2 second
		xor.b	#BIT0, &P1OUT
		mov 	#500, r15
		call	#delay_ms		
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
; TIMER INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
TIMER_ISR:
		; timer code here
		xor.b	#BIT1, &P1OUT
		reti

;------------------------------------------------------------------------------
; BUTTON INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
BUTTON_ISR:
		
		push	r15
		push	r14
;r11 is the counter
		inc r11

;MODES (Once a button is pressed, then the mode can switch to one of these 4 modes, depending on the value of r11)		
		cmp	#4, r11	
		jz	.mode_reset
		cmp	#1, r11	
		jz	.mode_two
		cmp	#2, r11	
		jz	.mode_three
		cmp	#3, r11	
		jz	.mode_four		

.Ldebounce:
		bit.b		#0x08, &P1IN
		jnz		.Ldebounce
		mov		#120, r15
		call		#delay_ms
	
		bic.b		#BIT3, &P1IFG
		pop		r14
		pop		r15
		reti
;MODES
.mode_reset:
		bic.b	#BIT6, &P1SEL 	;blue off
		mov	#0, r11		;counter to 0
		bic	#MC_3, &TA1CTL	;green off
		jmp	.Ldebounce	
.mode_two:
		bis	#TASSEL_2|MC_1|ID_3, &TA1CTL	;turn on green, red stays on
		jmp	.Ldebounce		
		
.mode_three:
		bic.b 	#BIT0,&P1OUT	;turn off red
		bis.b	#BIT6, &P1SEL	;turn on blue, blue is already set 1/4 second
		jmp	.Ldebounce
.mode_four:
		mov	#TASSEL_2|MC_0|ID_3, &TA1CTL	;turn off green
		bic.b	#BIT1, &P1OUT			
		mov	#62500, &TA0CCR0		;blue is now set to 1/2 second
		jmp	.Ldebounce
		
;------------------------------------------------------------------------------
; INTERRUPT VECTORS
;------------------------------------------------------------------------------
		.section ".vectors", "ax", @progbits
		.word UNEXPECTED_ISR	;0xffe0
		.word UNEXPECTED_ISR	;0xffe2
		.word BUTTON_ISR	;0xffe4 (PORT1_VECTOR)
		.word UNEXPECTED_ISR	;0xffe6 (PORT2_VECTOR)
		.word UNEXPECTED_ISR	;0xffe8
		.word UNEXPECTED_ISR	;0xffea (ADC10_VECTOR)
		.word UNEXPECTED_ISR	;0xffec (USCIAB0TX_VECTOR)
		.word UNEXPECTED_ISR	;0xffee (USCIAB0RX_VECTOR)
		.word UNEXPECTED_ISR	;0xfff0 (TIMER0_A1_VECTOR)
		.word UNEXPECTED_ISR	;0xfff2 (TIMER0_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfff4 (WDT_VECTOR)
		.word UNEXPECTED_ISR	;0xfff6 (COMPARATORA_VECTOR)
		.word UNEXPECTED_ISR	;0xfff8 (TIMER1_A1_VECTOR)
		.word TIMER_ISR		;0xfffa (TIMER1_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfffc (NMI_VECTOR)
		.word MAIN		;0xfffe (RESET_VECTOR)
		.end

