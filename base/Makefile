 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o compilador.h tabSimbolos.o tabSimbolos.h pilha.o pilha.h
	gcc lex.yy.c compilador.tab.c compilador.o tabSimbolos.o pilha.o -o compilador -ll -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: tabSimbolos.o tabSimbolos.h compilador.y compilador.h pilha.o pilha.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

tabSimbolos.o : tabSimbolos.h tabSimbolos.c
	gcc -c tabSimbolos.c -o tabSimbolos.o

pilha.o : pilha.h pilha.c
	gcc -c pilha.c -o pilha.o

clean :
	rm -f compilador.tab.* lex.yy.c compilador.o compilador pilha.o tabSimbolos.o
