#include "global.h"
#include "parser.h"
#include "entry.h"


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



