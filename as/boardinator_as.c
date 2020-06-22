

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

#include "preprocessor.h"
#include "mnemonic.h"
#include "symbols.h"

//#define DELETE_TEMPFILE_WHEN_FINISHED


typedef enum
{
	VHDL,
	RAW,
	PRETTY
} machine_fmt;

//
//FILE *fin, *fout, *ftemp, *ftemp2;
FILE *fin, *fout;
FILE *preprocessed;


//
bool parse_cmd_args(int argc, const char **argv);
uint16_t assemble(FILE *preprocessed);
void assemble_line(char *machine, char *line, const char *fn, int linenum);

void print_machine(FILE *stream, char *word, uint16_t addr, char *src, machine_fmt fmt);


int main(int argc, const char **argv)
{

	/*char stuff[200] = "well hi there test code!\ni hope you'll work!\n";
	tokrepl(stuff, "i", "iiii", true);
	puts(stuff);
	return 0;*/

	if(!parse_cmd_args(argc, argv))
		printf("exiting...\n");

	preprocessed = preprocess(argv[1]);

	uint16_t wordcnt = assemble(preprocessed);
	printf("Assembly successful (0x%04x words, 0x%04x bytes)\n", wordcnt, wordcnt<<1);

	fclose(fin);
	fclose(preprocessed);
	fclose(fout);

	//delete temp file
	#ifdef DELETE_TEMPFILE_WHEN_FINISHED
	//if(remove(TEMPFILE)) printf("failed to delete tempfile\n");
	#endif

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
		//printf("Fatal error lmao, file \'%s\' doesn't exist!\n", argv[1]);
		bail("file \'%s\' doesn't exist", argv[1]);
		//return false;
	}

	fout = fopen(argv[2], "w");
	if(!fout)
	{
		printf("couldn't open the write file, what gives brah\n");
		return false;
	}

	return true;
}




#define INSTR_BITS	(16)
#define OPCODE_BITS	(5)
uint16_t assemble(FILE *preprocessed)
{
	//char inbuf[161];
	//char *buf;
	char orig[161], buf[161];
	char *bp;
	int linenum;
	uint16_t wordcnt = 0x0000;
	char machine[INSTR_BITS+1];

	fseek(preprocessed, 0, SEEK_SET);

	while(1)
	{
		//read next line
		fgets(buf, 160, preprocessed);
		
		if(feof(preprocessed))
			break;

		if(strlen(buf) == 0)
			assert(0);
			//continue;

		//remove line number
		/*buf = strtok(inbuf, "|");
		linenum = strtol(buf, NULL, 10);
		buf = strtok(NULL, "|");*/
		//strcpy(buf, inbuf);
		char fn[161];
		bp = strtok(buf, ",|");
		strcpy(fn, bp);
		bp = strtok(NULL, ",|");
		linenum = strtol(bp, NULL, 10);
		bp = strtok(NULL, "|");
		strcpy(orig, bp);

		assemble_line(machine, bp, fn, linenum);
		//print_machine(stdout, machine, wordcnt, orig, PRETTY);
		print_machine(fout, machine, wordcnt, orig, VHDL);

		wordcnt++;
	}

	return wordcnt;
}

void assemble_line(char *machine, char *line, const char *fn, int linenum)
{
	char binbuf[OPCODE_BITS+1];
	char *mnem, *arg0, *arg1, *arg2;

	//printf("read line %d: %s", linenum, line);

	tokenize_asm(&mnem, &arg0, &arg1, &arg2, line);
	if(!mnem)
		error(fn, linenum, "syntax error");
		//bail("syntax error on line %d", linenum);

	int opcode = mnemonic_to_opcode(mnem);
	if(opcode == 0xFF)
		error(fn, linenum, "unrecognized mnemonic \'%s\'", mnem);
		//bail("unrecognized mnemonic: \'%s\' on line %d", mnem, linenum);

	binstring(binbuf, opcode, OPCODE_BITS);
	//printf("\tmnemonic: %s (opcode %d)\n", mnem, opcode);
	//printf("\targ 1: %s\n", arg0);
	//printf("\targ 2: %s\n", arg1);

	//for testing, initialize machine code word to a bad value (should set to '0')
	for(int i=0; i<INSTR_BITS; i++)
		machine[i] = '0';
		//machine[i] = 'x';

	//set opcode
	binstring(machine+INSTR_BITS-OPCODE_BITS, opcode, OPCODE_BITS);
		
	//format the rest of the machine word
	mnemonic_table[opcode].format(machine, arg0, arg1, arg2, fn, linenum);

	//output machine code
	//putchar('\t'); print_machine(stdout, machine, true);
	//print_machine(fout, machine, false);

	

}

//void print_machine(FILE *stream, char *word, bool print_pretty)
void print_machine(FILE *stream, char *word, uint16_t addr, char *src, machine_fmt fmt)
{
	/*for(int i=INSTR_BITS-1; ; i--)
	{
		fputc(word[i], stream);
		if(print_pretty)
			if(i == 8 || i == 11)
				fputc(' ', stream);

		if(!i) break;
	}
	fputc('\n', stream);*/


	if(fmt==VHDL) fprintf(stream, "\t\t%d => \"", addr);
	for(int i=INSTR_BITS-1; ; i--)
	{
		fputc(word[i], stream);
		if(fmt==PRETTY)
			if(i == 8 || i == 11)
				fputc(' ', stream);

		if(!i) break;
	}
	if(fmt==VHDL) fprintf(stream, "\",\t\t--%s", src);
	if (fmt!=VHDL) fputc('\n', stream);
}




