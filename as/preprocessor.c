

#include "preprocessor.h"

FILE *preprocess(const char *fpath)
{
	FILE *fp = fopen(fpath, "r");
	if(!fp)
		bail("couldnt open file blah blah");

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
	printf("loading macros...\n"); iterate_file(temp1, temp2, load_macros);
	//dump_symbols(MACRO); exit(0);
	printf("expanding macros...\n"); iterate_file(temp2, temp3, expand_macros);
	//printf("\n\n--------------------------------\n");
	//char tline[161] = "55|\taddl\tsp,5\n";
	//char tline[161] = "55|\tpush r5\n";
	//char tline[161] = "55|\tsetlcl 1,r3\n";
	//expand_macros(tline, temp4);
	//exit(0);
	printf("expanding macros...\n"); iterate_file(temp3, temp4, expand_macros);
	printf("expanding macros...\n"); iterate_file(temp4, temp5, expand_macros);
	//printf("expanding pseudos...\n"); iterate_file(temp3, temp4, expand_pseudos);		//this is gonna get deleted once we support double-arg macros
	printf("loading labels...\n"); iterate_file(temp5, temp6, load_labels);

	fclose(temp1);
	fclose(temp2);
	fclose(temp3);
	fclose(temp4);
	fclose(temp5);

	return temp6;
}

//file must already be open
void iterate_file(FILE *fp, FILE *next, void (*process)(char *line, FILE *next))
{
	char buf[161];

	fseek(fp, 0, SEEK_SET);

	while(1)
	{
		fgets(buf, 160, fp);
		if(feof(fp))
			break;

		process(buf, next);
	}

	fclose(fp);
}

void remove_comments_add_linenums(char *line, FILE *next)
{
	static int linenum = 0;

	//remove comments, search for reserved characters
		for(char *p=line; p<line+160; p++)
		{
			switch(*p)
			{
				case '\0':
					goto line_preprocessed;
					break;
				case '|':
					printf("buf:\n%s\n", line);
					bail("found illegal character \'|\'");
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
			fprintf(next, "%d|%s", linenum, line);
			//instr_addr++;
		}

	next_line:
	linenum++;
}

/*void expand_pseudos(char *line, FILE *next)
{
	char linecpy[161];
	strcpy(linecpy, line);

	char *bp = strtok(linecpy, "|");
	int linenum = strtol(bp, NULL, 10);
	bp = strtok(NULL, "|");

		char *mnem, *arg0, *arg1;
		tokenize_asm(&mnem, &arg0, &arg1, bp);
		if(!mnem)
			bail("syntax error on line %d", linenum);

		
		//check if the instruction is a pseudo
		int pseudo = mnemonic_to_pseudo(mnem);
		if(pseudo == 0xFF)
		{
			//copy the line
			fprintf(next, "%s", line);
		}
		else
		{
			//printf("expanding pseudoinstruction (%s, %s, %s)\n", mnem, arg0, arg1);
			//getchar();
			pseudoinstruction_table[pseudo].format((char *)next, arg0, arg1, linenum);
		}
}*/

//doesn't actually create a 3rd tempfile
void load_labels(char *line, FILE *next)
{
	char linecpy[161];
	strcpy(linecpy, line);

	static uint16_t instr_addr = 0x0000;
	//char sym_buf[81];

	char *bp = strtok(linecpy, "|");
	bp = strtok(NULL, "|");

	for(char *p=bp; p<bp+160; p++)
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
					printf("found label \'%s\' at addr 0x%04x\n", p, instr_addr);
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

void load_macros(char *line, FILE *next)
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

		//grab macro arguments (if there are any)
		char *arg1 = strtok(from, " \t,");
		arg1 = strtok(NULL, " \t,");
		char *arg2 = strtok(NULL, " \t,");

		//load it to the symbol table
		//printf("found macro: %s (args %s, %s) => %s\n", from, arg1, arg2, to);
		store_macro(from, to, arg1, arg2);

		//replace \n with newlines in macro
		while(strrepl(symbols_table[symbol_cnt-1].expand, "\\n", "\n"));
	}
	else
		fprintf(next, line);
}

