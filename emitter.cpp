#include "global.h"
#include "parser.h"
#include "entry.h"


std::string get_entry_type_string(int index) {
    switch (symtable[index].type)
    {
    case entry_type::function :
        return "function";
    case entry_type::procedure :
        return "procedure";
    case entry_type::variable :
        return "variable";
    case entry_type::number :
        return "number";
    case entry_type::uninitialized :
        return "uninitialized";
    case entry_type::label :
        return "label";
    default:
        return "unknown";
    }
}

data_type get_data_type(int entry) {
    if(entry == INTEGER) return data_type::integer;
    else if(entry == REAL) return data_type::real;
    else {
        throw std::runtime_error( "other type is unsupported (yet)" );
    }
}

void set_identifier_type_at_symbol_table(int type, std::list<int> &identifier_list_vect) {
    for(auto &symbol_table_index : identifier_list_vect) {
        if(type == INTEGER){
            set_variable_at_symbol_table(symbol_table_index, _INT_SIZE, data_type::integer);
        }
        else if(type == REAL){
            set_variable_at_symbol_table(symbol_table_index, _REAL_SIZE, data_type::real);
        }
        else if(type == ARRAY) {
            set_array_at_symbol_table(symbol_table_index, array_data);
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
        if(symtable[expr_id].type == entry_type::number) {
            auto new_expr_id=add_temporary_variable(symtable[expr_id].info.variable_type);
            generate_assign_op(new_expr_id, expr_id);
            expr_id = new_expr_id;
        }
        if(symtable[expr_id].info.variable_type != (*function_arg_pointer).variable_type) {
            yyerror(("argument " + std::to_string(current_parameter) + " passed to function " + symtable[procedure_id].name + " has incorrect type").c_str());
            expr_id = manage_assignment_operation_type_conversion((*function_arg_pointer).variable_type, expr_id);
        }
        if(expr_id == -1) {
            yyerror(("argument " + std::to_string(current_parameter) + " passed to function " + symtable[procedure_id].name + " cannot be implicitly converted").c_str());
            append_command_to_stream("push.i", "#-1", "&" + symtable[expr_id].name);
        }
        append_command_to_stream("push.i", symtable[expr_id].get_variable_to_asm(true), "&" + symtable[expr_id].name);
        ++function_arg_pointer;
        ++expr_list_pointer;
    }
}

int manage_assignment_operation_type_conversion(data_type left_type, int input_2){
    if(left_type == symtable[input_2].info.variable_type) {
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

std::tuple<int, int> manage_type_promotion(int input_1, int input_2) {

    if(symtable[input_1].info.variable_type == symtable[input_2].info.variable_type) {
        return {input_1, input_2};
    }
    else if(symtable[input_1].info.variable_type == data_type::integer) {
        auto tmp = add_temporary_variable(data_type::real);
        generate_command("inttoreal.i", input_1, tmp);
        return {tmp, input_2};
    }
    else if(symtable[input_2].info.variable_type == data_type::integer) {
        auto tmp_2 = add_temporary_variable(data_type::real);
        generate_command("inttoreal.i", input_2, tmp_2);
        return {input_1, tmp_2};
    }
    return {-1, -1};
}



