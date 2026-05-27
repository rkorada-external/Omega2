/*==============================================================================
Historique des modifications :
   <jj/mm/aaaa><auteur> <description de la modification>
[02]  28/09/2015  Florent :spot:29481 - Ajout  montants de sinistres RPCC dans le calcul du blanchiment pour les IBNR1A
[03]  13/06/2019  L. DOAN :spira:76241 - ANNULATION IBNR DE BLANCHIEMENT
[04]  07/10/2020  R. cassis :spira:86503  ajout colonnes SEG_NF, UWY_NF et Taux de conversion a devise du segment dans T_CASEX
[05]  27/04/2021  R. cassis :spira:92617  ajout colonnes AMORAT_CT pour connbaitre le type de montant dans fichiers de type segment
==============================================================================*/

#define NB_REC_MAX 50

typedef struct SEG { /* Vecteur fournissant les donnees du segment/exercice */
   char SEG_NF[11]; /* Numero de segment */
   short UWY_NF;    /* Exercice */
   char EGPCUR_CF[4]; /* Devise du segment */
   double Pa;       /* Prime actuarielle pure */
   double PA;       /* Prime acquise comptabilisee */
   double PAa;      /* Prime acquise actuarielle */
   double Ps;       /* Prime ultime de souscription */
   double Ss;       /* Sinistralite de souscription */
   double Sc;       /* Sinistralite comptabilisee */
   double Sa;       /* Sinistrailite actuarielle */
   char AMORAT_CT;  /* Type de montant (R=Taux/S=Montant) [05] */
   } T_SEG;

typedef struct EXER { /* Tableau fournissant les repartitions par exercice de 
                         survenance */
   short  EXER_NF;  /* Exercice de survenance */
   double SPIRAT_R; /* Pourcentage de repartition */
   double Sc;       /* Sinistres comptabilises */
   double IBNR;     /* IBNR par exercice de survenance */
   double PIBNR;    /* Pourcentage de repartition IBNR par exercice de 
                       survenance*/
   } T_EXER;

typedef struct CASEX { /* Tableau fournissant les donnees des contrats/avenants
                          sections/numero d'ordre de l'exercice */
   char   CTR_NF[10]; /* Contrat */
   short  END_NT;    /* Avenant */
   short  SEC_NF;    /* Section */
   short  UW_NT;     /* Numero d'ordre */
   char EGPCUR_CF[4]; /* Devise d'aliment */
   char   ModeGestion; /* Mode de gestion */
   short  TypeComptable; /* Type de comptable */ // [03]
   short  Nature;	/*Type Nature 40 ou 41 venant de contrat Non Proportionnel*/		
   double Pa;  /* Prime actuarielle pure */
   double PA;  /* Prime acquise comptabilisee */
   double PAa; /* Prime acquise actuarielle */
   double Ps;  /* Prime ultime de souscription */
   double Ss;  /* Sinistralite de souscription */
   double Sci; /* Sinistralite comptabilisee sur comptes incomplets */
   double Scc; /* Sinistralite comptabilisee sur SP comptes complets */
   double Scca; /* Sinistralite comptabilisee sur SAP comptes complets */
   double Sa;  /* Sinistralite actuarielle */
   double CALAMTPRM_M; /* Utilise pour l'ecriture en sortie en ctrl des est. et actuariat */
   double ENTAMTPRM_M; /* Utilise pour l'ecriture en sortie en ctrl des est. */
   char ADMMODPRM_CT;  /* Utilise pour l'ecriture en sortie en ctrl des est. */
   double CALAMTCLM_M; /* Utilise pour l'ecriture en sortie en ctrl des est. */
   double ENTAMTCLM_M; /* Utilise pour l'ecriture en sortie en ctrl des est. */
   double Scirpcci_M;
   double Sccarpcci_M;
   double IncurredPos; /* Incurred Position*/	
   char   SEG_NF[11]; /* Numero de segment */
   short  UWY_NF;    /* Exercice */
   double Taux;      /* Sauvegarde du Taux de conversion a la devise segment */
   char   AMORAT_CT; /* Type de montant (R=Taux/S=Montant) [05] */
   } T_CASEX; 

typedef struct IBNR { /* Tableau retournant les IBNR */
   char   CTR_NF[10]; /* Contrat */
   short  END_NT;    /* Avenant */
   short  SEC_NF;    /* Section */
   short  UW_NT;     /* Numero d'ordre */
   short  EXER_NF;   /* Exercice de survenance */
   double IBNR;      /* IBNR */
   } T_IBNR;
 
