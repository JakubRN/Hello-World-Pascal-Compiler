%{
#include <ctype.h>
#include <stdio.h>
#include "global.h"
#include "entry.h"

int relative_stack_pointer;
variable_info array_data;
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
%token WHILE
%token DO
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
        symtable[$2].type = entry_type::label;
        //TODO use identifier list
        identifier_list.clear();
    }
    declarations {global_scope = false;}
    subprogram_declarations { 
        global_scope = true;
        generate_label(symtable[$2].name);
        }
    compound_statement '.' {
        append_command_to_stream("exit");
        }
;
identifier_list:
    identifier_list ',' ID { 
            if(symtable[$3].type != entry_type::uninitialized) {
                if(symtable[$3].is_global && ! global_scope) {
                    //local variable with the same name
                    $3 = insert_name(symtable[$3].name, entry_type::uninitialized);
                }
                else {
                    yyerror("redeclaring variable with the same name: ");
                    YYABORT;
                }
            }
        identifier_list.emplace_back($3); 
        }
    | ID { 
            if(symtable[$1].type != entry_type::uninitialized) {
                if(symtable[$1].is_global && ! global_scope) {
                    //local variable with the same name
                    $1 = insert_name(symtable[$1].name, entry_type::uninitialized);
                }
                else {
                    yyerror("redeclaring variable with the same name: ");
                    YYABORT;
                }
            }
            identifier_list.emplace_back($1);
        }
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
    | ARRAY '[' NUM '.' '.' NUM ']'  OF standard_type {
        auto array_begin = std::stoi(symtable[$3].name);
        auto array_end = std::stoi(symtable[$6].name);
        auto size = array_end - array_begin + 1;
        assert(size > 0);
        array_data.number_of_elements = size;
        array_data.beginning_index = array_begin;
        array_data.ending_index = array_end;
        assert($9 == INTEGER || $9 == REAL);
        if($9 == INTEGER)
            array_data.variable_type = data_type::array_integer;
        else if($9 == REAL)
            array_data.variable_type = data_type::array_real;
    }
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
        write_to_valid_stringstream("enter.i", "#" + number_to_append, number_to_append, output_string_stream);
        //append_command_to_stream("enter.i", "#" + number_to_append, number_to_append);
        output_string_stream << single_module_output.str();
        single_module_output.str(std::string());
        if(symbol_table_size != 0)
            dump_symbol_table();
            symtable.erase(symtable.begin() + symbol_table_size, symtable.end());
    }
;
subprogram_head:
    FUNCTION ID {symbol_table_size = symtable.size();} arguments ':' standard_type ';' {
            if(symtable[$2].type != entry_type::uninitialized) {
                yyerror("function uses name that already exists");
                YYERROR;
            }
            //Expects you to push return variable last
            symtable[$2].is_global = false;
            symtable[$2].is_reference = true;
            symtable[$2].type = entry_type::function;
            symtable[$2].memory_offset = 8;

            symtable[$2].info.variable_type = get_data_type($6);
            relative_stack_pointer = 0;
            output_string_stream << symtable[$2].name << ':' << std::endl;;
            for(const auto &symbol_table_index : parameters_list) {
                symtable[$2].arguments_types.push_back( symtable[symbol_table_index].info );
            }
            parameters_list.clear();
        }
    | PROCEDURE ID {symbol_table_size = symtable.size();} arguments ';' { 
            if(symtable[$2].type != entry_type::uninitialized) {
                yyerror("function uses name that already exists");
                YYERROR;
            }
            symtable[$2].is_global = false;
            symtable[$2].type = entry_type::procedure;
            relative_stack_pointer = 0;
            output_string_stream << symtable[$2].name << ':' << std::endl;;
            for(const auto &symbol_table_index : parameters_list) {
                symtable[$2].arguments_types.push_back( {symtable[symbol_table_index].info.variable_type, 0 } );
            }
            parameters_list.clear();
            
        }
