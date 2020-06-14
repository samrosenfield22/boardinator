

#include "symbols.h"


typedef struct label_s
{
	char *name;
	uint16_t addr;
} label;
#define MAX_LABELS (400)
label known_labels[MAX_LABELS];
int label_cnt = 0;
void store_label(const char *name, uint16_t addr)
{
	known_labels[label_cnt].name = malloc(strlen(name)+1);
	assert(known_labels[label_cnt].name);
	strcpy(known_labels[label_cnt].name, name);

	known_labels[label_cnt].addr = addr;

	label_cnt++;
}

uint16_t search_label(const char *name)
{
	for(int i=0; i<label_cnt; i++)
	{
		if(strcmp(name, known_labels[i].name)==0)
		{
			return known_labels[i].addr;
		}
	}

	bail("missing label \'%s\'", name);
}

void dump_labels(void)
{
	printf("-------------------------\ndumping symbol table:\n");
	for(int i=0; i<label_cnt; i++)
	{
		printf("\'%s\'\t\t0x%04x\n", known_labels[i].name, known_labels[i].addr);
	}
}