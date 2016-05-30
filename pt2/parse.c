#include "parse.h"

commandStruct myCommand;

void prepAndExecuteCommand()
{

/*
  const char *ls[] = { "ls", "-l", 0 };
  const char *grep[] = { "grep", "parse", 0 };
  const char *awk[] = { "awk", "{print $1}", 0 };
  const char *sort[] = { "sort", 0 };
  const char *uniq[] = { "uniq", 0 };

  //char *args[] = { {ls}, {awk}, {sort}, {uniq} };
  char *args[] = { {ls}, {grep} };
  */
  int **args;
  int fd[2];

  //initial fd will be from whatever std in is for now...
  int inputFd = 0;
  


  //pipe loop runs n-1 times... Last (or potentially only) execution will
  //occur affer the loop has iterated over n-1 commands and the nth will
  //be fulfilled after 
  int i;
  for(i = 0; i < myCommand.commandCount - 1; i++)
  {
    //creating the pipe
    pipe(fd);

    //temporary data prep
    args = prepareCommand(i);  
     
    //runs the progrma
    executeCommand(inputFd, fd[1], args, 0);
  
    //closing the writing end of the pipe since all the info is already in there
    close(fd[1]);

    //redirect the read end of the pipe to our inputFd in preparation
    //of the next command to read from
   // dup2(fd[0], inputFd);
   // close(fd[0]);
   inputFd = fd[0];
  }

  if(inputFd != 0)
    dup2(inputFd, 0);

    args = prepareCommand(i);  
  
  //runs the last (or potentially first and only) program
  executeCommand(inputFd, 1, args, 0);
  //  execvp(args[0], args);

}

//helper funciton responsible for executing non-builting commands
void executeCommand(int inputFd, int outputFd, char *args[], int run_bg)
{
   pid_t pid = fork();
   int status;

  if(pid == -1)
  {
    perror("Could not fork a new process");
    exit(1);
  }
  else if(pid == 0)
  {
    //redirects our input strem to the correct file descriptor
    if(inputFd != 0)
    {
      //copying over the redirected input fd
      dup2(inputFd, 0); 
      
      //need do close fd so we dont run out
      close(inputFd);
    } 

    //redirects our output stream to the correct file descriptor
    if(outputFd != 1)
    {
      //copying over our redirected fd
      dup2(outputFd, 1);

      //closing the old fd
      close(outputFd);
    }
    
    //run command
    execvp(args[0], args);

    
    printf("Issue exec'ing program: %s\n", args[0]);
    exit(-1);
  }
 else
  {
    //waiting for child to terminte unless background flag is specified
    if(run_bg != 1)
      pid = wait(&status);

  }
}

char ** prepareCommand(int cmd)
{
  const int NAME_SIZE = 10000;
  
  char ** returnAr = (char *) malloc(myCommand.argCount[cmd] + 2);

  //sets the first command
  returnAr[0] = (char *) malloc(NAME_SIZE); 
  strncpy(returnAr[0], myCommand.command[cmd], NAME_SIZE);
  
  
  int i;
  for(i = 0; i < myCommand.argCount[cmd]; i++)
  {
    returnAr[i + 1] = (char *) malloc(NAME_SIZE); 
    strncpy(returnAr[i + 1], myCommand.commandArgs[cmd][i], NAME_SIZE);

  }

  //setting the null terminator of the arg array
  returnAr[myCommand.argCount[cmd] + 1] = 0; 

  return returnAr;
}
