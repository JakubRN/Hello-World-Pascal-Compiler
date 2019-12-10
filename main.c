#include "global.h"
#include "bison_parser.tab.h"
int
main () 
{
  init ();
  yyparse ();
  exit (0);
}