void expand_macros(char *line, FILE *next)
{
	//char argbuf[80];

	char incpy[161];
	char *bp = strtok(line, "|");
	int linenum = strtol(bp, NULL, 10);
	bp = strtok(NULL, "|");
	strcpy(incpy, bp);
	//printf("\t--- %s ---\n", incpy);

	//scan the line for macros
	for(int i=0; i<symbol_cnt; i++)
	{
		if(symbols_table[i].type != MACRO)
			continue;
		printf("searching for macro %s\n", symbols_table[i].name);

		char lcpy[161];
		strcpy(lcpy, incpy);

		char *tok = strtok(lcpy, " ,\t\n");
		while(tok)
		{
			printf("\tchecking token %s\n", tok);

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
				char argfield[161];
				//strcpy(tok_w_args, lcpy);
				char *argp, *arg1in, *arg2in;
				if(symbols_table[i].arg1)
				{
					printf("macro \'%s\' defined with default args: %s, %s\n",
						tok, symbols_table[i].arg1, symbols_table[i].arg2);
					//argin = strtok(NULL, " \t\n");
					//argin = strtok(NULL, "\t\n");

					argp = tok + strlen(tok) + 1;
					strcpy(argfield, argp);
					//argfield = tok_w_args + strlen(tok_w_args) + 1;
					printf("\targ string: %s\n", argfield);
					arg1in = strtok(argfield, ",\n");
					arg2in = strtok(NULL, ",\n");
					printf("\tmacro has args: %s, %s\n", arg1in, arg2in);
					//strcpy(argbuf, arg1in);
				}

				//expand the macro
				while(strtok(NULL, " ,\t\n"));	//does this do anything?

				//we're replacing the macro, AND any args -- "push r5" needs to get expanded (not just)
				//the "push" part.
				//repltarget is the entire part that gets replaced 
				char repltarget[161];
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

				printf("\tbefore expanding: %s (replacing token %s)\n", incpy, repltarget);
				//if(strstr(incpy, "setlcl")) getchar();
				strrepl(incpy, repltarget, symbols_table[i].expand);

				//substitute "default args" with actual args
				if(symbols_table[i].arg1)
					while(strrepl(incpy, symbols_table[i].arg1, arg1in));
				if(symbols_table[i].arg2)
					while(strrepl(incpy, symbols_table[i].arg2, arg2in));
				printf("after expanding: %s\n", incpy);
			}

			tok = strtok(NULL, " ,\t\n");
		}
	}

	
	//print each line of the expanded macro, prefixing with line numbers
	char *lprint = strtok(incpy, "\n");
	while(lprint)
	{
		fprintf(next, "%d|%s\n", linenum, lprint);
		lprint = strtok(NULL, "\n");
	}
}

//replace from with to (in line) -- only the 1st occurence. return a ptr to the start of the replaced string
char *strrepl(char *line, const char *from, const char *to)
{
	char *p = strstr(line, from);
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
	}

	return NULL;
}



/*
//remove comments and empty lines
void preprocess(void)
{
		
	ftemp = fopen(TEMPFILE, "w+");
	if(!ftemp) bail("failed to create temp file");

	uint16_t instr_addr = 0x0000;	//10-bit address
	char buf[161];
	int linenum = 1;
	while(1)
	{

		//
		fgets(buf, 160, fin);
		if(feof(fin))
			break;

		//remove comments, search for reserved characters
		for(char *p=buf; p<buf+160; p++)
		{
			switch(*p)
			{
				case '\0':
					goto line_preprocessed;
					break;
				case '|':
					printf("buf:\n%s\n", buf);
					bail("found illegal character \'|\'");
					break;
				case ';':
					*p++ = '\n';
					*p = '\0';
					break;
				case ':':
					*p = '\0';

					//move past leading whitespace
					p = buf;
					while(*p==' ' || *p == '\t' || *p == '\n') {p++;}
					if(*p)
					{
						printf("found label \'%s\' at addr 0x%04x\n", p, instr_addr);
						store_label(p, instr_addr);
					}
					

					goto next_line;
			}
		}

		line_preprocessed:

		//if(strlen(buf) > 1)	//this should remove empty lines -- right now it only gets rid of "\n"
		if(!is_whitespace(buf))
		{
			fprintf(ftemp, "%d|%s", linenum, buf);
			instr_addr++;
		}
		
		next_line:
		linenum++;
	}
}

void preprocess_pseudo(void)
{
	ftemp2 = fopen(TEMPFILE2, "w+");
	if(!ftemp2) bail("failed to create temp file 2");

	fseek(ftemp, 0, SEEK_SET);

	char inbuf[161], buf[161];
	char *bp;

	while(1)
	{
		//
		fgets(inbuf, 160, ftemp);
		if(feof(ftemp))
			break;
		strcpy(buf, inbuf);

		bp = strtok(buf, "|");
		int linenum = strtol(bp, NULL, 10);
		bp = strtok(NULL, "|");

		char *mnem, *arg0, *arg1;
		tokenize_asm(&mnem, &arg0, &arg1, bp);
		if(!mnem)
			bail("syntax error on line %d", linenum);

		
		//check if the instruction is a pseudo
		int pseudo = mnemonic_to_pseudo(mnem);
		if(pseudo == 0xFF)
		{
			//copy the line
			fprintf(ftemp2, "%s", inbuf);
		}
		else
		{
			//printf("expanding pseudoinstruction (%s, %s, %s)\n", mnem, arg0, arg1);
			//getchar();
			pseudoinstruction_table[pseudo].format((char *)ftemp2, arg0, arg1, linenum);
		}
	}

	
}
*/

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