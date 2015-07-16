%{
/*	tiny.y(
*
*	Tiny language parser 
*/
#include	<stdio.h>	/* for (f)printf() */
#include	<stdlib.h>	/* for exit() */

#include	"symtab.h"
#include	"types.h"
#include	"check.h"
#include    "three-adresss.h"

int		lineno	= 1;	/* number of current source line */
extern int	yylex();	/* lexical analyzer generated from lex.l */
extern char	*yytext;	/* last token, defined in lex.l  */
SYM_TAB 	*scope;		/* current symbol table, initialized in lex.l */
/*char		*base;		 basename of command line argument */

void
yyerror(char *s)
{
fprintf(stderr,"Syntax error on line #%d: %s\n",lineno,s);
fprintf(stderr,"Last token was \"%s\"\n",yytext);
exit(1);
}

%}

%union	{
	char*		name;
	int		value;
	char 	ch;
	T_LIST*		tlist;
	T_INFO*		type;
	SYM_INFO*	sym;
	SYM_ENTRY* sysentry;
	SYM_LIST*	slist;
	}

%token	INT CHAR WRITE READ NAME IF ELSE RETURN NUMBER LPAR RPAR QCHAR
%token  LBRACE RBRACE LBRACK RBRACK ASSIGN SEMICOLON COMMA WHILE 
%token	PLUS MINUS TIMES DIVIDE EQUAL NEQUAL NOT GREATER LESS LENGTH

%type	<name>	NAME
%type	<value>	NUMBER
%type   <ch>    QCHAR
%type	<type>	type formal_par
%type   <sysentry> exp var lexp
%type	<tlist>	formal_pars more_parameters
/*%type	<sym>	var*/

/*	associativity and precedence: in order of increasing precedence */

%nonassoc	LOW  /* dummy token to suggest shift on ELSE */
%nonassoc	ELSE /* higher than LOW */

%nonassoc	EQUAL NEQUAL GREATER LESS
%left		PLUS	MINUS
%left		TIMES	DIVIDE
%left		UMINUS	NOT LENGTH /* dummy token to use as precedence marker */
%left		LBRACK	/* C compatible precedence rules */

%%
program		: declarations
		;

declarations	: declaration declarations
		| /* empty */
		;

declaration	: fun_declaration
		| var_declaration
		;

fun_declaration	: type NAME {	/* this is $3 */
			$<sysentry>$ = symtab_insert(scope,$2,0);
			scope = symtab_open(scope); /* open new scope */
			scope->function = $<sysentry>$; /* attach to this function */
			}
		  LPAR formal_pars RPAR {	/* this is $7 */
			$<sysentry>3->syminf->type = types_fun($1,$5);
			}
		  block	{ scope = scope->parent; }
		;

formal_pars	: more_parameters	{ $$ = $1; }
		|			{ $$ = 0; }
		;

more_parameters	: formal_par COMMA more_parameters
					{ $$ = types_list_insert($3,$1); }
		| formal_par		{ $$ = types_list_insert(0,$1); }
		;

formal_par	: type NAME {
			symtab_insert(scope,$2,$1); /* insert in symbol table */
			$$ = $1; /* remember type info */
			}
		;

block		: LBRACE 		{  scope = symtab_open(scope); }
		  var_declarations statements RBRACE
					{ scope = scope->parent; /* close scope */}
		;

var_declarations: var_declaration var_declarations
		|
		;

var_declaration	: type NAME SEMICOLON	{ symtab_insert(scope,$2,$1);}
		;

type	: INT			{ $$ = types_simple(int_t); }
		| CHAR			{ $$ = types_simple(char_t); }
		| type LBRACK exp RBRACK /* array type */
					{ $$ = types_array($1); } %prec LOW
		| type LBRACK exp RBRACK LBRACK exp RBRACK /* array type */
					{ $$ = types_array($1); }
		;

statements	: statement SEMICOLON statements
		| /* empty */
		;

statement	: lexp ASSIGN exp	{ check_assignment($1->syminf->type,$3->syminf->type); 									
								  gen3ai(A0, $3, 0, $1);}
		;

lexp	: var			{ $$ = $1;}
		;

exp		: QCHAR { $$ = symtab_insert_literal(scope, $1, types_simple(char_t));
				  $$->syminf->type = types_simple(char_t);
				  $$->syminf->lit_ch_val = $1;}
		| LENGTH lexp { /* TODO */}		
		| exp PLUS exp		{ check_arith_op(PLUS,$1->syminf->type,$3->syminf->type); 		
							  $$ = newtemp($1->syminf->type);							  
							  gen3ai(A2PLUS, $1, $3, $$);
							  }
		| exp MINUS exp		{ check_arith_op(MINUS,$1->syminf->type,$3->syminf->type); 
						      $$ = newtemp($1->syminf->type);
							  gen3ai(A2MINUS, $1, $3, $$);}
		| exp TIMES exp		{ check_arith_op(TIMES,$1->syminf->type,$3->syminf->type);
							  $$ = newtemp($1->syminf->type);
							  gen3ai(A2TIMES, $1, $3, $$);}			
		| exp DIVIDE exp	{ check_arith_op(DIVIDE,$1->syminf->type,$3->syminf->type);
							  $$ = newtemp($1->syminf->type);
							  gen3ai(A2DIVIDE, $1, $3, $$);}
		| LPAR exp RPAR	{ $$ = $2; }
		| MINUS exp 	%prec UMINUS /* this will force a reduce */
					{ check_arith_op(UMINUS,$2->syminf->type,0);
					  $$ = newtemp($2->syminf->type);
					  gen3ai(A1MINUS, $2, NULL, $$);}		
		| var			{ $$ = $1; }
		| NUMBER 		{ $$ = symtab_insert_literal(scope, $1, types_simple(int_t));						  
						  $$->syminf->type = types_simple(int_t); 
						  $$->syminf->lit_int_val = $1; }				
		;

var		: NAME 			{ $$ = check_symbol(scope,$1); }
%%

int
main(int argc,char *argv[])
{
/*
if (argc!=2) {
	fprintf(stderr,"Usage: %s base_file_name",argv[0]);
	exit(1);
	}
base = argv[1];*/
return yyparse();
}
