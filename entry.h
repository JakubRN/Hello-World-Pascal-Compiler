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
        auto return_str = name;
        if(is_reference) return_str = '&' + return_str;
        return return_str;
    };
};