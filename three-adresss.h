/*
 *   three-address.h
 *   This file contain the definition for common functions and data structures
 *   used by the parser to generate Three Address Code
 * */

#include "symtab.h"
#include "types.h"

typedef enum {A2PLUS, A2TIMES, A2MINUS, A1MINUS, A2DIVIDE,
			  IFNEQ, IFEQ, IFGT, IFLT, GOTO, PARAM,
			  A1NOT, A1ITOF, A0,
			  CALL, AAC, AAS, ADDR, DEREF, DEREFA
			  } OPCODE; /* Possible opcode values */

typedef struct {
	OPCODE	op_code;
	SYM_ENTRY*	args[2];
	SYM_ENTRY*	result;
} INSTRUCTION;

// Global instruction memory
INSTRUCTION* inst_memory[1024];

/*
typedef struct inst_list{
	INSTRUCTION *inst;
	struct inst_list *next;
}INST_LIST;
*/

/* returns the address of the clast inserted instruction in the instruction memory */
int current3ai(void);

/* create quadruple representing instruction */
void gen3ai(OPCODE op_code,SYM_ENTRY* arg1, SYM_ENTRY* arg2, SYM_ENTRY* result);

/* Handles the genration of temp vars */
SYM_ENTRY* newtemp(T_INFO *i);

/* Insert an instruction in the instruction memory*/
static void instruction_memory_insert(INSTRUCTION *inst);
