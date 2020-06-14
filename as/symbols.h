

#ifndef SYMBOLS_H_
#define SYMBOLS_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>

//this really doesn't belong here...
#define bail(...)	do {printf("Error: "); printf(__VA_ARGS__); putchar('\n'); exit(-1);} while(0)
//#define bail(...)	do {printf("Error: "); printf(__VA_ARGS__); putchar('\n'); dump_labels(); exit(-1);} while(0)

void store_label(const char *name, uint16_t addr);
uint16_t search_label(const char *name);
void dump_labels(void);

#endif //SYMBOLS_H_