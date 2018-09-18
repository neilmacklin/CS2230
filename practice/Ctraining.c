#include <stdio.h>
void forLoopCMethod(int a) {
	int x = a;
	for (int i = 1; i < a+1;i++) {
		printf("'i' is currently %d. 'a' is currently %d.\n",i,x);
		x--;
	} 
}
void notTheMainMethod (int a) {
	if (a < 0) {
		printf("Welp, thats a negative Number....\n");
	} else {
		printf("That is a positive Number, good job.\n");
	}
}
int main(int a) {
	printf("Hello training\n");
	forLoopCMethod(a+1); /*print the i in for loop and the 'a' thats given*/
	notTheMainMethod(a); /*if and else statement*/
	return 0;
}
