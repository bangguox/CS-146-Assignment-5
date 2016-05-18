all: backup parse.c parse.tab.c lex.yy.c 
	gcc -o parser  parse.tab.c lex.yy.c

lex.yy.c: parse.l
	flex parse.l; 

parse.tab.c: parse.y
	bison -d parse.y; 
backup:
	cp parse.c my_parse.c_backup

run: parse.c parse.tab.c lex.yy.c
	parser

clean:
	rm -f parser parse.tab.h parse.tab.c lex.yy.c
