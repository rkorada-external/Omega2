/*==============================================================================
nom de l'application          : Propagation des gaaps
nom du source                 : ESTC2048.c
revision                      :
date de creation              : 12/10/2016
auteur                        : Paul GARNIER
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<modif> <jj/mm/aaaa>   <auteur>  <SPOT>  	<description de la modification>
         13/10/2016       SAS           		
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>


/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE        		*Kp_LifestIn;
FILE        		*Kp_LifestOut;
FILE 	    		*Kp_SubTrsesBrop;

T_RUPTURE_VAR 		pbd_RuptLifest;
T_SUBTRSESBPROP 	pbd_SubTrsesBrop;
char 				Ksz_CRE_D[22] = {'\0'};

// Fonctions de ruptures et synchronisation
int n_InitLifest(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLifest(char **tsz_CurrentLineLifest);


// Fonctions utilitaires
int n_GaapDenied(char **tsz_LineLifest, int gaap);


/*----------------------*/
/* variables Constante  */
/*----------------------*/
#define MZero        		"0.000"
#define HEURE_TRAITEMENT "23:59:51"

/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
	// Initialisation des signaux
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

	sprintf(Ksz_CRE_D, "%s %s", psz_GetCharArgv(1), HEURE_TRAITEMENT);

	// Ouverture des fichiers
	if (n_OpenFileAppl("ESTC2048_O1", "wt", &Kp_LifestOut) 				== ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2048_I2", "rb", &Kp_SubTrsesBrop) 	 		== ERR) ExitPgm(ERR_XX, "");

	/* 			Initialisation des structures 			*/
	memset(&pbd_SubTrsesBrop, 	0, sizeof(pbd_SubTrsesBrop));
	// Chargement en memoire du fichier pilotage
	if (n_ChargerSUBTRSESBPROP(Kp_SubTrsesBrop)							== ERR) ExitPgm(ERR_XX, "");

	if (n_InitLifest(&pbd_RuptLifest) 						     		== ERR) ExitPgm(ERR_XX, "");

	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&pbd_RuptLifest) 						== ERR) ExitPgm(ERR_XX, "");

	// Fermeture des fichiers
	if (n_CloseFileAppl("ESTC2048_I1", &(pbd_RuptLifest.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2048_I2", &Kp_SubTrsesBrop) 				== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2048_O1", &Kp_LifestOut) 					== ERR) ExitPgm(ERR_XX, "");


	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}

/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier perimetre.
==============================================================================================*/
int n_InitLifest(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerimPere");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl ("ESTC2048_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 0;
	pbd_Rupt->n_ActionLigne 		= n_ActionLifest;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLifest(char **tsz_CurrentLineLifest)
{
	int gaap = 0;
	DEBUT_FCT("n_ActionLifest");


	for(gaap = 1; gaap <= 5; ++gaap)
	{
		if (n_GaapDenied(tsz_CurrentLineLifest, gaap) == 0)
			tsz_CurrentLineLifest[PRE_ESTMNT_M] = MZero;
		tsz_CurrentLineLifest[PRE_GAAP_NF][0] = gaap + '0';
		tsz_CurrentLineLifest[PRE_CRE_D] 	  = Ksz_CRE_D;
		tsz_CurrentLineLifest[PRE_LSTUPD_D]	  = Ksz_CRE_D;
		tsz_CurrentLineLifest[PRE_BATCH_B]	  = "1";
		n_WriteCols(Kp_LifestOut, tsz_CurrentLineLifest, SEPARATEUR, 0);
	}

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_GaapDenied(char **tsz_LineLifest, int gaap)
{
	if (n_RechSUBTRSESBPROP(&pbd_SubTrsesBrop, tsz_LineLifest[PRE_DETTRNCOD_CF], tsz_LineLifest[PRE_SSD_CF], tsz_LineLifest[PRE_ESB_CF]) != -1)
	{
		switch (gaap)
		{
		case 1:
			if (pbd_SubTrsesBrop.GAAP1TRS_CT == 3)
				return (0);
			break;

		case 2:
			if (pbd_SubTrsesBrop.GAAP2TRS_CT == 3)
				return (0);
			break;

		case 3:
			if (pbd_SubTrsesBrop.GAAP3TRS_CT == 3)
				return (0);
			break;

		case 4:
			if (pbd_SubTrsesBrop.GAAP4TRS_CT == 3)
				return (0);
			break;

		case 5:
			if (pbd_SubTrsesBrop.GAAP5TRS_CT == 3)
				return (0);
			break;
		}
	}
	return (-1);
}