%{
  #include "parse.h"

  //declaring my global struct. Kind of hacky, but the 
  //  alternatives suck
  commandStruct myCommand;
  
  extern FILE * yyin;

  extern int yylineno;
  void yyerror(char *ps, ...){
    printf("In yylineno: %s\n", ps);
}
%}

/*union describe*/
%union {
       char *string;
}

/*start token describe*/
%start cmd_line

/*all tokens declared in my FLEX*/
%token <string> EXIT END_OF_FILE PIPE INPUT_REDIRECTION OUTPUT_REDIRECTION INPUT RUN_BACKGROUND APPEND


%%
cmd_line:
        | EXIT 
        {
          //printf("\nThe EXIT command has been detected! (No handling specified by Part 1 instuctions)\n"); 
          myCommand.eof = 1;
        }
        | END_OF_FILE
        {
          //printf("End of file token has been detected!\n");

          //sets the eof bit to true
          myCommand.eof = 1;

          //return 0 to stop the bison from looking for more tokens  
          return 0;
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
              myCommand.background = 1;
           }
           |
           {/*END OF LINE (if no background symbol exists)*/}
           ;


command: command INPUT
       {
          //sets the arguments
          myCommand.cmds[myCommand.commandCount - 1][myCommand.paramCount[myCommand.commandCount - 1]] = $2;

          //increments the parameter count of the array
          myCommand.paramCount[myCommand.commandCount - 1]++;
       }
       | INPUT
       {

          //increment command count
          myCommand.commandCount++;

          //sets the commands
          myCommand.cmds[myCommand.commandCount - 1][myCommand.paramCount[myCommand.commandCount - 1]] = $1;
      
          //increments the parameter count of the array
          myCommand.paramCount[myCommand.commandCount - 1]++;
       }
       ;

cmd_instance: command redirection_parse
      ;

redirection_parse: input_redirection output_redirection append
     ;

output_redirection:OUTPUT_REDIRECTION INPUT
            { 
              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.outputRedirected = myCommand.append + 1;
            
              //storing new direction
              myCommand.outputFileName = $2;

            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;

input_redirection:INPUT_REDIRECTION INPUT
            {
              //flagging that there is redirection 
              myCommand.inputRedirected = 1;
            
              //storing new direction
              myCommand.inputFileName = $2;
            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;


append:APPEND INPUT
            { 
              //printf("\nCatching the OUTPUT_REDIR and this is the new file: %s",$2);
              myCommand.append = myCommand.outputRedirected + 1;
            
              //storing new direction
              myCommand.appendFileName = $2;
            }
            |
            {/*no  redirection found on the command... therefore ignore*/}
            ;
%%

int main(int argc, char *argv[])
{

  //checking our cmd line params 
  assert(argc <= 2);

  //handles input scripts, otherwise points the fp to stdin
  if(argc == 2)
  {
    yyin = fopen(argv[1],"r");
  }
  else
  {
    yyin = stdin;

    //cmd prompt
    printf("? ");
  }

  while(!myCommand.eof)
  {

    //call to parse function
    Parse();

    //checking to see if the command is a cd request
    if(!myCommand.eof && myCommand.commandCount > 0) 
      //cheking for comment
      if(myCommand.cmds[0][0][0] == '#')
      {
        //does nothing because we ignore comments
      } 
      //checking for cd built-in command
      else if(!strcmp(myCommand.cmds[0][0], "cd"))
        cd();
      else
        prepAndExecuteCommand();

    if(argc < 2 && !myCommand.eof)
      printf("? ");

  }
  

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
  myCommand.append = 0;

  //ensuring all counter have been reset
  myCommand.commandCount = 0;

  myCommand.background = 0;
 
  //could probably save some timere here and only go through
  //  the previous count, but 16 is fairly small
  int i;
  for(i = 0; i < 16; i++)
  {
    myCommand.paramCount[i] = 0;
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
    printf("< '%s' ", myCommand.inputFileName);
  }

  //handles all of the commands and their arguments
  int i;
  for(i = 0; i < myCommand.commandCount; i++)
  {
    //printing all of the args to the command
    int j;
    for(j = 0; j < myCommand.paramCount[i]; j++)
    {
      printf(" '%s'", myCommand.cmds[i][j]);
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
    printf(" >'%s'", myCommand.outputFileName);
  }
  
  if(myCommand.append)
  {
    //prints the symbol and the redirected file name
    printf(" >>'%s'", myCommand.outputFileName);
  }
 
   //newline for formatting
  printf("\n");
}
