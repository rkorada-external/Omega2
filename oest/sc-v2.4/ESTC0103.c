/*==============================================================================
Nom de l'application          : Perimetre au niveau CASEX et CAS
Nom du source                 : ESTC0103.c
Revision                      : $Revision:   1.0  $
Date de creation              : 19/08/1997
Auteur                        : CGI
References des specifications : 
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre, mise a jour des champs qui n'ont pu l'etre lors
   de leur descente en ensembliste et sortie des perimetres au niveau CASEX et
   CAS en dommage et vie. Pour la segmentation un perimetre dommage au niveau
   CASEX et CAS est genere, pour l'inventaire un perimetre dommage et vie est
   genere au niveau CASEX.
   Le perimetre est trie au niveau contrat/avenant/section/exercice/
   numero d'ordre
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


/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE 	   *Kp_OutputFileDomCASEX; /* Pointeur sur le perimetre dommage au */
                                   /* niveau CASEX */
FILE 	   *Kp_OutputFileDomCAS;   /* Pointeur sur le perimetre dommage au */
                                   /* niveau CAS */
FILE 	   *Kp_OutputFileVieCASEX; /* Pointeur sur le perimetre vie au */
                                   /* niveau CASEX */
T_RUPTURE_VAR *pbd_Rupture;     /* Pointeur sur la structure de la rupture */

char Ksz_INC_D[9]; /* Date d'effet du premier exercice et du premier numero */
                   /* d'ordre */
char Kc_OPTION; /* Parametre passe au programme : vaut 'S' pour la */
                /* segmentation, 'I' pour l'inventaire */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture          (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture          (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]); 
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]); 


/**************************************************************************/
/*** Objet : rupture sur le fichier perimetre				***/
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

/* Initialisation des signaux */
   InitSig();

   if (n_BeginPgm(argc, argv) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
   }

/* Recuperation du parametre */
   Kc_OPTION = *(psz_GetCharArgv(1)); 
   

/* Ouverture du fichier de sortie dommage au niveau CASEX */
   if (n_OpenFileAppl("ESTC0103_O1", "wt", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDomCASEX");
   }

/* Ouverture du fichier de sortie dommage au niveau CAS */
   if (Kc_OPTION == 'S') {
      if (n_OpenFileAppl("ESTC0103_O2", "wt", &Kp_OutputFileDomCAS) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDomCAS");
      }
   }

/* Ouverture du fichier de sortie vie au niveau CASEX */
   if (Kc_OPTION == 'I') {
      if (n_OpenFileAppl("ESTC0103_O3", "wt", &Kp_OutputFileVieCASEX) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplVieCASEX");
      }
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0103_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0103_O1", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (Kc_OPTION == 'S') {
      if (n_CloseFileAppl("ESTC0103_O2", &Kp_OutputFileDomCAS) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }
   }

   if (Kc_OPTION == 'I') {
      if (n_CloseFileAppl("ESTC0103_O3", &Kp_OutputFileVieCASEX) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
      }
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);

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
   if (n_OpenFileAppl("ESTC0103_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->n_ActionLast[0]=n_ActionDerniereRupture;
   pbd_Rupture->c_Separ= '~';

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
   static short s_Ret;

   DEBUT_FCT("n_TestRupture");

   if (s_Ret = strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])) {
      return s_Ret;
   }
   if (s_Ret = strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])) {
      return s_Ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF]));
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

/* Recuperation de la date d'effet */
   strcpy(Ksz_INC_D, ptsz_LigneCour[PER_SECINC_D]);

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
   static char sz_ValeurNull[] = ""; /* Chaine de valeur nulle */
   static char sz_Valeur0[] = "0"; /* Chaine de valeur 0 */
   static char sz_Valeur1[] = "1"; /* Chaine de valeur 1 */
   static char sz_Valeur2[] = "2"; /* Chaine de valeur 2 */
   static char sz_Valeur12[] = "12"; /* Chaine de valeur 12 */
   static char sz_Valeur10[] = "1.0"; /* Chaine de valeur 1.0 */

   DEBUT_FCT("n_ActionLigneRupture");
   if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N') {

/* Affectation du champ CTRNAT_CT */
      if (strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0) {
         *ptsz_LigneCour[PER_CTRNAT_CT] = 'P';
      }

