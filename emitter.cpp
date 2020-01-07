#include "global.h"
#include "parser.h"
#include "entry.h"

std::tuple<int, int> manage_type_conversion(int input_1, int input_2) {

    if(symtable[input_1].variable_type == symtable[input_2].variable_type) {
        std::cout << "type is correct" << std::endl;
        return {input_1, input_2};
    }
    else if(symtable[input_1].variable_type == INTEGER) {
        std::cout << "casting first variable" << std::endl;
        auto tmp = add_temporary_variable(REAL);
        generate_command("inttoreal.i", input_1, tmp);
        return {tmp, input_2};
    }
    else if(symtable[input_2].variable_type == INTEGER) {
        std::cout << "casting second variable" << std::endl;
        auto tmp_2 = add_temporary_variable(REAL);
        generate_command("inttoreal.i", input_2, tmp_2);
        return {input_1, tmp_2};
    }
    return {-1, -1};
}

void emit (int t, int tval) 
{
  switch (t)
    
    {
    case '+':
    case '-':
    case '*':
    case '/':
      printf ("%c\n", t);
      break;
    case DIV:
      printf ("DIV\n");
      break;
    case MOD:
      printf ("MOD\n");
      break;
    case NUM_INT:
        int number_int;
        sscanf(symtable[tval].name.c_str(), "%d", &number_int);
        printf ("%d\n", number_int);
        break;
    case NUM_REAL:
        double number_real;
        sscanf(symtable[tval].name.c_str(), "%lf", &number_real);
        printf ("%lf\n", number_real);
        break;
    case ID:
      printf ("%s\n", symtable[tval].name.c_str());
      break;
    case VAR:
      printf ("%s\n", symtable[tval].name.c_str());
      break;
    default:
      printf ("token %d , tokenval %d\n", t, tval);
    }
}


