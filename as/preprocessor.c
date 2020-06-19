

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
	/*FILE *fp = fopen(fpath, "r");
	if(!fp)
		bail("couldnt open file %s", fpath);

	//open all tempfiles
	FILE *temp1, *temp2, *temp3, *temp4, *temp5, *temp6;
	temp1 = fopen(TEMPFILE1, "w+");
	if(!temp1)
		bail("failed to open %s", TEMPFILE1);
	temp2 = fopen(TEMPFILE2, "w+");
	if(!temp2)
		bail("failed to open %s", TEMPFILE2);
	temp3 = fopen(TEMPFILE3, "w+");
	if(!temp3)
		bail("failed to open %s", TEMPFILE3);
	temp4 = fopen(TEMPFILE4, "w+");
	if(!temp4)
		bail("failed to open %s", TEMPFILE4);
	temp5 = fopen(TEMPFILE5, "w+");
	if(!temp5)
		bail("failed to open %s", TEMPFILE5);
	temp6 = fopen(TEMPFILE6, "w+");
	if(!temp6)
		bail("failed to open %s", TEMPFILE6);


	iterate_file(fp, temp1, remove_comments_add_linenums);
	iterate_file(temp1, temp2, load_macros);
	//dump_symbols(MACRO); exit(0);
	iterate_file(temp2, temp3, expand_macros);
	//printf("\n\n--------------------------------\n");
	//char tline[161] = "55|\taddl\tsp,5\n";
	//char tline[161] = "55|\tpush r5\n";
	//char tline[161] = "55|\tsetlcl 1,r3\n";
	//expand_macros(tline, temp4);
	//exit(0);
	iterate_file(temp3, temp4, expand_macros);
	iterate_file(temp4, temp5, expand_macros);
	//printf("expanding pseudos...\n"); iterate_file(temp3, temp4, expand_pseudos);		//this is gonna get deleted once we support double-arg macros
	iterate_file(temp5, temp6, load_labels);
	*/

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
	iterate_file(TEMPFILE3, TEMPFILE4, expand_macros, true);
	iterate_file(TEMPFILE4, TEMPFILE5, expand_macros, true);
	iterate_file(TEMPFILE5, TEMPFILE6, expand_macros, true);
	iterate_file(TEMPFILE6, TEMPFILE7, load_labels, true);

	FILE *preprocessed = fopen(TEMPFILE7, "r");
	return preprocessed;
	

	/*fclose(temp1);
	fclose(temp2);
	fclose(temp3);
	fclose(temp4);
	fclose(temp5);

	return temp6;*/
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
			case '|':
				//printf("buf:\n%s\n", line);
				//bail("found illegal character \'|\'");
				error(fn, linenum, "found illegal character \'|\'");
				break;
			case ';':
				*p++ = '\n';
				*p = '\0';
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
				//printf("expanding macro %s\n", tok);
				/*if(strcmp(tok, "mklcl")==0)
				{
					printf("found mklcl\n");
					getchar();
				}*/

				//if the macro has an argument, grab it
				char argfield[241];
				//strcpy(tok_w_args, lcpy);
				char *argp, *arg1in, *arg2in;
				if(symbols_table[i].arg1)
				{
					//printf("macro \'%s\' defined with default args: %s, %s\n",
					//	tok, symbols_table[i].arg1, symbols_table[i].arg2);
					//argin = strtok(NULL, " \t\n");
					//argin = strtok(NULL, "\t\n");

					argp = tok + strlen(tok) + 1;
					strcpy(argfield, argp);
					//argfield = tok_w_args + strlen(tok_w_args) + 1;
					//printf("\targ string: %s\n", argfield);
					arg1in = strtok(argfield, ",\n");
					if(!arg1in)
						error(fname, linenum, "missing arg to macro %s", tok);
					if(symbols_table[i].arg2)
					{
						arg2in = strtok(NULL, ",\n");
						if(!arg2in)
							error(fname, linenum, "missing 2nd arg to macro %s", tok);

					}
					//printf("\tmacro has args: %s, %s\n", arg1in, arg2in);
					//strcpy(argbuf, arg1in);
				}

				//expand the macro
				while(strtok(NULL, " ,\t\n"));	//does this do anything?

				//we're replacing the macro, AND any args -- "push r5" needs to get expanded (not just)
				//the "push" part.
				//repltarget is the entire part that gets replaced 
				char repltarget[241];
				if(symbols_table[i].arg1)
				{
					char *p = incpy;
					while(*p!=' ' && *p!='\t') p++;
					while(*p!=',' && *p!='\n' && *p!='\0') p++;
					if(symbols_table[i].arg2)
						while(*p!='\n' && *p!='\0') p++;

					strncpy(repltarget, incpy, p-incpy+1);
					repltarget[p-incpy+1] = '\0';
				}
				else
					strcpy(repltarget, tok);

				//printf("\n\tbefore expanding: %s\t\treplacing token %s\n\t\twith %s\n",
				//	incpy, repltarget, symbols_table[i].expand);
				//if(strstr(incpy, "setlcl")) getchar();
				strrepl(incpy, repltarget, symbols_table[i].expand, false);
				//printf("main macro replaced\n%s\n", incpy);

				//substitute "default args" with actual args
				if(symbols_table[i].arg1)
				{
					printf("replacing %s\nwith %s\n", symbols_table[i].arg1, arg1in);
					printf("at (%s,%d)\n\n", fname, linenum);
					strrepl(incpy, symbols_table[i].arg1, arg1in, true);
				}
				if(symbols_table[i].arg2)
					strrepl(incpy, symbols_table[i].arg2, arg2in, true);
				//printf("after expanding: %s\n", incpy);
				//return;
			}

			tok = strtok(NULL, " ,\t\n");
		}
	}

	
	//print each line of the expanded macro, prefixing with line numbers
	char *lprint = strtok(incpy, "\n");
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
	//printf("-----------------\nreplacing string\n%s\nwith\n%s\n", from, to);
	//printf("in %s\n", line);
	//printf("lengths %d,%d,%d\n", strlen(line), strlen(from), strlen(to));

	char *p = strstr(line, from);
	while(p)
	{
		char *newline = malloc(strlen(line) + strlen(to) + 1);
		if(!newline) return NULL;

		//save the insert/replace location
		char *loc = p;

		*p = '\0';
		p += strlen(from);
		sprintf(newline, "%s%s%s", line, to, p);

		strcpy(line, newline);
		free(newline);

		if(!repl_all)
			return loc;

		//search again, starting from after the previous replacement
		char *search_pt = loc+strlen(to);
		if(search_pt > (line + strlen(line)))
			break;
		p = strstr(search_pt, from);
	}

	/*char *p = strstr(line, from);
	if(p)
	{
		char *newline = malloc(strlen(line) + strlen(to) + 1);
		if(!newline) return NULL;

		//save the insert/replace location
		char *loc = p;

		*p = '\0';
		p += strlen(from);
		sprintf(newline, "%s%s%s", line, to, p);

		strcpy(line, newline);
		free(newline);

		return loc;
	}*/

	return NULL;
}

void tokenize_asm(char **mnem, char **arg1, char **arg2, char *code)
{
	*mnem = strtok(code, " \t\n");
	*arg1 = strtok(NULL, " \t\n,");
	*arg2 = strtok(NULL, " \t\n");
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