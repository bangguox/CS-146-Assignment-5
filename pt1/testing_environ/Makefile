CC = gcc
CFLAGS = 
PROGRAM = tst 
N = 

all: lex yacc
	$(CC) lex.yy.c y.tab.c -o $(PROGRAM) 


lex: tst.l
	lex tst.l

yacc: tst.y
	yacc -d tst.y

run: $(PROGRAM)
	$(PROGRAM) $(N)

clean:
	rm lex.yy.c y.tab.h y.tab.c $(PROGRAM)

