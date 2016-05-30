#include "parse.h"

commandStruct myCommand;

void cd()
{
  char path[1000];
  char cwd[1000];

  //it is assumed that if there is no arguments with the command, then we change to home directory
  if( myCommand.paramCount[0] <  2) 
  {
      chdir(getenv("HOME"));
  }    
  else 
  {
    strcpy(path, myCommand.cmds[0][1]);

    if(path[0] != '/')
    {
      getcwd(cwd,sizeof(cwd));
      strcat(cwd,"/");
      strcat(cwd,path);
      chdir(cwd);
    } 
    else
    {
      chdir(path);
    }
  }
}
