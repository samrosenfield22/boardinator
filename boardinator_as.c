

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

#define TEMPFILE "tempfile.asm"

#define bail(...)	do {printf("Error: "); printf(__VA_ARGS__); putchar('\n'); exit(-1);} while(0)

//
FILE *fin, *fout, *ftemp;


//
bool parse_cmd_args(int argc, const char **argv);
void preprocess(void);
void assemble(void);
void tokenize_asm(char **mnem, char **arg1, char **arg2, char *code);
void print_machine(FILE *stream, char *word, bool print_pretty);
//void bail(const char *msg);
void store_label(const char *name, uint16_t addr);
uint16_t search_label(const char *name);
void binstring(char *strbuf, int bin, int bits);
uint8_t mnemonic_to_opcode(const char *mnemonic);

int main(int argc, const char **argv)
{

	if(!parse_cmd_args(argc, argv))
		printf("exiting...\n");

	preprocess();
	assemble();

	//delete temp file
	fclose(fin);
	fclose(fout);

	return 0;
}

bool parse_cmd_args(int argc, const char **argv)
{
	if(argc != 3)
	{
		printf("invalid number of args stupid\n");
		return false;
	}

	fin = fopen(argv[1], "r");
	if(!fin)
	{
		printf("Fatal error lmao, file \'%s\' doesn't exist!\n", argv[1]);
		return false;
	}

	fout = fopen(argv[2], "w");
	if(!fout)
	{
		printf("couldn't open the write file, what gives brah\n");
		return false;
	}

	return true;
}

//mov r0,r1
//

//remove comments and empty lines
void preprocess(void)
{
		
	ftemp = fopen(TEMPFILE, "w+");
	if(!ftemp) bail("failed to create temp file");

	uint16_t instr_addr = 0x0000;	//10-bit address
	char buf[81];
	int linenum = 1;
	while(1)
	{

		//
		fgets(buf, 80, fin);
		if(feof(fin))
			break;

		//remove comments, search for reserved characters
		for(char *p=buf; p<buf+80; p++)
		{
			/*if(*p=='\0')
				goto next_line;
			else*/ if(*p=='|')
			{
				printf("buf:\n%s\n", buf);
				printf("buf has len %d, p at %d\n", strlen(buf), p-buf);
				bail("found illegal character \'|\'");
			}
			else if(*p==';')
			{
				*p++ = '\n';
				*p = '\0';
			}
			else if(*p==':')	//label
			{
				*p = '\0';
				printf("found label %s\n", buf);
				
				//add it to the structure
				store_label(buf, instr_addr);

				goto next_line;
			}
		}

		if(strlen(buf) > 1)	//this should remove empty lines -- right now it only gets rid of "\n"
			fprintf(ftemp, "%d|%s", linenum, buf);
			//fputs(buf, ftemp);

		instr_addr += 2;
		next_line:
		linenum++;
	}
}

