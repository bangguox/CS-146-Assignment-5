%{
  #include "parse.h"

  //declaring my global struct. Kind of hacky, but the 
  //  alternatives suck
  commandStruct myCommand;

  extern int yylineno;
  void yyerror(char *ps, ...){
    printf("%s\n", ps);
}
%}

/*union describe*/
%union {
       char *string;
}

/*start token describe*/
%start cmd_line

/*all tokens declared in my FLEX*/
%token <string> EXIT PIPE INPUT_REDIRECTION OUTPUT_REDIRECTION INPUT RUN_BACKGROUND APPEND


%%
cmd_line:
        | EXIT 
        {
          printf("\nThe ECIT command has been detected! (No handling specified by Part 1 instuctions)\n"); 
        }
        | cmd_func background
        ;

cmd_func: cmd_func PIPE cmd_instance
        {/*performs a recurse with a pipe*/ }
        | cmd_instance
        {/*recurses on a single cmd*/}
        ;

background:  RUN_BACKGROUND
           {
            printf("\nThe BACKGROUND command has been detected! (No handling specified by Part 1 instuctions)\n"); 
           }
           |
           {/*END OF LINE (if no background symbol exists)*/}
           ;


command: command INPUT
       {
          //sets the arg for the command
          strcpy(myCommand.commandArgs[myCommand.commandCount - 1][myCommand.argCount[myCommand.commandCount - 1]], $2);

          //increments the counter
          myCommand.argCount[myCommand.commandCount - 1]++;
       }
       | INPUT
       {
          //set the command
          strcpy(myCommand.command[myCommand.commandCount],$1);

          //increment command count
          myCommand.commandCount++;
       }
       ;

cmd_instance: command redirection_parse
      ;

redirection_parse: input_redirection output_redirection append
     ;

output_redirection:OUTPUT_REDIRECTION INPUT
            { 
              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.outputRedirected = 1;
            
              //storing new direction
              strcpy(myCommand.outputSpecifier, $2);
            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;

input_redirection:INPUT_REDIRECTION INPUT
            {
              //flagging that there is redirection 
              myCommand.inputRedirected = 1;
            
              //storing new direction
              strcpy(myCommand.inputSpecifier, $2);
            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;


append:APPEND INPUT
            { 
              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.append = 1;
            
              //storing new direction
              strcpy(myCommand.outputSpecifier, $2);
            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;
%%

int main(int argc, char *argv[])
{
  signal();
  //checking our cmd line params 
  assert(argc == 1);

  FILE *fp = stdin;

  //can take in a BUF_SIZE line from file/stdin
  const int BUF_SIZE = 1000000;
  char buf[BUF_SIZE];
/*
  while(!feof(fp))
  {
    printf("? ");

    //call to parse function
    Parse(); 
    
    //prints specified parse info. Kind of a jank way to stop from printing
    //  if an EOF is found
    if(!feof(fp))
      printParse();
  }
*/

  char *args[] = {"ls", "-la", NULL};

 // executeCommand(0, 1, args, 0);
  //closing the file
  prepCommand();  

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
 
  myCommand.append = 0;
 
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
  
  if(myCommand.append)
  {
    //prints the symbol and the redirected file name
    printf(" >>'%s'", myCommand.outputSpecifier);
  }
 
   //newline for formatting
  printf("\n");
}




