#include "md_getoption.h"
#include <stddef.h>

int md_getoption(int argc, const char** argv, int* arg, const char** option) {
	if(arg == NULL || option == NULL)
		return 0;
	if(*arg >= argc)
		return 0;

	*option = argv[*arg];
	*arg += 1;

	return 1;
}

