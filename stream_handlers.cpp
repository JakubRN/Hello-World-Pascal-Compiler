#include "global.h"
#include "entry.h"

void generate_label(std::string label_name) {
    temporary_output_stream << label_name << ':' << std::endl;
};
void generate_command(std::string command_name, int first_arg, int second_arg, int third_arg) {
    std::stringstream comments_with_names;

    auto first_arg_str = symtable[first_arg].get_variable_to_asm();
    temporary_output_stream << command_name << " " << first_arg_str;
    comments_with_names << command_name << " " << symtable[first_arg].name;

    if(second_arg != -1) {
        auto second_arg_str = symtable[second_arg].get_variable_to_asm();
        temporary_output_stream << "," << second_arg_str;
        comments_with_names <<  "," << symtable[second_arg].name;
    }
    if(third_arg != -1) {
        auto third_arg_str = symtable[third_arg].get_variable_to_asm();
        temporary_output_stream << "," << third_arg_str;
        comments_with_names <<  "," << symtable[third_arg].name;
    }
    temporary_output_stream << "\t\t;" << comments_with_names.str() << std::endl;
};


void generate_jump(std::string label_name) {
    temporary_output_stream << "jump.i #" << label_name <<"\t\t;jump.i " << label_name << std::endl;
}