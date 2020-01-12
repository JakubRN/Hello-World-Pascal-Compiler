%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
#include "entry.h"

bool global_scope = true;
int relative_stack_pointer;
std::vector<int> identifier_list_vect;
std::vector<int> expression_list_vect;
std::stringstream single_module_output;
std::stack<entry> module_stack;

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
        generate_jump(symtable[$2].name);
        symtable[$2].token = LABEL;
        //TODO use identifier list
        identifier_list_vect.clear();
    }
    declarations {global_scope = false;}
    subprogram_declarations { 
        generate_label(symtable[$2].name);
        global_scope = true;
        }
    compound_statement '.' {
        append_command_to_stream("exit");
        }
;
identifier_list:
    identifier_list ',' ID { identifier_list_vect.push_back($3); }
    | ID { identifier_list_vect.push_back($1) ;}
;
declarations:
    declarations VAR identifier_list ':' type ';' {
            set_identifier_type_at_symbol_table($5, identifier_list_vect);

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
    subprogram_head declarations compound_statement {
        generate_command("leave");
        generate_command("return");
        auto number_to_append = std::to_string(abs(relative_stack_pointer) - 4);
        append_command_to_stream("enter.i", "#" + number_to_append, number_to_append);
        output_string_stream << single_module_output.str();
        single_module_output.str(std::string());
    }
;
subprogram_head:
    FUNCTION ID arguments ':' standard_type ';' {
        //Expects you to push return variable first, and then arguments
        symtable[$2].is_global = false;
        symtable[$2].is_reference = true;
        symtable[$2].token = FUNCTION;
        symtable[$2].memory_offset = relative_stack_pointer;
        symtable[$2].variable_type = $5;
        relative_stack_pointer = -4;
        std::cout << "memory offset: " << symtable[$2].memory_offset << std::endl;
        generate_label(symtable[$2].name);
        identifier_list_vect.clear();
        }
    | PROCEDURE ID arguments ';' { 
        symtable[$2].is_global = false;
        symtable[$2].token = PROCEDURE;
        relative_stack_pointer = -4;
        generate_label(symtable[$2].name);
        identifier_list_vect.clear();
        }
;
arguments:
    '(' parameter_list ')' {
        relative_stack_pointer = 8;
        for(const auto &symbol_table_index : identifier_list_vect) {
            assert(symtable[symbol_table_index].is_global == false);
            symtable[symbol_table_index].memory_offset = relative_stack_pointer;
            symtable[symbol_table_index].size = 4;
            symtable[symbol_table_index].is_reference=true;
            relative_stack_pointer += 4;
            std::cout << relative_stack_pointer << std::endl;
        }
    }
    | {
        relative_stack_pointer = 8;
    }
;
parameter_list:
    parameter_list ';' identifier_list ':' type 
    {
        set_identifier_type_at_symbol_table($5, identifier_list_vect);
    }
    | identifier_list ':' type {
        set_identifier_type_at_symbol_table($3, identifier_list_vect);
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
    FUNCTION
    | VAR                  
    | VAR '[' expr ']' 
;
procedure_statement:
    PROCEDURE
    | PROCEDURE '(' expression_list ')' {
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
    | expression_list ',' expr
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
    | FUNCTION
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}