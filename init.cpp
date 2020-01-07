#include "global.h"
#include "parser.h"
#include "entry.h"
void
init () {
    entry keywords[] = { 
        {"div", DIV}, 
        {"mod", MOD}, 
        {"", 0} 
    };

    struct entry *p;
    for (p = keywords; p->token; p++)
    insert_name (p->name, p->token);
}


