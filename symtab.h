#ifndef	SYMBOL_H
#define	SYMBOL_H
/*	symtab.h
*	
*	Symbol table management
*/

#include	<stdlib.h>	/* for malloc() and friends */
#include	<stdio.h>	/* for fprintf() and friends */

typedef struct indiceslist LOC_LIST;

typedef struct syminfo {
	union{
		char			*name;
		int 	  lit_int_val;
		char 	   lit_ch_val;
	};
	struct type_info	*type;
	LOC_LIST 		    *truelist;
	LOC_LIST 		    *falselist;
	LOC_LIST 		    *next;
	} SYM_INFO;

/* System table will act as a system table and a literal table at the same time */
typedef struct symentry{
	short literal; /* 0 -> Variable, fun, array .... 1-> literal -> int or char*/
	SYM_INFO *syminf;
}SYM_ENTRY;

typedef struct symcell {
	SYM_ENTRY	*enrty;
	struct symcell	*next;
	} SYM_LIST;

typedef struct symtab {
	struct symtab	*parent;
	SYM_ENTRY	*function; /* enclosing this scope */
	SYM_LIST	*list;
	} SYM_TAB;

typedef struct lit_list{
	SYM_ENTRY *entry;
	struct lit_list *next;
}LITERAL_LIST;

SYM_TAB*	symtab_open(SYM_TAB* enclosing_scope);
SYM_ENTRY*	symtab_find(SYM_TAB*,char*);
SYM_ENTRY*	symtab_insert(SYM_TAB*,char*,struct type_info*);
SYM_ENTRY*	symtab_insert_literal(SYM_TAB*,int,struct type_info*);
int		symtab_list_equal(SYM_LIST*,SYM_LIST*);
SYM_LIST*	symtab_list_insert(SYM_LIST*,SYM_ENTRY*);
SYM_ENTRY*	symtab_list_find(SYM_LIST*,char*);
void		symtab_list_release(SYM_LIST*);
SYM_ENTRY*  symtab_entry_new(SYM_INFO*, short);
SYM_INFO*	symtab_info_new(char*,struct type_info*);

void		symtab_print(FILE*,SYM_TAB*);
void		symtab_info_print(FILE*,SYM_INFO*);
void		symtab_list_print(FILE*,SYM_LIST*,char* separator);
#endif
