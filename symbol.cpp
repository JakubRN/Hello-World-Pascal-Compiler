#include <vector>
#include <string>
#include "global.h"

std::vector<entry> symtable;

int lookup_name (char s[]) {
  for (std::size_t i = 0; i < symtable.size(); ++i) {
    if (symtable[i].is_name && symtable[i].name.compare(s) == 0)
      return i;
  }
  return 0;
}
int insert_name (std::string s, int tok)  {

    symtable.emplace_back(
        s,
        tok,
        -1.0,
        true
    );

    return symtable.size() - 1;
}

int lookup_num (double num) {
  for (std::size_t i = 0; i < symtable.size(); ++i) {
    if (!symtable[i].is_name && symtable[i].number == num)
      return i;
  }
  return 0;
}

int insert_num (double num, int tok)  {
    symtable.emplace_back(
        std::string(""),
        tok,
        num,
        false
    );
    return symtable.size() - 1;
}

