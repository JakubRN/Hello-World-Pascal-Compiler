%{
/* recognize articles a, an, the */
#include "global.h"
#include "bison_parser.tab.h"
int lineno = 1;
int tokenval = NONE;

int install_id();
int scan_num();
%}
delim       [ \t]
ws          {delim}+
letter      [A-Za-z]
digit       [0-9]
id          {letter}({letter}|{digit})*
number      [0-9]+
opsign      [\+\-\*\/\(\);]     
%%
[\n]        {lineno++;}
{ws}        {/* no action and no return */}
{number}    {scan_num(); return(NUM);}
{id}        {tokenval = install_id();  return(symtable[tokenval].token);}
<<EOF>>     {return(DONE);}
{opsign}    {return(yytext[0]);}
%%
/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */
int install_id() {
     int p = lookup (yytext);
        if (p == 0){
            printf( "installing ID: %s, %d\n", yytext, yyleng);
            p = insert (yytext, ID);
        }
    return p;
}
int scan_num() {
    sscanf(yytext, "%d", &tokenval);
    return tokenval;
}

int lexan () 
{
 return yylex();
}