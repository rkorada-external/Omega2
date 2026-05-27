/*==============================================================================
Nom de l'application          : Calcul de participation calculable (1/2)
Nom du source                 : ESTC0104.c
Revision                      : $Revision:   1.0  $
Date de creation              : 20/08/1997
Auteur                        : CGI
References des specifications : 
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre PERICASE, calcul de la participation (CTBCOM_B)
   POUR LES TRAITES SEULEMENT.
   Initialement CTBCOM_B vaut 0. Si le test reussit CTBCOM_B vaut 1 pour la
   derniere section du contrat/avenant/exercice/numero d'ordre.
   2 operations sont effectuees dans ce programme :
      - au niveau contrat/avenant/exercice/numero d'ordre pour toutes les
        sections : verification que le champ CTBCALLVL_CF vaut 3 ou 4 et que des
        champs sont egaux,
      - au niveau contrat/avenant/exercice/numero d'ordre pour toutes les
        sections verification que des champs de toutes les lignes du fichier
        FFAMCHG2 sont egales entre elles pour le meme numero de ligne.
   NB : le calcul est fait pour le dernier segment du contrat/avenant/exercice/
   numero d'ordre. L'affectation des autres sections est faite dans le programme
   ESTC0102.c.
   Le perimetre en entree est trie au niveau contrat/avenant/exercice/
   numero d'ordre/section
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "ESTC0104.h"


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 	      *Kp_OutputFile; /* Pointeur sur le fichier de sortie */
T_RUPTURE_VAR *pbd_Rupture;   /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_Sync; /* Pointeur sur la structure de synchronisation */

char Ksz_MessageErr[256]; /* Message d'erreur */
short Ks_CTBCOM_B;      /* Valeur du bit CTBCOM_B, des qu'il vaut 0 l'analyse */
                        /* est stoppee */
short Ks_PremiereSection; /* Vaut 1 pour la premiere section du contrat/   */
                          /* avenant/exercice/numero d'ordre du perimetre, */
                          /* autrement 0. */

T_LIGNESSECTION Ktbd_LignesSection[MAX_LIGNES]; /* Tableau contenant les */
                          /* donnees des differents numero de ligne de la */
                          /* premiere section a comparer aux autres sections */
int Kn_NbreLignesSection; /* Nombre de lignes du tableau precedent */
short Ks_AnalyseLignesSection; /* Vaut 1 dans le cas de participation */
                               /* variable */
int Kn_CompteurLignesSection;/* Compteur utilise pour passer les differentes  */
                             /* lignes du tableau precedent                   */
T_SECTION Kbd_Section;    /* Donnees de la premiere section a comparer aux    */
                          /* sections suivantes                               */

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]); 
int n_ActionLigneRupture (char *ptsz_LigneCour[]);


/*----------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le perimetre et FFAMCHG2 */
/*----------------------------------------------------------------*/

