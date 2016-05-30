#include "parse.h"

commandStruct myCommand;

void cd()
{
    char path[1000];
    
    strcpy(path, myCommand.cmds[0][1]);

    char cwd[1000];
    if(path[0] != '/')
    {// true for the dir in cwd
        getcwd(cwd,sizeof(cwd));
        strcat(cwd,"/");
        strcat(cwd,path);
        chdir(cwd);
    }else{//true for dir w.r.t. /
        chdir(pth);
    }
}
