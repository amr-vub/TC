/*
 *   three-address.h
 *   This file contain the definition for common functions and data structures
 *   used by the parser to generate Three Address Code
 * */

#include "symtab.h"
#include "types.h"

typedef enum {A2PLUS, A2TIMES, A2MINUS, A2DIV, A1MINUS, A2DIVIDE,
			  A1FTOI, A1ITOF, A0, GOTO, IFEQ, PARAM,
			  CALL, AAC, AAS, ADDR, DEREF, DEREFA
			  } OPCODE; /* Possible opcode values */

typedef struct {
	OPCODE	op_code;
	SYM_ENTRY*	args[2];
	SYM_ENTRY*	result;
} INSTRUCTION;

typedef struct inst_list{
	INSTRUCTION *inst;
	struct inst_list *next;
}INST_LIST;


/* create quadruple representing instruction */
void gen3ai(short op_code,SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result);

/* Handles the genration of temp vars */
SYM_ENTRY* newtemp(T_INFO *i);

/* Insert an instruction in the instruction memory*/
void instruction_memory_insert(INSTRUCTION *inst);
