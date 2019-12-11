%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
//#define YYSTYPE double
%}
%token NUM
%token ID
%token DONE
%token DIV 
%token MOD 
%left '+' '-'
%left '*' '/' MOD DIV
%right UMINUS
%%

lines : expr ';' lines  { printf("\n"); }
| /* empty */
| error '\n' { yyerror ( "re-enter previous line : " ) ; yyerrok ; }
;
expr : expr '+' expr { emit('+', NONE); }
| expr '-' expr { emit('-', NONE); }
| expr '*' expr { emit('*', NONE); }
| expr '/' expr { emit('/', NONE); }
| expr DIV expr { emit(DIV, NONE); }
| expr MOD expr { emit(MOD, NONE); }
| '(' expr ')' { ; }
| '-' expr %prec UMINUS { emit('-', NONE); }
| NUM {$$ = $1; emit (NUM, tokenval);}
| ID {$$ = $1; emit(ID, tokenval);}
| DONE {return 0;}
;
%%