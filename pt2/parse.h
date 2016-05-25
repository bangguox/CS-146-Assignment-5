#ifndef PARSE_H
#define PARSE_H
//includes
#include <stdio.h>
#include <errno.h>
#include <assert.h>
#include <stdlib.h>

//prototypes 
void Parse();
void printParse();

//struct for storing cmd line info
typedef struct commandStruct{

  //stores the number of commands that exist  
  int commandCount;

  //potentially 16 commands
  int argCount[16];  

  //flag to signal input redirection
  int inputRedirected;

  //flag to signal output redirection
  int outputRedirected;
 
  //flag to signal output redirection
  int append;

  //stores to input redirect 
  char inputSpecifier[10000];

  //stores the output redirect file
  char outputSpecifier[100000];

  //storing the command  
  //char command[MAX_COMMANDS][MAX_FILE_NAME_SIZE];
  char command[16][10000];
  
  //storing the command args  
  //char command[MAX_COMMANDS][MAX_ARGS][MAX_FILE_NAME_SIZE];
  char commandArgs[16][10000][10000];
} commandStruct;

extern commandStruct myCommand;
#endif
