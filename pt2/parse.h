#ifndef PARSE_H
#define PARSE_H
//includes
#include <stdio.h>
#include <errno.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

//prototypes 
void Parse();
void printParse();
void prepAndExecuteCommand();
void executeCommand();
void cd();

//struct for storing cmd line info
typedef struct commandStruct{

  //stores if the end-of-file has been reahced
  int eof;

  //stores the number of commands that exist  
  int commandCount;

  //sores if the program is to be run in the background or not
  int background;

  //flag to signal input redirection
  int inputRedirected;

  //flag to signal output redirection
  int outputRedirected;
 
  //flag to signal output redirection
  int append;

  //stores to input redirect 
  char* inputFileName;

  //stores the output redirect file
  char* outputFileName;

  //stores the append redirect file
  char* appendFileName;

  //stores the number of paramets for a single command
  int paramCount[16];

  //stores the parameters of the command
  char *cmds[16][10000];

} commandStruct;

extern commandStruct myCommand;
#endif