;
arguments:
    '(' parameter_list ')' {
        assert($-2 == PROCEDURE || $-2 == FUNCTION);
        if($-2 == PROCEDURE) {
            relative_stack_pointer = parameters_list.size()*4 + 4;
        }
        else if($-2 == FUNCTION) {
            relative_stack_pointer = parameters_list.size()*4 + 8;
        }
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
    WHILE {
        auto begin = add_free_label();
        generate_label(symtable[begin].name);
        $1 = begin;
    } expr DO {
        auto end = add_free_label();
        $4 = end;
        std::string command = "je";
        symtable[$3].info.variable_type == data_type::real ? command+=".r" : command += ".i";
        generate_command(command, $3, index_of_zero, end);
    } statement {
        generate_jump(symtable[$1].name);
        generate_label(symtable[$4].name);
    }
    | matched_statement
    | unmatched_statement
;
matched_statement:
    if_expr then_expr _ELSE matched_statement {
        generate_label(symtable[$2].name);
    }
    | other_statement
;
unmatched_statement:
    if_expr _THEN statement {
        generate_label(symtable[$1].name);
    }
    | if_expr then_expr _ELSE unmatched_statement {
        generate_label(symtable[$2].name);
    }
;
if_expr: 
    _IF expr {
        auto if_false = add_free_label();
        std::string command = "je";
        symtable[$2].info.variable_type == data_type::real ? command+=".r" : command += ".i";
        generate_command(command, $2, index_of_zero, if_false);
        $$ = if_false;
    }
    ;
then_expr:
    _THEN matched_statement {
        auto if_true = add_free_label();
        generate_jump(symtable[if_true].name);
        generate_label(symtable[$0].name);
        $$ = if_true;
    }
    ;
other_statement:
    variable ASSIGN_OP expr { generate_assign_op($1, $3); }
    | procedure_statement
    | compound_statement
    ;
variable:
    ID { 
        if(symtable[$1].type == entry_type::uninitialized) {
            yyerror("unknown variable");
            YYERROR;
        }
    }
    | ID '[' expr ']'  {
        //TODO offset is calculated from starting index, not 1
        assert(symtable[$1].is_array());
        auto address_index = add_temporary_variable(data_type::integer);
        auto right_hand = manage_assignment_operation_type_conversion(data_type::integer, $3);
        generate_command("sub.i", right_hand, insert_dummy_number(symtable[$1].info.beginning_index), address_index);
        int return_index;
        if(symtable[$1].info.variable_type == data_type::array_integer){
            generate_command("mul.i", address_index, index_of_four, address_index);
            return_index = add_temporary_variable(data_type::integer);
        }

        if(symtable[$1].info.variable_type == data_type::array_real){
            generate_command("mul.i", address_index, index_of_eight, address_index);
            return_index = add_temporary_variable(data_type::real);
        }
        symtable[return_index].is_reference = true;
        symtable[return_index].size = _INT_SIZE;
        generate_command("add.i", $1, address_index, return_index, true, false, true);
        $$ = return_index;
    }
;
procedure_statement:
    ID {
        if(symtable[$1].type == entry_type::procedure) {
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
        }
        else {
            yyerror(("expected procedure, got: " + get_entry_type_string($1)).c_str());
            YYERROR;
        }
        }
    | ID '(' expression_list ')' {
        if(symtable[$1].type == entry_type::procedure) {
            auto write_id = lookup_name("write");
            auto read_id = lookup_name("read");
            if($1 == write_id) {
                for(auto &elem : expression_list) {
                    if(symtable[elem].info.variable_type == data_type::real)
                        generate_command("write.r", elem);
                    else if(symtable[elem].info.variable_type == data_type::integer)
                        generate_command("write.i", elem);
                    else {
                        yyerror("wrong type of variable to write: expecting real or int");
                        YYERROR;
                    }
                }
            }
            else if ($1 == read_id) {
                for(auto &elem : expression_list) {
                    if(symtable[elem].info.variable_type == data_type::real)
                        generate_command("read.r", elem);
                    else if(symtable[elem].info.variable_type == data_type::integer)
                        generate_command("read.i", elem);
                    else {
                        yyerror("wrong type of variable to read: expecting real or int");
                        YYERROR;
                    }
                }
            }
            else {
                push_arguments_list($1, expression_list);
                append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
                auto stack_ptr = symtable[$1].arguments_types.size() * 4;
                append_command_to_stream("incsp.i", "#" + std::to_string(stack_ptr), std::to_string(stack_ptr));
            }
        }
        else if(symtable[$1].type == entry_type::function) {
            push_arguments_list($1, expression_list);
            auto tmp_index = add_temporary_variable(symtable[$1].info.variable_type);
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
    | expr MOD expr { $$ = generate_arithmetic_operation("mod", $1, $3); }

    | '-' expr %prec UMINUS { $$ = $2; }
    | '+' expr %prec UPLUS  { $$ = $2; }
    | NOT expr { $$ = $2; }
    | '(' expr ')' { $$ = $2; }
    | NUM
    | variable {
        if(symtable[$1].type == entry_type::function) {
            auto tmp_index = add_temporary_variable(symtable[$1].info.variable_type);
            append_command_to_stream("push.i", "#" + symtable[tmp_index].get_variable_to_asm(), "&" + symtable[tmp_index].name);
            append_command_to_stream("call.i", "#" + symtable[$1].name, "&" + symtable[$1].name);
            append_command_to_stream("incsp.i", "#4", "4");
            $$ = tmp_index;
        }
    }
    | ID '(' expression_list ')' {
        if(symtable[$1].type == entry_type::function) {
            push_arguments_list($1, expression_list);
            auto tmp_index = add_temporary_variable(symtable[$1].info.variable_type);
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