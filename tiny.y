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
	T_LIST*		tlist;
	T_INFO*		type;
	SYM_INFO*	sym;
	SYM_LIST*	slist;
	}

%token	INT CHAR WRITE READ NAME IF ELSE RETURN NUMBER LPAR RPAR QCHAR
%token  LBRACE RBRACE LBRACK RBRACK ASSIGN SEMICOLON COMMA WHILE 
%token	PLUS MINUS TIMES DIVIDE EQUAL NEQUAL NOT GREATER LESS LENGTH

%type	<name>	NAME
%type	<value>	NUMBER
%type	<type>	type formal_par exp lexp
%type	<tlist>	formal_pars more_parameters pars
%type	<sym>	var

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
			$<sym>$ = symtab_insert(scope,$2,0);
			scope = symtab_open(scope); /* open new scope */
			scope->function = $<sym>$; /* attach to this function */
			}
		  LPAR formal_pars RPAR {	/* this is $7 */
			$<sym>3->type = types_fun($1,$5);
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
		| type TIMES		{ $$ = types_array($1); }
		| type LBRACK exp RBRACK /* array type TODO */
					{ $$ = types_array($3); }
		;

statements	: statement SEMICOLON statements
		| /* empty */
		;

statement	: IF LPAR exp RPAR statement 		%prec LOW
		| IF LPAR exp RPAR statement ELSE statement	/* shift */
		| WHILE LPAR exp RPAR statement
		| lexp ASSIGN exp	{ check_assignment($1,$3); }
		| RETURN exp /* statements always in scope with function */
			{ check_assignment(scope->function->type->info.fun.target,$2); }
		| NAME LPAR pars RPAR		// function call TODO:  check name in the scope??
		| block
		| WRITE exp
		| READ lexp
		;

lexp	: var			{ $$ = $1->type; }
		| lexp LBRACK exp RBRACK{ $$ = check_array_access($1,$3); }	
		;

exp		: QCHAR { $$ = types_simple(char_t);}
		| LENGTH lexp { /* TODO */}
		| exp LBRACK exp RBRACK	{ $$ = check_array_access($1,$3); }
		| exp PLUS exp		{ $$ = check_arith_op(PLUS,$1,$3); }
		| exp MINUS exp		{ $$ = check_arith_op(MINUS,$1,$3); }
		| exp TIMES exp		{ $$ = check_arith_op(TIMES,$1,$3); }
		| exp DIVIDE exp	{ $$ = check_arith_op(DIVIDE,$1,$3); }
		| exp EQUAL exp		{ $$ = check_relop(EQUAL,$1,$3); }
		| exp NEQUAL exp		{ $$ = check_relop(NEQUAL,$1,$3); }
		| exp GREATER exp		{ $$ = check_relop(GREATER,$1,$3); }
		| exp LESS exp			{ $$ = check_relop(LESS,$1,$3); }
		| LPAR exp RPAR	{ $$ = $2; }
		| MINUS exp 	%prec UMINUS /* this will force a reduce */
					{ $$ = check_arith_op(UMINUS,$2,0); }
		| NOT exp 	{ $$ = check_arith_op(NOT,$2,0); }
		| var			{ $$ = $1->type; }
		| NUMBER 		{ $$ = types_simple(int_t); }
		| NAME LPAR RPAR	{ $$ = check_fun_call(scope,$1,0); }
		| NAME LPAR pars RPAR	{ $$ = check_fun_call(scope,$1,&$3); }
		;

pars	: exp 				{ $$ = types_list_insert(0,$1); }
		| exp COMMA pars	{ $$ = types_list_insert($3,$1); }
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
