#ifndef TABSIMBOLOS
#define TABSIMBOLOS

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_IDENT 100

typedef enum Categoria {
  var_simples, param_formal, procedimento
} Categoria;

typedef enum Tipo {
  boolean,
  integer,
  vazio
} Tipo;

typedef struct Simbolo {
	char identificador[MAX_IDENT];
	Categoria categoria;
	int nivel;
	Tipo tipo;
	int deslocamento;

	/*Procedimento e função*/
	int rotulo;
	int numParams;

	struct Simbolo* anterior;
} Simbolo;

extern int nivel_lexico;

void insere(char* identificador, Categoria categoria);
void insereComRotulo(char* identificador, int rotulo, int numParams, Categoria categoria);
Simbolo* busca(char* identificador);
void retira(int n);
void atualizaTipo(char* tipoStr);
void printTabSimbolo();

#endif
