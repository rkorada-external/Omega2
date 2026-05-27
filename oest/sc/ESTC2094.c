/*==============================================================================
nom de l'application          : Omega 2
nom du source                 : ESTC2094.c
révision                      : $Revision: 1.0 $
date de création              : 27/09/2016
auteur                        : P.GARNIER
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   RETRO INTERNE - realignement des ACY = UWY dans le cadre des contrat type 1

------------------------------------------------------------------------------
historique des modifications :
[000] 27/09/2016 PGA :spot:31124 realignement des ACY = UWY dans le cadre des contrat type 1
[001] 07/10/2016 MMA :spot:31124 realignement des ACY = UWY dans le cadre des contrat type 1
[002] 02/05/2017 DFI spira:61477 correction du champ ESB a partir de la valeur du PERICASE
[003] 01/04/2021 BEL spira:84032 correction du champ ACCADMTYP a partir de la valeur du PERICASE
=============================================================================*/


/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/


/*---------------------------*/
/*   variables de travail    */
/*---------------------------*/
FILE    			*Kp_OutputFilLifest;	// pointuer sur le filedescriptor associer au fichier de sortie LIFEST
T_RUPTURE_VAR 		pbd_RuptLifest; 		// pointeur sur structure de lecture de fichier LIFEST
T_RUPTURE_SYNC_VAR 	pbd_SyncPericase;		// pointeur sur structure de synchro de fichier Pericase
int ACCType;
int ESB;      //[002]

/*---------------------------*/
/*   prototype des fonctions */
/*---------------------------*/

int n_InitLifest(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneLifest(char **pbd_InRecLifest);

int n_InitPericase(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPericase(char **pbd_InRecLifest, char **pbd_InRecPericase);
int n_ActionLignePericase(char **pbd_InRecLifest, char **pbd_InRecPericase);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;
	/* début programme */
	if (n_BeginPgm (argc, argv) == ERR)
		ExitPgm(ERR_XX , "") ;
	
	/* Ouverture des fichiers de sortis */
	if (n_OpenFileAppl("ESTC2094_O1", "wt", &Kp_OutputFilLifest) == ERR)
		ExitPgm(ERR_XX, "");

	/* Initialisation des structure de pilotage moteur */
	if (n_InitLifest(&pbd_RuptLifest))
		ExitPgm(ERR_XX , "") ;
	if (n_InitPericase(&pbd_SyncPericase))
		ExitPgm(ERR_XX , "") ;
	
	
	/* appel des fonctions de mise en marche moteur */
	if (n_ProcessingRuptureVar(&pbd_RuptLifest) == ERR)
		ExitPgm(ERR_XX , "") ;
	

	/* fermeture des fichiers ouvert lors de l'execution du programme */
	if (n_CloseFileAppl("ESTC2094_I1", &(pbd_RuptLifest.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX , "") ;
	if (n_CloseFileAppl("ESTC2094_I2", &(pbd_SyncPericase.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX , "") ;
	if (n_CloseFileAppl("ESTC2094_O1", &Kp_OutputFilLifest) == ERR)
		ExitPgm(ERR_XX, "");

	/* fin programme */
	if (n_EndPgm() == ERR)
		ExitPgm(ERR_XX , "");
	
	exit(OK) ;
}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/

int n_InitLifest(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitLifest");
	
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	
	/* ouverture du fichier esclave */
	if (n_OpenFileAppl("ESTC2094_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);
	
	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture 		= 0;
	
	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne 	= n_ActionLigneLifest;
	
	pbd_Rupt->c_Separ 			= SEPARATEUR;
	
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave Perim

retour :
        OK
==============================================================================*/
int n_InitPericase(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
    DEBUT_FCT("n_InitPericase");
    
    memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));
    
    /* ouverture du fichier esclave */
    if (n_OpenFileAppl("ESTC2094_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    	RETURN_VAL(ERR);
   
    pbd_Rupt->n_NbRupture 			= 0;
   
    /* fonction du test de la ligne du maitre avec l'esclave */
    pbd_Rupt->ConditionEndSync      = n_ConditionSyncPericase;
   
    /* fonction d'action sur la ligne courante du fichier esclave */
    pbd_Rupt->n_ActionLigne         = n_ActionLignePericase;
    
    pbd_Rupt->c_Separ               = SEPARATEUR;
    
    RETURN_VAL (OK);
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild (egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPericase(char **pbd_InRecLifest, char **pbd_InRecPericase)
{
	int ret ;
	
	DEBUT_FCT("n_ConditionSyncPre") ;
	
	
	if ((ret = strcmp(pbd_InRecLifest[PRE_CTR_NF], pbd_InRecPericase[PER_CTR_NF])) != 0) return ret ;
	if ((ret = strcmp(pbd_InRecLifest[PRE_SEC_NF], pbd_InRecPericase[PER_SEC_NF])) != 0) return ret ;
	if ((ret = strcmp(pbd_InRecLifest[PRE_UWY_NF], pbd_InRecPericase[PER_UWY_NF])) != 0) return ret ;
	
	RETURN_VAL (0);
}


/*===============================================================================
objet	:		fonction lancee pour chaque ligne

retour  :  	OK ---> traitement correctement effectue
    		ERR --> probleme rencontre

(1)->[002] , (2)->[003]
Correction des champs (1)ESB (filiale) et (2)ACCADMTYP pour les estimations issues 
de la retro interne
=================================================================================*/
int n_ActionLigneLifest(char **pbd_InRecLifest)
{
	DEBUT_FCT("n_ActionLigneLifest");
	
	ESB=0;

	/*[001]*/
	/* synchronisation du fichier Lifest avec le fichier Pericase */
	n_ProcessingRuptureSyncVar(&pbd_SyncPericase, pbd_InRecLifest);
	if (pbd_InRecLifest[PRE_ACMTRS_NT][3] != '4')
	{	
		if ( ACCType == 1)
			pbd_InRecLifest[PRE_UWY_NF] = pbd_InRecLifest[PRE_ACY_NF];
		
		sprintf(pbd_InRecLifest[PRE_ACCADMTYP_CT], "%d", ACCType); // [003]
		sprintf(pbd_InRecLifest[PRE_ESB_CF],"%d",ESB);

	    n_WriteCols(Kp_OutputFilLifest, pbd_InRecLifest, SEPARATEUR, 0);
	}
	RETURN_VAL(OK);
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne
PER
retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePericase(char **pbd_InRecLifest, char **pbd_InRecPericase)
{
	DEBUT_FCT("n_ActionLignePericase");

	ACCType = atoi(pbd_InRecPericase[PER_ACCADMTYP_CT]);
	ESB     = atoi(pbd_InRecPericase[PER_ACCESB_CF]);

	RETURN_VAL(OK);
}
