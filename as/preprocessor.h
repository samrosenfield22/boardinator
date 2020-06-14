/*
1st sweep: add source line numbers, eliminate empty lines, eliminate comments
2nd sweep: expand pseudoinstructions
3rd sweep: load symbols
*/

#ifndef PREPROCESSOR_H_
#define PREPROCESSOR_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include "mnemonic.h"
#include "symbols.h"

#define TEMPFILE1 "tempfile1.asm"
#define TEMPFILE2 "tempfile2.asm"
#define TEMPFILE3 "tempfile3.asm"


void iterate_file(FILE *fp, FILE *next, void (*process)(char *line, FILE *next));

FILE *preprocess(const char *fpath);

void remove_comments_add_linenums(char *line, FILE *next);
void expand_pseudos(char *line, FILE *next);
void load_symbols(char *line, FILE *next);

//this might belong in a different file
void tokenize_asm(char **mnem, char **arg1, char **arg2, char *code);

bool is_whitespace(const char *str);


#endif //PREPROCESSOR_H_