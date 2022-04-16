
%{
#include <stdio.h>
%}

%token IDENTA IDENTB MAIS MENOS OR ASTERISCO DIV ABRE_PARENTESES FECHA_PARENTESES AND

%%

expr       : expr MAIS termoInt {printf ("+"); } |
             expr MENOS termoInt {printf ("-"); } |
             termoInt |
             termoBool
;

termoInt      : termoInt ASTERISCO fatorInt  {printf ("*"); }| 
             termoInt DIV fatorInt  {printf ("/"); }| 
             fatorInt
;

termoBool      : termoBool AND fatorBool  {printf ("and"); }| 
             termoBool OR fatorBool  {printf ("or"); }| 
             fatorBool
;

fatorInt      : IDENTA {printf ("A"); }
;

fatorBool      : IDENTB {printf("B");}
;

%%

void yyerror(char *s) {
   fprintf(stderr, "%s\n", s);
   return;
}

main (int argc, char** argv) {
   yyparse();
   printf("\n");
}

