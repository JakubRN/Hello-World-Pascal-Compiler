#pragma once
#include "global.h"

enum class data_type {
    integer,
    real,
    array_integer,
    array_real
};
struct variable_info {
    data_type variable_type;
    int array_size = 0;
};

struct entry {
    bool is_reference = false;
    bool is_global = true;
    std::string name;
    int token;

    int variable_type;

    int size = 0;

    int memory_offset = 0;

    std::list<int> arguments_types;
    entry(std::string _name, int _token) : 
         name(std::move(_name)), token(_token) { ; }

    std::string get_variable_to_asm(){
        std::string return_name;
        if(token == NUM_INT || token == NUM_REAL)
            return_name = "#" + name;
        else
            return_name = std::to_string(abs(memory_offset));

        if( ! is_global) {
            if(memory_offset < 0) return_name = "BP-"+ return_name;
            else return_name = "BP+"+ return_name;
        }
        if(is_reference) return_name = '*' + return_name;
        return return_name;
    };
};