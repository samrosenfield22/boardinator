

#include "preprocessor.h"

//
typedef struct
{
	char *path, *shortpath;
	bool done;
} include_files_t;
include_files_t include_files[MAX_INCLUDES];
//char *include_files[MAX_INCLUDES];
int inc_cnt = 0, inc_next = 0;
//int remaining_incs = 0, all_incs = 0;

FILE *preprocess(const char *fpath)
{
	//clear TEMPFILE2, since it gets appended to (from each include file) without deleting
	FILE *fclear = fopen(TEMPFILE2, "w");
	fclose(fclear);

	//run the first 2 passes on the input file, then run them iteratively on each included file
	add_include_file(fpath);
	while(!all_includes_processed())
	{
		//printf("including file %s\n", include_files[inc_next].shortpath);
		assert(include_files[inc_next].done == false);
		iterate_file(include_files[inc_next].path, TEMPFILE1, remove_comments_add_linenums, true);
		iterate_file(TEMPFILE1, TEMPFILE2, expand_includes, false);
		
		include_files[inc_next].done = true;
		inc_next++;

		//with inc_next, do we even need all_includes_processed()?
		assert(inc_next <= inc_cnt);
	}
	
	iterate_file(TEMPFILE2, TEMPFILE3, load_macros, true);
	//dump_symbols(MACRO); exit(0);
	iterate_file(TEMPFILE3, TEMPFILE4, expand_macros, true);
	iterate_file(TEMPFILE4, TEMPFILE5, expand_macros, true);
	iterate_file(TEMPFILE5, TEMPFILE6, expand_macros, true);
	iterate_file(TEMPFILE6, TEMPFILE7, expand_macros, true);
	iterate_file(TEMPFILE7, TEMPFILE8, load_labels, true);

	FILE *preprocessed = fopen(TEMPFILE8, "r");
	return preprocessed;
}

//file must already be open
//void iterate_file(FILE *fp, FILE *next, void (*process)(char *line, FILE *next))
void iterate_file(const char *inpath, const char *outpath,void (*process)(const char *fn, char *line, FILE *next),
	bool overwrite)
{
	FILE *fp = fopen(inpath, "r");
	assert(fp);
	FILE *next = fopen(outpath, overwrite? "w":"a");	//was w+
	assert(next);
	fseek(next, 0, SEEK_END);

	char buf[241];

	//fseek(fp, 0, SEEK_SET);

	while(1)
	{
		fgets(buf, 240, fp);
		if(feof(fp))
			break;

		process(inpath, buf, next);
	}

	fclose(fp);
	fclose(next);
}

void remove_comments_add_linenums(const char *fn, char *line, FILE *next)
{
	static int linenum = 1;
	static const char *prev_file = NULL;

	if(prev_file != fn)
	{
		//new file, reset the line numbers
		linenum = 1;
		prev_file = fn;
	}

	//remove comments, search for reserved characters
	for(char *p=line; p<line+240; p++)
	{
		switch(*p)
		{
			case '\0':
				goto line_preprocessed;
				break;
			case ';':
				*p++ = '\n';
				*p = '\0';
				goto line_preprocessed;
				//break;
			case '|':
				//printf("buf:\n%s\n", line);
				//bail("found illegal character \'|\'");
				error(fn, linenum, "found illegal character \'|\'");
				break;
				
			goto next_line;
		}
	}

	line_preprocessed:

	//if(strlen(buf) > 1)	//this should remove empty lines -- right now it only gets rid of "\n"
	if(!is_whitespace(line))
	{
		//fprintf(next, "%d|%s", linenum, line);

		//if this is an include file (and it might use the full path), replace with the short path
		const char *insert_name = fn;
		for(int i=0; i<inc_cnt; i++)
		{
			if(strcmp(fn, include_files[i].path)==0)
				insert_name = include_files[i].shortpath;
		}
		fprintf(next, "%s,%d|%s", insert_name, linenum, line);
		//instr_addr++;
	}

	next_line:
	linenum++;
}

