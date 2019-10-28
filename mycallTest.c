#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <stdio.h>

#define MYCALL_NUM 436

int main(){
	long res = syscall(MYCALL_NUM);
	printf("System call returned %ld.\n", res);
	printf("Check message from your System call with \"dmesg\" \n");
	return 0;
}
