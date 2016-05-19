%{
  #include "parse.tab.h"
  #include <string.h>

  #ifdef DOESNT_HAVE_STRDUP
  #warning DOESNT_HAVE_STRDUP
    char *strdup(const char *s);
  #endif
%}

%%
 
[0-9a-zA-Z_=/\-\*\.]+ {  yylval.string = strdup(yytext); return INPUT; }
[>]                   { return OUTPUT_REDIRECTION; }
[<]                   { return INPUT_REDIRECTION; }
[|]                   { return PIPE;}
[&]                   { return RUN_BACKGROUND; }
exit                  { return EXIT;}
[\n]                  { return 0; }
.               ;

%%

int yywrap(){
  return 1;
}
