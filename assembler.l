%{
#include "assembler.tab.h"
#include <stdio.h>

#define YY_DECL extern int yylex()

int line_num = 1;
%}
%%
[ \t]                                    ;
\[                                       {return IDXOPEN;}
\],?                                     {return IDXCLOSE;}
\+                                       {return PLUS;}
(;[^\n]*)?\n                             {++line_num; return NEWLINE;}
(pc|sp|fp|lr|r[0-9]|r1[0-5]),?           {yylval.str = strdup(yytext); return REGISTER;}
(0x[a-f0-9]+|0b[01]+|-?[0-9]+),?         {yylval.str = strdup(yytext); return CONSTANT;}
\.[a-zA-Z]+                              {yylval.str = strdup(yytext); return DIRECTIVE;}
([a-zA-Z0-9_-]+):                        {yylval.str = strdup(yytext); return LABEL;}
([a-zA-Z0-9_-]+),?                       {yylval.str = strdup(yytext); return WORD;}
