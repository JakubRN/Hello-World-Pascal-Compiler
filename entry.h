#include "global.h"

struct entry {
    std::string name;
    int token;
    

    entry(std::string _name, int _token) : 
         name(std::move(_name)), token(_token) { ; }
    // entry(const entry &other) : 
    //     name(other.name), token(other.token), is_name(other.is_name) {
    //     var.value_real = other.var.value_real;
    //     var.type = variable_type::real;
    // }
    // entry(entry &&other) : 
    //     name(std::move(other.name)), token(other.token), is_name(other.is_name) {
    //     var.value_real = other.var.value_real;
    //     var.type = variable_type::real;
    // }
};