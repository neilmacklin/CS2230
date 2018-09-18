#include <msp430.h>

#define SP r1                       ; you can define things in .S files
                                    ; as well as use words like WDTPW

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
        bis.b   #0b00000111, &P2DIR ; P1.4 as output

.Lloop:
        ; some code that happens
        ; over and over
mov.b   #BIT0, &P2OUT ; red
        mov     #10000, r15          ; wait for 100ms
	        
	call    #delay_ms

mov.b   #BIT1, &P2OUT ; green
        mov     #10000, r15          ; wait for 100ms
        
	call    #delay_ms

mov.b   #BIT2, &P2OUT ; blue
        mov     #10000, r15          ; wait for 100ms
        
	call    #delay_ms

mov.b   #0b00000101, &P2OUT ; purple(red & blue)
        mov     #10000, r15          ; wait for 100ms
        
	call    #delay_ms

mov.b   #0b00000011, &P2OUT ; yellow(red & green)
        mov     #10000, r15          ; wait for 100ms

        call    #delay_ms

mov.b   #0b00000110, &P2OUT ; cyan(green & blue)
        mov     #10000, r15          ; wait for 100ms

        call    #delay_ms              ; do it again

mov.b   #0b00000111, &P2OUT ; white(red, blue and green)
        mov     #10000, r15          ; wait for 100ms

        call    #delay_ms
mov.b   #0b00000000, &P2OUT ; OFF
        mov     #10000, r15          ; wait for 100ms

        call    #delay_ms

	jmp     .Lloop
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
        .word UNEXPECTED_ISR    ;0xfff2 (TIMER0_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff4 (WDT_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff6 (COMPARATORA_VECTOR)
        .word UNEXPECTED_ISR    ;0xfff8 (TIMER1_A1_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffa (TIMER1_A0_VECTOR)
        .word UNEXPECTED_ISR    ;0xfffc (NMI_VECTOR)
        .word MAIN              ;0xfffe (RESET_VECTOR)
        .end