/* Affectation du champ SBJPRM_M */
      if (*ptsz_LigneCour[PER_SBJPRM_M] == '\0') {
         ptsz_LigneCour[PER_SBJPRM_M] = ptsz_LigneCour[PER_CLECUTPER_NB];
      }
      if ( (*ptsz_LigneCour[PER_ADMMODPRM_CT] == 'A') && (atoi(ptsz_LigneCour[PER_SBJCPTDEF_B]) == 1) ) {
         ptsz_LigneCour[PER_SBJPRM_M] = ptsz_LigneCour[PER_ORICUR_B];
      }
      ptsz_LigneCour[PER_CLECUTPER_NB] = sz_ValeurNull;
      ptsz_LigneCour[PER_ORICUR_B] = sz_ValeurNull;
   }


/* Affectation du champ CTRRET_B */
   if (*ptsz_LigneCour[PER_CTRRET_B] == '\0') {
      ptsz_LigneCour[PER_CTRRET_B] = sz_Valeur0;
   }
   else {
      ptsz_LigneCour[PER_CTRRET_B] = sz_Valeur1;
   }

/* Affectation du champ EXP_D */
   if (atoi(ptsz_LigneCour[PER_SECSTS_CT]) == 19) {
      ptsz_LigneCour[PER_EXP_D] = ptsz_LigneCour[PER_RETCTRCAT_CF];
   }
   else { /* Ajout : suppression d'un jour a SCOEXP_D */
      n_AddDays(ptsz_LigneCour[PER_EXP_D], 1, '-', ptsz_LigneCour[PER_EXP_D]);
   }
   ptsz_LigneCour[PER_RETCTRCAT_CF] = sz_ValeurNull;

/* Affectation du champ SCOEGP_M */
   if (*ptsz_LigneCour[PER_SCOEGP_M] == '\0') {
      ptsz_LigneCour[PER_SCOEGP_M] = ptsz_LigneCour[PER_CLECUTPER_B];
   }
   ptsz_LigneCour[PER_CLECUTPER_B] = sz_ValeurNull;

/* Affectation du champ ESTSEC_NF */
   if (strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0) {
      ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur1;
   }
   if (strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0) {
      ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur2;
   }

/* Ecriture de la ligne dans le perimetre dommage ou vie au niveau CASEX */
   if ( (strcmp(ptsz_LigneCour[PER_LOB_CF], "30")) && (strcmp(ptsz_LigneCour[PER_LOB_CF], "31")) ) {
      n_WriteCols(Kp_OutputFileDomCASEX, ptsz_LigneCour, '~', 0);
   } 
   else {
      if (Kc_OPTION == 'I') {
         n_WriteCols(Kp_OutputFileVieCASEX, ptsz_LigneCour, '~', 0);
      }
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne en rupture derniere du 	***/
/***         fichier maitre						***/
/***									***/
/*** Nom : n_ActionDerniereRupture					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneCour : pointeur sur la ligne courante		***/
/***									***/	
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionDerniereRupture(char *ptsz_LigneCour[])
{
   DEBUT_FCT("n_ActionDerniereRupture");

   if (Kc_OPTION == 'S') {

/* Ecriture de la ligne dans le perimetre au niveau CAS */
      fprintf(Kp_OutputFileDomCAS,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
              ptsz_LigneCour[PER_CTR_NF],
              ptsz_LigneCour[PER_END_NT],
              ptsz_LigneCour[PER_SEC_NF],
              ptsz_LigneCour[PER_ANLCTY_CF],
              ptsz_LigneCour[PER_CED_NF],
              ptsz_LigneCour[PER_CLINAT_CF],
              ptsz_LigneCour[PER_CTRNAT_CT],
              ptsz_LigneCour[PER_CTRRET_B],
              ptsz_LigneCour[PER_DIV_NT],
              ptsz_LigneCour[PER_ESTCRB_CT],
              ptsz_LigneCour[PER_ESTCTR_NF],
              ptsz_LigneCour[PER_EXP_D],
              Ksz_INC_D,
              ptsz_LigneCour[PER_LIFTRTTYP_CF],
              ptsz_LigneCour[PER_LOB_CF],
              ptsz_LigneCour[PER_NAT_CF],
              ptsz_LigneCour[PER_ORDNBR_NT],
              ptsz_LigneCour[PER_PCPCUR_CF],
              ptsz_LigneCour[PER_PCPRSKTRY_CF],
              ptsz_LigneCour[PER_SECACCSTS_CT],
              ptsz_LigneCour[PER_SECSTS_CT],
              ptsz_LigneCour[PER_SEG_NF],
              ptsz_LigneCour[PER_SEGTYP_CT],
              ptsz_LigneCour[PER_SOB_CF],
              ptsz_LigneCour[PER_SSD_CF],
              ptsz_LigneCour[PER_SUBNAT_CF],
              ptsz_LigneCour[PER_TOP_CF],
              ptsz_LigneCour[PER_UWGRP_CF]
      );
   }

   RETURN_VAL(OK);
}

