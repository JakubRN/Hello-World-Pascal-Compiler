#include "global.h"
#include "parser.h"
void
emit (int t, int tval) 
{
  switch (t)
    
    {
    case '+':
    case '-':
    case '*':
    case '/':
      printf ("%c\n", t);
      break;
    case DIV:
      printf ("DIV\n");
      break;
    case MOD:
      printf ("MOD\n");
      break;
    case NUM:
      printf ("%lf\n", symtable[tval].number);
      break;
    case ID:
      printf ("%s\n", symtable[tval].name.c_str());
      break;
    default:
      printf ("token %d , tokenval %d\n", t, tval);
    }
}


