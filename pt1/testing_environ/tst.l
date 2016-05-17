%{
#include <stdio.h>
#include "y.tab.h"
#define YYSTYPE int;
int yylval;
%}
%%

[a-zA-Z][a-zA-Z0-9]*    yylval=strdup(yytext); return WORD;
[<]                     return INPUT_REDIRECTION;
[>]                     return OUTPUT_REDIRECTION;
[|]                     return PIPE;
\n                      // ignore end of line ;
[ \t]+                  //ignore whitespace ;

%%

/*
[0-9]+                  yylval=atoi(yytext); return NUMBER;
heat                    return TOKHEAT;
on|off                  yylval=!strcmp(yytext,"on"); return STATE;
target                  return TOKTARGET;
temperature             return TOKTEMPERATURE;
*/
