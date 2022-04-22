
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Funções auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include "compilador.h"


/* -------------------------------------------------------------------
 *  variáveis globais
 * ------------------------------------------------------------------- */

simbolos simbolo, relacao;
char token[TAM_TOKEN];

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando) {

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    fprintf(fp, "     %s\n", comando); fflush(fp);
  } else {
    fprintf(fp, "%s: %s \n", rot, comando); fflush(fp);
  }
}

void comparaTiposAtribuicao(int tipoEsq, int tipoDir) {
  if (tipoEsq != tipoDir) {
    imprimeErro("Expressão entre variáveis de tipos diferentes");
  }
}

Pilha* comparaTipos(Tipo tipo, Pilha* pilhaTipos) {

  int t1 = devolveValor(pilhaTipos);
  pilhaTipos = desempilha(pilhaTipos);
  int t2 = devolveValor(pilhaTipos);
  pilhaTipos = desempilha(pilhaTipos);

  if (t1 != t2) {
    imprimeErro("Expressão entre variáveis de tipos diferentes");
  }

  if (tipo == vazio){
    pilhaTipos = empilha(pilhaTipos, t1);
  } else {
    pilhaTipos = empilha(pilhaTipos, tipo);    
  }

  return pilhaTipos;
}

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}