int n_InitSync	 	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSync	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/**************************************************************************/
/*** Objet : synchronisation entre le fichier perimetre et le fichier   ***/
/***         des familles de charges iterees TFAMCHG2     		***/
/***									***/
/*** Nom : main		     						***/
/***									***/
/*** Parametres:							***/
/***	i argc : nombre de parametres					***/
/***	i argv : tableau de pointeurs sur les parametres		***/	
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int main(
   int argc,
   char *argv[]
)
{
   pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));
   pbd_Sync=malloc(sizeof(T_RUPTURE_SYNC_VAR));

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Ouverture du fichier de sortie */
   if (n_OpenFileAppl("ESTC0104_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation */
   if (n_InitSync(pbd_Sync) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTD0601_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTD0601_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTD0601_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_Sync);

   exit(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la structure de rupture			***/
/***									***/
/*** Nom : n_InitRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Rupture : pointeur sur la structure de rupture		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre ESTPERICASE */
   if (n_OpenFileAppl("ESTC0104_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation du maitre avec	***/
/***         l'esclave                                                  ***/
/***									***/
/*** Nom : n_InitSync     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

n_InitSync(
   T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave ESTCASEEST */
   if (n_OpenFileAppl("ESTC0104_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction de test de rupture				***/
/***									***/
/*** Nom : n_TestRupture     						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LineSuiv : pointeur sur la ligne suivante,		***/
/***	i ptsz_LineCour : pointeur sur la ligne precedente.		***/
/***									***/	
/*** Retour:								***/
/***	0 si pas de rupture,						***/
/***	1 si rupture.							***/
/**************************************************************************/

int n_TestRupture(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
   static short s_ret;

   DEBUT_FCT("n_TestRupture");

   if (s_ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])) {
      return s_ret;
   }

   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture premiere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionPremiereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionPremiereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionPremiereRupture");

/* Analyse des differentes sections du CAEX dans le cas de niveau de calcul */
/* de participation valant 'section' ou 'contrat' */
   if ( (atoi(ptsz_LigneCour[PER_CTBCALLVL_CF]) == 3) || (atoi(ptsz_LigneCour[PER_CTBCALLVL_CF]) == 4) ) {
      Ks_CTBCOM_B = 1; /* CTBCOM_B vaut 1 tant que les test n'ont pas echoues */

/* Sauvegarde de champs de la premiere section */
      Kbd_Section.PRFCOMEXI_B = (short)atoi(ptsz_LigneCour[PER_PRFCOMEXI_B]);
      Kbd_Section.LOSCTBEXI_B = (short)atoi(ptsz_LigneCour[PER_LOSCTBEXI_B]);
      Kbd_Section.CTBTYP_CT = (short)atoi(ptsz_LigneCour[PER_CTBTYP_CT]);
      Kbd_Section.PRFCOM_R = atof(ptsz_LigneCour[PER_PRFCOM_R]);
      Kbd_Section.LOSCTB_R = atof(ptsz_LigneCour[PER_LOSCTB_R]);
      Kbd_Section.CTBGENFEE_R = atof(ptsz_LigneCour[PER_CTBGENFEE_R]);
      Kbd_Section.SCLCTBEXI_B = (short)atoi(ptsz_LigneCour[PER_SCLCTBEXI_B]);
      Kbd_Section.RESTRFTYP_CF = (short)atoi(ptsz_LigneCour[PER_RESTRFTYP_CF]);
      Kbd_Section.RESTRFDUR_N = (short)atoi(ptsz_LigneCour[PER_RESTRFDUR_N]);

/* Analyse des differentes lignes du fichier FFAMCHG2 dans le cas de */
/* participation a 'variable' */
      if (atoi(ptsz_LigneCour[PER_CTBTYP_CT]) == 2) {
         Ks_AnalyseLignesSection = 1;
         Kn_NbreLignesSection = 0; /* Initialisation du nombre de lignes du */
                                   /* fichier FFAMCHG2 par CASEX */
      }
      else {
         Ks_AnalyseLignesSection = 0;
      }
   }

/* Autrement aucune analyse n'est faite et la ligne du perimetre est */
/* integralement reportee en sortie */
   else {
      Ks_CTBCOM_B = 0;
   }

/* Rupture premiere sur section */
   Ks_PremiereSection = 1;

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du fichier maitre	***/
/***									***/
/*** Nom : n_ActionLigneRupture						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneRupture(char *ptsz_LigneCour[])
{
   static char sz_CTBCOM_B[2]; /* Chaine contenant la valeur de CTBCOM_B */

   DEBUT_FCT("n_ActionLigneRupture");

/* Analyse si CTBCOM_B vaut 1 */
   if (Ks_CTBCOM_B == 1) {

/* Comparaison de champs de la section avec les champs suavegardes de la */
/* premiere section */
      if (Ks_PremiereSection == 0) {
         if ( (Kbd_Section.PRFCOMEXI_B != (short)atoi(ptsz_LigneCour[PER_PRFCOMEXI_B]))
              || (Kbd_Section.LOSCTBEXI_B != (short)atoi(ptsz_LigneCour[PER_LOSCTBEXI_B]))
              || (Kbd_Section.CTBTYP_CT != (short)atoi(ptsz_LigneCour[PER_CTBTYP_CT]))
              || (Kbd_Section.PRFCOM_R != atof(ptsz_LigneCour[PER_PRFCOM_R]))
              || (Kbd_Section.LOSCTB_R != atof(ptsz_LigneCour[PER_LOSCTB_R]))
              || (Kbd_Section.CTBGENFEE_R != atof(ptsz_LigneCour[PER_CTBGENFEE_R]))
              || (Kbd_Section.SCLCTBEXI_B != (short)atoi(ptsz_LigneCour[PER_SCLCTBEXI_B]))
              || (Kbd_Section.RESTRFTYP_CF != (short)atoi(ptsz_LigneCour[PER_RESTRFTYP_CF]))
              || (Kbd_Section.RESTRFDUR_N != (short)atoi(ptsz_LigneCour[PER_RESTRFDUR_N]))
              || (atoi(ptsz_LigneCour[PER_CTBCALLVL_CF]) < 3)
              || (atoi(ptsz_LigneCour[PER_CTBCALLVL_CF]) > 4)
            ) {
            Ks_CTBCOM_B = 0;
         }
      }

/* Analyse des lignes de FFAMCHG2 si Ks_AnalyseLignesSection */
      if ( (Ks_CTBCOM_B) && (Ks_AnalyseLignesSection) ) {

/* Synchronisation du fichier esclave pour chaque ligne */
         Kn_CompteurLignesSection = 0; /* Initialisation du compteur de lignes */
                                    /* du fichier FFAMCHG2 par CASEX */
         n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);
     }

/* Cas non rupture derniere sur section : ecriture de la ligne */
      if (b_IsRupture(pbd_Rupture, L1) == FALSE) {
         n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
      }      

/* Cas rupture derniere sur section : ecriture de la ligne avec la valeur de */
/* CTBCOM_B */
      else { /* En rupture derniere ecriture du champ */
         sprintf(sz_CTBCOM_B, "%d", Ks_CTBCOM_B);

/* Pour debuggage */

/*       printf("CTBCOM : %d\n", Ks_CTBCOM_B);
         printf("CTR %s, END %s, SEC %s, UWY %s, UW %s, Nombre lignes %d\n",
                ptsz_LigneCour[PER_CTR_NF],
                ptsz_LigneCour[PER_END_NT],
                ptsz_LigneCour[PER_SEC_NF],
                ptsz_LigneCour[PER_UWY_NF],
                ptsz_LigneCour[PER_UW_NT],
                Kn_NbreLignesSection
         ); */


         ptsz_LigneCour[PER_CTBCOM_B] = sz_CTBCOM_B;
         n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
      }
   }

/* Pas d'analyse si CTBCOM_B vaut 0 : ecriture de la ligne courante */
   else { 
      n_WriteCols(Kp_OutputFile, ptsz_LigneCour, '~', 0);
   }

/* Fin rupture premiere sur section */
   Ks_PremiereSection = 0;

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation maitre esclave				***/
/***									***/
/*** Nom : n_ConditionSync						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave	***/
/***									***/	
/*** Retour:								***/
/***	0 si synchronise,						***/
/***	<0 si la ligne esclave est depassee,				***/
/***    >0 si la ligne esclave n'est pas depassee.			***/
/**************************************************************************/

int n_ConditionSync(
   char *ptsz_LigneMaitre[], 
   char *ptsz_LigneEsclave[] 
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSync");

   if (s_ret = strcmp(ptsz_LigneMaitre[PER_CTR_NF], ptsz_LigneEsclave[CHG2_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[PER_END_NT], ptsz_LigneEsclave[CHG2_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[PER_UWY_NF], ptsz_LigneEsclave[CHG2_UWY_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[PER_UW_NT], ptsz_LigneEsclave[CHG2_UW_NT])) {
      return s_ret;
   }

   RETURN_VAL(strcmp(ptsz_LigneMaitre[PER_SEC_NF], ptsz_LigneEsclave[CHG2_SEC_NF]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne de l'esclave		***/
/***									***/
/*** Nom : n_ActionLigneSync						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSync(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{	
   DEBUT_FCT("n_ActionLigneSync");

   if (Ks_CTBCOM_B) {
      if (Ks_PremiereSection == 1) {
         if (Kn_NbreLignesSection == MAX_LIGNES) {
            sprintf(Ksz_MessageErr, "CTR %s, END %s, SEC %s, UWY %s, UW %s : maximum number of lines in FFAMCHG2 file is reached ; increase MAX_LIGNES value",
                    ptsz_LigneMaitre[PER_CTR_NF],
                    ptsz_LigneMaitre[PER_END_NT],
                    ptsz_LigneMaitre[PER_SEC_NF],
                    ptsz_LigneMaitre[PER_UWY_NF],
                    ptsz_LigneMaitre[PER_UW_NT]
            );
            n_WriteLog('E', Ksz_MessageErr);
         }
         else {
            Ktbd_LignesSection[Kn_NbreLignesSection].RATTYP_B = (short)atoi(ptsz_LigneEsclave[CHG2_RATTYP_B]);
            Ktbd_LignesSection[Kn_NbreLignesSection].MAX_R = atof(ptsz_LigneEsclave[CHG2_MAX_R]);
            Ktbd_LignesSection[Kn_NbreLignesSection].MINRAT_R = atof(ptsz_LigneEsclave[CHG2_MINRAT_R]);
            Ktbd_LignesSection[Kn_NbreLignesSection].MIN_R = atof(ptsz_LigneEsclave[CHG2_MIN_R]);
            Ktbd_LignesSection[Kn_NbreLignesSection].MAXRAT_R = atof(ptsz_LigneEsclave[CHG2_MAXRAT_R]);
            Kn_NbreLignesSection++;
         }
      }
      else {
         if (Kn_CompteurLignesSection > Kn_NbreLignesSection) {
            Ks_CTBCOM_B = 0;
         }
         else {
            if ( (Ktbd_LignesSection[Kn_CompteurLignesSection].RATTYP_B  != (short)atoi(ptsz_LigneEsclave[CHG2_RATTYP_B]))
                 || (Ktbd_LignesSection[Kn_CompteurLignesSection].MAX_R != atof(ptsz_LigneEsclave[CHG2_MAX_R]))
                 || (Ktbd_LignesSection[Kn_CompteurLignesSection].MINRAT_R != atof(ptsz_LigneEsclave[CHG2_MINRAT_R]))
                 || (Ktbd_LignesSection[Kn_CompteurLignesSection].MIN_R !=  atof(ptsz_LigneEsclave[CHG2_MIN_R]))
                 || (Ktbd_LignesSection[Kn_CompteurLignesSection].MAXRAT_R != atof(ptsz_LigneEsclave[CHG2_MAXRAT_R]))
            ) {
               Ks_CTBCOM_B = 0;
            }
            Kn_CompteurLignesSection++;
         }
      }
   }
   RETURN_VAL(OK);
}
