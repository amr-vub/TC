/*
 * three-adress.c
 */
#include 	"three-adresss.h"
#include 	"util.h"
#include    <ctype.h>
#include	<string.h>

static INST_LIST *inst_memory=0;
static char countTemp[2] = "0"; /* keeps track of last used temp var number */
static char temp[2] = "t";

/* create quadruple representing instruction */
void gen3ai(short op_code,SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	//printf("IN gen3ai\n");
	// allocate memmory for this instruction
	INSTRUCTION* inst = fmalloc(sizeof(INSTRUCTION));
	// populate the instruction
	inst->op_code = op_code;
	inst->args[0] = arg1;
	inst->args[1] = arg2;
	inst->result = result;
	// Then put it in the instruction memory
	instruction_memory_insert(inst);
	//printf("%s = %s %d %s \n", result->syminf->name,arg1->syminf->name, "+" ,arg2->syminf->name);
	printf("result: %s \n", result->syminf->name);
}

/* Handles the generation of temp vars */
SYM_ENTRY* newtemp(T_INFO *i)
{
	SYM_ENTRY *temp_entry = fmalloc(sizeof(SYM_ENTRY));
	temp_entry->literal = 0; /* not a literal */
	strcpy(temp,"t");
	strcat(temp,countTemp);
	countTemp[0]++;
	temp_entry->syminf = symtab_info_new(temp, i);


	return temp_entry;
}

/* Insert an instruction in the instruction memory*/
void instruction_memory_insert(INSTRUCTION *inst)
{
	/* First time to insert an instruction */
	if(!inst_memory)
	{
		inst_memory = fmalloc(sizeof(INST_LIST));
		inst_memory->inst = inst;
		inst_memory->next = 0;
		return;
	}
	/* Instruction memory already exist */
	/* Insert the instruction at the end of the list*/
	INST_LIST *inst_memory_copy = inst_memory;
	while(inst_memory_copy->next)
		inst_memory_copy = inst_memory_copy->next;
	/* now inst_memory_copy points to the end of the instruction memory*/
	INST_LIST *new_inst = fmalloc(sizeof(INST_LIST));
	new_inst->inst = inst;
	new_inst->next = 0;
	inst_memory_copy->next = new_inst;
}
