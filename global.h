#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <string>
#include <vector>
#include <iostream>
#include <cassert>
#include <fstream>

#include "parser.h"

struct entry;
//#define NDEBUG

#define NONE -1

#define EOS '\0'

extern int tokenval;
extern int lineno;

extern std::ofstream output_file_stream;
extern std::vector<entry> symtable;

int insert_name (std::string s, int tok);
void error (const char *m);
int lookup_name (char s[], int tok);
void init () ;
extern "C" int yylex();
void expr () ;
void term () ;
void factor () ;
void match (int t) ;
void emit (int t, int tval) ;
