#pragma once
#include "global.h"

struct entry {
    bool is_reference = false;
    std::string name;
    int token;

    int variable_type;
    int size = 0;
    int memory_offset = 0;
    entry(std::string _name, int _token) : 
         name(std::move(_name)), token(_token) { ; }

    std::string get_variable_to_asm(){
        std::string return_name;
        if(token == NUM_INT || token == NUM_REAL)
            return_name = "#" + name;
        else if(token == VAR)
            return_name = std::to_string(memory_offset);
        if(is_reference) return_name = '*' + return_name;
        return return_name;
    };
};