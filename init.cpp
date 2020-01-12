#include "global.h"
#include "parser.h"
#include "entry.h"
void
init () {
    entry keywords[] = { 
        {"read", PROCEDURE}, 
        {"write", PROCEDURE}, 
        {"", 0} 
    };

    struct entry *p;
    for (p = keywords; p->token; p++)
    insert_name (p->name, p->token);
}


