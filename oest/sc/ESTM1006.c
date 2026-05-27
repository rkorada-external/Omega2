/*==============================================================================
Nom de l'application          : Cumul de postes du GT cumule, du GT des
                                complements de prime et du GT des PNA estimes
                                pour calculer la prime acquise
Nom du source                 : ESTM1006.c
Revision                      : $Revision: 1.2 $
Date de creation              : 01/07/1997
Auteur                        : CGI
References des specifications :
Squelette de base             : batch
------------------------------------------------------------------------------
Description :
  Calcul de la prime acquise
  Tous les GT sont enrichis.
  En entree : GT cumule,
              GT des complements de prime,
              GT des PNA
  En sortie : GT des primes acquises.
------------------------------------------------------------------------------
Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

	  29/01/03      J. Ribot    ajout 1 champs a NULL en sortie pour retintamt_m
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
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

FILE 		   *Kp_OutputFile; /* Pointeur sur le fichier GT des primes */
                                   /* acquises 				    */
T_RUPTURE_VAR *pbd_Rupture;        /* Pointeur sur la structure du maitre   */
T_RUPTURE_SYNC_VAR *pbd_SyncPre;   /* Pointeur sur la structure de synchro  */
                                   /* avec le GT des complements de prime   */
T_RUPTURE_SYNC_VAR *pbd_SyncPNA;   /* Pointeur sur la structure de synchro  */
                                   /* avec le GT des PNA estimes  	    */
T_RUPTURE_SYNC_VAR *pbd_SyncCUMGT; /* Pointeur sur la structure de synchro  */
				   /* avec le CUMGT  			    */
double Kd_Pa;			/* Prime acquise 			    */
double Kd_Pan;			/* Prime acquise en cas de prime acquise <0 */
char Ksz_CLODAT_D[9];		/* Date de libelle d'inventaire		    */
char Ksz_Annee[5];		/* Annee de la date d'inventaire 	    */
char Ksz_Mois[3];		/* Mois de la date d'inventaire */
char Ksz_Jour[3];		/* Jour de la date d'inventaire */
char Ksz_CUR_CF[4];		/* Monnaie de l'estimation de Prime Aquise */
char **Kptsz_LigneEsclave;	/* Pointeur sur la ligne de l'esclave */
			  	/* pour recuperer la ligne dans le maitre */
char Ksz_MessageErr[256];

int Kn_SSD_CF;	/* Filiale		*/
int Kn_ESB_CF;	/* Etablissement	*/
/*--------------------------------*/
/* Fonctions du fichier GT cumule */
/*--------------------------------*/

