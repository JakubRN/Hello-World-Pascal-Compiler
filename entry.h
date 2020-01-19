#pragma once
#include "global.h"

struct variable_info {
    data_type variable_type = data_type::integer;
    int array_size;
};

struct entry {
    bool is_reference = false;
    bool is_global = true;
    std::string name;
    entry_type token; 

    variable_info type;

    int size = 0;

    int memory_offset = 0;

    std::list<variable_info> arguments_types;
    
    entry(std::string _name, entry_type _token) : 
         name(std::move(_name)), token(_token) { ; }

    std::string get_variable_to_asm(bool pass_reference = false){
        std::string return_name;
        if(token == entry_type::number)
            return_name = "#" + name;
        else if(token == entry_type::label)
            return_name = "#" + name;
        else {
            return_name = std::to_string(abs(memory_offset));

            if( ! is_global) {
                if(memory_offset < 0) return_name = "BP-"+ return_name;
                else return_name = "BP+"+ return_name;
            }
            if(is_reference &&  ! pass_reference) {
                return_name = '*' + return_name;

            }
            else if ( pass_reference && ! is_reference) {
                return_name = '#' + return_name;
            }
        }

            
        return return_name;
    };
};