%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
void
yyerror (const char *m) ;
%}
%define parse.error verbose

%token NOT_EQUAL
%token LESS_THAN_OR_EQUAL
%token MORE_THAN_OR_EQUAL
%token __IF
%token __THEN
%token __ELSE
%token ASSIGN_OP
%token __BEGIN
%token __END
%token PROCEDURE
%token FUNCTION
%token ARRAY
%token INTEGER
%token REAL
%token PROGRAM
%token VAR
%token OF

%token NUM
%token ID
%token DIV 
%token MOD 


%left '<' '>' '=' NOT_EQUAL LESS_THAN_OR_EQUAL MORE_THAN_OR_EQUAL
%left '+' '-'
%left '*' '/' MOD DIV
%right UMINUS UPLUS
%%

program:
    PROGRAM ID '(' identifier_list ')' ';'
    declarations
    subprogram_declarations
    compound_statement
;
identifier_list:
    identifier_list ',' ID
    | ID
;
declarations:
    declarations VAR identifier_list ':' type ';' {printf("it's a declaration\n"); }
    | 
;
type:
    standard_type
    | ARRAY '[' NUM '.' '.' NUM ']' 
standard_type:
    INTEGER
    | REAL
;
subprogram_declarations:
    subprogram_declarations subprogram_declaration ';'
    | 
;
subprogram_declaration:
    subprogram_head declarations compound_statement
;
subprogram_head:
    FUNCTION ID arguments ':' standard_type ';'
    | PROCEDURE ID arguments ';'
;
arguments:
    '(' parameter_list ')'
;
parameter_list:
    identifier_list ':' type
    | parameter_list ';' identifier_list ':' type
;
compound_statement:
    __BEGIN
    optional_statements
    __END '.'
;
optional_statements:
    statement_list
    | 
;
statement_list:
    statement
    | statement_list ';' statement
;
statement:
    matched_statement
    | unmatched_statement
;
matched_statement:
    __IF expr __THEN matched_statement __ELSE matched_statement
    |variable ASSIGN_OP expr
    | procedure_statement
    | compound_statement
;
unmatched_statement:
    __IF expr __THEN statement
    | __IF expr __THEN matched_statement __ELSE unmatched_statement
;
variable:
    ID                  
    | ID '[' expr ']' 
;
procedure_statement:
    ID
    | ID '(' expression_list ')'
;
expression_list:
    expr
    | expression_list',' expr
;
expr:
    expr '<' expr { if($1 < $3) printf("true"); else printf("false"); }
    | expr '>' expr { if($1 > $3) printf("true"); else printf("false"); }
    | expr '=' expr { if($1 == $3) printf("true"); else printf("false"); }
    | expr MORE_THAN_OR_EQUAL expr { if($1 >= $3) printf("true"); else printf("false"); }
    | expr LESS_THAN_OR_EQUAL expr { if($1 <= $3) printf("true"); else printf("false"); }
    | expr NOT_EQUAL expr { if($1 != $3) printf("true"); else printf("false"); }

    | expr '+' expr  { emit('+', NONE); }
    | expr '-' expr { emit('-', NONE); }

    | expr '*' expr { emit('*', NONE); }
    | expr '/' expr { emit('/', NONE); }
    | expr DIV expr { emit(DIV, NONE); }
    | expr MOD expr { emit(MOD, NONE); }

    | '-' expr %prec UMINUS { emit('-', NONE); }
    | '+' expr %prec UPLUS { emit('+', NONE); }

    | '(' expr ')' { ; }
    | NUM { emit (NUM, $1);}
    | ID { emit(ID, $1);}
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}