int n_InitRupture (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture	(char *ptsz_LigneCour[]);
int n_ActionLigneRupture	(char *ptsz_LigneCour[]);
int n_ActionDerniereRupture	(char *ptsz_LigneCour[]);


/*----------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier des identifiants    */
/* et le GT des complements de prime                                    */
/*----------------------------------------------------------------------*/

int n_InitSyncPre	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncPre	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPre	(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);


/*--------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier des identifiants        */
/* et GT des PNA estimees                                                   */
/*--------------------------------------------------------------------------*/

int n_InitSyncPNA 	(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncPNA(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncPNA(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);

/*--------------------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le fichier des identifiants        */
/* et CUMGT								    */
/*--------------------------------------------------------------------------*/

int n_InitSyncCUMGT (T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncCUMGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);
int n_ConditionSyncCUMGT(char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[]);



/**************************************************************************/
/*** Objet : synchronisation entre le fichier maitre et esclave         ***/
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
   pbd_Rupture  =malloc(sizeof(T_RUPTURE_VAR));
   pbd_SyncPre  =malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncPNA  =malloc(sizeof(T_RUPTURE_SYNC_VAR));
   pbd_SyncCUMGT=malloc(sizeof(T_RUPTURE_SYNC_VAR));

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
   Ksz_Mois[0] = Ksz_CLODAT_D[4];
   Ksz_Mois[1] = Ksz_CLODAT_D[5];
   Ksz_Mois[2] = '\0';
   Ksz_Jour[0] = Ksz_CLODAT_D[6];
   Ksz_Jour[1] = Ksz_CLODAT_D[7];
   Ksz_Jour[2] = '\0';

/* Ouverture des fichiers de sortie */
   if (n_OpenFileAppl("ESTM1006_O1", "wt", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
   }

/* Initialisation de la structure de rupture */
   if (n_InitRupture(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
   }

/* Initialisation de la structure de synchronisation */
   if (n_InitSyncPre(pbd_SyncPre) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncPre");
   }

/* Initialisation de la structure de synchronisation */
   if (n_InitSyncPNA(pbd_SyncPNA) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncPNA");
   }

/* Initialisation de la structure de synchronisation */
   if (n_InitSyncCUMGT(pbd_SyncCUMGT) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSyncCUMGT");
   }

/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   }

   if (n_CloseFileAppl("ESTM1006_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1006_I2", &(pbd_SyncPre->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1006_I3", &(pbd_SyncPNA->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1006_I4", &(pbd_SyncCUMGT->pf_InputFil)) == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_CloseFileAppl("ESTM1006_O1", &Kp_OutputFile) == ERR) {
      ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
   }

   if (n_EndPgm() == ERR) {
      ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
   }

   free(pbd_Rupture);
   free(pbd_SyncPre);
   free(pbd_SyncPNA);
   free(pbd_SyncCUMGT);

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
   if (n_OpenFileAppl("ESTM1006_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_ActionLigne=n_ActionLigneRupture;
   pbd_Rupture->c_Separ= '~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : Initialisation de la synchro entre le fichier              ***/
/***         des identifiants et le fichier des primes estimees         ***/
/***       								***/
/***									***/
/*** Nom : n_InitSyncPre     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncPre(
   T_RUPTURE_SYNC_VAR  *pbd_SyncPre
)
{
   DEBUT_FCT("n_InitSyncPre");
   memset(pbd_SyncPre, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM1006_I2", "rt", &(pbd_SyncPre->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncPre->ConditionEndSync=n_ConditionSyncPre;
   pbd_SyncPre->n_ActionLigne=n_ActionLigneSyncPre;
   pbd_SyncPre->c_Separ='~';

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : initialisation de la synchronisation du GT des PNA estimees***/
/***         avec le fichier des identifiants				***/
/***									***/
/*** Nom : n_InitSyncPNA     						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_InitSyncPNA(
   T_RUPTURE_SYNC_VAR  *pbd_SyncPNA
)
{
   DEBUT_FCT("n_InitSyncPNA");
   memset(pbd_SyncPNA, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM1006_I3", "rt", &(pbd_SyncPNA->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncPNA->ConditionEndSync=n_ConditionSyncPNA;
   pbd_SyncPNA->n_ActionLigne=n_ActionLigneSyncPNA;
   pbd_SyncPNA->c_Separ='~';

   RETURN_VAL(OK);
}


/*************************************************************************/
/*** Objet : initialisation de la synchronisation du GTCUM avec  	***/
/***         le fichier des identifiants				***/
/***									***/
/*** Nom : n_InitSyncCUMGT   						***/
/***									***/
/*** Parametres:							***/
/***	i pbd_Sync : pointeur sur la structure de synchro		***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/*************************************************************************/

int n_InitSyncCUMGT(
   T_RUPTURE_SYNC_VAR  *pbd_SyncCUMGT
)
{
   DEBUT_FCT("n_InitSyncCUMGT");
   memset(pbd_SyncCUMGT, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTM1006_I4", "rt", &(pbd_SyncCUMGT->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_SyncCUMGT->ConditionEndSync=n_ConditionSyncCUMGT;
   pbd_SyncCUMGT->n_ActionLigne=n_ActionLigneSyncCUMGT;
   pbd_SyncCUMGT->c_Separ='~';

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

   if (s_Ret=strcmp(ptsz_LigneSuiv[IDENT_CTR_NF], ptsz_LigneCour[IDENT_CTR_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[IDENT_END_NT], ptsz_LigneCour[IDENT_END_NT])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[IDENT_SEC_NF], ptsz_LigneCour[IDENT_SEC_NF])) {
      return s_Ret;
   }
   if (s_Ret=strcmp(ptsz_LigneSuiv[IDENT_UWY_NF], ptsz_LigneCour[IDENT_UWY_NF])) {
      return s_Ret;
   }
   return (strcmp(ptsz_LigneSuiv[IDENT_UW_NT], ptsz_LigneCour[IDENT_UW_NT]));
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
   static char sz_Pa[25];	/* Chaine contenant la prime acquise */
   static char sz_Poste[10];	/* Chaine contenant le poste */

   DEBUT_FCT("n_ActionLigneRupture");

   Kd_Pa = 0;
   Kd_Pan = 0;
   strcpy(Ksz_CUR_CF,"");
   Kn_SSD_CF=0;
   Kn_ESB_CF=0;

/* Synchronisation avec le GT des complements de prime */
   n_ProcessingRuptureSyncVar(pbd_SyncPre, ptsz_LigneCour);

/* Synchronisation avec le GT des PNA estimees */
   n_ProcessingRuptureSyncVar(pbd_SyncPNA, ptsz_LigneCour);

/* Synchronisation avec le CUMGT	       */
   n_ProcessingRuptureSyncVar(pbd_SyncCUMGT, ptsz_LigneCour);

/* determination de la monnaie de l'estimation de prime aquise */

/*   if (Kd_Pa < 0)
   {
      Generation d'une anomalie
     sprintf (Ksz_MessageErr, "%s: earned premium is < 0, Kd_Pa=%f replaced with Kd_Pan=%f",
	      ptsz_LigneCour[IDENT_CTR_NF], Kd_Pa, Kd_Pan);
     n_WriteAno(Ksz_MessageErr);
     Kd_Pa = Kd_Pan;
   }*/

/* Ecriture du fichier en sortie */
   sprintf(sz_Pa, "%-.3lf", Kd_Pa);
   sprintf(sz_Poste, "%d", 1002);
/*ajout une colonne pour retintamt_m */
   fprintf(Kp_OutputFile,"%d~%d~%s~%s~%s~~~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%s~%s~%s\n",
	Kn_SSD_CF,
	Kn_ESB_CF,
	Ksz_Annee,
	Ksz_Mois,
	Ksz_Jour,
	ptsz_LigneCour[IDENT_CTR_NF],
	ptsz_LigneCour[IDENT_END_NT],
	ptsz_LigneCour[IDENT_SEC_NF],
	ptsz_LigneCour[IDENT_UWY_NF],
	ptsz_LigneCour[IDENT_UW_NT],
	sz_Poste,
	sz_Pa,
	Ksz_CUR_CF);

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation maitre et GT des complements de prime	***/
/***									***/
/*** Nom : n_ConditionSyncPre						***/
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

int n_ConditionSyncPre(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSyncPre");

   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_END_NT], ptsz_LigneEsclave[GT_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[IDENT_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du GT des complements de ***/
/***         prime							***/
/***									***/
/*** Nom : n_ActionLigneSyncPre						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncPre(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncPre");
   if ( strcmp(ptsz_LigneEsclave[GT_TRNCOD_CF],"11107002") != 0 )
   {
   	strcpy(Ksz_CUR_CF,ptsz_LigneEsclave[GT_CUR_CF]);
   	Kn_SSD_CF=atoi(ptsz_LigneEsclave[GT_SSD_CF]);
   	Kn_ESB_CF=atoi(ptsz_LigneEsclave[GT_ESB_CF]);

   	Kd_Pa = Kd_Pa + atof(ptsz_LigneEsclave[GT_AMT_M]);
   	Kd_Pan = Kd_Pan + atof(ptsz_LigneEsclave[GT_AMT_M]);
   }

   RETURN_VAL(OK);
}


/**************************************************************************/
/*** Objet : synchronisation maitre et GT des PNA estimees		***/
/***									***/
/*** Nom : n_ConditionSyncPNA						***/
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

int n_ConditionSyncPNA(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSyncPNA");

   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_END_NT], ptsz_LigneEsclave[GT_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[IDENT_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du GT des complements de ***/
/***         prime							***/
/***									***/
/*** Nom : n_ActionLigneSyncPre						***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncPNA(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncPNA");

   if (strcmp(Ksz_CUR_CF,"")==0)
      strcpy(Ksz_CUR_CF,ptsz_LigneEsclave[GT_CUR_CF]);
   Kn_SSD_CF=atoi(ptsz_LigneEsclave[GT_SSD_CF]);
   Kn_ESB_CF=atoi(ptsz_LigneEsclave[GT_ESB_CF]);


/* Pour debuggage */
/* printf ("PNA CTR %s, END %s, SEC %s, UWY %s, UW %s, Montant %lf\n",
           ptsz_LigneMaitre[IDENT_CTR_NF],
           ptsz_LigneMaitre[IDENT_END_NT],
           ptsz_LigneMaitre[IDENT_SEC_NF],
           ptsz_LigneMaitre[IDENT_UWY_NF],
           ptsz_LigneMaitre[IDENT_UW_NT],
           atof(ptsz_LigneEsclave[GT_AMT_M])
          ); */


   Kd_Pa = Kd_Pa + atof(ptsz_LigneEsclave[GT_AMT_M]);

   RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : synchronisation maitre et CUMGT				***/
/***									***/
/*** Nom : n_ConditionSyncCUMGT						***/
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

int n_ConditionSyncCUMGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   static short s_ret;

   DEBUT_FCT("n_ConditionSyncCUMGT");

   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_CTR_NF], ptsz_LigneEsclave[GT_CTR_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_END_NT], ptsz_LigneEsclave[GT_END_NT])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_SEC_NF], ptsz_LigneEsclave[GT_SEC_NF])) {
      return s_ret;
   }
   if (s_ret = strcmp(ptsz_LigneMaitre[IDENT_UWY_NF], ptsz_LigneEsclave[GT_UWY_NF])) {
      return s_ret;
   }
   RETURN_VAL(strcmp(ptsz_LigneMaitre[IDENT_UW_NT], ptsz_LigneEsclave[GT_UW_NT]));
}


/**************************************************************************/
/*** Objet : fonction lancee pour chaque ligne du CUMGT			***/
/***									***/
/*** Nom : n_ActionLigneSyncCUMGT					***/
/***									***/
/*** Parametres:							***/
/***	i ptsz_LigneMaitre  : pointeur sur la ligne du maitre,		***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave.       ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/

int n_ActionLigneSyncCUMGT(
   char *ptsz_LigneMaitre[],
   char *ptsz_LigneEsclave[]
)
{
   DEBUT_FCT("n_ActionLigneSyncCUMGT");
   if (strcmp(Ksz_CUR_CF,"")==0)
      strcpy(Ksz_CUR_CF,ptsz_LigneEsclave[GTE_ACMCUR_CF]);
   Kn_SSD_CF=atoi(ptsz_LigneEsclave[GTE_SSD_CF]);
   Kn_ESB_CF=atoi(ptsz_LigneEsclave[GTE_ESB_CF]);

   if ( (atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10000) || (atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10010) || (atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10020) || (atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10030) || (atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10040) ) {
      Kd_Pa = Kd_Pa + atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
   }

if ( atoi(ptsz_LigneEsclave[GTE_ACMTRS_NT]) == 10000)
      {
      Kd_Pan = Kd_Pan + atof(ptsz_LigneEsclave[GTE_ACMAMT_M]);
   }

   RETURN_VAL(OK);
}
