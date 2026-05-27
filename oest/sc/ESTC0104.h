#define MAX_LIGNES 50 /* Nombre maximum de lignes du fichier FFAMCHG2 pour */
                      /* contrat/avenant/exercice/numero d'ordre/section fixe */

typedef struct LIGNESSECTION { /* Chaque structure contient des champs d'une */
                               /* ligne du fichier FFAMCHG2 pour la premiere */
                               /* section du CAEX en cours */
   short RATTYP_B;  /* Type de ratio */
   double MAX_R;    /* Taux de commission max */
   double MINRAT_R; /* Ratio minimum */
   double MIN_R;    /* Taux de commission mini */
   double MAXRAT_R; /* Ratio maximum */
} T_LIGNESSECTION;

typedef struct SECTION { /* Contient des champs de la premiere section du */
                         /* perimetre pour le CAEX en cours */
   short PRFCOMEXI_B;
   short LOSCTBEXI_B;
   short CTBTYP_CT;
   double PRFCOM_R;
   double LOSCTB_R;
   double CTBGENFEE_R;
   short SCLCTBEXI_B;
   short RESTRFTYP_CF;
   short RESTRFDUR_N;
} T_SECTION;
