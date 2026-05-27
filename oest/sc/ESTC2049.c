/*==============================================================================
nom de l'application          : Separation des ecriture s allant ou non dans le GLT dans un LIFEST
nom du source                 : ESTC2049.c
revision                      :
date de creation              : 05/01/2016
auteur                        : MMA
references des specifications : RA
squelette de base             : batch
------------------------------------------------------------------------------
description :
				INPUT  : - VLIFEST
						 - FSUBTRSESBPROP	
				OUTPUT : - VLIFEST SRV, w/o GLT

			On veut garder toutes les lignes d'ACY <= bilan qui vont dans SRV et pas dans le GLT.
------------------------------------------------------------------------------
historique des modifications :
<modif> <jj/mm/aaaa>   <auteur>  <SPOT>  	<description de la modification>
[001] 13/01/2016 R. cassis spira #57931 commentaires si n_acy <= n_BALSHTYEA_NF
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

// Date de 
int                 n_BALSHTYEA_NF;

// Fonctions de ruptures et synchronisation
int n_InitLifest(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLifest(char **tsz_CurrentLineLifest);


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

	// Recupération des paramètres
	n_BALSHTYEA_NF = n_GetIntArgv(1);

	// Ouverture des fichiers
	if (n_OpenFileAppl("ESTC2049_O1", "wt", &Kp_LifestOut) 				== ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2049_I2", "rb", &Kp_SubTrsesBrop) 	 		== ERR) ExitPgm(ERR_XX, "");

	/* 			Initialisation des structures 			*/
	memset(&pbd_SubTrsesBrop, 	0, sizeof(pbd_SubTrsesBrop));
	// Chargement en memoire du fichier pilotage
	if (n_ChargerSUBTRSESBPROP(Kp_SubTrsesBrop)							== ERR) ExitPgm(ERR_XX, "");

	if (n_InitLifest(&pbd_RuptLifest) 						     		== ERR) ExitPgm(ERR_XX, "");

	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&pbd_RuptLifest) 						== ERR) ExitPgm(ERR_XX, "");

	// Fermeture des fichiers
	if (n_CloseFileAppl("ESTC2049_I1", &(pbd_RuptLifest.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2049_I2", &Kp_SubTrsesBrop) 				== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2049_O1", &Kp_LifestOut) 					== ERR) ExitPgm(ERR_XX, "");


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
	if (n_OpenFileAppl ("ESTC2049_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
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
	int n_acy = atof (tsz_CurrentLineLifest[PRE_ACY_NF] ) ;
	DEBUT_FCT("n_ActionLifest");

	//Si l'estimation est une estimation future => SRV
	//Si elle ne l'est pas :
	//         - Si le crible est different de S/D/A/E, que le montant est non null, et qu'on n'alimente pas le GLT => SRV
	//		   - sinon => SRV
	if ( n_acy <= n_BALSHTYEA_NF )
	{
		/*  [001]
		int result =   n_RechSUBTRSESBPROP(&pbd_SubTrsesBrop, tsz_CurrentLineLifest[PRE_DETTRNCOD_CF], tsz_CurrentLineLifest[PRE_SSD_CF], tsz_CurrentLineLifest[PRE_ESB_CF]);

		if ( ( (*tsz_CurrentLineLifest[PRE_ESTCRB_CT] != 'S') && 
			   (*tsz_CurrentLineLifest[PRE_ESTCRB_CT] != 'D') && 
			   (*tsz_CurrentLineLifest[PRE_ESTCRB_CT] != 'A') && 
			   (*tsz_CurrentLineLifest[PRE_ESTCRB_CT] != 'E') )
		     && (atof(tsz_CurrentLineLifest[PRE_ESTMNT_M]) != 0) )
		{
		    if ((result == 0 && pbd_SubTrsesBrop.GLTFEEDING_B == 0))
		        n_WriteCols(Kp_LifestOut, tsz_CurrentLineLifest, SEPARATEUR, 0);
		} 
		else 
		{
			n_WriteCols(Kp_LifestOut, tsz_CurrentLineLifest, SEPARATEUR, 0);
		}
		*/
	}
	else
		n_WriteCols(Kp_LifestOut, tsz_CurrentLineLifest, SEPARATEUR, 0);
	
	RETURN_VAL(OK);
}
