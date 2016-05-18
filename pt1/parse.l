/* -*- indented-text -*- */
%{
#include "parse.tab.h"
#include <string.h>

#ifdef DOESNT_HAVE_STRDUP
#warning DOESNT_HAVE_STRDUP
char *strdup(const char *s);
#endif

#define ECHO
%}

%%
 
exit                  { ECHO; return EXIT; }
[\n]                  { ECHO; return 0; }
[&]                   { ECHO; return BACKGROUND; }
[|]                   { ECHO; return PIPE;}
[>]                   { ECHO; return OUTPUT_REDIR; }
[<]                   { ECHO; return INPUT_REDIR; }
[0-9a-zA-Z_=/\-\*\.]+  { ECHO; yylval.string = strdup(yytext); return STRING; }
.               ;

%%


int yywrap(){
  return 1;
}
