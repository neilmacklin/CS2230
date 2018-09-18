#include <msp430.h>

#define SP r1						; you can define things in .S files
									; as well as use words like WDTPW

; 1/2 second - 62500
		;1/4 = 31,250
		;1/3 = 41,666
;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
		.text						; this section is for instructions
		.global MAIN
;------------------------------------------------------------------------------
MAIN:

; disable watchdog and run at 1Mhz
mov		#WDTPW|WDTHOLD, &WDTCTL
mov.b	&CALBC1_1MHZ,	&BCSCTL1
mov.b	&CALDCO_1MHZ,	&DCOCTL

; initialize stack pointer

		; disable watchdog and run at 1Mhz
		mov		#WDTPW|WDTHOLD, &WDTCTL
		mov.b	&CALBC1_1MHZ,	&BCSCTL1
		mov.b	&CALDCO_1MHZ,	&DCOCTL

		; initialize stack pointer
		mov		#0x400, SP

		; happens once
		bis.b	#BIT1, &P1DIR		; P1.6 as output
		bis		#TASSEL_2|MC_1|ID_3, &TA1CTL
		mov.b #0,&P1OUT
		mov		#41666, &TA1CCR0
		mov		#41666, &TA1CCR1
		bis		#CCIE, &TA1CCTL0

		bis		#GIE|CPUOFF, r2
.Lloop:
		jmp		.Lloop				; do it again

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
		xor.b	#BIT1, &P1OUT
		reti

;------------------------------------------------------------------------------
; BUTTON INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
BUTTON_ISR:
		; do something
		reti

;------------------------------------------------------------------------------
; INTERRUPT VECTORS
;------------------------------------------------------------------------------
		.section ".vectors", "ax", @progbits
		.word UNEXPECTED_ISR	;0xffe0
		.word UNEXPECTED_ISR	;0xffe2
		.word BUTTON_ISR			;0xffe4 (PORT1_VECTOR)
		.word UNEXPECTED_ISR	;0xffe6 (PORT2_VECTOR)
		.word UNEXPECTED_ISR	;0xffe8
		.word UNEXPECTED_ISR	;0xffea (ADC10_VECTOR)
		.word UNEXPECTED_ISR	;0xffec (USCIAB0TX_VECTOR)
		.word UNEXPECTED_ISR	;0xffee (USCIAB0RX_VECTOR)
		.word UNEXPECTED_ISR	;0xfff0 (TIMER0_A1_VECTOR)
		.word UNEXPECTED_ISR		;0xfff2 (TIMER0_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfff4 (WDT_VECTOR)
		.word UNEXPECTED_ISR	;0xfff6 (COMPARATORA_VECTOR)
		.word UNEXPECTED_ISR				;0xfff8 (TIMER1_A1_VECTOR)
		.word TIMER_ISR	;0xfffa (TIMER1_A0_VECTOR)
		.word UNEXPECTED_ISR	;0xfffc (NMI_VECTOR)
		.word MAIN				;0xfffe (RESET_VECTOR)
		.end
