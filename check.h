#ifndef	CHECK_H
#define	CHECK_H
/*
*	check.h(1.3)	10:31:17	97/12/10
*
*	Semantic checks.
*/
#include	"proc.h"
#include	"types.h"
#include	"tiny.tab.h"		/* for tokens */

void		check_assignment(T_INFO*,T_INFO*);
T_INFO*		check_array_access(T_INFO* ta,T_INFO* ti);
void		check_arith_op(enum yytokentype,T_INFO* t1,T_INFO* t2);
void		check_relop(enum yytokentype token,T_INFO* t1,T_INFO* t2);
T_INFO*		check_fun_call(SYM_TAB*,char*,T_LIST**);
SYM_ENTRY*	check_symbol(SYM_TAB* scope,char* name);

#endif
