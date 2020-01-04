%{
/* recognize articles a, an, the */
#include "global.h"
#include "parser.h"
int lineno = 1;
int install_id();
int install_num();
%}
delim       [ \t]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
id          {letter}({letter}|{digit})*
digits      {digit}+
optional_fraction   (\.{digits})?
optional_exponent   (E((\+|\-)?){digits})?
num         {digits}{optional_fraction}{optional_exponent}
opsign      [\+\-\*\/\(\);]     
%%
[\n]        {lineno++;}
{ws}        {/* no action and no return */}
{num}       {yylval = install_num(); return(symtable[yylval].token);}
{id}        {yylval = install_id();  return(symtable[yylval].token);}
{opsign}    {return(yytext[0]);}
%%
/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */
int install_id() {
     int p = lookup_name (yytext);
        if (p == 0){
            p = insert_name (yytext, ID);
        }
    return p;
}
int install_num() {
    double number;
    sscanf(yytext, "%lf", &number);
    int p = lookup_num (number);
        if (p == 0){
            p = insert_num (number, NUM);
        }
    return p;
}