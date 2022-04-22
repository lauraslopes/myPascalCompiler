
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"

int num_vars;
char l_elem[MAX_IDENT];
char str[MAX_IDENT];
Pilha* pilhaTipos;
int rotulo = 0;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token ABRE_COLCHETES FECHA_COLCHETES ABRE_CHAVES FECHA_CHAVES
%token LABEL TYPE OF GOTO ARRAY RELACAO
%token PROCEDURE FUNCTION
%token IF THEN ELSE WHILE DO
%token OR AND NOT DIV MAIS MENOS ASTERISCO BARRA NUMERO
%token IGUAL DIFF MENOR MENOR_IGUAL MAIOR MAIOR_IGUAL

%%

programa    :
    {
        geraCodigo (NULL, "INPP");
    }
    PROGRAM IDENT lista_identificadores PONTO_E_VIRGULA bloco PONTO
    {
        geraCodigo (NULL, "PARA");
    }
;

lista_identificadores    :
     ABRE_PARENTESES lista_idents FECHA_PARENTESES |
;

bloco    :
    parte_declara_vars
    {
        num_vars = 0;
    }
    comando_composto
;

parte_declara_vars:  var
;


var    : 
    { } VAR declara_vars |
;

declara_vars    : 
    declara_vars declara_var | 
    declara_var
;

declara_var : 
    { } lista_id_var DOIS_PONTOS tipo
    { 
        sprintf(str, "AMEM %d", num_vars);
        geraCodigo (NULL, str);
        num_vars = 0;
    }
    PONTO_E_VIRGULA
;

tipo    : 
    IDENT 
    {
        atualizaTipo(token);
    }
;

lista_id_var    : 
    lista_id_var VIRGULA IDENT
    {
        insere(token, var_simples); num_vars++;/* insere ultima vars na tabela de simbolos */ 
    } | 
    IDENT 
    { 
        insere(token, var_simples); num_vars++; /* insere vars na tabela de simbolos */
    }
;

lista_idents    : 
    lista_idents VIRGULA IDENT |
    IDENT
;

comando_composto    : 
    T_BEGIN comandos T_END |
    T_BEGIN comandos T_END PONTO_E_VIRGULA
;

comandos    : 
    comandos comando | 
    comando
;

comando    : 
    comando_sem_rotulo
;

comando_sem_rotulo    :
    atribuicao |
    comando_composto |
    comando_repetitivo
;

comando_repetitivo    : 
    WHILE 
    {
        sprintf(str, "R%d: NADA", rotulo);
        rotulo++;
        geraCodigo(NULL, str);
    } 
    ABRE_PARENTESES expr FECHA_PARENTESES
    {
        sprintf(str, "DSVF R%d", rotulo);
        geraCodigo(NULL, str);
    } 
    DO comando_composto 
    {
        sprintf(str, "DSVS R%d", rotulo-1); 
        geraCodigo(NULL, str);
        sprintf(str, "R%d: NADA", rotulo); 
        geraCodigo(NULL, str);
    }
;

atribuicao    : 
    IDENT 
    {
        strncpy(l_elem, token, TAM_TOKEN);
    } 
    ATRIBUICAO expr PONTO_E_VIRGULA 
    {
        Simbolo* simbolo = busca(l_elem);
        sprintf(str, "ARMZ %d,%d", nivel_lexico, simbolo->deslocamento);

        int t1 = devolveValor(pilhaTipos);
        pilhaTipos = desempilha(pilhaTipos);
        comparaTiposAtribuicao(t1, simbolo->tipo);

        geraCodigo(NULL, str);
    }
;

expr    : 
    expr MAIS termo 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
    } |
    expr MENOS termo 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
    } |
    expr relacao 
    {
        pilhaTipos = comparaTipos(boolean, pilhaTipos);
    } |
    termo
;

termo    : 
    termo ASTERISCO fator 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
    } |
    termo DIV fator 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
    } |
    fator
;

fator    : 
    IDENT 
    {
        Simbolo* simbolo = busca(token);
        sprintf(str, "CRVL %d,%d", nivel_lexico, simbolo->deslocamento);
        pilhaTipos = empilha(pilhaTipos, simbolo->tipo);
        geraCodigo(NULL, str);
    } | 
    NUMERO
    {
        sprintf(str, "CRCT %s", token);
        geraCodigo(NULL, str);
        pilhaTipos = empilha(pilhaTipos, integer);
    } |
    ABRE_PARENTESES expr FECHA_PARENTESES
;

relacao    :
    IGUAL expr
    {
        geraCodigo(NULL, "CMIG");
    } | 
    DIFF expr
    {
        geraCodigo(NULL, "CMDG");
    } | 
    MENOR expr
    {
        geraCodigo(NULL, "CMME");
    } | 
    MENOR_IGUAL expr
    {
        geraCodigo(NULL, "CMEG");
    } | 
    MAIOR expr
    {
        geraCodigo(NULL, "CMMA");
    } | 
    MAIOR_IGUAL expr
    {
        geraCodigo(NULL, "CMAG");
    }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
    return;
}

int main (int argc, char** argv) {
    FILE* fp;
    extern FILE* yyin;

    if (argc<2 || argc>2) {
        printf("usage compilador <arq>a %d\n", argc);
        return(-1);
    }

    fp=fopen (argv[1], "r");
    if (fp == NULL) {
        printf("usage compilador <arq>b\n");
        return(-1);
    }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de S�mbolos
 * ------------------------------------------------------------------- */

    yyin=fp;
    yyparse();
    printTabSimbolo();

    return 0;
}
