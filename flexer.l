%{
/* recognize articles a, an, the */
#include "global.h"
#include "entry.h"
#include "parser.h"
int lineno = 1;
int lookup_or_install(entry_type ID_name);
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
(if)        {return _IF;}
(then)      {return _THEN;}
(else)      {return _ELSE;}
(while)     {return WHILE;}
(do)        {return DO;}
(:=)        {return ASSIGN_OP;}
(div)       {return DIV;}
(mod)       {return MOD;}
(begin)     {return _BEGIN;}
(end)       {return _END;}
(function)  {yylval = FUNCTION; return FUNCTION;}
(procedure) {yylval = PROCEDURE; return PROCEDURE;}
(array)     {yylval = ARRAY; return ARRAY;}
(integer)   {yylval = INTEGER; return INTEGER;}
(real)      {yylval = REAL; return REAL;}
(program)   {return PROGRAM;}
(var)       {return VAR;}
(of)        {return OF;}
(or)        {return OR;}
(and)        {return AND;}
(not)        {return NOT;}
{num_int}        {  yylval = lookup_or_install(entry_type::number);
                    symtable[yylval].info.variable_type=data_type::integer;
                    return NUM;}
{num_real}       {yylval = lookup_or_install(entry_type::number); 
                symtable[yylval].info.variable_type=data_type::real;
                return NUM;}
{id}        {yylval = lookup_or_install(entry_type::uninitialized);  return ID;}
{opsign}    {return(yytext[0]);}
%%
//old relop that detects whole relative operations
//relop       \=|(\<\>)|\<|(\<\=)|(\>\=)|\>

/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */

int lookup_or_install(entry_type ID_name) {
     int p = lookup_name (yytext);
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