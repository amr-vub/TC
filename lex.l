%{
/* $Id: lex.l,v 1.1 2008/07/09 13:06:42 dvermeir Exp $
* 
* Lexical analyzer for the toy language ``TINY''
*/
#include <string.h> /* for strcmp, strdup & friends */
#include <stdlib.h> /* for atoi() */

/*#include	"symtab.h"	 symbol table management */
#include	"proc.h"
#include	"types.h"
#include	"tiny.tab.h"	/* token type definitions from .y file */
#include	"names.h"	/* string pool management */

extern int lineno;  /* defined in tiny.y */
extern SYM_TAB *scope;		/* current symbol table */ 
void
lex_init() {
  /* Initialize data structures etc. for scanner */
 scope	= symtab_open(0);	/* open topmost scope */
}

/*
* The macro below will be called automatically when the generated scanner
* initializes itself.
*/
#define YY_USER_INIT lex_init();

%}

alpha   [A-Za-z]
digit   [0-9]
alphanum  [A-Za-z0-9_]

%%
[ \t]   break;  /* ignore white space */
"\n"    ++lineno; 

"int"					{return INT;}
"char"					{return CHAR;}
"return"				{return RETURN;}
"length"				{return LENGTH;}
"while"					{return WHILE;}
"if"            		{return IF;}
"else"          		{return ELSE;}
"read"          		{return READ;}
"write"         		{return WRITE;}

{alpha}{alphanum}*      {
                          yylval.name = names_find_or_add(yytext);
                          return NAME;
                        }

{digit}+                {
                        yylval.value = atoi(yytext);
                        return NUMBER; 
                        }
\'{alpha}\'             {
                        yylval.value = atoi(yytext);
                        return QCHAR; 
                        }                                                
"("                     return LPAR;
")"                     return RPAR;
"{"                     return LBRACE;
"}"                     return RBRACE;
"["                     return LBRACK;
"]"                     return RBRACK;
"="                     return ASSIGN;
"=="					return EQUAL;
"!="					return NEQUAL;
"!"						return NOT;
";"                     return SEMICOLON;
"+"                     return PLUS;
"-"                     return MINUS;
"*"                     return TIMES;
"/"                     return DIVIDE;
","                     return COMMA;
">"                     return GREATER;
"<"                     return LESS;
\/\/[^\n]*				{
                        // Do nothing, just neglect the comments
                        //fprintf(stdout,"comment has been detected on line %d and discarded \n", lineno);                        
                        }
.                       { 
                        fprintf(stderr,
                                "Illegal character \'%s\' on line #%d\n",
                                yytext, lineno);
                        exit(1);
                        }

%%

int
yywrap() {
  return 1; /* tell scanner no further files need to be processed */
}

