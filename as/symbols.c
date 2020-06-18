

#include "symbols.h"





symbol symbols_table[MAX_SYMBOLS];
int symbol_cnt = 0;

void store_symbol(const char *name, uint16_t addr, SYMBOL_TYPE type)
{
	symbols_table[symbol_cnt].name = malloc(strlen(name)+1);
	assert(symbols_table[symbol_cnt].name);
	strcpy(symbols_table[symbol_cnt].name, name);

	symbols_table[symbol_cnt].type = type;
	symbols_table[symbol_cnt].addr = addr;

	symbol_cnt++;
}

uint16_t search_symbol(const char *name, SYMBOL_TYPE type)
{
	for(int i=0; i<symbol_cnt; i++)
		if(type == symbols_table[i].type)
			if(strcmp(name, symbols_table[i].name)==0)
				return symbols_table[i].addr;

	bail("missing symbol \'%s\'", name);
}

void dump_symbols(SYMBOL_TYPE type)
{
	printf("-------------------------\ndumping symbol table:\n");
	for(int i=0; i<symbol_cnt; i++)
		if(type == symbols_table[i].type)
			printf("\'%s\'\t\t%s\t%s\t%s\t0x%04x\n\n", symbols_table[i].name, symbols_table[i].expand, symbols_table[i].arg1, symbols_table[i].arg2, symbols_table[i].addr);
}