void expand_includes(const char *fn, char *line, FILE *next)
{
	if(strstr(line, ".include"))
	{
		//assert(0);
		char *srcfile = strtok(line, ",|");
		char *ln = strtok(NULL, ",|");
		int linenum = strtol(ln, NULL, 10);
		char *infile = strtok(NULL, "\"");
		infile = strtok(NULL, "\"");
		//printf("adding include file %s\n\tfound in %s,%d\n", infile, srcfile, linenum);
		if(!add_include_file(infile))
			error(srcfile, linenum, "couldn't find include file \'%s\'", infile);
	}
	else
		fprintf(next, "%s", line);
}

#define PATH_TO_BR "C:/Users/Sam/Documents/boardinator"
bool add_include_file(const char *fpath)
{
	//search for it, in order: in as/lib/, in the working dir, in as/
	char paths[3][240];
	sprintf(paths[0], "%s%s%s", PATH_TO_BR, "/as/lib/", fpath);
	strcpy(paths[1], fpath);
	sprintf(paths[2], "%s%s%s", PATH_TO_BR, "/as/", fpath);
	
	for(int i=0; i<3; i++)
	{
		//printf("looking for include file: %s\n", paths[i]);
		FILE *fp = fopen(paths[i], "r");
		if(fp)
		{
			//check if that file has already been added to the list. if it has, don't keep looking in the other paths
			for(int j=0; j<inc_cnt; j++)
			{
				if(strcmp(paths[i], include_files[j].path)==0)
				{
					//printf("--- include guard stopped repeated include of file ---\n"); 
					fclose(fp);
					return true;
				}
			}

			//add the file path to the list
			include_files[inc_cnt].path = malloc(strlen(paths[i])+1);
			strcpy(include_files[inc_cnt].path, paths[i]);
			include_files[inc_cnt].shortpath = malloc(strlen(fpath)+1);
			strcpy(include_files[inc_cnt].shortpath, fpath);
			include_files[inc_cnt].done = false;
			inc_cnt++;
			fclose(fp);
			return true;
		}
	}

	//couldn't find the include file
	return false;
}

bool all_includes_processed(void)
{
	for(int i=0; i<inc_cnt; i++)
	{
		if(include_files[i].done == false)
			return false;
	}
	return true;
}

void load_macros(const char *fn, char *line, FILE *next)
{
	char *def = strstr(line, ".define");
	if(def)
	{
		//grab the macro
		def += 7;
		strtok(def, "\"");
		char *from = strtok(NULL, "\"");
		strtok(NULL, "\"");
		char *to = strtok(NULL, "\"");
		//printf("\tfound macro (%s => %s)\n", from, to);

		//grab macro arguments (if there are any)
		char *arg1 = strtok(from, " \t,");
		arg1 = strtok(NULL, " \t,");
		char *arg2 = strtok(NULL, " \t,");

		//load it to the symbol table
		//printf("found macro: %s (args %s, %s) => %s\n", from, arg1, arg2, to);
		store_macro(from, to, arg1, arg2);

		//replace \n with newlines in macro
		strrepl(symbols_table[symbol_cnt-1].expand, "\\n", "\n", true);
	}
	else
		fprintf(next, line);
}

