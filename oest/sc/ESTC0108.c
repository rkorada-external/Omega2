/*==============================================================================
Nom de l'application          : Perimetre au niveau CASEX et CAS
Nom du source                 : ESTC0108.c
Revision                      : $Revision: 1.2 $
Date de creation              : 09/09/1998
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   Dans le fichier perimetre, mise a jour des champs qui n'ont pu l'etre lors
   de leur descente en ensembliste et sortie des perimetres au niveau CASEX et
   CAS en dommage et vie. Pour la segmentation deux perimetres dommage au niveau
   CASEX et CAS sont generes.
   Le perimetre est trie au niveau contrat/avenant/section/exercice/
   numero d'ordre
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    02/10/2003     J Ribot  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3"
    21/10/2003     J Ribot  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3" pour filiale 4
    14/11/2003     j Ribot  affectation CNATYP_CT  sur filiale = 14
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
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

T_RUPTURE_VAR *pbd_Rupture;     /* Pointeur sur la structure de la rupture */

char Ksz_INC_D[9]; /* Date d'effet du premier exercice et du premier numero */
                   /* d'ordre */


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

/* Ouverture du fichier de sortie dommage au niveau CASEX */
   if (n_OpenFileAppl("ESTC0108_O1", "wt", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDomCASEX");
   }

/* Ouverture du fichier de sortie dommage au niveau CAS */
   if (n_OpenFileAppl("ESTC0108_O2", "wt", &Kp_OutputFileDomCAS) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileApplDomCAS");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTC0108_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0108_O1", &Kp_OutputFileDomCASEX) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTC0108_O2", &Kp_OutputFileDomCAS) == ERR) {
         ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
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

int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre ESTPERICASE */
   if (n_OpenFileAppl("ESTC0108_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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
   static char sz_Valeur3[] = "3"; /* Chaine de valeur 3 */
 	 static char sz_Valeur4[] = "4"; /* Chaine de valeur 4 */
   static char sz_Valeur12[] = "12"; /* Chaine de valeur 12 */
   static char sz_Valeur10[] = "1.0"; /* Chaine de valeur 1.0 */

   DEBUT_FCT("n_ActionLigneRupture");

/*****************************************************************/
/*****************************************************************/
/**  ATTENTION - toutes modifs ou evol concernant la mise 	**/
/**  a jour des champs du perimetre doivent etre repercutees 	**/
/**  dans le programme ESTC0103.c du job ESEJ0001.cmd. Le prog	**/
/**  ESTC0103.c met a jour les memes champs pour le perimetre	**/
/**  IADPERICASE descendu quotidiennement			**/
/*****************************************************************/
/*****************************************************************/

   if (*ptsz_LigneCour[PER_CTRNAT_CT] == 'N') {

/* Affectation du champ CTRNAT_CT */
      if (strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0) {
         *ptsz_LigneCour[PER_CTRNAT_CT] = 'P';
      }

/* Affectation du champ SBJPRM_M */
      if (*ptsz_LigneCour[PER_SBJPRM_M] == '\0' ) {
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
   if (*ptsz_LigneCour[PER_SCOEGP_M] == '\0' ) {
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

	/* AJOUT JR 02/10/2003  affectation ESTSEC_NF  hors SOREMA (liftrttyp_cf not = "B3"  */
	/*************************************************************************************/
/*if (strcmp(ptsz_LigneCour[PER_LIFTRTTYP_CF], "B3") != 0) */
/* ajout jr 21/10/2003 sur filiale = 4 */
if (strcmp(ptsz_LigneCour[PER_LIFTRTTYP_CF], "B3") != 0)
 {

   if (strcmp(ptsz_LigneCour[PER_SSD_CF], "4") == 0)
  {

   	if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur1;

    if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "30") < 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur2;

   	if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "30") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "29") > 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur3;

    if ((strcmp(ptsz_LigneCour[PER_LOB_CF], "31") == 0) && ( strcmp(ptsz_LigneCour[PER_NAT_CF], "29") > 0 ))

      		ptsz_LigneCour[PER_ESTSEC_NF] = sz_Valeur4;

   }
  }

	/* FIN AJOUT JR 02/10/2003  affectation ESTSEC_NF  hors SOREMA  */

	/* AJOUT JR 14/11/2003  affectation CNATYP_CT
/* ajout jr 14/11/2003 sur filiale = 14 */
   if (strcmp(ptsz_LigneCour[PER_SSD_CF], "14") == 0)
  {

         		ptsz_LigneCour[PER_CNATYP_CT] = sz_Valeur3;
   }


/****************************************/
/* Modifs du 30/06/98 - M.HA-THUC       */
/* Affectation particuliere de          */
/* ERNPRMADM_CT si Non prop             */
/****************************************/
   if ( *ptsz_LigneCour[PER_CTRNAT_CT] == 'N' )
   {
      if ( *ptsz_LigneCour[PER_ACCADMTYP_CT] == '2' )
	  ptsz_LigneCour[PER_ERNPRMADM_B] = sz_Valeur1 ;

      if ( *ptsz_LigneCour[PER_ACCADMTYP_CT] == '3' )
	  ptsz_LigneCour[PER_ERNPRMADM_B] = sz_Valeur0 ;
   }

/* Ecriture de la ligne dans le perimetre dommage ou vie au niveau CASEX */
   if ( (strcmp(ptsz_LigneCour[PER_LOB_CF], "30")) && (strcmp(ptsz_LigneCour[PER_LOB_CF], "31")) )
   {
      n_WriteCols(Kp_OutputFileDomCASEX, ptsz_LigneCour, '~', 0);
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
              ptsz_LigneCour[PER_UWGRP_CF] ) ;

   RETURN_VAL(OK);
}

