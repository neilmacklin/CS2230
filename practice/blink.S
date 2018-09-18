#include <msp430.h>

#define SP r1                       ; you can define things in .S files
                                    ; as well as use words like WDTPW
#define SR r2
;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
        .text                       ; this section is for instructions
        .global MAIN
;------------------------------------------------------------------------------
MAIN:
        ; disable watchdog and run at 1Mhz
        mov     #WDTPW|WDTHOLD, &WDTCTL
        mov.b   &CALBC1_1MHZ,   &BCSCTL1
        mov.b   &CALDCO_1MHZ,   &DCOCTL

        ; initialize stack pointer
        mov     #0x400, SP

        ; happens once
        bis.b   #BIT6, &P1DIR ; BIT0 as output ;or BIT6 for the right light-green
	bis	#TASSEL_2|MC_1|ID_3, &TA0CTL ;or can be ID_0
	mov	#500, &TA0CCR0 	;max is 62500
	;bis	#CCIE, &TA0CCTL0 ;TIMER_ISR
	bis	#OUTMOD_4, &TA0CCTL1
	mov	#250, &TA0CCR1 ;where the begin starts
	bis.b	#BIT6, &P1SEL	;changing this # to be fading in/out

	;eint
	bis	#GIE|CPUOFF, SR
.Lloop:
        ; some code that happens
        ; over and over

        jmp     .Lloop              ; do it again

;------------------------------------------------------------------------------
; DELAY_MS FUNCTION
;------------------------------------------------------------------------------
delay_ms:
        mov     r15, r14
1:      mov     #245, r15
2:      dec     r15
        tst     r15
        jnz     2b
        dec     r14
        jnz     1b
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
	xor.b	#BIT0, &P1OUT ;or BIT6 for the right light thats green
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
        .word UNEXPECTED_ISR    ;0xffe0 
        .word UNEXPECTED_ISR    ;0xffe2 
        .word BUTTON_ISR        ;0xffe4 (PORT1_VECTOR)
        .word UNEXPECTED_ISR    ;0xffe6 (PORT2_VECTOR)
        .word UNEXPECTED_ISR    ;0xffe8 
        .word UNEXPECTED_ISR    ;0xffea (ADC10_VECTOR)
        .word UNEXPECTED_ISR    ;0xffec (USCIAB0TX_VECTOR) 
        .word UNEXPECTED_ISR    ;0xffee (USCIAB0RX_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff0 (TIMER0_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff2 (TIMER0_A0_VECTOR) (TIMER_ISR)
        .word UNEXPECTED_ISR    ;0xfff4 (WDT_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff6 (COMPARATORA_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff8 (TIMER1_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffa (TIMER1_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffc (NMI_VECTOR)
        .word MAIN              ;0xfffe (RESET_VECTOR)
        .end

