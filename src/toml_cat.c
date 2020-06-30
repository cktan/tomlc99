/*
MIT License

Copyright (c) 2017 CK Tan
https://github.com/cktan/tomlc99

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifdef NDEBUG
#undef NDEBUG
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <assert.h>
#include "toml.h"

typedef struct node_t node_t;
struct node_t {
    const char*   key;
    toml_table_t* tab;
};

node_t stack[20];
int stacktop = 0;


static void print_table_title(const char* arrname)
{
    int i;
    printf("%s", arrname ? "[[" : "[");
    for (i = 1; i < stacktop; i++) {
	printf("%s", stack[i].key);
	if (i + 1 < stacktop)
	    printf(".");
    }
    if (arrname)
	printf(".%s]]\n", arrname);
    else
	printf("]\n");
}


static void print_array_of_tables(toml_array_t* arr, const char* key);
static void print_array(toml_array_t* arr);


static void print_table(toml_table_t* curtab)
{
    int i;
    const char* key;
    const char* raw;
    toml_array_t* arr;
    toml_table_t* tab;


    for (i = 0; 0 != (key = toml_key_in(curtab, i)); i++) {
	if (0 != (raw = toml_raw_in(curtab, key))) {
	    printf("%s = %s\n", key, raw);
	} else if (0 != (arr = toml_array_in(curtab, key))) {
	    if (toml_array_kind(arr) == 't') {
		print_array_of_tables(arr, key);
	    }
	    else {
		printf("%s = [\n", key);
		print_array(arr);
		printf("    ]\n");
	    }
	} else if (0 != (tab = toml_table_in(curtab, key))) {
	    stack[stacktop].key = key;
	    stack[stacktop].tab = tab;
	    stacktop++;
	    print_table_title(0);
	    print_table(tab);
	    stacktop--;
	} else {
	    abort();
	}
    }
}

static void print_array_of_tables(toml_array_t* arr, const char* key)
{
    int i;
    toml_table_t* tab;
    printf("\n");
    for (i = 0; 0 != (tab = toml_table_at(arr, i)); i++) {
	print_table_title(key);
	print_table(tab);
	printf("\n");
    }
}


static void print_array(toml_array_t* curarr)
{
    toml_array_t* arr;
    const char* raw;
    toml_table_t* tab;
    int i;

    switch (toml_array_kind(curarr)) {

    case 'v': 
	for (i = 0; 0 != (raw = toml_raw_at(curarr, i)); i++) {
	    printf("  %d: %s,\n", i, raw);
	}
	break;

    case 'a': 
	for (i = 0; 0 != (arr = toml_array_at(curarr, i)); i++) {
	    printf("  %d: \n", i);
	    print_array(arr);
	}
	break;
	    
    case 't': 
	for (i = 0; 0 != (tab = toml_table_at(curarr, i)); i++) {
	    print_table(tab);
	}
	printf("\n");
	break;
	
    case '\0':
	break;

    default:
	abort();
    }
}



static void cat(FILE* fp)
{
    char  errbuf[200];
    
    toml_table_t* tab = toml_parse_file(fp, errbuf, sizeof(errbuf));
    if (!tab) {
	fprintf(stderr, "ERROR: %s\n", errbuf);
	return;
    }

    stack[stacktop].tab = tab;
    stack[stacktop].key = "";
    stacktop++;
    print_table(tab);
    stacktop--;

    toml_free(tab);
}


int main(int argc, const char* argv[])
{
    int i;
    if (argc == 1) {
	cat(stdin);
    } else {
	for (i = 1; i < argc; i++) {
	    
	    FILE* fp = fopen(argv[i], "r");
	    if (!fp) {
		fprintf(stderr, "ERROR: cannot open %s: %s\n",
			argv[i], strerror(errno));
		exit(1);
	    }
	    cat(fp);
	    fclose(fp);
	}
    }
    return 0;
}
