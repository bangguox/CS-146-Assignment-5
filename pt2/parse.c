#include "parse.h"

commandStruct myCommand;

void prepCommand()
{


  const char *ls[] = { "ls", "-l", 0 };
  const char *grep[] = { "grep", "parse", 0 };
  const char *awk[] = { "awk", "{print $1}", 0 };
  const char *sort[] = { "sort", 0 };
  const char *uniq[] = { "uniq", 0 };

  char *args[] = { {ls}, {awk}, {sort}, {uniq} };
  //char *args[] = { {ls}, {grep} };
  
  int fd[2];

  //initial fd will be from whatever std in is for now...
  int inputFd = 0;
  int stdOUT;
  dup2(0, inputFd);

  //pipe loop runs n-1 times... Last (or potentially only) execution will
  //occur affer the loop has iterated over n-1 commands and the nth will
  //be fulfilled after 
  int i;
  for(i = 0; i < 1; i++)
  {
    //creating the pipe
    pipe(fd);

    //temporary data prep
//    char *args[] = {"ls", "-la", NULL};  
   
     //runs the progrma
     executeCommand(inputFd, fd[1], args[i], 0);
  
    //closing the writing end of the pipe since all the info is already in there
    close(fd[1]);

    //redirect the read end of the pipe to our inputFd in preparation
    //of the next command to read from
    
   // inputFd = fd[0];
   
    dup2(fd[0], inputFd);
    close(fd[0]);
  }

  if(inputFd != 0)
    dup2(inputFd, 0);  


  //runs the last (or potentially first and only) program
  executeCommand(stdin, stdout, args[1], 0);
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