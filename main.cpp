#include "global.h"
#include <string.h>
#include <iostream>
extern FILE* yyin;

bool initialize_output_file(int argc, char *argv[]) {
    return true;
}

int main (int argc, char *argv[]) {
	if (argc < 2) {
		std::cout << "Error: wrong parameter number" << std::endl;
		return -1;
	}
    if( ( strcmp( argv[1], "--help") == 0) || (strcmp(argv[1], "-h") == 0)){
        std::cout << "compiler expects at most two arguments:\n"
                  << "1 - name of the input file,\n"
                  << "2 - name of the output file.\n"
                  << "Should the name of the output file not be provided, the program generates the file with the same name."
                  << "Should the output file already exist, it will be overwritten." << std::endl;
		return -1;
    }
	FILE *input_file = fopen(argv[1], "r");
	if (!input_file) {
		printf("Error: File not found\n");
		return -1;
	}
    yyin = input_file;

    assert(initialize_output_file(argc, argv));

    init ();
    yyparse ();
    exit (0);
}


