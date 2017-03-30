all: assembler

assembler: assembler.tab.c assembler.tab.h lex.yy.c
	gcc -g -lfl -o assembler assembler.tab.c lex.yy.c
assembler.tab.c assembler.tab.h: assembler.y
	bison -d assembler.y
lex.yy.c: assembler.l
	flex assembler.l

clean:
	-rm assembler.tab.c assembler.tab.h lex.yy.c assembler
