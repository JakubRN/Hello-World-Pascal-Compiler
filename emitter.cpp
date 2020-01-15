#include "global.h"
#include "parser.h"
#include "entry.h"


void set_identifier_type_at_symbol_table(int type, std::list<int> &identifier_list_vect) {
    for(const auto &symbol_table_index : identifier_list_vect) {
        if(type == INTEGER){
            set_variable_at_symbol_table(symbol_table_index, _INT_SIZE, INTEGER);
        }
        else if(type == REAL){
            set_variable_at_symbol_table(symbol_table_index, _REAL_SIZE, REAL);
        }
        else if(type == ARRAY) {
            std::cout << symtable[symbol_table_index].name  << " is array" << std::endl;
        }
        else {
            std::cout << "identifiers are unknown" << std::endl;
        }
    }
}

std::tuple<int, int> manage_assignment_operation_type_conversion(int input_1, int input_2){
    if(symtable[input_1].variable_type == symtable[input_2].variable_type) {
        return {input_1, input_2};
    }
    else if(symtable[input_1].variable_type == INTEGER) {
        auto tmp = add_temporary_variable(INTEGER);
        generate_command("realtoint.r", input_2, tmp);
        return {input_1, tmp};
    }
    else if(symtable[input_1].variable_type == REAL) {
        auto tmp_2 = add_temporary_variable(REAL);
        generate_command("inttoreal.i", input_2, tmp_2);
        return {input_1, tmp_2};
    }
    return {-1, -1};
}

std::tuple<int, int> manage_arithmetical_operation_type_conversion(int input_1, int input_2) {

    if(symtable[input_1].variable_type == symtable[input_2].variable_type) {
        return {input_1, input_2};
    }
    else if(symtable[input_1].variable_type == INTEGER) {
        auto tmp = add_temporary_variable(REAL);
        generate_command("inttoreal.i", input_1, tmp);
        return {tmp, input_2};
    }
    else if(symtable[input_2].variable_type == INTEGER) {
        auto tmp_2 = add_temporary_variable(REAL);
        generate_command("inttoreal.i", input_2, tmp_2);
        return {input_1, tmp_2};
    }
    return {-1, -1};
}



