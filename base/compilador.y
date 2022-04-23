
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
Pilha* pilhaRotulos;
Pilha* pilhaNumVars;
Pilha* pilhaNumParams;
Categoria categoriaVar;
Passagem passagemVar;
int rotulo = 0;
int indexParam = 0;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
%token ABRE_COLCHETES FECHA_COLCHETES ABRE_CHAVES FECHA_CHAVES
%token LABEL TYPE OF GOTO ARRAY RELACAO
%token PROCEDURE FUNCTION READ WRITE
%token IF THEN ELSE WHILE DO
%token OR AND NOT DIV MAIS MENOS ASTERISCO BARRA NUMERO
%token IGUAL DIFF MENOR MENOR_IGUAL MAIOR MAIOR_IGUAL

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

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
    {
        num_vars = 0;
        desloc = 0;
    }
    parte_declara_vars
    parte_declara_subrotinas comando_composto
    {
        int nVars = devolveValor(pilhaNumVars);
        pilhaNumVars = desempilha(pilhaNumVars);
        sprintf(str, "DMEM %d", nVars);
        geraCodigo (NULL, str);
    }
;

parte_declara_subrotinas    :
    declara_procedimento
    {
        int numParams = devolveValor(pilhaNumParams);
        pilhaNumParams = desempilha(pilhaNumParams);
        sprintf(str, "RTPR %d,%d", nivel_lexico, numParams);
        geraCodigo (NULL, str);

        int r0 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "R%d: NADA", r0);
        geraCodigo (NULL, str);
        nivel_lexico--;
    } |
;

declara_procedimento    :
    PROCEDURE IDENT 
    {
        nivel_lexico++;
        sprintf(str, "DSVS R%d", rotulo); 
        pilhaRotulos = empilha(pilhaRotulos, rotulo);
        geraCodigo(NULL, str);
        sprintf(str, "R%d: ENPR %d", rotulo+1, nivel_lexico);
        insereComRotulo(token, rotulo+1, procedimento); 
        geraCodigo(NULL, str);
        rotulo+=2;
    }
    parametros_formais PONTO_E_VIRGULA bloco
;

parametros_formais    :
    ABRE_PARENTESES lista_parametros FECHA_PARENTESES
    {
        int numParams = atualizaDeslocamento();
        pilhaNumParams = empilha(pilhaNumParams, numParams);
        atualizaProcedimento(numParams);
    } |
;

lista_parametros    :
    lista_parametros PONTO_E_VIRGULA parametro |
    parametro
;

parametro    :
    VAR
    {
        categoriaVar = param_formal;
        passagemVar = referencia;
    } declara_param |
    {
        categoriaVar = param_formal;
        passagemVar = porValor;
    }
    declara_param
;

declara_param    :
    lista_id_var DOIS_PONTOS tipo

parte_declara_vars:  var
;

var    : 
    VAR 
    {
        categoriaVar = var_simples;
        passagemVar = porValor;
    }
    declara_vars
    { 
        pilhaNumVars = empilha(pilhaNumVars, num_vars);
        sprintf(str, "AMEM %d", num_vars);
        geraCodigo (NULL, str);
    }
;

declara_vars    : 
    declara_vars declara_var | 
    declara_var
;

declara_var : 
    lista_id_var DOIS_PONTOS tipo PONTO_E_VIRGULA
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
        insere(token, categoriaVar, passagemVar); num_vars++;/* insere ultima vars na tabela de simbolos */ 
    } | 
    IDENT 
    { 
        insere(token, categoriaVar, passagemVar); num_vars++; /* insere vars na tabela de simbolos */
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
    comandos comando PONTO_E_VIRGULA | 
    comando PONTO_E_VIRGULA |
    comando
;

comando    : 
    comando_sem_rotulo
;

a    :
    IDENT 
    {
        strncpy(l_elem, token, TAM_TOKEN);
    } 
    a_continua
;

a_continua    :
    atribuicao |
    chamada_procedimento
;

comando_sem_rotulo    :
    a |
    comando_composto |
    comando_repetitivo |
    comando_condicional |
    leitura |
    escrita 
;

chamada_procedimento    :
    ABRE_PARENTESES
    {
        indexParam = 0;
    } 
    lista_expr FECHA_PARENTESES
    {

        Simbolo* simbolo = busca(l_elem);
        sprintf(str, "CHPR R%d,%d", simbolo->rotulo, nivel_lexico);
        geraCodigo(NULL, str);
    } | 
    {
        Simbolo* simbolo = busca(l_elem);
        sprintf(str, "CHPR R%d,%d", simbolo->rotulo, nivel_lexico);
        geraCodigo(NULL, str);
    } 
;

leitura    :
    READ ABRE_PARENTESES leitura_identificadores FECHA_PARENTESES
; 

leitura_identificadores    :
    leitura_identificadores VIRGULA IDENT
    {
        geraCodigo(NULL, "LEIT");
        Simbolo* simbolo = busca(token);
        sprintf(str, "ARMZ %d,%d", simbolo->nivel, simbolo->deslocamento);
        geraCodigo(NULL, str);
    } |
    IDENT 
    {
        geraCodigo(NULL, "LEIT");
        Simbolo* simbolo = busca(token);
        sprintf(str, "ARMZ %d,%d", simbolo->nivel, simbolo->deslocamento);
        geraCodigo(NULL, str);
    }
;

escrita    :
    WRITE ABRE_PARENTESES escrita_identificadores FECHA_PARENTESES
; 

escrita_identificadores    :
    escrita_identificadores VIRGULA expr
    {
        geraCodigo(NULL, "IMPR");
    } |
    expr 
    {
        geraCodigo(NULL, "IMPR");
    }
;


comando_repetitivo    : 
    WHILE 
    {
        sprintf(str, "R%d: NADA", rotulo);

        pilhaRotulos = empilha(pilhaRotulos, rotulo);
        pilhaRotulos = empilha(pilhaRotulos, rotulo+1);
        rotulo+=2;
        geraCodigo(NULL, str);
    } 
    ABRE_PARENTESES expr FECHA_PARENTESES
    {
        int r1 = devolveValor(pilhaRotulos);
        sprintf(str, "DSVF R%d", r1);
        geraCodigo(NULL, str);
    } 
    DO comando_sem_rotulo 
    {
        int r1 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        int r0 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "DSVS R%d", r0); 
        geraCodigo(NULL, str);
        sprintf(str, "R%d: NADA", r1); 
        geraCodigo(NULL, str);
    }
