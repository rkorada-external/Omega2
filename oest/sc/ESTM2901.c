/*==============================================================================
Nom de l'application          : Rejet et reconduction du bilan precedent en
                                comptabilite
Nom du source                 : ESTM2901.c
Revision                      : $Revision: 1.2 $
Date de creation              : 20/04/1998
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
   On cumule les montants des lignes du GT correspondants a la clef et aux
   postes comptables specifies. Le rejet se fait par l'ecriture du
   montant oppose, la reconduction par l'ecriture du montant (pour le 1er
   janvier de l'annee suivante du libelle d'inventaire).

   Le programme est identique au programme ESTM7602.c de la chaine des
   rejets - reconductions de l'inventaire, avec 2 fichiers en sortie
   ( un pour les rejets et un autre pour les reconductions ).

------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/

FILE	   *Kp_OutputFilRejet ;  	/* Pointeur sur le fichier de rejets */
FILE	   *Kp_OutputFilRecond ;  	/* Pointeur sur le fichier de reconductions */

T_RUPTURE_VAR *pbd_Rupture;      /* Pointeur sur la structure de la rupture */

double Kd_MontantAcc; /* Cumul des montants acceptation */
double Kd_MontantRet; /* Cumul des montants retrocession */
short Ks_Analyse;     /* Vaut 1 si le poste doit etre analyse, 0 autrement */
char Ksz_CLODAT_D[9]; /* Date de libelle d'inventaire */
short Ks_BLCSHMTH_NF; /* Mois de la periode comptable */
char Ksz_Annee[5];    /* Annee de la date d'inventaire */


/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/

int n_InitRupture	   (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	   (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLigneRupture   (char *ptsz_LigneCour[]);
int n_ActionDerniereRupture(char *ptsz_LigneCour[]);


/**************************************************************************/
/*** Objet : Cumul des montants						***/
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

/* Recuperation du parametre correspondant a la date libelle d'inventaire */
   strcpy(Ksz_CLODAT_D, psz_GetCharArgv(1));
   Ksz_Annee[0] = Ksz_CLODAT_D[0];
   Ksz_Annee[1] = Ksz_CLODAT_D[1];
   Ksz_Annee[2] = Ksz_CLODAT_D[2];
   Ksz_Annee[3] = Ksz_CLODAT_D[3];
   Ksz_Annee[4] = '\0';
   sprintf(Ksz_Annee, "%d", atoi(Ksz_Annee) + 1);

/* Ouverture du fichier de sortie des rejets */
   if (n_OpenFileAppl("ESTM2901_O1", "wt", &Kp_OutputFilRejet) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Ouverture du fichier de sortie des reconductions */
   if (n_OpenFileAppl("ESTM2901_O2", "wt", &Kp_OutputFilRecond) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM2901_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM2901_O1", &Kp_OutputFilRejet) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM2901_O2", &Kp_OutputFilRecond) == ERR) {
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

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTM2901_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
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

   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_CTR_NF], ptsz_LigneCour[GT_CTR_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_END_NT], ptsz_LigneCour[GT_END_NT])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_SEC_NF], ptsz_LigneCour[GT_SEC_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_UWY_NF], ptsz_LigneCour[GT_UWY_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_UW_NT], ptsz_LigneCour[GT_UW_NT])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_ACY_NF], ptsz_LigneCour[GT_ACY_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_SCOENDMTH_NF], ptsz_LigneCour[GT_SCOENDMTH_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_SCOSTRMTH_NF], ptsz_LigneCour[GT_SCOSTRMTH_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_OCCYEA_NF], ptsz_LigneCour[GT_OCCYEA_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_CLM_NF], ptsz_LigneCour[GT_CLM_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_CUR_CF], ptsz_LigneCour[GT_CUR_CF])) {
      return s_Ret;
   }

   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETCTR_NF], ptsz_LigneCour[GT_RETCTR_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETEND_NT], ptsz_LigneCour[GT_RETEND_NT])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETSEC_NF], ptsz_LigneCour[GT_RETSEC_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RTY_NF], ptsz_LigneCour[GT_RTY_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETUW_NT], ptsz_LigneCour[GT_RETUW_NT])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETACY_NF], ptsz_LigneCour[GT_RETACY_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETSCOENDMTH_NF], ptsz_LigneCour[GT_RETSCOENDMTH_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETSCOSTRMTH_NF], ptsz_LigneCour[GT_RETSCOSTRMTH_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETOCCYEA_NF], ptsz_LigneCour[GT_RETOCCYEA_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RCL_NF], ptsz_LigneCour[GT_RCL_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_RETCUR_CF], ptsz_LigneCour[GT_RETCUR_CF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[GT_PLC_NT], ptsz_LigneCour[GT_PLC_NT])) {
      return s_Ret;
   }

   RETURN_VAL(strcmp(ptsz_LigneSuiv[GT_TRNCOD_CF], ptsz_LigneCour[GT_TRNCOD_CF]));
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

/* Si le poste correspond : initialisation des cumuls */
   if ( ( (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '1')
          && (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '3')
          && ( (ptsz_LigneCour[GT_TRNCOD_CF][7] == '2')
             || (ptsz_LigneCour[GT_TRNCOD_CF][7] == '4')
             || (ptsz_LigneCour[GT_TRNCOD_CF][7] == '6')
             )
        ) ||
        ( (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '4')
          && (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '6')
        ) ||
        ( (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'S')
         || (ptsz_LigneCour[GT_TRNCOD_CF][1] == 'C')
        )
      ) {
      Ks_Analyse = 1;
      Kd_MontantAcc = 0;
      Kd_MontantRet = 0;
   }

