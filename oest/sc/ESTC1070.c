/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1070.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 15/06/2015
 Auteur                        : -=Dch=-  
 References des specifications : EST49 - ULAE Design
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description : Ratios ULAE appliqués aux montants des aggrégats 
------------------------------------------------------------------------------
 Historique des modifications :
________________
MODIFICATION    
		Auteur:         Date:           ref:        Description:    
[001]  -=Dch=-  	15/06/2015 		:spot:28941 	SOLVENCY II - ULAE

==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <util.h>
#include <stdarg.h>
#include "estserv.h"

#include "ESTC1070.h" 



/*------------*/
/* Constantes */
/*------------*/

#define SEPARATOR 	"~"




T_RUPTURE_VAR       *pbd_Rupture; /* Pointeur sur la structure de la rupture   */
T_RUPTURE_SYNC_VAR  *pbd_Sync; /* Pointeur sur la structure de synchronisation */



// Variable de fichiers d'entree
FILE *Kp_InputRatios;
FILE *Kp_InputCumul;

// Variable de fichiers de sortie
FILE *Kp_OutputBatch;
FILE *Kp_OutputLog;

/*--------------------------------------------*
* 	Fonctions du fichier d'aggregat
*--------------------------------------------*/

int n_InitRupture	 (T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupture	 (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionPremiereRupture(char *ptsz_LigneCour[]);
int n_ActionLignePere( char **ptb_InRec);
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Sync);
int n_ConditionSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_ActionLigneSync(char *ptsz_LigneMaitre[],char *ptsz_LigneEsclave[]);
int n_ActionFilsSansPere(char *ptsz_LigneEsclave[]);



/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{

	pbd_Rupture=malloc(sizeof(T_RUPTURE_VAR));
   	pbd_Sync=malloc(sizeof(T_RUPTURE_SYNC_VAR));
    
    // Initialisation des signaux
    InitSig () ;

	
    if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

    // Ouverture des fichiers binaires et des fichiers de sortie

    if (n_OpenFileAppl("ESTC1070_O1", "wt", &Kp_OutputBatch)== ERR ) 
					ExitPgm(ERR_XX, "Problème lors de l'ouverture 1er fichier (cumul)." );
    if (n_OpenFileAppl("ESTC1070_O2", "wt", &Kp_OutputLog) ==ERR ) 
					ExitPgm(ERR_XX, "Problème lors de l'ouverture du 2e fichier(logs). " );

    // Initialisation des variables de gestion de ruptures
    if (n_InitRupture(pbd_Rupture)== ERR ) 
							ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode pdb_Rupture");
	

	// Initialisation de la structure de synchronisation
   if (n_InitSync(pbd_Sync) == ERR) 
					      ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");						


	/* Lancement du traitement du fichier maitre */
   if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) 
	   							ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
   


	// Fermeture des fichiers ouverts

	if (n_CloseFileAppl("ESTC1070_I2", &(pbd_Rupture->pf_InputFil)) == ERR)  
								ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'ULAE.");
	if (n_CloseFileAppl("ESTC1070_I1", &(pbd_Sync->pf_InputFil)) == ERR)  
								ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
    if (n_CloseFileAppl("ESTC1070_O1", &Kp_OutputBatch) == ERR)          
								ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cumul.");
    if (n_CloseFileAppl("ESTC1070_O2", &Kp_OutputLog) ==ERR)     
								ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier log Ledgers.");

    if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");


	// libération mémoire
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
int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
   DEBUT_FCT("n_InitRupture");
   memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

/* Ouverture du fichier maitre */
   if (n_OpenFileAppl("ESTC1070_I2", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Rupture->n_NbRupture=1;
   pbd_Rupture->n_ConditionRupture[0]=n_TestRupture;
   //pbd_Rupture->n_ActionFirst[0]=n_ActionPremiereRupture;
   pbd_Rupture->n_ActionLigne = n_ActionPremiereRupture;

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
int n_InitSync(
   T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
   DEBUT_FCT("n_InitSync");
   memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

/* Ouverture du fichier esclave */
   if (n_OpenFileAppl("ESTC1070_I1", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
      RETURN_VAL(ERR);
   }
   pbd_Sync->ConditionEndSync=n_ConditionSync;
   pbd_Sync->n_ActionLigne=n_ActionLigneSync;
   pbd_Sync->n_FilsSansPere=n_ActionFilsSansPere;
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

   s_ret = strcmp(ptsz_LigneSuiv[CML_SSD_CF], ptsz_LigneCour[CML_SSD_CF]);
   if (s_ret)
      return s_ret;
   
   RETURN_VAL (strcmp(ptsz_LigneSuiv[CML_ESB_CF], ptsz_LigneCour[CML_ESB_CF]));
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

	/* Synchronisation avec le fichier esclave à chaque rupture */
  n_ProcessingRuptureSyncVar(pbd_Sync, ptsz_LigneCour);

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
	int ret;

	DEBUT_FCT( "n_ConditionSync" );

		if ( ( ret = strcmp( ptsz_LigneMaitre[CML_SSD_CF], ptsz_LigneEsclave[RTO_SSD_CF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( ptsz_LigneMaitre[CML_ESB_CF], ptsz_LigneEsclave[RTO_ESB_CF] ) ) != 0 ) return ret;
      
	RETURN_VAL( 0 );
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
	int compteur, sortie;
	float  	Ratio , 
			AMT_M , 
			RETAMT_M, 
			ACMAMT_M ;

	char acmtrs[][4] = {"301","303","309","312","314","316","320"};
	
	sortie =0;
	Ratio = strtof (ptsz_LigneMaitre[RTO_RATIO_NF],NULL);	
	AMT_M = strtof(ptsz_LigneEsclave[CML_AMT_M], NULL);
	RETAMT_M = strtof(ptsz_LigneEsclave[CML_RETAMT_M], NULL); 
	ACMAMT_M = strtof(ptsz_LigneEsclave[CML_ACMAMT_M], NULL);
	
	char amount[LONGBUF], retamount[LONGBUF], acamount[LONGBUF];

	memset(amount,0, sizeof(amount));
	memset(retamount,0, sizeof(retamount));
	memset(acamount,0, sizeof(acamount));

	sprintf(amount , "%.3f" , AMT_M * Ratio);
	sprintf(retamount , "%.3f" , RETAMT_M * Ratio);
	sprintf(acamount , "%.3f" , ACMAMT_M * Ratio);
	
	// apply ratio amout
	ptsz_LigneEsclave[CML_AMT_M] = amount;
	ptsz_LigneEsclave[CML_RETAMT_M] = retamount;
	ptsz_LigneEsclave[CML_ACMAMT_M] = acamount;
	ptsz_LigneEsclave[CML_PRS_CF] = "751";
			

	if (strncmp(ptsz_LigneEsclave[CML_ACMTRS_NT],"320", 3)==0)
	{
		ptsz_LigneEsclave[CML_ACMTRS3_NT] = "3115";
		ptsz_LigneEsclave[CML_ACMTRS_NT] = "314";
		sortie++;
	}
	else 
	for (compteur = 0; compteur < 7 ; compteur++)
	{
		if (strncmp(ptsz_LigneEsclave[CML_ACMTRS_NT],acmtrs[compteur],3) == 0)
		{
			ptsz_LigneEsclave[CML_ACMTRS3_NT]= "3114" ;
			ptsz_LigneEsclave[CML_ACMTRS_NT] = "314";
			sortie++;
		}
	}
	/* Ecriture du fichier regroupement des contrats en sortie */
	if (sortie)
			n_WriteCols(Kp_OutputBatch, ptsz_LigneEsclave, '~', 0);
	RETURN_VAL(OK);
}

/**************************************************************************/
/*** Objet : fonction lancee quand aucune ligne du fichier maitre ne 	***/
/***         correspond a la ligne courante du fichier esclave          ***/
/***									***/
/*** Nom : n_ActionFilsSansPere						***/
/***									***/
/*** Parametres:							***/
/***    i ptsz_LigneEsclave : pointeur sur la ligne de l'esclave        ***/
/***									***/
/*** Retour:								***/
/***	OK si pas d'erreur,						***/
/***	ERR si erreur.							***/
/**************************************************************************/
int n_ActionFilsSansPere(char *ptsz_LigneEsclave[])
{
   DEBUT_FCT("n_ActionFilsSansPere");

   	n_WriteCols(Kp_OutputLog, ptsz_LigneEsclave, '~', 0);

   RETURN_VAL(OK);
}


