

#include "preprocessor.h"

FILE *preprocess(const char *fpath)
{
	FILE *fp = fopen(fpath, "r");
	if(!fp)
		bail("couldnt open file blah blah");

	//open all tempfiles
	FILE *temp1, *temp2, *temp3;
	temp1 = fopen(TEMPFILE1, "w+");
	if(!temp1)
		bail("failed to open %s", TEMPFILE1);
	temp2 = fopen(TEMPFILE2, "w+");
	if(!temp2)
		bail("failed to open %s", TEMPFILE2);
	temp3 = fopen(TEMPFILE3, "w+");
	if(!temp3)
		bail("failed to open %s", TEMPFILE3);


	iterate_file(fp, temp1, remove_comments_add_linenums);
	iterate_file(temp1, temp2, expand_pseudos);
	iterate_file(temp2, temp3, load_symbols);

	return temp3;
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

void expand_pseudos(char *line, FILE *next)
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
}

//doesn't actually create a 3rd tempfile
void load_symbols(char *line, FILE *next)
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
					store_label(p, instr_addr);
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