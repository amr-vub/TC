/*
 * trace.c
 */

#include "trace.h"

int __DEBUG__ = 1;

void DEBUG(char *s, char *func, char*file)
{
	//if(__DEBUG__ == 1)
		printf(s, func, file);
}
