#include <vector>
#include <string>
#include "global.h"
#include "entry.h"

std::vector<entry> symtable;
int number_of_temporary_variables = 0;
int lookup_name (std::string s) {
  for (std::size_t i = 0; i < symtable.size(); ++i) {
    if (symtable[i].name.compare(s) == 0)
      return i;
  }
  return 0;
}
int insert_name (std::string s, int tok)  {
    symtable.emplace_back(
        s,
        tok
    );
    return symtable.size() - 1;
}

void set_memory_offset(entry &element) {
    int curr_offset = 0;
    for(auto &curr_entry : symtable) {
        if(&curr_entry != &element)
            curr_offset +=curr_entry.size;
    }
    element.memory_offset = curr_offset;
}
void set_variable_at_symbol_table(int index, int size, int var_type) {
    symtable[index].size = size;
    symtable[index].token = VAR;
    symtable[index].variable_type = var_type;
    set_memory_offset(symtable[index]);
}

int add_temporary_variable(int type) {
    auto tmp_variable_name = std::string("$t") + std::to_string(number_of_temporary_variables++);
    auto index = insert_name(tmp_variable_name, VAR);
    if(type == INTEGER) {
        set_variable_at_symbol_table(index, _INT_SIZE, INTEGER);
    }
    else if(type == REAL) {
        set_variable_at_symbol_table(index, _REAL_SIZE, REAL);
    }
    else {
        yyerror("wrong temporary variable type");
        //asssuming real
        set_variable_at_symbol_table(index, _REAL_SIZE, REAL);
    }
    return index;
}

void dump_symbol_table() {
    for(auto &curr_entry : symtable) {
        switch (curr_entry.token)
        {
        case VAR:
            if(curr_entry.variable_type == INTEGER){
                std::cout << " integer variable, value: " << curr_entry.name;
            }
            else if(curr_entry.variable_type == REAL) {
                std::cout << " real variable, value: " << curr_entry.name;
            }
            break;
        case NUM_INT:
            std::cout << " integer constant, value: " << curr_entry.name;
            break;
        case NUM_REAL:
            std::cout << " real constant, value: " << curr_entry.name;
            break;
        case LABEL:
            std::cout << " label: " << curr_entry.name;
            break;
        default:
            std::cout << " unknown: " << curr_entry.name << std::endl;
            continue;
            break;
        }
        std::cout << " Offset: " << curr_entry.memory_offset << ", size: " << curr_entry.size;
        std::cout << std::endl;
    }
}