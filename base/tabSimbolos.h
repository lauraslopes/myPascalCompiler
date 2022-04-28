#ifndef TABSIMBOLOS
#define TABSIMBOLOS

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#define MAX_IDENT 100

typedef enum Passagem {
  porValor, referencia
} Passagem;

typedef enum Categoria {
  var_simples, param_formal, procedimento, funcao
} Categoria;

typedef enum Tipo {
  boolean,
  integer,
  vazio
} Tipo;

typedef struct ParamFormal {
	Tipo tipo;
	Passagem passagem;
} ParamFormal;

typedef struct Simbolo {
	char identificador[MAX_IDENT];
	Categoria categoria;
	int nivel;
	Tipo tipo;
	int deslocamento;

	/*Procedimento e função*/
	int rotulo;
	int numParams;
	Passagem passagem;
	ParamFormal* parametros;

	struct Simbolo* anterior;
} Simbolo;

extern int nivel_lexico;

void insere(char* identificador, Categoria categoria, Passagem passagem);
void insereComRotulo(char* identificador, int rotulo, Categoria categoria);
Simbolo* busca(char* identificador);
void retira(int n);
void atualizaTipo(char* tipoStr);
void atualizaTipoFuncao(Simbolo* funcao, char* tipoFuncao);
void printTabSimbolo();
int atualizaDeslocamento();
void atualizaProcedimento(int numParams);

#endif
