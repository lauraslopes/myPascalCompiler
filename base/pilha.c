#include "pilha.h"

Pilha* empilha(Pilha *p, int valor) {

	Pilha* elemento = malloc(sizeof(Pilha));
	elemento->valor = valor;

	if (p != NULL) {
		elemento->anterior = p;
	}

	return elemento;
}
/*
void remove(Pilha *p, int n) {

	Pilha* aux = p->anterior;
	for (int i = 0; i < n; i++) {
		free(p);
		p = aux;
		aux = aux->anterior;
	}
}
*/

int devolveValor(Pilha *p) {
	if (p == NULL){
		return 0;
	}

	return p->valor;
}

Pilha* desempilha(Pilha *p) {

	Pilha* aux = p->anterior;
	free(p);

	return aux;
}