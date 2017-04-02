%{
#include <stdio.h>
#include <string.h>

extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern void yyerror(const char *str);

extern int line_num;

char * to_lisp_constant(char *constant);
%}

%union {
  char *str;
}

%token IDXOPEN IDXCLOSE PLUS NEWLINE
%token <str> REGISTER
%token <str> CONSTANT
%token <str> DIRECTIVE
%token <str> LABEL
%token <str> WORD
%%
program:
    lines                               {printf("Successfully lexed program.\n");}
lines:
    line lines | line
line:
    instruction
    | label
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
index_open:
    IDXOPEN                             {printf(" (@+ ");}
index_close:
    IDXCLOSE                            {printf(")");}
index:
    index_open offset index_close
    | index_open
    REGISTER                            {printf("%%%s 0", $2);}
    index_close
simple_argument:
    REGISTER                            {printf(" %%%s", $1);}
    | CONSTANT                          {printf(" %s", to_lisp_constant($1));}
    | WORD                              {printf(" %s", $1);}
label:
    LABEL NEWLINE                       {$1[strlen($1)-1] = '\0'; printf("(.label %s)\n", $1);}
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
    printf("\nLine %d: %s\n", line_num, str);
    exit(1);
}

char * to_lisp_constant(char *constant)
{
    if(constant[0] == '0'
       && (constant [1] == 'x'
           || constant[1] == 'b'
           || constant[1] == 'd')) {
        constant[0] = '#';
    }
    return constant;
}
