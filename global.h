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
//#define NDEBUG

#define NONE -1

#define _INT_SIZE 4
#define _REAL_SIZE 8
#define _CHAR_SIZE 1

#define EOS '\0'

extern int tokenval;
extern int lineno;

extern std::stringstream output_string_stream;
extern std::stringstream single_module_output;
extern std::vector<entry> symtable;
extern int relative_stack_pointer;
extern bool global_scope;

void generate_assign_op(int left_operand, int right_operand);
void append_command_to_stream(std::string command, std::string parameters = "", std::string parameters_string = "", std::stringstream &output = output_string_stream);
int generate_arithmetic_operation(std::string command, int index_operand_1, int index_operand_2);
void generate_command(std::string command_name, int first_arg = -1, int second_arg = -1, int third_arg = -1);
void generate_label(std::string label_name, std::stringstream &output = output_string_stream);
void generate_jump(std::string label_name, std::stringstream &output = output_string_stream);

void set_memory_offset(entry &element);
void set_variable_at_symbol_table(int index, int size, int var_type);
int add_temporary_variable(int type);
void dump_symbol_table();
int insert_name (std::string s, int tok);
int lookup_name (std::string s);


void error (const char *m);
void init () ;
extern "C" int yylex();
void yyerror (const char *m) ;
void expr () ;
void term () ;
void factor () ;
void match (int t) ;

void set_identifier_type_at_symbol_table(int type, std::list<int> &identifier_list);
std::tuple<int, int> manage_assignment_operation_type_conversion(int input_1, int input_2);
std::tuple<int, int> manage_arithmetical_operation_type_conversion(int input_1, int input_2);
void emit (int t, int tval) ;
