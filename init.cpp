#include "global.h"
#include "parser.h"
#include "entry.h"
void
init () {
    entry keywords[] = { 
        {"0", entry_type::number},
        {"1", entry_type::number},
        {"4", entry_type::number},
        {"8", entry_type::number},
        {"read", entry_type::procedure}, 
        {"write", entry_type::procedure}
    };

    for (auto &p : keywords)
        insert_name (p.name, p.type);
}


