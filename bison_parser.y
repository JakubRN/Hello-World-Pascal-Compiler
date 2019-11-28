%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
#define YYSTYPE double

%}
%token number
%left '+' '-'
%left '*' '/'
%right UMINUS
%%
lines: lines expr '\n' { printf("%g\n", $2); }
| lines '\n'
| /* empty */
;
expr : expr '+' expr { $$ = $1 + $3; }
| expr '-' expr { $$ = $1 - $3; }
| expr '*' expr { $$ = $1 * $3; }
| expr '/' expr { $$ = $1 / $3; }
| '(' expr ')' { $$ = $2; }
| '-' expr %prec UMINUS { $$ = -$2; }
| number
;
%%
