#ifndef PILHA_H_   
#define PILHA_H_

#include <stdio.h>
#include <stdlib.h>

typedef struct Pilha {
	int valor;	
	struct Pilha* anterior;
} Pilha;

Pilha* empilha(Pilha *p, int valor);
//void remove(Pilha *p, int n);
int devolveValor(Pilha *p);
Pilha* desempilha(Pilha *p);
#endif