%{
/* $Id: lex.l,v 1.1 2008/07/09 13:06:42 dvermeir Exp $
* 
* Lexical analyzer for the toy language ``Micro''
*/
#include <string.h> /* for strcmp, strdup & friends */
#include <stdlib.h> /* for atoi() */

#include "micro.tab.h" /* token type definitions from .y file */
#include "symbol.h" /* symbol table management */

extern int lineno;  /* defined in micro.y */

void
lex_init() {
  /* Initialize data structures etc. for scanner */
  symbol_insert("int",INT); /*Insert keywords in symbol table */
  symbol_insert("char",CHAR);
  symbol_insert("return",RETURN);  
  symbol_insert("length",LENGTH);
  symbol_insert("while",WHILE);
  symbol_insert("if",IF);
  symbol_insert("else",ELSE);
  symbol_insert("read",READ); 
  symbol_insert("write",WRITE);
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
                        yylval.idx = symbol_find(yytext);

                        if (yylval.idx<0) { /* new symbol: insert it */
                          yylval.idx =symbol_insert(yytext, NAME);
                          return NAME;
                        }
                        else
                          return symbol_type(yylval.idx);
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
"["                     return RBRACK;
"]"                     return LBRACK;
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
\/\/[^/n]*				{
                        // Do nothing, just neglect the comments
                        //fprintf(stdout,"comment has been detected on line %d and discarded", lineno);
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

