%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
#include "entry.h"

int relative_stack_pointer;
size_t symbol_table_size = 0;
bool global_scope = true;
std::list<int> identifier_list;
std::list<int> parameters_list;
std::list<int> expression_list;
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
    PROGRAM ID '(' identifier_list ')' ';' {
        generate_jump(symtable[$2].name);
        symtable[$2].token = LABEL;
        //TODO use identifier list
        identifier_list.clear();
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
    identifier_list ',' ID { identifier_list.emplace_back($3); }
    | ID { identifier_list.emplace_back($1) ;}
;
declarations:
    declarations VAR identifier_list ':' type ';' {
            set_identifier_type_at_symbol_table($5, identifier_list);
            identifier_list.clear();
        }
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
    subprogram_head declarations compound_statement {
        generate_command("leave");
        generate_command("return");
        auto number_to_append = std::to_string(abs(relative_stack_pointer));
        append_command_to_stream("enter.i", "#" + number_to_append, number_to_append);
        output_string_stream << single_module_output.str();
        single_module_output.str(std::string());
        if(symbol_table_size != 0)
            dump_symbol_table();
            symtable.erase(symtable.begin() + symbol_table_size, symtable.end());
    }
;
subprogram_head:
    FUNCTION ID {symbol_table_size = symtable.size();} arguments ':' standard_type ';' {
            //Expects you to push return variable last
            symtable[$2].is_global = false;
            symtable[$2].is_reference = true;
            symtable[$2].token = FUNCTION;
            symtable[$2].memory_offset = 8;

            symtable[$2].type.variable_type = get_data_type($6);
            relative_stack_pointer = 0;
            generate_label(symtable[$2].name);
            for(const auto &symbol_table_index : parameters_list) {
                symtable[$2].arguments_types.push_back( {symtable[symbol_table_index].type.variable_type, 0 } );
            }
            parameters_list.clear();
        }
    | PROCEDURE ID {symbol_table_size = symtable.size();} arguments ';' { 
            symtable[$2].is_global = false;
            symtable[$2].token = PROCEDURE;
            relative_stack_pointer = 0;
            generate_label(symtable[$2].name);
            for(const auto &symbol_table_index : parameters_list) {
                symtable[$2].arguments_types.push_back( {symtable[symbol_table_index].type.variable_type, 0 } );
            }
            parameters_list.clear();
            
        }
;
arguments:
    '(' parameter_list ')' {
        relative_stack_pointer = parameters_list.size()*4 + 8;
        for(const auto &symbol_table_index : parameters_list) {
            assert(symtable[symbol_table_index].is_global == false);
            symtable[symbol_table_index].memory_offset = relative_stack_pointer;
            symtable[symbol_table_index].size = 4;
            symtable[symbol_table_index].is_reference=true;
            relative_stack_pointer -= 4;
        }
    }
    |
;
parameter_list:
    parameter_list ';' identifier_list ':' type {
        set_identifier_type_at_symbol_table($5, identifier_list);
        parameters_list.splice(parameters_list.end(), identifier_list);
        identifier_list.clear();
    }
    | identifier_list ':' type {
        set_identifier_type_at_symbol_table($3, identifier_list);
        parameters_list.splice(parameters_list.end(), identifier_list);
        identifier_list.clear();
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
    PROCEDURE {append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);}
    | PROCEDURE '(' expression_list ')' {
        auto write_id = lookup_name("write");
        auto read_id = lookup_name("read");
        if($1 == write_id) {
            for(auto &elem : expression_list) {
                if(symtable[elem].type.variable_type == data_type::real)
                    generate_command("write.r", elem);
                else if(symtable[elem].type.variable_type == data_type::integer)
                    generate_command("write.i", elem);
                else yyerror("wrong type of variable to write: expecting real or int");
            }
        }
        else if ($1 == read_id) {
            for(auto &elem : expression_list) {
                if(symtable[elem].type.variable_type == data_type::real)
                    generate_command("read.r", elem);
                else if(symtable[elem].type.variable_type == data_type::integer)
                    generate_command("read.i", elem);
                else yyerror("wrong type of variable to read: expecting real or int");
            }
        }
        else {
            push_arguments_list($1, expression_list);
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
            auto stack_ptr = 4 + symtable[$1].arguments_types.size() * 4;
            append_command_to_stream("incsp.i", "#" + std::to_string(stack_ptr), std::to_string(stack_ptr));
        }
        expression_list.clear();
    }
;
expression_list:
    expr {expression_list.push_back($1);}
    | expression_list ',' expr {expression_list.push_back($3);}
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
    | NUM
    | VAR { ; }
    | FUNCTION {
        auto tmp_index = add_temporary_variable(symtable[$1].type.variable_type);
        append_command_to_stream("push.i", "#" + symtable[tmp_index].get_variable_to_asm(), "&" + symtable[tmp_index].name);
        append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
        append_command_to_stream("incsp.i", "#4", "4");
        $$ = tmp_index;
    }
    | FUNCTION '(' expression_list ')' {
        push_arguments_list($1, expression_list);
        auto tmp_index = add_temporary_variable(symtable[$1].type.variable_type);
        append_command_to_stream("push.i", symtable[tmp_index].get_variable_to_asm(true), "&" + symtable[tmp_index].name);
        append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
        auto stack_ptr = 4 + symtable[$1].arguments_types.size() * 4;
        append_command_to_stream("incsp.i", "#" + std::to_string(stack_ptr), std::to_string(stack_ptr));
        $$ = tmp_index;
        expression_list.clear();

    }
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}