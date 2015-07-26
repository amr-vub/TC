/*
 * three-adress.c
 */
#include 	"three-adresss.h"
#include 	"util.h"
#include    <ctype.h>
#include	<string.h>
#include    "trace.h"

static char countTemp[2] = "0"; /* keeps track of last used temp var number */
static char temp[2] = "t";
static int current3aiVar=0;

static void printarg(SYM_ENTRY* arg)
{
	//printf("liertal: %d \n", arg->literal);
	if(arg->literal)
	{
		//printf("	if(arg->literal)");
		switch(arg->syminf->type->cons)
		{
		case int_t:
			printf("%d ", arg->syminf->lit_int_val);
			break;
		case char_t:
			printf("%c ", arg->syminf->lit_ch_val);
			break;
		}
	}
	else
	{
		//printf("NAME ---- \N");
		printf("%s ", arg->syminf->name);
	}
}

static void print3ai(char* op, SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	printf("%s = ", result->syminf->name); /* e.g. t0 =  */
	if(arg1)
		printarg(arg1);
	printf("%s ",op);
	if(arg2)
		printarg(arg2);
	printf("\n");
}

static void printIf(char* op, SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	/* Statement one */
	printf("IF ");
	printarg(arg1);
	printf(" %s ",op);
	printarg(arg2);
	printf(" GOTO ");
	printf("-- \n");
	//printf("%d\n", result->syminf->lit_int_val);
	/* Statement two: E.value ‘=’ ‘0’*/
}

static void printGOTO(char *binop, SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	/* The flow -->
	 * produce (‘if’ arg1 relop arg2 value ‘goto’ current3ai + 3)
	 * produce (E.value ‘=’ ‘0’)
	 * produce (‘goto’ current3ai + 2)
	 * produce (E.value ‘=’ ‘1’) */
	printf(" GOTO -- \n");
	//printf("%d\n", result->syminf->lit_int_val);

}

/* returns the address of the last inserted instruction in the instruction memory */
int current3ai(void)
{
	/*SYM_INFO *syminfo_label = fmalloc(sizeof(SYM_INFO));
	syminfo_label->lit_int_val = current3aiVar;
	syminfo_label->type = types_simple(int_t);
	SYM_ENTRY *label = symtab_entry_new(syminfo_label, 1);
	 */
	//printf(" return current3aiVar %d \n", current3aiVar);
	return current3aiVar;
}

/* create quadruple representing instruction */
void gen3ai(OPCODE op_code,SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result)
{
	DEBUG("Function: %s --- File: %s \n ", __func__, __FILE__);
	// allocate memory for this instruction
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
		print3ai("+", arg1,arg2,result);
		break;
	case A2MINUS:
		print3ai("-", arg1,arg2,result);
		break;
	case A2TIMES:
		print3ai("*", arg1,arg2,result);
		break;
	case A2DIVIDE:
		print3ai("/", arg1,arg2,result);
		break;
	case A0:
		print3ai(" ", arg1,arg2,result);
		break;
	case IFEQ:
		printIf("==", arg1, arg2, result);
		break;
	case IFNEQ:
		printIf("!=", arg1, arg2, result);
		break;
	case IFGT:
		printIf(">", arg1, arg2, result);
		break;
	case IFLT:
		printIf("<", arg1, arg2, result);
		break;
	case A1NOT:
		print3ai("!", arg1,arg2,result);
		break;
	case GOTO:
		printGOTO("GOTO",arg1, arg2, result);
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
	inst_memory[current3aiVar] = inst;
//	/* First time to insert an instruction */
//	if(!inst_memory)
//	{
//		inst_memory = fmalloc(sizeof(INST_LIST));
//		inst_memory->inst = inst;
//		inst_memory->next = 0;
//		return;
//	}
//	/* Instruction memory already exist */
//	/* Insert the instruction at the end of the list*/
//	INST_LIST *inst_memory_copy = inst_memory;
//	while(inst_memory_copy->next)
//		inst_memory_copy = inst_memory_copy->next;
//	/* now inst_memory_copy points to the end of the instruction memory*/
//	INST_LIST *new_inst = fmalloc(sizeof(INST_LIST));
//	new_inst->inst = inst;
//	new_inst->next = 0;
//	inst_memory_copy->next = new_inst;

	current3aiVar++;
}
