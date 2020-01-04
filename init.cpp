#include "global.h"
#include "parser.h"

void
init () {
    entry keywords[] = { 
        {"div", DIV, -1.0, true}, 
        {"mod", MOD, -1.0, true}, 
        {"", 0, -1.0, true} 
    };

    struct entry *p;
    for (p = keywords; p->token; p++)
    insert_name (p->name, p->token);
}


