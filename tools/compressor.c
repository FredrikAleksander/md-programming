#include "md_getoption.h"
#include "md_compression.h"
#include <stdio.h>
#include <stddef.h>
#include <string.h>

#define FORMAT_NEMESIS 0

void print_usage(FILE* fp) {
}

int main(int argc, const char* argv[]) {
	FILE* finput;
	FILE* foutput;
	const char* option;
	const char* input;
	const char* output;
	int         format;
	int         arg;
	int         r;

	input = NULL;
	output = NULL;
	format = -1;
	arg = 1;

	while(md_getoption(argc, argv, &arg, &option)) {
		if(strcmp("-h", option) == 0 || strcmp("--help", option) == 0) {
			print_usage(stdout);
			return 0;
		}
		else if(strcmp("-i", option) == 0 || strcmp("--input", option) == 0) {
			if(input != NULL || !md_getoption(argc, argv, &arg, &input)) {
				fprintf(stderr, "Only one input file may be selected\n");
				print_usage(stderr);
				return 1;
			}
		}
		else if(strcmp("-o", option) == 0 || strcmp("--output", option) == 0) {
			if(output != NULL || !md_getoption(argc, argv, &arg, &output)) {
				fprintf(stderr, "Only one output file may be selected\n");
				print_usage(stderr);
				return 1;
			}
		}
		else if(strcmp("-n", option) == 0 || strcmp("--nemesis", option) == 0) {
			if(format != -1) {
				fprintf(stderr, "Only one compression format may be selected\n");
				return 1;
			}
			format = FORMAT_NEMESIS;
		}
		else {
			fprintf(stderr, "Unknown option: %s\n", option);
			print_usage(stderr);
			return 1;
		}
	}

	if(format != FORMAT_NEMESIS) {
		fprintf(stderr, "Must specify a compression format\n");
		print_usage(stderr);
		return 1;
	}

	if(input == NULL) {
		fprintf(stderr, "Must specify a input filename\n");
		print_usage(stderr);
		return 1;
	}
	if(output == NULL) {
		fprintf(stderr, "Must specify a output filename\n");
		print_usage(stderr);
		return 1;
	}

	finput = fopen(input, "rb");
	if(finput == NULL) {
		fprintf(stderr, "Failed to open input file for reading\n");
		return 2;
	}

	foutput = fopen(output, "wb");
	if(foutput == NULL) {
		fclose(finput);
		fprintf(stderr, "Failed to open output file for writing\n");
		return 3;
	}

	switch(format) {
		case FORMAT_NEMESIS:
			r = md_compress_nemesis(finput, foutput);
			break;
		default:
			r = 4;
			break;
	}

	fclose(finput);
	fclose(foutput);

	return r;
}
