#include "global.h"
#include "parser.h"
int
main () 
{
  init ();
  yyparse ();
  exit (0);
}


