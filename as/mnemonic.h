

#ifndef MNEMONIC_H_
#define MNEMONIC_H_

#include <string.h>
#include <stdint.h>

#include "symbols.h"	//only for bail(), might fix later

uint8_t mnemonic_to_opcode(const char *mnemonic);
//uint8_t mnemonic_to_pseudo(const char *mnemonic);

void format_machine_reg_literal(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);
void format_machine_double_reg(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);
void format_machine_triple_reg(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);
void format_machine_single_op(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);
void format_machine_jmp(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);
//void format_machine_sfr(char *machine, char *arg0, char *arg1, char *arg2, const char *fn, int linenum);

/*void push_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void pop_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void mklcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void setlcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void getlcl_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void call_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void enter_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void leave_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void ret_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void clean_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
void getarg_pseudoinstruction(char *machine, char *arg0, char *arg1, int linenum);
*/

int get_reg_num(char *arg, const char *fn, int linenum);

void binstring(char *strbuf, int bin, int bits);


typedef struct mnem_entry_s
{
	const char *mnem;
	void (*format)(char *machine, char *arg0, char *arg1,  char *arg2, const char *fn, int linenum);
} mnem_entry;

extern mnem_entry mnemonic_table[];
extern mnem_entry pseudoinstruction_table[];

#endif //MNEMONIC_H_