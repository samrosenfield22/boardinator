

#ifndef SYMBOLS_H_
#define SYMBOLS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

//this really doesn't belong here...
#define bail(...)		do {printf("Error: "); printf(__VA_ARGS__); putchar('\n'); exit(-1);} while(0)
//#define bail(...)	do {printf("Error: "); printf(__VA_ARGS__); putchar('\n'); dump_symbols(); exit(-1);} while(0)
#define error(file, lnum, ...)					\
	do {										\
		printf("Error (%s, %d): ", file, lnum);	\
		printf(__VA_ARGS__);					\
		putchar('\n');							\
		exit(-1);								\
	} while(0)

typedef enum
{
	LABEL,
	MACRO
	//FUNCTION?
} SYMBOL_TYPE;

typedef struct symbol_s
{
	SYMBOL_TYPE type;
	char *name;

	//fields for macros only
	char *expand, *arg1, *arg2;

	uint16_t addr;
} symbol;

#define MAX_SYMBOLS (400)
extern symbol symbols_table[MAX_SYMBOLS];
extern int symbol_cnt;

void store_symbol(const char *name, uint16_t addr, SYMBOL_TYPE type);
void store_macro(const char *name, const char *expand, const char *arg1, const char *arg2);
uint16_t search_symbol(const char *name, SYMBOL_TYPE type);
void dump_symbols(SYMBOL_TYPE type);

#endif //SYMBOLS_H_