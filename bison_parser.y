%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
//#define YYSTYPE double
void
yyerror (const char *m) ;
%}
%define parse.error verbose
%token NUM
%token ID
%token DIV 
%token MOD 
%left '+' '-'
%left '*' '/' MOD DIV
%right UMINUS
%%

input : input line   { printf("\n"); }
    | /* empty */
;
line : expr ';'
    | error ';' { yyerror ( "re-enter previous line : " ) ; yyerrok ; }
;
expr : expr '+' expr  { emit('+', NONE); }
    | expr '-' expr { emit('-', NONE); }
    | expr '*' expr { emit('*', NONE); }
    | expr '/' expr { emit('/', NONE); }
    | expr DIV expr { emit(DIV, NONE); }
    | expr MOD expr { emit(MOD, NONE); }
    | '(' expr ')' { ; }
    | '-' expr %prec UMINUS { emit('-', NONE); }
    | NUM { emit (NUM, $1);}
    | ID { emit(ID, $1);}
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}