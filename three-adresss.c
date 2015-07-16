/*
 * three-adress.c
 */
#include 	"three-adresss.h"
#include 	"util.h"
#include    <ctype.h>
#include	<string.h>
#include    "trace.h"

static INST_LIST *inst_memory=0;
static char countTemp[2] = "0"; /* keeps track of last used temp var number */
static char temp[2] = "t";

static void printarg(SYM_ENTRY* arg)
{
	if(arg->literal)
		switch(arg->syminf->type->cons)
		{
		case int_t:
			printf("%d ", arg->syminf->lit_int_val);
			break;
		case char_t:
			printf("%c ", arg->syminf->lit_ch_val);
			break;
		}
	else
	{
		printf("%s ", arg->syminf->name);
	}
}

static void print3ai(char* op, SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	printf("%s = ", result->syminf->name); /* e.g. t0 =  */
	if(arg1)
		printarg(arg1);
	printf("%s ",op);
	printarg(arg2);
	printf("\n");
}

/* create quadruple representing instruction */
void gen3ai(OPCODE op_code,SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	// allocate memmory for this instruction
	INSTRUCTION* inst = fmalloc(sizeof(INSTRUCTION));
	// populate the instruction
	inst->op_code = op_code;
	inst->args[0] = arg1;
	inst->args[1] = arg2;
	inst->result = result;
	// Then put it in the instruction memory
	instruction_memory_insert(inst);
	switch(op_code)
	{
	case A2PLUS:
		 A2MINUS:
		 A2TIMES:
		 A2DIVIDE:
		 print3ai("+", arg1,arg2,result);
		break;
	case A0:
		print3ai(" ", arg1,arg2,result);
		break;
	}
}

/* Handles the generation of temp vars */
SYM_ENTRY* newtemp(T_INFO *i)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	SYM_ENTRY *temp_entry = fmalloc(sizeof(SYM_ENTRY));
	temp_entry->literal = 0; /* not a literal */
	strcpy(temp,"t");
	strcat(temp,countTemp);
	countTemp[0]++;
	temp_entry->syminf = symtab_info_new(temp, i);


	return temp_entry;
}

/* Insert an instruction in the instruction memory*/
static void instruction_memory_insert(INSTRUCTION *inst)
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
