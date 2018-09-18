#include "dtc.h"
#include <msp430g2553.h>

//Array declarations
char digit[] = {BIT5, BIT6, BIT7};
char GR1[] = {BIT1, 0x00};
char GR2[] = {0x6D, 0xC0};

char P1[] = { /*0*/ BIT1, /*1*/ BIT1, /*2*/ BIT1, /*3*/ BIT1, 
    	/*4*/ BIT1, /*5*/ 0x00, /*6*/ 0x00, /*7*/ BIT1, /*8*/ BIT1, /*9*/ BIT1, 
    	/*A*/ BIT1, /*b*/ 0x00, /*c*/ 0x00, /*d*/ BIT1, /*E*/ 0x00, /*F*/ 0x00, 
};

char P2[] = {/*0*/ 0xAD, /*1*/ 0x04, /*2*/ 0xC9, /*3*/ 0x4D, /*4*/ 0x64, 
    	/*5*/ 0x6D, /*6*/ 0xED, /*7*/ 0x05, /*8*/ 0xED, /*9*/ 0x65, /*A*/ 0xE5, 
    	/*b*/ 0xEC, /*c*/ 0xA9, /*d*/ 0xCC, /*E*/ 0xE9, /*F*/ 0xE1, 
};

//
unsigned number = 0;
int mode = 0;
int cursor = 1;

int main() {

//Initializations
  initialize_dtc(INCH_4, &number);
  WDTCTL = WDTPW | WDTHOLD;
  BCSCTL1 = CALBC1_1MHZ;
  DCOCTL = CALDCO_1MHZ;

//Port 1
  P1DIR = 0xE6;
  P1SEL |= BIT2; //print to screen?         
  P1OUT = 0x06;
  P1REN = BIT3; 
  P1OUT |= BIT3; 
  P1IE  |= BIT3; 
  P1IES |= BIT3;
  P1IFG &= ~BIT3; 

//Port 2
  P2DIR  = 0xFF;
  P2SEL  = BIT1 | BIT4;
  P2SEL &= ~(BIT6 | BIT7);
  P2OUT  = 0xED;

 //Timer
  TA0CCTL0 = CCIE;
  TA0CTL   = TASSEL_2 | MC_1;
  TA0CCR0  = 1023;
  TA0CCTL1 = OUTMOD_7;
  TA0CCR1  = 0;
  TA1CTL   = TASSEL_2 | MC_1;
  TA1CCR0  = 1023; 
  TA1CCTL1 = OUTMOD_7;        
  TA1CCTL2 = OUTMOD_7;        
  TA1CCR1  = 0;               
  TA1CCR2  = 0;               
  _BIS_SR(GIE);               
 
//Loop funtion
  for(;;) {}
}

#pragma vector=TIMER0_A0_VECTOR
__interrupt void Timer0_A0_ISR (void)
{
  int n = number >> 2;
  P1OUT |=  BIT1;
  P1OUT &= ~(BIT5 | BIT6 | BIT7);
  P2OUT |= 0xED;

  switch (mode) {
    case 0:
      TA0CCR1 = number;
      break;
    case 1:
      TA1CCR1 = number;
      break;
    case 2:
      TA1CCR2 = number;
      break;
  }

  switch (cursor) {
    case 0:
      P1OUT |= digit[0];
      switch (mode) {
        case 0:
          P1OUT &= ~GR1[1];
          P2OUT &= ~GR2[1];
          break;
        case 1:
          P1OUT &= ~GR1[0];
          P2OUT &= ~GR2[0];
          break;
        case 2:
          P1OUT &= ~P1[11];
          P2OUT &= ~P2[11];
          break;
      }
      break;
    case 1:
      P1OUT |= digit[1];
      P1OUT &= ~P1[n / 0x10   % 0x10];
      P2OUT &= ~P2[n / 0x10   % 0x10];
      break;
    case 2:
      P1OUT |= digit[2];
      P1OUT &= ~P1[n          % 0x10];
      P2OUT &= ~P2[n          % 0x10];
      break;
  }
  cursor++;
  cursor %= 3;
}

#pragma vector=PORT1_VECTOR
__interrupt void modeSwitch(void)
{
  while (!(BIT3 & P1IN)) {}
  __delay_cycles(31250);
  P1IFG &= ~BIT3;
  mode++;
  mode %= 3;
 
}