#define INSTR_BITS	(16)
#define OPCODE_BITS	(5)
void assemble(void)
{
	char inbuf[81], binbuf[OPCODE_BITS+1], machine[INSTR_BITS+1];
	char *buf;
	int linenum;
	char *mnem, *arg1, *arg2;
	fseek(ftemp, 0, SEEK_SET);

	while(1)
	{
		//read next line
		fgets(inbuf, 80, ftemp);
		
		if(feof(ftemp))
			break;

		if(strlen(inbuf) == 0)
			assert(0);
			//continue;

		//remove line number
		buf = strtok(inbuf, "|");
		linenum = strtol(buf, NULL, 10);
		buf = strtok(NULL, "|");

		printf("read line %d: %s", linenum, buf);

		tokenize_asm(&mnem, &arg1, &arg2, buf);

		int opcode = mnemonic_to_opcode(mnem);
		binstring(binbuf, opcode, OPCODE_BITS);
		printf("\tmnemonic: %s (opcode %d)\n", mnem, opcode);
		printf("\targ 1: %s\n", arg1);
		printf("\targ 2: %s\n", arg2);

		//for testing, initialize machine code word to a bad value
		for(int i=0; i<INSTR_BITS; i++)
			machine[i] = 'x';

		//set opcode
		binstring(machine+INSTR_BITS-OPCODE_BITS, opcode, OPCODE_BITS);
		
		if(opcode == 0)	//dst/literal format: cccccddd llllllll
		{
			if(arg1[0] != 'r') bail("line %d: expected register as argument", linenum);
			int dst = arg1[1] - '0';
			binstring(machine+8, dst, 3);

			int lit = strtol(arg2, NULL, 0);	
			binstring(machine, lit, 8);
		}
		else if(opcode<=7)	//src/dst format: cccccddd 00000sss
		{
			if(arg1[0] != 'r') {printf("ruh roh!\n"); exit(-1);}
			int dst = arg1[1] - '0';
			binstring(machine+8, dst, 3);

			if(arg2[0] != 'r') {printf("error: expected register as dest argument to %s\n", mnem); exit(-1);};
			int src = arg2[1] - '0';
			binstring(machine, src, 3);
		}
		else if(opcode<=10)	//single-operand format: cccccddd 00000000
		{
			if(arg1[0] != 'r') bail("expected register as argument");
			int dst = arg1[1] - '0';
			binstring(machine+8, dst, 3);
		}
		else if(opcode<=15)	//jumps. format: ccccc0aa aaaaaaaa (10-bit instruction addr)
		{
			//jmp LABEL
			uint16_t addr = search_label(arg1);
			printf("\t\t found label %s!!\n", arg1);
			//int addr = strtol(arg1, NULL, 0);
			binstring(machine, addr, 10);
		}
		else if(opcode<=17)	//sfr-access: cccccrrr ssssssss (8-bit sfr addr)
		{
			//look up SFR name in table
			//for now we'll pretend like a literal was passed
			
			//the register comes first either way:
			//setsfr r0, MEMCTL
			//getsfr r0, MEMCTL
			if(arg1[0] != 'r') bail("expected register as argument");
			int dst = arg1[1] - '0';
			binstring(machine+8, dst, 3);

			int addr = strtol(arg2, NULL, 0);
			binstring(machine, addr, 8);
		}
		else assert(0);

		putchar('\t'); print_machine(stdout, machine, true);
		print_machine(fout, machine, false);
	}

}

void tokenize_asm(char **mnem, char **arg1, char **arg2, char *code)
{
	*mnem = strtok(code, " \t\n");
	*arg1 = strtok(NULL, " \t,");
	*arg2 = strtok(NULL, " \t\n");
}

const char *mnemonic_table[] =
{
	//0: literal instructions	cccccddd llllllll
	"set",

	//1-7: src/dst instructions	cccccddd 00000sss
	"mov",
	"add",
	"sub",
	"xor",
	"and",
	"or",
	"cmp",

	//8-10: single-operand		cccccddd 00000000
	"not",
	"push",
	"pop",

	//11-15: jump instructions	ccccc0aa aaaaaaaa	jmp literal
	"jmp",
	"jeq",
	"jne",
	"jgt",
	"jlt",

	//16-17: sfr (8-bit address range) access		cccccrrr ssssssss
	"setsfr",
	"getsfr"
};

/*const char *pseudoinstruction_table[][2] =
{
	"clr r", "xor r,r"
}*/

uint8_t mnemonic_to_opcode(const char *mnemonic)
{
	for(int i=0; i<(sizeof(mnemonic_table)/sizeof(mnemonic_table[0])); i++)
	{
		if(strcmp(mnemonic, mnemonic_table[i])==0)
			return i;
	}

	//
	printf("error: unrecognized mnemonic \'%s\'\n", mnemonic);
	exit(-1);
	return 0xFF;
}

void print_machine(FILE *stream, char *word, bool print_pretty)
{
	for(int i=INSTR_BITS-1; ; i--)
	{
		//putchar(word[i]);
		fputc(word[i], stream);
		if(print_pretty)
			if(i == 8 || i == 11)
				fputc(' ', stream);

		if(!i) break;
	}
	fputc('\n', stream);
}
/*
void bail(const char *msg)
{
	printf("Error: %s\n", msg);
	exit(-1);
}*/

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

	bail("missing label %s", name);
}

void binstring(char *strbuf, int bin, int bits)
{
	int i = bits;
	for(uint16_t mask=(1<<(bits-1)); mask; mask>>=1)
	{
		strbuf[--i] = (bin & mask)? '1':'0';
		//if(!mask)
		//	break;

		//assert(i <= bits);
	}

	//strbuf[bits] = '\0';
}
