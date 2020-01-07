%{
/* recognize articles a, an, the */
#include "global.h"
#include "entry.h"
#include "parser.h"
int lineno = 1;
int install(int ID_name);
// int install_num();
%}
delim       [ \t]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
id          {letter}({letter}|{digit})*
digits      {digit}+
optional_fraction   (\.{digits})?
optional_exponent   (E((\+|\-)?){digits})?
num_int         {digits}{optional_exponent}
num_real         {digits}{optional_fraction}{optional_exponent}
opsign      [\+\-\*\/\(\)\;\<\>\=\.\:\[\]\,]
%%
[\n]        {lineno++;}
{ws}        {/* no action and no return */}
(<>)        {return NOT_EQUAL;}
(<=)        {return LESS_THAN_OR_EQUAL;}
(>=)        {return MORE_THAN_OR_EQUAL;}
(if)        {return __IF;}
(then)      {return __THEN;}
(else)      {return __ELSE;}
(:=)        {return ASSIGN_OP;}
(begin)     {return __BEGIN;}
(end)       {return __END;}
(function)  {return FUNCTION;}
(procedure) {return PROCEDURE;}
(array)     {yylval = ARRAY; return ARRAY;}
(integer)   {yylval = INTEGER; return INTEGER;}
(real)      {yylval = REAL; return REAL;}
(program)   {return PROGRAM;}
(var)       {return VAR;}
(of)        {return OF;}
{num_int}        {yylval = install(NUM_INT); return(symtable[yylval].token);}
{num_real}       {yylval = install(NUM_REAL); return(symtable[yylval].token);}
{id}        {yylval = install(ID);  return(symtable[yylval].token);}
{opsign}    {return(yytext[0]);}
%%
//old relop that detects whole relative operations
//relop       \=|(\<\>)|\<|(\<\=)|(\>\=)|\>

/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */

int install(int ID_name) {
     int p = lookup_name (yytext, ID_name);
        if (p == 0){
            p = insert_name (yytext, ID_name);
        }
    return p;
}

// int install_num() {
//     double number;
//     sscanf(yytext, "%lf", &number);
//     int p = lookup_name (number);
//         if (p == 0){
//             p = insert_name (number, NUM_real);
//         }
//     return p;
// }