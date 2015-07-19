/*
 * trace.c
 */

#include "trace.h"


void DEBUG(char *s, char *func, char*file)
{
	if(__DEBUG__ == 1)
		printf(s, func, file);
}
