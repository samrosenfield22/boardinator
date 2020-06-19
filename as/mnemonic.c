

#include "mnemonic.h"


mnem_entry mnemonic_table[] =
{
	{"set", format_machine_reg_literal},

	{"mov", format_machine_double_reg},
	{"add", format_machine_double_reg},
	{"addl", format_machine_reg_literal},
	{"sub", format_machine_double_reg},
	{"subl", format_machine_reg_literal},
	{"xor", format_machine_double_reg},
	{"and", format_machine_double_reg},
	{"or", format_machine_double_reg},
	{"cmp", format_machine_double_reg},

	{"not", format_machine_single_op},	//i think this still isn't implemented

	{"jmp", format_machine_jmp},
	{"jeq", format_machine_jmp},
	{"jne", format_machine_jmp},
	{"jgt", format_machine_jmp},
	{"jlt", format_machine_jmp},
	{"jovf", format_machine_jmp},

	{"setstk", format_machine_double_reg},
	{"getstk", format_machine_double_reg},

	{"getpcl", format_machine_single_op},
	{"getpch", format_machine_single_op},
	{"setpc", format_machine_double_reg}

	//{"setsfr", format_machine_sfr},
	//{"getsfr", format_machine_sfr}
};

/*mnem_entry pseudoinstruction_table[] =
{
	{"push", push_pseudoinstruction},
	{"pop", pop_pseudoinstruction},
	{"mklcl", mklcl_pseudoinstruction},
	{"setlcl", setlcl_pseudoinstruction},
	{"getlcl", getlcl_pseudoinstruction},
	{"call", call_pseudoinstruction},
	{"enter", enter_pseudoinstruction},
	{"leave", leave_pseudoinstruction},
	{"ret", ret_pseudoinstruction},
	{"clean", clean_pseudoinstruction},
	{"getarg", getarg_pseudoinstruction}
	//{"", _pseudoinstruction},
	
};*/

uint8_t mnemonic_to_opcode(const char *mnemonic)
{
	for(int i=0; i<(sizeof(mnemonic_table)/sizeof(mnemonic_table[0])); i++)
	{
		if(strcmp(mnemonic, mnemonic_table[i].mnem)==0)
			return i;
	}

	return 0xFF;
}

/*uint8_t mnemonic_to_pseudo(const char *mnemonic)
{
	for(int i=0; i<(sizeof(pseudoinstruction_table)/sizeof(pseudoinstruction_table[0])); i++)
	{
		if(strcmp(mnemonic, pseudoinstruction_table[i].mnem)==0)
			return i;
	}

	return 0xFF;
}*/


void format_machine_reg_literal(char *machine, char *arg0, char *arg1, const char *fn, int linenum)
{
	//if(arg0[0] != 'r') error("in", linenum, "expected register as 1st argument"); //bail("line %d: expected register as argument", linenum);
	//int dst = arg0[1] - '0';
	//int dst = strtol(arg0+1, NULL, 10);
	//if(dst<0 || dst>7) error("in", linenum, "invalid register r%d", dst);
	int dst = get_reg_num(arg0, fn, linenum);
	binstring(machine+8, dst, 3);

	int lit = strtol(arg1, NULL, 0);	
	binstring(machine, lit, 8);
}

void format_machine_double_reg(char *machine, char *arg0, char *arg1, const char *fn, int linenum)
{

	//if(arg0[0] != 'r') {printf("ruh roh! problem on line %d\n", linenum); exit(-1);}
	//int dst = arg0[1] - '0';
	int dst = get_reg_num(arg0, fn, linenum);
	binstring(machine+8, dst, 3);

	//if(arg1[0] != 'r') {printf("error: expected register as dest argument to %s\n", mnem); exit(-1);};
	//if(arg1[0] != 'r') {bail("expected register as dest argument on line %d", linenum); exit(-1);};
	//int src = arg1[1] - '0';
	int src = get_reg_num(arg1, fn, linenum);
	binstring(machine, src, 3);
}


