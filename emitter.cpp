#include "global.h"
#include "parser.h"
#include "entry.h"

data_type get_data_type(int token) {
    if(token == INTEGER) return data_type::integer;
    else if(token == REAL) return data_type::real;
    else {
        throw std::runtime_error( "other type is unsupported (yet)" );
    }
}

void set_identifier_type_at_symbol_table(int type, std::list<int> &identifier_list_vect) {
    for(const auto &symbol_table_index : identifier_list_vect) {
        if(type == INTEGER){
            set_variable_at_symbol_table(symbol_table_index, _INT_SIZE, data_type::integer);
        }
        else if(type == REAL){
            set_variable_at_symbol_table(symbol_table_index, _REAL_SIZE, data_type::real);
        }
        else if(type == ARRAY) {
            std::cout << symtable[symbol_table_index].name  << " is array" << std::endl;
        }
        else {
            std::cout << "identifiers are unknown" << std::endl;
        }
    }
}

void push_arguments_list(int procedure_id, std::list<int> &expression_list) {
    if(expression_list.size() < symtable[procedure_id].arguments_types.size()) {
        yyerror(("too little arguments passed to function: " + symtable[procedure_id].name).c_str());
        return;
    }
    if(expression_list.size() > symtable[procedure_id].arguments_types.size()) {
        yyerror(("too many arguments passed to function" + symtable[procedure_id].name).c_str());
        return;
    }
    auto expr_list_pointer = expression_list.begin();
    auto function_arg_pointer = symtable[procedure_id].arguments_types.begin();
    for(unsigned current_parameter = 1; current_parameter <= symtable[procedure_id].arguments_types.size(); ++current_parameter) {
        int expr_id = *expr_list_pointer;
        if(symtable[expr_id].token == NUM) {
            auto new_expr_id=add_temporary_variable(symtable[expr_id].type.variable_type);
            generate_assign_op(new_expr_id, expr_id);
            expr_id = new_expr_id;
        }
        if(symtable[expr_id].type.variable_type != (*function_arg_pointer).variable_type) {
            yyerror(("argument " + std::to_string(current_parameter) + " passed to function " + symtable[procedure_id].name + " has incorrect type").c_str());
            expr_id = manage_assignment_operation_type_conversion((*function_arg_pointer).variable_type, expr_id);
        }
        append_command_to_stream("push.i", symtable[expr_id].get_variable_to_asm(true), "&" + symtable[expr_id].name);
        ++function_arg_pointer;
        ++expr_list_pointer;
    }
}

int manage_assignment_operation_type_conversion(data_type left_type, int input_2){
    if(left_type == symtable[input_2].type.variable_type) {
        return input_2;
    }
    else if(left_type == data_type::integer) {
        auto tmp = add_temporary_variable(data_type::integer);
        generate_command("realtoint.r", input_2, tmp);
        return  tmp;
    }
    else if(left_type == data_type::real) {
        auto tmp_2 = add_temporary_variable(data_type::real);
        generate_command("inttoreal.i", input_2, tmp_2);
        return tmp_2;
    }
    return -1;
}

std::tuple<int, int> manage_arithmetical_operation_type_conversion(int input_1, int input_2) {

    if(symtable[input_1].type.variable_type == symtable[input_2].type.variable_type) {
        return {input_1, input_2};
    }
    else if(symtable[input_1].type.variable_type == data_type::integer) {
        auto tmp = add_temporary_variable(data_type::real);
        generate_command("inttoreal.i", input_1, tmp);
        return {tmp, input_2};
    }
    else if(symtable[input_2].type.variable_type == data_type::integer) {
        auto tmp_2 = add_temporary_variable(data_type::real);
        generate_command("inttoreal.i", input_2, tmp_2);
        return {input_1, tmp_2};
    }
    return {-1, -1};
}



