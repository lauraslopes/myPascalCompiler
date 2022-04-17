#ifndef TABSIMBOLOS
#define TABSIMBOLOS

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "compilador.h"

typedef enum Categoria {
  var_simples, param_formal, procedimento
} Categoria;

typedef enum Tipo {
  integer,
  vazio
} Tipo;

typedef struct Simbolo {
	char identificador[MAX_IDENT];
	Categoria categoria;
	int nivel;
	Tipo tipo;
	int deslocamento;
	
	struct Simbolo* anterior;
} Simbolo;

extern int nivel_lexico;

void insere(char* identificador, Categoria categoria);
Simbolo* busca(char* identificador);
void retira(int n);
void atualizaTipo(char* tipoStr);

#endif
