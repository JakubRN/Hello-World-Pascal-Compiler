#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <string>
#include <vector>
#include <iostream>
#include <cassert>
#include <fstream>
#include <sstream>
#include <tuple>
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

extern std::ofstream output_file_stream;
extern std::stringstream temporary_output_stream;
extern std::vector<entry> symtable;

extern bool global_scope;

void generate_command(std::string command_name, int first_arg, int second_arg = -1, int third_arg = -1);
void generate_label(std::string label_name);
void generate_jump(std::string label_name);

void set_memory_offset(entry &element);
void set_variable_at_symbol_table(int index, int size, int var_type);
int add_temporary_variable(int type);
void dump_symbol_table();
int insert_name (std::string s, int tok);
int lookup_name (char s[], int tok);


void error (const char *m);
void init () ;
extern "C" int yylex();
void yyerror (const char *m) ;
void expr () ;
void term () ;
void factor () ;
void match (int t) ;

std::tuple<int, int> manage_type_conversion(int input_1, int input_2);
void emit (int t, int tval) ;
