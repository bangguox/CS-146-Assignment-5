%{
//#include <stdio.h>
//#include <stdlib.h>
#include "parse.h"

commandStruct myCommand;

extern int yylineno;
void yyerror(char *ps, ...){
  printf("%s\n", ps);
}
%}

%union {
       char *string;
}


%start cmd_line
%token <string> EXIT PIPE INPUT_REDIR OUTPUT_REDIR STRING NL BACKGROUND


%%
cmd_line:
        | EXIT 
        {
          printf("\nSetting the exit var!\n"); 
        }
        | pipeline back_ground
        ;

back_ground:  BACKGROUND
           {
              printf("\nSetting the Background var"); 
           }
           |
           { 
              printf("\nEND OF CMD");  
           }
           ;

simple: command redir
       ;

command: command STRING
       {
          //stuff here
         // printf("\nThis is the option: %s", $2);
          
          //sets the arg for the command
          strcpy(myCommand.commandArgs[myCommand.argCount[myCommand.commandCount]], $2);

          //increments the counter
          myCommand.argCount[myCommand.commandCount]++;
       }
       | STRING
       {
          //printf("\nThis is the command: %s", $1);

          //set the command
          strcpy(myCommand.command[myCommand.commandCount], $1);

          //increment command count
          myCommand.commandCount++;
       }
       ;

redir: input_redir output_redir
     ;

output_redir:OUTPUT_REDIR STRING
            { 
              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.outputRedirected = 1;
            
              //storing new direction
              strcpy(myCommand.outputSpecifier, $1);
            }
            |        /* empty */
            {
              
              puts("\noutput_redir (set stdout?)");
            }
            ;

input_redir:INPUT_REDIR STRING
            {
              printf("\nCatching the INPUT_REDIR and this is the new file: %s",$2);
            }
            |/* empty */
            {
              //stuff here
              puts("\ninput_redir (set stdin?)");
            }
            ;

pipeline: pipeline PIPE simple
        {
          printf("pipeline PIP simple: cmd");
        }
        | simple
        {
          //stuff 
          puts("\nThis is in simple (recursive?)\n");
        }
        ;
%%

int main()
{
  
  FILE *fp = stdin;

    //can take in a BUF_SIZE line from file/stdin
    const int BUF_SIZE = 1000000;
    char buf[BUF_SIZE];

    while(!feof(fp))
    {
      printf("? ");

      yyparse();

      printf("This is the count: %s", myCommand.command[myCommand.commandCount - 1]);
      
    }

    //closing the file
    fclose(fp);



  return 0;
}