void format_machine_single_op(char *machine, char *arg0, char *arg1, const char *fn, int linenum)
{
	//if(arg0[0] != 'r') bail("expected register as argument on line %d\n", linenum);
	//int dst = arg0[1] - '0';
	int dst = get_reg_num(arg0, fn, linenum);
	binstring(machine+8, dst, 3);
}

void format_machine_jmp(char *machine, char *arg0, char *arg1, const char *fn, int linenum)
{
	uint16_t addr = search_symbol(arg0, LABEL);
	//printf("\t\t found label %s!!\n", arg0);
	//int addr = strtol(arg0, NULL, 0);
	binstring(machine, addr, 10);
}

void format_machine_sfr(char *machine, char *arg0, char *arg1, const char *fn, int linenum)
{

	//look up SFR name in table
	//for now we'll pretend like a literal was passed
			
	//the register comes first either way:
	//setsfr r0, MEMCTL
	//getsfr r0, MEMCTL
	//if(arg0[0] != 'r') bail("expected register as argument on line %d", linenum);
	//int dst = arg0[1] - '0';
	int dst = get_reg_num(arg0, fn, linenum);
	binstring(machine+8, dst, 3);

	int addr = strtol(arg1, NULL, 0);
	binstring(machine, addr, 8);
}

int get_reg_num(char *arg, const char *fn, int linenum)
{
	if(arg[0] != 'r') error(fn, linenum, "expected register as argument (\'%s\' is not a valid register)", arg);
	int dst = strtol(arg+1, NULL, 10);
	if(dst<0 || dst>7) error(fn, linenum, "invalid register \'r%d\'", dst);
	return dst;
}

/*
void push_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	fprintf(fp, "%d|setstk\tr6,%s\n", linenum, arg0);
	fprintf(fp, "%d|addl\tr6,1\n", linenum);
}

void pop_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	fprintf(fp, "%d|subl\tr6,1\n", linenum);
	fprintf(fp, "%d|getstk\t%s,r6\n", linenum, arg0);
}

void mklcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	fprintf(fp, "%d|addl\tr6,%s\n", linenum, arg0);
}

void setlcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	//setlcl ofs,reg
	fprintf(fp, "%d|addl\tr7,%s\n", linenum, arg0);
	fprintf(fp, "%d|setstk\tr7,%s\n", linenum, arg1);
	fprintf(fp, "%d|subl\tr7,%s\n", linenum, arg0);
}

void getlcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	//getlcl reg,ofs
	fprintf(fp, "%d|addl\tr7,%s\n", linenum, arg1);
	fprintf(fp, "%d|getstk\t%s,r7\n", linenum, arg0);
	fprintf(fp, "%d|subl\tr7,%s\n", linenum, arg1);
}

void call_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	//FILE *fp = (FILE *)machine;

	
}

void enter_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	//push bp
	fprintf(fp, "%d|setstk\tr6,r7\n", linenum);
	fprintf(fp, "%d|addl\tr6,1\n", linenum);

	//set bp, sp
	fprintf(fp, "%d|mov\tr7,r6\n", linenum);
}

void leave_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	//set sp, bp
	fprintf(fp, "%d|mov\tr6,r7\n", linenum);

	//pop bp
	fprintf(fp, "%d|subl\tr6,1\n", linenum);
	fprintf(fp, "%d|set\tr7,r6\n", linenum);
}

void ret_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	//FILE *fp = (FILE *)machine;

	
}

void clean_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	//FILE *fp = (FILE *)machine;

	
}

void getarg_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum)
{
	FILE *fp = (FILE *)machine;

	//locals start at bp-3
	int ofs = strtol(arg1, NULL, 0);	
	ofs += 3;

	//getarg reg,lcl
	fprintf(fp, "%d|subl\tr7,%d\n", linenum, ofs);
	fprintf(fp, "%d|getstk\t%s,r7\n", linenum, arg0);
	fprintf(fp, "%d|addl\tr7,%d\n", linenum, ofs);
}
*/


void binstring(char *strbuf, int bin, int bits)
{
	int i = bits;
	for(uint16_t mask=(1<<(bits-1)); mask; mask>>=1)
	{
		strbuf[--i] = (bin & mask)? '1':'0';
	}
}
