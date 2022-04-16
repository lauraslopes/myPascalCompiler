#include "tabSimbolos.h"

Simbolo* topo;
int nivel_lexico;
int desloc;

void printSimbolo(Simbolo* simbolo) {
	printf("%s ", simbolo->identificador);
	printf("%d ", simbolo->nivel);
	printf("%d\n", simbolo->deslocamento);
}

void printTabSimbolo(Simbolo* simbolo) {
	Simbolo* atual = topo;
	while (atual != NULL) {
		printSimbolo(atual);
		atual = atual->anterior;
	}
}

void insere(char* identificador, Categoria categoria) {

	Simbolo* simbolo = malloc(sizeof(Simbolo));
	strncpy(simbolo->identificador, identificador, MAX_IDENT);
	simbolo->categoria = categoria;
	simbolo->nivel = nivel_lexico;
	simbolo->tipo = vazio;
	simbolo->deslocamento = desloc;

	if (topo != NULL) {
		simbolo->anterior = topo;
	}

	topo = simbolo;
	desloc++;
}

Simbolo* busca(char* identificador) {

	Simbolo* atual = topo;
	while (atual != NULL) {
		if (strcmp(atual->identificador, identificador)) {
			return atual;
		}

		atual = atual->anterior;
	}

	return NULL;
}

void retira(int n) {

	Simbolo* aux = topo->anterior;
	for (int i = 0; i < n; i++) {
		free(topo);
		topo = aux;
		aux = aux->anterior;
	}
}

void atualizaTipo(Tipo tipo) {
	Simbolo* aux = topo;
	while ((aux != NULL) && (aux->tipo == vazio)) {
		aux->tipo = tipo;
		aux = aux->anterior;
	}
}
