#include "tabSimbolos.h"

Simbolo* topo;
int nivel_lexico;
int desloc;

void printSimbolo(Simbolo* simbolo) {
	printf("%s ", simbolo->identificador);
	printf("%d ", simbolo->tipo);
	printf("%d ", simbolo->nivel);
	printf("%d\n", simbolo->deslocamento);
}

void printTabSimbolo() {
	Simbolo* atual = topo;
	while (atual != NULL) {
		printSimbolo(atual);
		atual = atual->anterior;
	}
}

void insere(char* identificador, Categoria categoria, Passagem passagem) {

	Simbolo* simbolo = malloc(sizeof(Simbolo));
	strncpy(simbolo->identificador, identificador, MAX_IDENT);
	simbolo->categoria = categoria;
	simbolo->nivel = nivel_lexico;
	simbolo->tipo = vazio;

	if (categoria == var_simples) {
		simbolo->deslocamento = desloc;
		desloc++;
	} else {
		simbolo->deslocamento = -1;
		simbolo->passagem = passagem;
	}

	if (topo != NULL) {
		simbolo->anterior = topo;
	}

	topo = simbolo;
}

void insereComRotulo(char* identificador, int rotulo, Categoria categoria) {

	Simbolo* simbolo = malloc(sizeof(Simbolo));
	strncpy(simbolo->identificador, identificador, MAX_IDENT);
	simbolo->categoria = categoria;
	simbolo->nivel = nivel_lexico;
	simbolo->rotulo = rotulo;
	simbolo->numParams = 0;
	simbolo->deslocamento = -2;

	if (topo != NULL) {
		simbolo->anterior = topo;
	}

	topo = simbolo;
}

Simbolo* busca(char* identificador) {

	Simbolo* atual = topo;
	while (atual != NULL) {
		if (strcmp(atual->identificador, identificador) == 0) {
			return atual;
		}

		atual = atual->anterior;
	}

	imprimeErro("Variável não declarada.");
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

void atualizaTipo(char* tipoStr) {

	if (strcmp(tipoStr, "integer") != 0) {
		imprimeErro("Tipo inválido");
	}

	Simbolo* aux = topo;
	while ((aux != NULL) && (aux->tipo == vazio)) {
		aux->tipo = integer;
		aux = aux->anterior;
	}
}

int atualizaDeslocamento() {

	int numParams = 0;
	int deslocamento = -4;
	Simbolo* aux = topo;
	while ((aux != NULL) && (aux->deslocamento == -1)) {
		aux->deslocamento = deslocamento;
		deslocamento--;
		numParams++;
		aux = aux->anterior;
	}

	return numParams;
}

void atualizaProcedimento(int numParams) {

	ParamFormal* parametros = malloc(numParams*sizeof(ParamFormal));
	Simbolo* aux = topo;
	for (int i = 0; i < numParams; i++) {
		parametros[i].tipo = aux->tipo;
		parametros[i].passagem = aux->passagem;
		aux = aux->anterior;
	}

	aux->numParams = numParams;
	aux->parametros = parametros;
}
