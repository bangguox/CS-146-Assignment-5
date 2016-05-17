%{
#include <stdio.h>
#include <string.h>

 
void yyerror(const char *str)
{
        fprintf(stderr,"error: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 
  
main()
{
        yyparse();
} 

%}

/*%token NUMBER TOKHEAT STATE TOKTARGET TOKTEMPERATURE*/

%token WORD INPUT_REDIRECTION OUTPUT_REDIRECTION PIPE

%%
  commands: /*empty*/
          | commands command
          ;

  command:
          input_redirection
          |
          output_redirection
          |
          pipe
          |
          word
          ;

  input_redirection:
          INPUT_REDIRECTION WORD
          {
                  printf("\tINPUT REDIRECTED->WORD: %s\n", $2);
          }
          ;

  output_redirection:
           OUTPUT_REDIRECTION WORD
          {
                  printf("\tOUTPUT REDIRECTED->WORD: %s\n", $2);
          }
          ;

  pipe:
          PIPE
          {
                  printf("\tPIPE\n");
          }
          ;

  word:
          WORD
          {
                  printf("\tWORD: %s\n", $1);
          }
          ;

%%
