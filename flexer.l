%{
/* recognize articles a, an, the */
#include "global.h"
int lineno = 1;
int tokenval = NONE;
char lexbuf[BSIZE];

int install_id();
int install_num();
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
{number}    {install_num(); return(NUM);}
{id}        {return(install_id());}
<<EOF>>     {return(EOF);}
{opsign}    {return(yytext[0]);}
%%
int install_id() {

    
    strncpy(&lexbuf[0], &yytext[0], yyleng);
    lexbuf[yyleng] = EOS;
     int p = lookup (lexbuf);
        if (p == 0){
            // printf( "installing ID: %s, %d\n", yytext, yyleng);
            p = insert (lexbuf, ID);
        }
    tokenval = p;
    return symtable[p].token;

/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */
}
int install_num() {
    sscanf(yytext, "%d", &tokenval);
    return tokenval;
/* procedure to install the lexeme, whose first character is pointed by yytext
and whose length is yyleng, into the symbol table and return a pointer thereto */
}

int lexan () 
{
 return yylex();
}