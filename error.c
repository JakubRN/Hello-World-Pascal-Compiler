#include "global.h"

void
error (const char *m) 
{
  fprintf (stderr, "line%d:%s\n", lineno, m);
  exit (1);
}
void
yyerror (const char *m) 
{
    error(m);
}

