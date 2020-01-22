#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <string>
#include <vector>
#include <list>
#include <stack>
#include <iostream>
#include <cassert>
#include <fstream>
#include <sstream>
#include <tuple>
#include <iomanip>
#include "parser.h"

struct entry;
auto constexpr index_of_zero = 0;
auto constexpr index_of_one = 1;
auto constexpr index_of_four = 2;
auto constexpr index_of_eight = 3;
enum class data_type {
    integer,
    real,
    array_integer,
    array_real
};

struct variable_info {
    data_type variable_type = data_type::integer;
    int number_of_elements;
    int beginning_index;
    int ending_index;
};

enum class entry_type {
    uninitialized,
    function,
    procedure,
    variable,
    number,
    label
};

//#define NDEBUG

#define NONE -1

#define _INT_SIZE 4
#define _REAL_SIZE 8

#define EOS '\0'

extern int tokenval;
extern int lineno;

extern variable_info array_data;

extern std::stringstream output_string_stream;
extern std::stringstream single_module_output;
extern std::vector<entry> symtable;
extern int relative_stack_pointer;
extern bool global_scope;

std::string get_entry_type_string(int index);
void generate_assign_op(int left_operand, int right_operand);

void write_to_valid_stringstream(std::string command, std::string parameters, std::string parameters_string, std::stringstream &output);
void append_command_to_stream(std::string command, std::string parameters = "", std::string parameters_string = "");
int generate_arithmetic_operation(std::string command, int index_operand_1, int index_operand_2);
void generate_command(std::string command_name, int first_arg = -1, int second_arg = -1, int third_arg = -1, 
                        bool pass_ref_1 = false, bool pass_ref_2 = false, bool pass_ref_3 = false);
void generate_label(std::string label_name);
void generate_jump(std::string label_name);
int generate_relop(std::string command, int operand_1, int operand_2);

int add_free_label();
int insert_dummy_number (int n);
void set_memory_offset(entry &element);
void set_array_at_symbol_table(int index, variable_info array_info);
void set_variable_at_symbol_table(int index, int size, data_type var_type);
int add_temporary_variable(data_type type);
void dump_symbol_table();
int insert_name (std::string s, entry_type tok);
int lookup_name (std::string s);

int yylex_destroy();
void error (const char *m);
void init () ;
extern "C" int yylex();
void yyerror (const char *m) ;
void yywarning (const char *m);
void expr () ;
void term () ;
void factor () ;
void match (int t) ;


data_type get_data_type(int token);
void push_arguments_list(int procedure_id, std::list<int> &expression_list);
void set_identifier_type_at_symbol_table(int type, std::list<int> &identifier_list);
int manage_assignment_operation_type_conversion(data_type left_type, int input_2);
std::tuple<int, int> manage_type_promotion(int input_1, int input_2);
void emit (int t, int tval) ;
