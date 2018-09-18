#include <msp430.h>
#include <libemb/serial/serial.h>
#include <libemb/conio/conio.h>
#include <stdio.h>

int main(void) {
	WDTCTL = WDTPW | WDTHOLD;
	BCSCTL1 = CALBC1_1MHZ;
	DCOCTL = CALDCO_1MHZ;

	P1DIR = BIT0;//BIT0 is the same as the number 1
	P1OUT = 1;//same as BIT0
	
	serial_init(9600);
	for(;;) {
		cio_printf("Hello, World!\n\r");
//		P1OUT ^= 1;
		__delay_cycles(1000000);
	}

	return 0;
}
