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
%token _IF
%token _THEN
%token _ELSE
%token ASSIGN_OP
%token _BEGIN
%token _END
%token PROCEDURE
%token FUNCTION
%token ARRAY
%token INTEGER
%token REAL
%token PROGRAM
%token OF

%token OR
%token AND
%token NOT

%token VAR
%token LABEL

%token NUM
%token ID
%token DIV 
%token MOD 


%left OR
%left AND
%left '<' '>' '=' NOT_EQUAL LESS_THAN_OR_EQUAL MORE_THAN_OR_EQUAL
%left '+' '-' 
%left '*' '/' MOD DIV
%right UMINUS UPLUS NOT
%%

program:
    PROGRAM ID '(' identifier_list ')' ';' {
        generate_jump(symtable[$2].name);
        symtable[$2].token = entry_type::label;
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
            symtable[$2].token = entry_type::function;
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
            symtable[$2].token = entry_type::procedure;
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
    _BEGIN
    optional_statements
    _END
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
    if_expr _THEN matched_statement {
        auto if_true = add_free_label();
        generate_jump(symtable[if_true].name);
        generate_label(symtable[$1].name);
        $3 = if_true;
    } _ELSE matched_statement {
        generate_label(symtable[$3].name);
    }
    | other_statement
;
unmatched_statement:
    if_expr _THEN statement {
        generate_label(symtable[$1].name);
    }
    | if_expr _THEN matched_statement {
        auto if_true = add_free_label();
        generate_jump(symtable[if_true].name);
        generate_label(symtable[$1].name);
        $3 = if_true;
    } _ELSE unmatched_statement {
        generate_label(symtable[$3].name);
    }
;
if_expr: 
    _IF expr {
        auto if_false = add_free_label();
        std::string command = "je";
        symtable[$2].type.variable_type == data_type::real ? command+=".r" : command += ".i";
        generate_command(command, $2, index_of_zero, if_false);
        $$ = if_false;
    }
other_statement:
    variable ASSIGN_OP expr { generate_assign_op($1, $3); }
    | procedure_statement
    | compound_statement
    ;
variable:
    ID                  
    | ID '[' expr ']' 
;
procedure_statement:
    ID {
        if(symtable[$1].token == entry_type::procedure) {
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
        }
        else {
            yyerror(("expected procedure, got: " + get_entry_type_string($1)).c_str());
        }
        }
    | ID '(' expression_list ')' {
        if(symtable[$1].token == entry_type::procedure) {
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
        }
        else if(symtable[$1].token == entry_type::function) {
            push_arguments_list($1, expression_list);
            auto tmp_index = add_temporary_variable(symtable[$1].type.variable_type);
            append_command_to_stream("push.i", symtable[tmp_index].get_variable_to_asm(true), "&" + symtable[tmp_index].name);
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
            auto stack_ptr = 4 + symtable[$1].arguments_types.size() * 4;
            append_command_to_stream("incsp.i", "#" + std::to_string(stack_ptr), std::to_string(stack_ptr));
            $$ = tmp_index;
        }
        else {
            yywarning(("expected procedure or function, got: " + get_entry_type_string($1)).c_str());
        }
        expression_list.clear();
    }
;
expression_list:
    expr {expression_list.push_back($1);}
    | expression_list ',' expr {expression_list.push_back($3);}
;
expr:
    expr OR expr {
        std::cout << $1 << ", " << $3 << std::endl;
        $$ = generate_arithmetic_operation("or", $1, $3);
    }
    | expr AND expr {
        std::cout << $1 << ", " << $3 << std::endl;
        $$ = generate_arithmetic_operation("and", $1, $3);
    }
    | expr '<' expr { 
        $$ = generate_relop("jl", $1, $3);
     }
    | expr '>' expr { 
        $$ = generate_relop("jg", $1, $3);
    }
    | expr '=' expr { 
        $$ = generate_relop("je", $1, $3);
    }
    | expr MORE_THAN_OR_EQUAL expr { 
        $$ = generate_relop("jge", $1, $3);
     }
    | expr LESS_THAN_OR_EQUAL expr { 
        $$ = generate_relop("jle", $1, $3);
     }
    | expr NOT_EQUAL expr { 
        $$ = generate_relop("jne", $1, $3);
     }

    | expr '+' expr  { $$ = generate_arithmetic_operation("add", $1, $3); }
    | expr '-' expr { $$ = generate_arithmetic_operation("sub", $1, $3); }

    | expr '*' expr { $$ = generate_arithmetic_operation("mul", $1, $3); }
    | expr '/' expr { $$ = generate_arithmetic_operation("div", $1, $3); }
    | expr DIV expr { $$ = generate_arithmetic_operation("div", $1, $3); }
    | expr MOD expr { $$ = generate_arithmetic_operation("add", $1, $3); }

    | '-' expr %prec UMINUS { $$ = $2; }
    | '+' expr %prec UPLUS  { $$ = $2; }
    | NOT expr { $$ = $2; }
    | '(' expr ')' { $$ = $2; }
    | NUM
    | ID {
        if(symtable[$1].token == entry_type::function) {
            auto tmp_index = add_temporary_variable(symtable[$1].type.variable_type);
            append_command_to_stream("push.i", "#" + symtable[tmp_index].get_variable_to_asm(), "&" + symtable[tmp_index].name);
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
            append_command_to_stream("incsp.i", "#4", "4");
            $$ = tmp_index;
        }

    }
    | ID '(' expression_list ')' {
        if(symtable[$1].token == entry_type::function) {
            push_arguments_list($1, expression_list);
            auto tmp_index = add_temporary_variable(symtable[$1].type.variable_type);
            append_command_to_stream("push.i", symtable[tmp_index].get_variable_to_asm(true), "&" + symtable[tmp_index].name);
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
            auto stack_ptr = 4 + symtable[$1].arguments_types.size() * 4;
            append_command_to_stream("incsp.i", "#" + std::to_string(stack_ptr), std::to_string(stack_ptr));
            $$ = tmp_index;
            expression_list.clear();
        }
    }
;
%%

void
yyerror (const char *m) 
{
    fprintf (stderr, "error at line: %d:%s\n", lineno, m);
}
void
yywarning (const char *m) 
{
    fprintf (stderr, "warning at line: %d:%s\n", lineno, m);
}