#include "global.h"
#include "parser.h"
#include "entry.h"
void
init () {
    entry keywords[] = { 
        {"read", ID}, 
        {"write", ID}, 
        {"", 0} 
    };

    struct entry *p;
    for (p = keywords; p->token; p++)
    insert_name (p->name, p->token);
}


