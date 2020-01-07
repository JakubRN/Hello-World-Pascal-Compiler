#include "global.h"
#include "parser.h"
#include "entry.h"
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
    case NUM_INT:
        int number_int;
        sscanf(symtable[tval].name.c_str(), "%d", &number_int);
        printf ("%d\n", number_int);
        break;
    case NUM_REAL:
        double number_real;
        sscanf(symtable[tval].name.c_str(), "%lf", &number_real);
        printf ("%lf\n", number_real);
    case ID:
      printf ("%s\n", symtable[tval].name.c_str());
      break;
    default:
      printf ("token %d , tokenval %d\n", t, tval);
    }
}


