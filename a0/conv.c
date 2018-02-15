#include <stdio.h>
#include <stdlib.h>

char *ascii = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/";

int whatBase(int base) {//determine if base is power of two or not
	if (base == 2) {
		return 1;
	} else if (base == 4) {
		return 1;
	} else if (base == 8) {
		return 1;
	} else if (base == 16) {
		return 1;
	} else if (base == 32) {
		return 1;
	} else if (base == 64) {
		return 1;
	} else {
		return 0;
	}
}

int shiftNum(int base) {//determine the power of two bases' shift numbers
	if (base == 2) {
		return 1;
	} else if (base == 4) {
		return 2;
	} else if (base == 8) {
		return 3;
	} else if (base == 16) {
		return 4;
	} else if (base == 32) {
		return 5;
	} else if (base == 64) {
		return 6;
	}
}

int main(int argc, char *argv[]) {
	char buf[32];
	buf[31] = '\0';
	int count = 30;
	unsigned int convertThis = atoi(argv[1]); //unsigned to handle longer integers
	unsigned int base = atoi(argv[2]);
	int shift = 0;
	unsigned int temp;	

	if (argc != 3) {
		printf("Usage: conv <decimal> <base>\n");//usage will print if 3 inputs aren't given
		return 0;
	} else if (base > 64 && base != 256) {
		printf("%s\n","Invalid base");
		return 0;
	} else if (base == 0) {
		printf("0");
	} else if (base != 256 && whatBase(base) == 0) {//any base other than power of two bases
		while (convertThis > 0) {
			temp = convertThis % base;
			buf[count] = ascii[temp];
			convertThis = convertThis / base;
			count--;	
		}
		printf("%s\n", &buf[count + 1]);
		return 0;
	} else if (base != 0 && base != 256) {//any power of two base other than 256 
		
		shift = shiftNum(base);
		
		int mask = base; 
		while (convertThis > 0) {
			temp = convertThis % mask;
			buf[count] = ascii[temp];
			convertThis >>= shift;
			count--;
		} 
		
		printf("%s\n", &buf[count + 1]);
		return 0;	
	} else if (base == 256) {//base 256 
		int formatCounter = 0; //To place zeros when there is a zero in the ip address and doubles as a counter to place the '.' in the ip address format
		while (convertThis > 0) {
			temp = convertThis % 256;
			if (temp == 0 && formatCounter > 0) {
				buf[count] = ascii[0];
				count--;
			}
			while (temp > 0) {
				buf[count] = ascii[temp % 10];  
				temp /= 10;
				count--;
			}
			
			if (formatCounter < 3 && formatCounter > -1) {
				buf[count] = '.';
			}
			convertThis >>= 8;
			count--;
			formatCounter++;
		}
		printf("%s\n", &buf[count + 2]);
		return 0;
	} 
	return 0;
}
