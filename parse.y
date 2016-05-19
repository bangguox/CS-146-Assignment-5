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
          printf("This is the Arg: %s This is the cmdCt: %d This is the argCt: %d\n", $2, myCommand.commandCount - 1, myCommand.argCount[myCommand.commandCount]);
          //printf("This is the array: commandArgs[][]\n", $2, myCommand.commandCount - 1, myCommand.argCount[myCommand.commandCount]);
          
          //sets the arg for the command
          strcpy(myCommand.commandArgs[myCommand.commandCount - 1][myCommand.argCount[myCommand.commandCount - 1]], $2);

          //increments the counter
          myCommand.argCount[myCommand.commandCount - 1]++;
       }
       | STRING
       {
          printf("This is the cmd: %s This is the cmdCt: %d This is the currentcmdSlot: %s\n", $1, myCommand.commandCount, myCommand.command[myCommand.commandCount]);
          //set the command
          strcpy(myCommand.command[myCommand.commandCount],$1);

          //increment command count
          myCommand.commandCount++;
       }
       ;

redir: input_redir output_redir
     ;

output_redir:OUTPUT_REDIR STRING
            { 

              printf("This is the OUTPUT_REDIR STRING: '%s' This is the cmdCt: %d This is the currentcmdSlot: %s\n", $2, myCommand.commandCount, myCommand.outputSpecifier);

              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.outputRedirected = 1;
            
              //storing new direction
              strcpy(myCommand.outputSpecifier, $2);
            }
            |        /* empty */
            {
              
             // puts("\nno ouput redir detected");
            }
            ;

input_redir:INPUT_REDIR STRING
            {
           
              printf("This is the INPUT_REDIR STRING: '%s' This is the cmdCt: %d This is the currentcmdSlot: %s\n", $2, myCommand.commandCount, myCommand.inputSpecifier);
             
              //flagging that there is redirection 
              myCommand.inputRedirected = 1;
            
              //storing new direction
              strcpy(myCommand.inputSpecifier, $2);
            }
            |/* empty */
            {
              //stuff here

              //puts("\nno input redir detected");
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

      //call to parse function
      Parse(); 

      //prints specified parse info
      printParse();
    }

    //closing the file
    fclose(fp);


  return 0;
}

/*
*Tivial method to call lex/bison parser. Collects all info in header instance of command
*/
void Parse()
{
  //resetting both redirections
  myCommand.inputRedirected = 0;
  myCommand.outputRedirected = 0;  

  //ensuring all counter have been reset
  myCommand.commandCount = 0;
  
  //could probably save some timere here and only go through
  //  the previous count, but 16 is fairly small
  int i;
  for(i = 0; i < 16; i++)
  {
    myCommand.argCount[i] = 0;
  }

  //call out lex + bison
   yyparse();
}


/*
*prints the command stuct in accordance with assignment instructions
*/
void printParse()
{
  printf("\nTHIS IS THE OUTPUT:\n");

  //outputs the number of commands
  printf("%d: ", myCommand.commandCount);

  //handles any input redirection
  if(myCommand.inputRedirected)
  {
    //prints the symbol and the redirected file name
    printf("< '%s' ", myCommand.inputSpecifier);
  }


  //handles all of the commands and their arguments
  int i;
  for(i = 0; i < myCommand.commandCount; i++)
  {
      printf("'%s'", myCommand.command[i]);

    //printing all of the args to the command
    int j;
    for(j = 0; j < myCommand.argCount[i]; j++)
    {
      printf(" '%s'", myCommand.commandArgs[i][j]);
    }

    //printing the pipe if there is a following command
    if(i != myCommand.commandCount - 1)
      printf(" | ");
    else
    printf(" ");
  }

  //handles any output redirection
  if(myCommand.outputRedirected)
  {
    //prints the symbol and the redirected file name
    printf(" >'%s'", myCommand.outputSpecifier);
  }

  //newline for formatting
  printf("\n");
}




