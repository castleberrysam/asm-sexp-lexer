%{
#include <stdio.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern void yyerror(const char *str);

extern int line_num;

const char * to_lisp_constant(const char *constant);
%}

%union {
  char *str;
}

%token IDXOPEN IDXCLOSE PLUS NEWLINE
%token <str> REGISTER
%token <str> CONSTANT
%token <str> DIRECTIVE
%token <str> WORD
%%
program:
    lines                               {printf("Successfully lexed program.\n");}
lines:
    line lines | line
line:
    instruction
    | directive
    | NEWLINE                           {printf("\n");}
instruction:
    WORD                                {printf("(%s", $1);}
    arguments
    NEWLINE                             {printf(")\n");}
arguments:
    argument arguments | argument
argument:
    offset | index | simple_argument
offset:
    REGISTER PLUS CONSTANT              {printf("%%%s %s", $1, to_lisp_constant($3));}
index:
    IDXOPEN                             {printf(" (@+ ");}
    offset
    IDXCLOSE                            {printf(")");}
    | IDXOPEN REGISTER IDXCLOSE         {printf(" (@+ %%%s 0)", $2);}
simple_argument:
    REGISTER                            {printf(" %%%s", $1);}
    | CONSTANT                          {printf(" %s", to_lisp_constant($1));}
    | WORD                              {printf(" %s", $1);}
directive:
    DIRECTIVE                           {printf("(%s", $1);}
    simple_argument
    NEWLINE                             {printf(")\n");}
%%
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
  if(argc != 2) {
    printf("Usage: %s <file>\n", argv[0]);
    return 1;
  }

  yyin = fopen(argv[1], "r");
  if(!yyin) {
    printf("Failed to open file: %s\n", argv[1]);
    return 1;
  }

  do {
     yyparse();
  } while(!feof(yyin));
}

void yyerror(const char *str)
{
    printf("Line %d: %s\n", line_num, str);
    exit(1);
}

const char * to_lisp_constant(const char *constant)
{
  size_t len = strlen(constant);
  if(len < 3
     || constant[0] != '0'
     || (constant[1] != 'x'
	 && constant[1] != 'b'
	 && constant[1] != 'd')) {return constant;}
  
  char *new_constant = strdup(constant);
  new_constant[0] = '#';
  return new_constant;
}
