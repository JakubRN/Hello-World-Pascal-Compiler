#include "global.h"
#include "entry.h"

void write_to_valid_stringstream(std::string command, std::string parameters, std::string parameters_string, std::stringstream &output) {
    output  << std::setw(8) << " ";
    std::size_t command_width = 8;
    if(command.length() >= command_width) command_width = (command.length() + 1);
    output  << std::setw(command_width) << std::left << (command + " ");
    output  << std::setw(32 - command_width) << std::left << parameters;
    output  << ";" << std::setw(8) << std::left << (command + " ");
    output  << std::setw(24) << std::left << parameters_string << std::endl;
}

void append_command_to_stream(std::string command, std::string parameters, std::string parameters_string) {
    if( global_scope)
        write_to_valid_stringstream(command, parameters, parameters_string, output_string_stream);
    else
       write_to_valid_stringstream(command, parameters, parameters_string, single_module_output);

}

void generate_assign_op(int left_operand, int right_operand){
    right_operand = manage_assignment_operation_type_conversion(symtable[left_operand].info.variable_type, right_operand);
    std::string command;
    if(symtable[left_operand].info.variable_type == data_type::integer)
        command = "mov.i";
    else if(symtable[left_operand].info.variable_type == data_type::real)
        command = "mov.r";
    generate_command(command, right_operand, left_operand);
}

int generate_arithmetic_operation(std::string command, int index_operand_1, int index_operand_2) {
    auto [index_input_1, index_input_2] = manage_type_promotion(index_operand_1, index_operand_2);
        int output_index;
        if(symtable[index_input_1].info.variable_type == data_type::real) {
            command += ".r";
            output_index = add_temporary_variable(data_type::real);
        }
        else {
            command += ".i";
            output_index = add_temporary_variable(data_type::integer);
        }
        generate_command(command, index_input_1, index_input_2, output_index);
        return output_index;
}

void generate_label(std::string label_name) {
    if(global_scope)
        output_string_stream << label_name << ':' << std::endl;
    else
        single_module_output << label_name << ':' << std::endl;
}

void generate_command(std::string command_name, int first_arg, int second_arg, int third_arg, 
                        bool pass_ref_1, bool pass_ref_2, bool pass_ref_3) {
    std::stringstream comments_with_names;
    std::stringstream tmp_stringstream;
    if(first_arg != -1) {
        tmp_stringstream << symtable[first_arg].get_variable_to_asm(pass_ref_1);
        comments_with_names  << symtable[first_arg].get_name_to_asm(pass_ref_1);
    }
    if(second_arg != -1) {
        tmp_stringstream << "," << symtable[second_arg].get_variable_to_asm(pass_ref_2);
        comments_with_names <<  "," << symtable[second_arg].get_name_to_asm(pass_ref_2);
    }
    if(third_arg != -1) {
        tmp_stringstream << "," << symtable[third_arg].get_variable_to_asm(pass_ref_3);
        comments_with_names <<  "," << symtable[third_arg].get_name_to_asm(pass_ref_3);
    }
    append_command_to_stream(command_name, tmp_stringstream.str(), comments_with_names.str());
}


void generate_jump(std::string label_name) {
    append_command_to_stream("jump.i", "#" + label_name, "#" + label_name);
}


int generate_relop(std::string command, int operand_1, int operand_2) {
    std::tie(operand_1, operand_2) = manage_type_promotion(operand_1, operand_2);
    symtable[operand_1].info.variable_type == data_type::real ? command+=".r" : command += ".i";
    auto if_true = add_free_label();
    auto if_false = add_free_label();
    generate_command(command, operand_1, operand_2, if_true);
    auto result = add_temporary_variable(data_type::integer);
    generate_assign_op(result, index_of_zero);
    generate_jump(symtable[if_false].name);
    generate_label(symtable[if_true].name);
    generate_assign_op(result, index_of_one);
    generate_label(symtable[if_false].name);
    return result;
}