;

comando_condicional    : 
    IF expr 
    {
        sprintf(str, "DSVF R%d", rotulo+1);
        geraCodigo(NULL, str);

        pilhaRotulos = empilha(pilhaRotulos, rotulo); 
        pilhaRotulos = empilha(pilhaRotulos, rotulo+1);
        pilhaRotulos = empilha(pilhaRotulos, rotulo);
        rotulo+=2; 
    }
    THEN comando_sem_rotulo cond_else
;

cond_else    :
    {
        int r0 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "DSVS R%d", r0); 
        geraCodigo(NULL, str);
    } 
    ELSE 
    {
        int r1 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "R%d: NADA", r1); 
        geraCodigo(NULL, str);
    }
    comando_sem_rotulo
    {
        int r0 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "R%d: NADA", r0); 
        geraCodigo(NULL, str);
    } |
    %prec LOWER_THAN_ELSE
    {
        pilhaRotulos = desempilha(pilhaRotulos);
        int r1 = devolveValor(pilhaRotulos);
        pilhaRotulos = desempilha(pilhaRotulos);
        sprintf(str, "R%d: NADA", r1);
        geraCodigo(NULL, str);
        pilhaRotulos = desempilha(pilhaRotulos);
    }
;

atribuicao    : 
    ATRIBUICAO expr
    {
        Simbolo* simbolo = busca(l_elem);
        if (simbolo->passagem == porValor) {
            sprintf(str, "ARMZ %d,%d", simbolo->nivel, simbolo->deslocamento);
        } else {
            sprintf(str, "ARMI %d,%d", simbolo->nivel, simbolo->deslocamento);
        }

        int t1 = devolveValor(pilhaTipos);
        pilhaTipos = desempilha(pilhaTipos);
        comparaTiposAtribuicao(t1, simbolo->tipo);

        geraCodigo(NULL, str);
    }
;

lista_expr    :
    lista_expr VIRGULA expr
    {
        indexParam++;
    } |
    expr
    {
        indexParam++;
    }
;

expr    : 
    expr MAIS termo 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
        geraCodigo(NULL, "SOMA");
    } |
    expr MENOS termo 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
        geraCodigo(NULL, "SUBT");
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
        geraCodigo(NULL, "MULT");
    } |
    termo DIV fator 
    {
        pilhaTipos = comparaTipos(vazio, pilhaTipos);
        geraCodigo(NULL, "DIVI");
    } |
    fator
;

fator    : 
    IDENT 
    {
        Simbolo* simbolo = busca(token);
        if (simbolo->passagem == referencia) {
            sprintf(str, "CRVI %d,%d", simbolo->nivel, simbolo->deslocamento);
        } else {
            sprintf(str, "CRVL %d,%d", simbolo->nivel, simbolo->deslocamento);
        }

        if (strcmp(l_elem, "") != 0) {
            Simbolo* proc = busca(l_elem);
            if ((proc->categoria == procedimento) && (proc->numParams > 0) && (indexParam < proc->numParams)) {
                printf("INDEX %d, PROCEDIMENTO %s, PASSAGEM PROC %d, PASSAGEM SIMB %d\n", indexParam, proc->identificador, proc->parametros[indexParam].passagem,simbolo->passagem);
                if (proc->parametros[indexParam].passagem == referencia) {
                    if (simbolo->passagem == referencia) {
                        sprintf(str, "CRVL %d,%d", simbolo->nivel, simbolo->deslocamento);
                    } else {
                        sprintf(str, "CREN %d,%d", simbolo->nivel, simbolo->deslocamento);
                    }
                }
            }
        }
        
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
