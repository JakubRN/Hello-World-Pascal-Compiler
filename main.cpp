#include "global.h"


std::ofstream output_file_stream;
std::stringstream temporary_output_stream;

extern FILE* yyin;

bool initialize_output_file(int argc, char *argv[]) {
    std::string output_filename;
    if (argc == 2) {
		output_filename = std::string(argv[1]);
	} else if (argc > 2) {
		output_filename = std::string(argv[2]);
	} else {
		return false;
	}
    output_filename = output_filename.substr(0, output_filename.find_last_of("."));
    output_filename += ".asm";
	output_file_stream.open(output_filename, std::ofstream::out | std::ofstream::trunc);
	if (!output_file_stream.is_open()) {
		printf("Error: Cannot open output file");
		return false;
	}
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

    // init ();
    yyparse ();

    output_file_stream << temporary_output_stream.rdbuf();
    dump_symbol_table();
    exit (0);
}


