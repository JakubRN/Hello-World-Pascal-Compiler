#include <vector>
#include <string>
#include "global.h"
#include "entry.h"

std::vector<entry> symtable;

int lookup_name (char s[], int tok) {
  for (std::size_t i = 0; i < symtable.size(); ++i) {
    if (symtable[i].name.compare(s) == 0 && tok == symtable[i].token)
      return i;
  }
  return 0;
}
int insert_name (std::string s, int tok)  {

    symtable.emplace_back(
        s,
        tok
    );

    return symtable.size() - 1;
}

// int lookup_real (double num) {
//   for (std::size_t i = 0; i < symtable.size(); ++i) {
//     if (symtable[i].var.value_real == num)
//       return i;
//   }
//   return 0;
// }

// int insert_real (double num, int tok)  {
//     symtable.emplace_back(
//         std::string(""),
//         tok,
//         num,
//         false
//     );
//     return symtable.size() - 1;
// }

// int lookup_int (int num) {
//   for (std::size_t i = 0; i < symtable.size(); ++i) {
//     if (symtable[i].var.value_int == num)
//       return i;
//   }
//   return 0;
// }

// int insert_int (int num, int tok)  {
//     symtable.emplace_back(
//         std::string(""),
//         tok
//     );
//     return symtable.size() - 1;
// }