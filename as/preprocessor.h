/*
1st sweep: add source line numbers, eliminate empty lines, eliminate comments
2nd sweep: expand pseudoinstructions
3rd sweep: load symbols
*/
/*
1st pass: remove comments
	comments have to be removed first so other preprocessor passes (loading includes) don't interact w them
2nd pass: remove whitespace. add line numbers. eventually, process include directives.
	line numbers have to be added along with removing whitespace so they're correct
3rd pass: load macros
4th pass: expand macros
	need load/expand to be separate steps so one macro doesn't expand inside another
4th pass: load labels
	this has to be done after any passes that change the number of instructions (i.e. expanding macros)
5th pass: expand labels
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
#define TEMPFILE4 "tempfile4.asm"
#define TEMPFILE5 "tempfile5.asm"
#define TEMPFILE6 "tempfile6.asm"
#define TEMPFILE7 "tempfile7.asm"
#define TEMPFILE8 "tempfile8.asm"

#define MAX_INCLUDES	(100)


//void iterate_file(FILE *fp, FILE *next, void (*process)(char *line, FILE *next));
void iterate_file(const char *inpath, const char *outpath, void (*process)(const char *fn, char *line, FILE *next),
	bool overwrite);
FILE *preprocess(const char *fpath);

void remove_comments_add_linenums(const char *fn, char *line, FILE *next);
//void expand_pseudos(char *line, FILE *next);
void expand_includes(const char *fn, char *line, FILE *next);
bool add_include_file(const char *fpath);
bool all_includes_processed(void);
void load_labels(const char *fn, char *line, FILE *next);
void load_macros(const char *fn, char *line, FILE *next);
void expand_macros(const char *fn, char *line, FILE *next);

char *strrepl(char *line, const char *from, const char *to, bool repl_all);
char *tokrepl(char *line, const char *from, const char *to, bool repl_all);
char *replace_in_string(char *line, const char *from, const char *to, bool repl_all, bool only_tokens);

//this might belong in a different file
void tokenize_asm(char **mnem, char **arg1, char **arg2, char **arg3, char **arg4, char *code);

bool is_whitespace(const char *str);


#endif //PREPROCESSOR_H_