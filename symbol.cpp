#include <vector>
#include <string>
#include "global.h"
#include "entry.h"

std::vector<entry> symtable;
int label_index = 1;
int number_of_temporary_variables = 0;

int lookup_name (std::string s) {
  for (int i = symtable.size() - 1; i >= 0 ; --i) {
    if (symtable[i].name.compare(s) == 0)
      return i;
  }
  return 0;
}
int insert_name (std::string s, entry_type tok)  {
    symtable.emplace_back(
        s,
        tok
    );
    return symtable.size() - 1;
}

int insert_dummy_number (int n)  {
    symtable.emplace_back(
        std::to_string(n),
        entry_type::number
    );
    return symtable.size() - 1;
}


void set_memory_offset(entry &element) {
    int curr_offset = 0;
    for(auto &curr_entry : symtable) {
        if(&curr_entry != &element && curr_entry.is_global == true)
            curr_offset +=curr_entry.size;
    }
    element.memory_offset = curr_offset;
}
void set_variable_at_symbol_table(int index, int size, data_type var_type) {
    if( global_scope) set_memory_offset(symtable[index]);
    else {
        symtable[index].is_global = false;
        relative_stack_pointer -= size;
        symtable[index].memory_offset = relative_stack_pointer;
    }
    symtable[index].size = size;
    symtable[index].token = entry_type::variable;
    symtable[index].type.variable_type = var_type;
}

void set_array_at_symbol_table(int index, variable_info array_info) {
    int memory_allocation_size;
    assert(array_info.variable_type == data_type::array_integer || array_info.variable_type == data_type:: array_real);
    if(array_info.variable_type == data_type::array_integer)
        memory_allocation_size = _INT_SIZE * array_info.number_of_elements;
    else if(array_info.variable_type == data_type:: array_real)
        memory_allocation_size = _REAL_SIZE * array_info.number_of_elements;
    
    if(global_scope) set_memory_offset(symtable[index]);
    else {
        symtable[index].is_global = false;
        relative_stack_pointer -= memory_allocation_size;
        symtable[index].memory_offset = relative_stack_pointer;
    }
    symtable[index].size = memory_allocation_size;
    symtable[index].token = entry_type::variable;
    symtable[index].type = array_info;
}

int add_temporary_variable(data_type type) {
    auto tmp_variable_name = std::string("$t") + std::to_string(number_of_temporary_variables++);
    auto index = insert_name(tmp_variable_name, entry_type::variable);
    if(type == data_type::integer) {
        set_variable_at_symbol_table(index, _INT_SIZE, type);
    }
    else if(type == data_type::real) {
        set_variable_at_symbol_table(index, _REAL_SIZE, type);
    }
    else {
        yyerror("wrong temporary variable type");
        //asssuming real
        set_variable_at_symbol_table(index, _REAL_SIZE, data_type::real);
    }
    return index;
}

int add_free_label() {
    auto label_name = "lab" + std::to_string(label_index++);
    auto lookup_index = lookup_name(label_name);
    if(lookup_index) {
        label_name = "collision_avoidance_" + label_name;
    }
    return insert_name(label_name, entry_type::label);
}
void dump_symbol_table() {
    for (size_t i = 0; i < symtable.size(); i++)
    {
        std::cout << i << ". ";
        auto & curr_entry = symtable[i];
        if(curr_entry.is_global)
            std::cout << "Global: ";
        else 
            std::cout << "Local: ";
        switch (curr_entry.token)
        {
        case entry_type::variable:
            if(curr_entry.type.variable_type == data_type::integer){
                std::cout << " integer variable, value: " << curr_entry.name;
                std::cout << " Offset: " << curr_entry.memory_offset << ", size: " << curr_entry.size;
            }
            else if(curr_entry.type.variable_type == data_type::real) {
                std::cout << " real variable, value: " << curr_entry.name;
                std::cout << " Offset: " << curr_entry.memory_offset << ", size: " << curr_entry.size;
            }
            else if(curr_entry.type.variable_type == data_type::array_integer) {
                std::cout << " integer array, value: " << curr_entry.name;
                std::cout << " Offset: " << curr_entry.memory_offset << ", size: " << curr_entry.size << ", number of elements: " << curr_entry.type.number_of_elements;
            }
            else if(curr_entry.type.variable_type == data_type::array_real) {
                std::cout << " real array, value: " << curr_entry.name;
                std::cout << " Offset: " << curr_entry.memory_offset << ", size: " << curr_entry.size << ", number of elements: " << curr_entry.type.number_of_elements;
            }
            break;
        case entry_type::number:
            std::cout << "constant, value: " << curr_entry.name;
            break;
        case entry_type::label:
            std::cout << " label: " << curr_entry.name;
            break;
        case entry_type::procedure:
            std::cout << " procedure: " << curr_entry.name;
            break;
        case entry_type::function:
            std::cout << " function: " << curr_entry.name ;
            if(curr_entry.type.variable_type == data_type::integer){
                std::cout << " returns int";
            }
            else if(curr_entry.type.variable_type == data_type::real) {
                std::cout << " returns real " << curr_entry.name;
            }
            break;
        default:
            std::cout << " unknown: " << curr_entry.name;
        }
        std::cout << std::endl;
    }
}