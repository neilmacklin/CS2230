#include <msp430.h>

#define SP r1                   ; you can define things in .S files
                                ; as well as use words like WDTPW

;------------------------------------------------------------------------------
; PROGRAM INSTRUCTIONS
        .text                   ; this section is for instructions
        .global MAIN
;------------------------------------------------------------------------------
MAIN:
        ; disable watchdog and run at 1Mhz
        mov     #WDTPW|WDTHOLD, &WDTCTL
        mov.b   &CALBC1_1MHZ,   &BCSCTL1
        mov.b   &CALDCO_1MHZ,   &DCOCTL

        ; initialize stack pointer
        mov     #0x400, SP

        mov.b   #0x10, &P1DIR   ; P1.4 as output, all other pins inputs
        bis.b   #0x08, &P1REN   ; enable resistor for P1.3
        mov.b   #0x08, &P1OUT   ; select pull-UP, also turn P1.4 off
        bis.b   #0x08, &P1IE    ; enable P1.3 to cause a PORT1_VECTOR interrupt
        bis.b   #0x08, &P1IES   ; select the FALLING edge to cause interrupt
        bic.b   #0x08, &P1IFG   ; clear flag because we are scared
        eint                    ; enable GLOBAL interrupts

        bis.b   #0xF0, r2       ; go to sleep HARD, HARDEST SLEEP POSSIBLE
;.Lloop:
 ;       jmp     .Lloop

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
; BUTTON INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------
BUTTON_ISR:
        xor.b   #0x10, &P1OUT   ; toggle the light  
        ; bit.b #0x08, &P1IN
        ; jc        BUTTON_ISR
        ; mov       #120, r15
        ; call  #delay_ms
        bic.b   #0x08, &P1IFG   ; tell hardware we did service the interrupt
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
        .word UNEXPECTED_ISR    ;0xfff2 (TIMER0_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff4 (WDT_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff6 (COMPARATORA_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff8 (TIMER1_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffa (TIMER1_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffc (NMI_VECTOR)
        .word MAIN              ;0xfffe (RESET_VECTOR)
        .end

