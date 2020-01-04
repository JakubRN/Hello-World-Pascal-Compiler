#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <vector>
#include <string>
#include <iostream>
#define BSIZE 128
#define NONE -1
#define EOS '\0'

extern int tokenval;
extern int lineno;

struct entry {
    std::string name;
    int token;
    double number;
    bool is_name;
    entry(){}
    entry(std::string _name, int _token, double _number, bool _is_name) : 
        name(std::move(_name)), token(_token), number(_number), is_name(_is_name) 
        {;}
    entry(const entry &other) : 
        name(other.name), token(other.token), number(other.number), is_name(other.is_name) 
        {;}
    entry(entry &&other) : 
        name(std::move(other.name)), token(other.token), number(other.number), is_name(other.is_name) 
        {;}
};
extern std::vector<entry> symtable;
int insert_name (std::string s, int tok);
int insert_num (double num, int tok);
void error (const char *m);
int lookup_name (char s[]);
int lookup_num (double num);
void init () ;
extern "C" int yylex();
void expr () ;
void term () ;
void factor () ;
void match (int t) ;
void emit (int t, int tval) ;