/* Autres postes */
   else {
      Ks_Analyse = 0;
   }

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
   DEBUT_FCT("n_ActionLigneRupture");

/* Si le poste correspond : cumul des montants */
   if (Ks_Analyse) {
      Kd_MontantAcc = Kd_MontantAcc + atof(ptsz_LigneCour[GT_AMT_M]);
      Kd_MontantRet = Kd_MontantRet + atof(ptsz_LigneCour[GT_RETAMT_M]);
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
   char sz_SCOSTRMTH_NF[3]; /* Chaine contenant le debut de la periode */
   char sz_SCOENDMTH_NF[3]; /* Chaine contenant la fin de la periode */
   char sz_AMT_M[25];       /* Chaine contenant le montant acceptation */
   char sz_RETAMT_M[25];    /* Chaine contenant le montant retrocession */
   char sz_TRNCOD_CF[9];    /* Chaine contenant le poste comptable */

   DEBUT_FCT("n_ActionDerniereRupture");

/* Si le poste correspond : ecriture d'une ligne dans le fichier de rejet et */
/* dans le fichier de reconduction */
   if (Ks_Analyse) {

/* Date bilan : 01/01 + Annee du libelle d'inventaire + 1 */
      ptsz_LigneCour[GT_BALSHEY_NF] = Ksz_Annee;
      strcpy(ptsz_LigneCour[GT_BALSHRMTH_NF], "1");
      strcpy(ptsz_LigneCour[GT_BALSHRDAY_NF], "1");

/***************************/
/* Fichier de reconduction */
/***************************/
      sprintf(sz_AMT_M, "%-.3lf", Kd_MontantAcc);
      sprintf(sz_RETAMT_M, "%-.3lf", Kd_MontantRet);
      ptsz_LigneCour[GT_AMT_M] = sz_AMT_M;
      ptsz_LigneCour[GT_RETAMT_M] = sz_RETAMT_M;

/********************************************************/
/* Modifs du 01/04/98 - M.HA-THUC			*/
/* pas d'ecriture dans le fichier des reconductions	*/
/* si les montants sont nuls				*/
/********************************************************/

/* cas : acceptation pure */
/**************************/
if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] == 0
	&& fabs( Kd_MontantAcc ) >= 0.0005 )
	n_WriteCols(Kp_OutputFilRecond, ptsz_LigneCour,'~', 0);

/* cas : retrocession pure */
/**************************/
if ( *ptsz_LigneCour[GT_CTR_NF] == 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
	&& fabs( Kd_MontantRet ) >= 0.0005 )
	n_WriteCols(Kp_OutputFilRecond, ptsz_LigneCour,'~', 0);

/* cas : retrocession par acceptation */
/**************************************/
if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
	&& ( fabs( Kd_MontantRet ) >= 0.0005 || fabs( Kd_MontantAcc ) >= 0.0005 ) )
	n_WriteCols(Kp_OutputFilRecond, ptsz_LigneCour,'~', 0);


/********************/
/* Fichier de rejet */
/********************/
      if ( (ptsz_LigneCour[GT_TRNCOD_CF][1] >= '1') && (ptsz_LigneCour[GT_TRNCOD_CF][1] <= '3') ) {
         sprintf(sz_TRNCOD_CF, "%d", atoi(ptsz_LigneCour[GT_TRNCOD_CF]) + 1);
      }
      else {
         strcpy(sz_TRNCOD_CF, ptsz_LigneCour[GT_TRNCOD_CF]);
         switch (ptsz_LigneCour[GT_TRNCOD_CF][1]) {
            case '4':
               sz_TRNCOD_CF[1] = '7';
               break;
            case '5':
               sz_TRNCOD_CF[1] = '8';
               break;
            case '6':
               sz_TRNCOD_CF[1] = '9';
               break;
            case 'S':
               sz_TRNCOD_CF[1] = 'O';
               break;
            case 'C':
               sz_TRNCOD_CF[1] = 'R';
               break;

         }
      }

      sprintf(sz_AMT_M, "%-.3lf", - Kd_MontantAcc);
      sprintf(sz_RETAMT_M, "%-.3lf", - Kd_MontantRet);
      ptsz_LigneCour[GT_TRNCOD_CF] = sz_TRNCOD_CF;


/********************************************************/
/* Modifs du 01/04/98 - M.HA-THUC			*/
/* pas d'ecriture dans le fichier des rejets		*/
/* si les montants sont nuls				*/
/********************************************************/

/* cas : acceptation pure */
/**************************/
if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] == 0
	&& fabs( Kd_MontantAcc ) >= 0.0005 )
	n_WriteCols(Kp_OutputFilRejet, ptsz_LigneCour,'~', 0);

/* cas : retrocession pure */
/**************************/
if ( *ptsz_LigneCour[GT_CTR_NF] == 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
	&& fabs( Kd_MontantRet ) >= 0.0005 )
	n_WriteCols(Kp_OutputFilRejet, ptsz_LigneCour,'~', 0);

/* cas : retrocession par acceptation */
/**************************************/
if ( *ptsz_LigneCour[GT_CTR_NF] != 0 && *ptsz_LigneCour[GT_RETCTR_NF] != 0
	&& ( fabs( Kd_MontantRet ) >= 0.0005 || fabs( Kd_MontantAcc ) >= 0.0005 ) )
	n_WriteCols(Kp_OutputFilRejet, ptsz_LigneCour,'~', 0);

   }

   RETURN_VAL(OK);
}
