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
        symtable[$1].token = LABEL;
        generate_jump(symtable[$1].name);
        generate_label(symtable[$1].name);
        //TODO use identifier list
        identifier_list_vect.clear();
    }
    declarations
    subprogram_declarations
    compound_statement '.'
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
    |variable ASSIGN_OP expr
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

    | expr '+' expr  {
        std::cout << symtable[$1].variable_type << ", " << symtable[$3].variable_type << std::endl;
        auto [index_input_1, index_input_2] = manage_type_conversion($1, $3);
        
        std::cout << symtable[index_input_1].variable_type << ", " << symtable[index_input_2].variable_type << std::endl;
        std::string command;
        int output_index;
        if(symtable[index_input_1].variable_type == REAL) {
            command = "add.r";
            output_index = add_temporary_variable(REAL);
        }
        else {
            command = "add.i";
            output_index = add_temporary_variable(INTEGER);
        }
        generate_command(command, index_input_1, index_input_2, output_index);
        $$ = output_index;
        // emit('+', NONE);
    }
    | expr '-' expr { emit('-', NONE); }

    | expr '*' expr { emit('*', NONE); }
    | expr '/' expr { emit('/', NONE); }
    | expr DIV expr { emit(DIV, NONE); }
    | expr MOD expr { emit(MOD, NONE); }

    | '-' expr %prec UMINUS { emit('-', NONE); }
    | '+' expr %prec UPLUS { emit('+', NONE); }

    | '(' expr ')' { ; }
    | NUM_INT { ; }
    | NUM_REAL { ; }
    | VAR {; }
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}