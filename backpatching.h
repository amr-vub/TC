/*
 * backpatching.h
 * */

#include	"symtab.h"

/*
typedef struct locationslist{
	INSTRUCTION *location;
	typedef struct locationslist *next;
}LOC_LIST;
*/

typedef struct indiceslist{
	int location;
	struct indiceslist *next;
}LOC_LIST;


/*
 * creates a new list containing only i, an index into the array of instructions
 * returns a pointer to the newly created list
 * */
LOC_LIST* makelist(int index);

/*
 * concatenates the lists pointed to by p1 and p2
 * returns a pointer to t h e concatenated list
 *
 * */
LOC_LIST* merge(LOC_LIST *p1, LOC_LIST *p2);

/*
 * inserts i as t h e target label for each of the instructions on the list pointed to by p
 * */
void backpatch(LOC_LIST* p, SYM_ENTRY* i);