void expand_macros(const char *fn, char *line, FILE *next)
{
	//char argbuf[80];

	/*char incpy[241], header[241];
	char *bp = strtok(line, "|");
	strcpy(header, bp);
	bp = strtok(NULL, "|");
	strcpy(incpy, bp);*/

	char incpy[241], fname[241];
	char *bp = strtok(line, ",|");
	strcpy(fname, bp);
	bp = strtok(NULL, ",|");
	int linenum = strtol(bp, NULL, 10);
	bp = strtok(NULL, "|");
	strcpy(incpy, bp);


	//scan the line for macros
	for(int i=0; i<symbol_cnt; i++)
	{
		if(symbols_table[i].type != MACRO)
			continue;
		//printf("searching for macro %s\n", symbols_table[i].name);

		char lcpy[241];
		strcpy(lcpy, incpy);

		char *tok = strtok(lcpy, " ,\t\n");
		while(tok)
		{
			//printf("\tchecking token %s\n", tok);

			//printf("%s\n", tok);
			if(strcmp(tok, symbols_table[i].name)==0)
			{
				//if the macro has an argument, grab it
				char argfield[241];

				char *argp, *arg1in, *arg2in;
				if(symbols_table[i].arg1)
				{
					argp = tok + strlen(tok) + 1;
					strcpy(argfield, argp);

					arg1in = strtok(argfield, ",\n");
					if(!arg1in)
						error(fname, linenum, "missing arg to macro %s", tok);
					if(symbols_table[i].arg2)
					{
						arg2in = strtok(NULL, ",\n");
						if(!arg2in)
							error(fname, linenum, "missing 2nd arg to macro %s", tok);

					}
				}

				//expand the macro
				while(strtok(NULL, " ,\t\n"));	//does this do anything?

				//we're replacing the macro, AND any args -- "push r5" needs to get expanded (not just
				//the "push" part).
				//repltarget is the entire part that gets replaced 
				char repltarget[241];
				if(symbols_table[i].arg1)
				{
					/*char *p = strstr(incpy, tok);
					while(*p!=' ' && *p!='\t') p++;
					while(*p!=',' && *p!='\n' && *p!='\0') p++;
					if(symbols_table[i].arg2)
						while(*p!='\n' && *p!='\0') p++;

					strncpy(repltarget, p, p-incpy+1);
					repltarget[p-incpy+1] = '\0';*/

					//point p to the start of the replace-string, rp to the end of it
					char *p = strstr(incpy, tok);
					char *rp = p + strlen(tok) + 1;	//push r5\n...
					printf("\t--- rp at char %d (\'%c\')\n", rp-p, *rp);
					while(*rp==' ' || *rp=='\t' || *rp=='\n') rp++;
					while(!(*rp==' ' || *rp=='\t' || *rp=='\n' || *rp=='\0')) rp++;
					printf("\t--- rp at char %d (\'%c\')\n", rp-p, *rp);
					//if(symbols_table[i].arg2)
					//	rp = strpbrk(rp, " \t\0");

					strncpy(repltarget, p, rp-p);
					repltarget[rp-p] = '\0';
				}
				else
					strcpy(repltarget, tok);
				//char *p = strstr(incpy, tok);
				//strcpy(repltarget, p);

				//if the macro contains labels, mangle them
				char macrotext[241];
				char macromangled[281];
				strcpy(macrotext, symbols_table[i].expand);
				char macrolabel[8][241];
				int labels_to_mangle = 0;
				char *mp = macrotext;
				for(int j=0; j<8; j++)
				{
					mp = strchr(mp, ':');
					if(mp)
					{
						labels_to_mangle++;
						//grab the label
						*mp = '\0';
						char *lp = mp;
						while(*lp != ' ' && *lp != '\t') lp--;
						lp++;
						
						strcpy(macrolabel[j], lp);
						*mp = ':';
						mp++;
					}
					else
						break;
				}
				while(labels_to_mangle)
				{
					sprintf(macromangled, "%s_mangled_%s_%d", macrolabel[labels_to_mangle-1], fn, linenum);
					//printf("\tmangled: \'%s\'\n", macromangled);

					//replace all occurences
					strrepl(macrotext, macrolabel[labels_to_mangle-1], macromangled, true);
					labels_to_mangle--;
				}
				//printf("after mangling:\n%s\n\n", macrotext);

				int tempargs = ((bool)(symbols_table[i].arg1)) + ((bool)(symbols_table[i].arg2));
				printf("-----------------------\nmacro with %d args\ntok is %s\n", tempargs, tok);
				printf("\n\tbefore expanding: %s\t\treplacing token %s\n\t\twith %s\n",
					incpy, repltarget, macrotext);
					//incpy, repltarget, symbols_table[i].expand);
				//if(strstr(incpy, "setlcl")) getchar();
				strrepl(incpy, repltarget, macrotext, false);
				//printf("main macro replaced\n%s\n", incpy);

				printf("expanded main: %s\n", incpy);

				//substitute "default args" with actual args
				if(symbols_table[i].arg1)
					tokrepl(incpy, symbols_table[i].arg1, arg1in, true);
				if(symbols_table[i].arg2)
					tokrepl(incpy, symbols_table[i].arg2, arg2in, true);
				printf("after expanding: %s\n", incpy);
				//getchar();
				//return;
				goto print_expanded_macro;
			}

			tok = strtok(NULL, " ,\t\n");
		}
	}

	

	//print each line of the expanded macro, prefixing with line numbers
	char *lprint;
	print_expanded_macro:
	lprint = strtok(incpy, "\n");
	while(lprint)
	{
		//fprintf(next, "%d|%s\n", linenum, lprint);
		fprintf(next, "%s,%d|%s\n", fname, linenum, lprint);
		lprint = strtok(NULL, "\n");
	}
}

