all: parse.tab.c lex.yy.c 
	gcc -w parse.tab.c lex.yy.c parse.c -o nsh

lex.yy.c: parse.l
	flex parse.l; 

parse.tab.c: parse.y
	bison -d parse.y; 

run: all
	./nsh

clean:
	rm -f nsh parse.tab.h parse.tab.c lex.yy.c
