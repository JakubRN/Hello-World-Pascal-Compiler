%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
#include "entry.h"

bool global_scope = true;
std::vector<int> identifier_list_vect;
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
%token OF

%token VAR
%token LABEL

%token NUM_INT
%token NUM_REAL
%token ID
%token DIV 
%token MOD 


%left '<' '>' '=' NOT_EQUAL LESS_THAN_OR_EQUAL MORE_THAN_OR_EQUAL
%left '+' '-'
%left '*' '/' MOD DIV
%right UMINUS UPLUS
%%

program:
    PROGRAM ID '(' identifier_list ')' ';' {
        symtable[$2].token = LABEL;
        generate_jump(symtable[$2].name);
        generate_label(symtable[$2].name);
        //TODO use identifier list
        identifier_list_vect.clear();
    }
    declarations
    subprogram_declarations
    compound_statement '.' {append_command_to_stream("exit");}
;
identifier_list:
    identifier_list ',' ID { identifier_list_vect.push_back($3); }
    | ID { identifier_list_vect.push_back($1) ;}
;
declarations:
    declarations VAR identifier_list ':' type ';' {
            for(const auto &symbol_table_index : identifier_list_vect) {
                if($5 == INTEGER){
                    set_variable_at_symbol_table(symbol_table_index, _INT_SIZE, INTEGER);
                }
                else if($5 == REAL){
                    set_variable_at_symbol_table(symbol_table_index, _REAL_SIZE, REAL);
                }
                else if($5 == ARRAY) {
                    std::cout << symtable[symbol_table_index].name  << " is array" << std::endl;
                }
                else {
                    std::cout << "identifiers are unknown" << std::endl;
                }
            }
            identifier_list_vect.clear();
        }
    | 
;
type:
    standard_type
    | ARRAY '[' NUM_INT '.' '.' NUM_INT ']' 
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
    { std::cout << symtable[$2].name << " is function" << std::endl;}
    | PROCEDURE ID arguments ';' 
    { std::cout << symtable[$2].name << " is procedure" << std::endl;}
;
arguments:
    '(' parameter_list ')' 
    |
;
parameter_list:
    identifier_list ':' type 
    {
        for(const auto &symbol_table_index : identifier_list_vect) {
            if($3 == INTEGER){
                std::cout << symtable[symbol_table_index].name << " is integer" << std::endl;
            }
            else if($3 == REAL){
                std::cout << symtable[symbol_table_index].name  << " is real" << std::endl;
            }
            else if($3 == ARRAY) {
                std::cout << symtable[symbol_table_index].name  << " is array" << std::endl;
            }
            else {
                std::cout << "identifiers are unknown" << std::endl;
            }
        }
        identifier_list_vect.clear();
    }

    | parameter_list ';' identifier_list ':' type 
    {
        for(const auto &symbol_table_index : identifier_list_vect) {
            if($5 == INTEGER){
                std::cout << symtable[symbol_table_index].name << " is integer" << std::endl;
            }
            else if($5 == REAL){
                std::cout << symtable[symbol_table_index].name  << " is real" << std::endl;
            }
            else if($5 == ARRAY) {
                std::cout << symtable[symbol_table_index].name  << " is array" << std::endl;
            }
            else {
                std::cout << "identifiers are unknown" << std::endl;
            }
        }
        identifier_list_vect.clear();
    }
;
compound_statement:
    __BEGIN
    optional_statements
    __END
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
    |variable ASSIGN_OP expr { generate_assign_op($1, $3); }
    | procedure_statement
    | compound_statement
;
unmatched_statement:
    __IF expr __THEN statement
    | __IF expr __THEN matched_statement __ELSE unmatched_statement
;
variable:
    VAR                  
    | VAR '[' expr ']' 
;
procedure_statement:
    ID
    | ID '(' expression_list ')' {
        auto write_id = lookup_name("write");
        auto read_id = lookup_name("read");
        if($1 == write_id || $1 == read_id) {
            if(symtable[$3].variable_type == REAL)
                generate_command("write.r", $3);
            else if(symtable[$3].variable_type == INTEGER)
                generate_command("write.i", $3);
            else yyerror("wrong type of variable to write: expecting real or int");
        }
    }
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

    | expr '+' expr  { $$ = generate_arithmetic_operation("add", $1, $3); }
    | expr '-' expr { $$ = generate_arithmetic_operation("sub", $1, $3); }

    | expr '*' expr { $$ = generate_arithmetic_operation("mul", $1, $3); }
    | expr '/' expr { $$ = generate_arithmetic_operation("div", $1, $3); }
    | expr DIV expr { $$ = generate_arithmetic_operation("div", $1, $3); }
    | expr MOD expr { $$ = generate_arithmetic_operation("add", $1, $3); }

    | '-' expr %prec UMINUS { }
    | '+' expr %prec UPLUS  { }

    | '(' expr ')' { ; }
    | NUM_INT { symtable[$1].variable_type = INTEGER; }
    | NUM_REAL { symtable[$1].variable_type = REAL; }
    | VAR { ; }
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}