/*
 * backpatching.c
 * */

#include	"backpatching.h"
#include	"util.h"
#include	"three-adresss.h"

/*
 * creates a new list containing only i, an index into the array of instructions
 * returns a pointer to the newly created list
 * */
LOC_LIST* makelist(int index)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	if(index != -1)
	{
		LOC_LIST *loc = fmalloc(sizeof(LOC_LIST));
		loc->location = index;
		loc->next = NULL;

		return loc;
	}
	return NULL;
}

/*
 * concatenates the lists pointed to by p1 and p2
 * returns a pointer to t h e concatenated list
 *
 * */
LOC_LIST* merge(LOC_LIST *p1, LOC_LIST *p2)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	if(p1)
	{
		LOC_LIST *tempHead = p1;
		while(tempHead->next)
			tempHead = tempHead->next;
		tempHead->next = p2;

		return p1;
	}
	return p2;
}

/*
 * inserts i as t h e target label for each of the instructions on the list pointed to by p
 * */
void backpatch(LOC_LIST* p, SYM_ENTRY* i)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	// loop through all indecies in p and insert i as a result address
	if(p)
	{
		LOC_LIST* tmp = p;
		while(tmp->next)
		{
			inst_memory[tmp->location]->result = i;
			tmp = tmp->next;
		}
	}
}