//
void load_labels(const char *fn, char *line, FILE *next)
{
	char linecpy[241];
	strcpy(linecpy, line);

	static uint16_t instr_addr = 0x0000;
	//char sym_buf[81];

	char *bp = strtok(linecpy, "|");
	bp = strtok(NULL, "|");

	for(char *p=bp; p<bp+240; p++)
	{
		if(*p == '\0')
			break;
		else if(*p == ':')
		{
			//strncpy(sym_buf, bp, 80);
			//char *sp = sym_buf + (p-bp);
			*p = '\0';

			//move past leading whitespace
			//p = sym_buf;
			p = bp;
			while(*p==' ' || *p == '\t' || *p == '\n') {p++;}
			if(*p)
			{
				//printf("found label \'%s\' at addr 0x%04x\n", p, instr_addr);
				store_symbol(p, instr_addr, LABEL);
			}
				
			//goto line_scanned;
			return;
		}
	}

	//copy the line
	fprintf(next, "%s", line);

	//line_scanned:
	instr_addr++;
}

//replace from with to (in line) -- only the 1st occurence. return a ptr to the start of the replaced string
//if repl_all is true, replace every instance. if it's false, only replace the 1st.
char *strrepl(char *line, const char *from, const char *to, bool repl_all)
{
	return replace_in_string(line, from, to, repl_all, false);
}

//replace from with to (in line) -- only the 1st occurence. return a ptr to the start of the replaced string
//if repl_all is true, replace every instance. if it's false, only replace the 1st.
char *tokrepl(char *line, const char *from, const char *to, bool repl_all)
{
	return replace_in_string(line, from, to, repl_all, true);
}

//replace from with to (in line) -- only the 1st occurence. return a ptr to the start of the replaced string
//if repl_all is true, replace every instance. if it's false, only replace the 1st.
char *replace_in_string(char *line, const char *from, const char *to, bool repl_all, bool only_tokens)
{
	char *search_pt = line;
	char *p;
	while((p = strstr(search_pt, from)))
	{
		char *newline = malloc(strlen(line) + strlen(to) + 1);
		if(!newline) return NULL;

		//save the insert/replace location
		char *loc = p;
		char *after = p + strlen(from);

		

		//if we're replacing tokens, the "from" substring must be delimited by whitespace/commas
		if(only_tokens)
		{
			if(!(loc==line || *(loc-1)==' ' || *(loc-1)=='\t' || *(loc-1)==',' || *(loc-1)=='\n'))
				goto next_substring;
			if(!(after==(line+strlen(line)) || *after==' ' || *after=='\t' || *after==',' || *after=='\n'))
				goto next_substring;
		}

		*p = '\0';
		sprintf(newline, "%s%s%s", line, to, after);
		strcpy(line, newline);
		

		if(!repl_all)
			return loc;

		//search again, starting from after the previous replacement
		next_substring:
		free(newline);

		search_pt = loc+strlen(to);
		if(search_pt > (line + strlen(line)))
			break;
		//p = strstr(search_pt, from);
	}

	return NULL;
}


void tokenize_asm(char **mnem, char **arg1, char **arg2, char **arg3, char *code)
{
	*mnem = strtok(code, " \t\n");
	*arg1 = strtok(NULL, " \t\n,");
	*arg2 = strtok(NULL, " \t\n,");
	*arg3 = strtok(NULL, " \t\n");
}

bool is_whitespace(const char *str)
{
	for(const char *c=str; *c; c++)
	{
		if(*c != ' ' && *c != '\t' && *c != '\n')
			return false;
	}

	return true;
}