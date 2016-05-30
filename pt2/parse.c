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
     */
  int fd[2];

  //initial fd will be from whatever std in is for now...
  int saveInput = dup(fileno(stdin));
  int saveOutput = dup(fileno(stdout));
  int inputFd;
/*
  //standard input points to the inputFD
  //dup2(inputFd, fileno(stdin));

  //pipe loop runs n-1 times... Last (or potentially only) execution will
  //occur affer the loop has iterated over n-1 commands and the nth will
  //be fulfilled after 
  int i;
  for(i = 0; i < myCommand.commandCount - 1; i++)
  {
    //creating the pipe
    pipe(fd);

    //appends a null to the end of the cmd array before execution
    myCommand.cmds[i][myCommand.paramCount[i]] = NULL;

    //runs the progrma
    executeCommand(inputFd, fd[1], myCommand.cmds[i], 0);

    //closing the writing end of the pipe since all the info is already in there
    close(fd[1]);

    //redirect the read end of the pipe to our inputFd in preparation
    //of the next command to read from
    // dup2(fd[0], inputFd);
    // close(fd[0]);
    inputFd = fd[0];
  }

//  if(inputFd != 0)
//    dup2(inputFd, 0);

  //appends a null to the end of the cmd array before execution
  myCommand.cmds[i][myCommand.paramCount[i]] = NULL;


  //handling output redirection
  if(myCommand.outputRedirected) 
  { 
    //opens the output file 
    int outputRedirect = fopen(myCommand.outputFileName, "w"); 
  
    if(outputRedirect == NULL)
    {
      perror("prepAndExecute: Could not open outputRedirect file");
      exit(1);
    }
printf("This is the value: %d\n", myCommand.outputRedirected);

    //redirects the stdout
    dup2(outputRedirect, 1); 

    //closes the opened file
    close(outputRedirect); 
  }
*/
  //runs the last (or potentially first and only) program
  executeCommand(fileno(stdin), fileno(stdout), myCommand.cmds[0], 0);
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
    if(inputFd != fileno(stdin))
    {
      //copying over the redirected input fd
      dup2(inputFd, fileno(stdin)); 

      //need do close fd so we dont run out
      close(inputFd);

      puts("We are in the inputFD Redirection child\n");
    } 

    //redirects our output stream to the correct file descriptor
    if(outputFd != fileno(stdout))
    {
      //copying over our redirected fd
      dup2(outputFd, fileno(stdout));

      //closing the old fd
      close(outputFd);

      puts("We are in the outputFD Redirection child\n");
    }

    //run command
    execvp(args[0], args);

    //error message for programs not found
    printf("-nsh: %s: command not found\n", args[0]);
    exit(-1);
  }
  else
  {
    //waiting for child to terminte unless background flag is specified
    if(run_bg != 1)
      pid = wait(&status);

  }
}

