/*==============================================================================
nom de l'application          :
nom du source                 : ESTC1075.c
revision                      : $Revision:   1.0  $
date de creation              : 23/07/2015
auteur                        : N.Esse
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :

------------------------------------------------------------------------------
historique des modifications :
    <jj/mm/aaaa><auteur>  <description de la modification>
[01] 07/06/2016 Florent    :spot:30543 on passe à 65 années
[02] 14/05/2020 Charles S  : SPIRA 82584 ajout d'un nouveaux type d'input (124 colones)
[03] 26/08/2020 HR  : SPIRA 82685 : struct.h
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
//#include <structA.h>
#include <struct.h>
#include "ESTC3001A.h"

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_Inputfile_FTECLEDSII;  /* fichier en entree */
FILE *Kp_Outputfile_FTECLEDSII; /* fichier en sortie */

T_RUPTURE_VAR bd_RuptFTECLEDSII; /* gestion rupture */
char    inputtype[4];        // [02] pour récupérer le type d'input qu'on dois géré 
char    closing_date[10];        // [02] pour récupérer la closing date passé paramètre

extern int Ksz_Argc ;

int n_InitFTECLEDSII(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFTECLEDSII(char **pbd_InRec_Cur);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
    InitSig () ;
	
    if ( n_BeginPgm (argc  , argv) == ERR )
        ExitPgm ( ERR_XX , "" );

    //[02]
	if (Ksz_Argc == 2)
	{ 	
  	    strcpy(inputtype, psz_GetCharArgv(2));
	}
	else{
		strcpy(inputtype,"106");
	}
  
	strcpy(closing_date, psz_GetCharArgv(1));
	
	printf("--->  parametre 1 %s\n", closing_date);
	printf("--->  parametre 2 %s\n", inputtype);
	
    /* Ouverture des fichiers en sortie */
    if ( n_OpenFileAppl ("ESTC1075_O1", "wt", &Kp_Outputfile_FTECLEDSII) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptFTECLEDSII */
    if ( n_InitFTECLEDSII(&bd_RuptFTECLEDSII) )
        ExitPgm ( ERR_XX , "" );

    /* Lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptFTECLEDSII) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Fermeture fichier */
    if (n_CloseFileAppl ("ESTC1075_I1", &(bd_RuptFTECLEDSII.pf_InputFil)) == ERR)
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC1075_O1", &Kp_Outputfile_FTECLEDSII) == ERR)
        ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )
        ExitPgm ( ERR_XX , "" );

    exit(OK);
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :
        OK
==============================================================================*/
int n_InitFTECLEDSII(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitFTECLEDSII");

    memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC1075_I1", "rt", &(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 0 ;
    pbd_Rupt->n_ActionLigne = n_ActionLigneFTECLEDSII ;

    pbd_Rupt->c_Separ = '~' ;

    RETURN_VAL (OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFTECLEDSII(char **ptb_InRec_Cur_FTECLEDSII)
{
    DEBUT_FCT("n_ActionLigneFTECLEDSII");
    double  d_TIFI_M = 0;
    char    sz_TIFI_M[30] = {'\0'};
    int     i, n_annee = 1;

	//[02]
	if (atoi(inputtype) != 126){
		for (i = TTECLEDSII_AN1; i <= TTECLEDSII_AN65; ++i)
		{
			//il y a 2 champs entre le montant de la 40ème année et de la 41 éme année: c'est le format de la table BSAR..TTECLEDSII
			if (i != TTECLEDSII_COMMENT_CF && i != TTECLEDSII_TIFI_M )
			{
				d_TIFI_M = d_TIFI_M + ((n_annee - 0.5) * atof(ptb_InRec_Cur_FTECLEDSII[i]));
				++n_annee;
			}
		}
		sprintf(sz_TIFI_M, "%.3f", d_TIFI_M);
		ptb_InRec_Cur_FTECLEDSII[TTECLEDSII_TIFI_M] = sz_TIFI_M;
	}
	else{
		for (i = CML_AM01_MC; i <= CML_AM_FIN; ++i)
		{
				d_TIFI_M = d_TIFI_M + ((n_annee - 0.5) * atof(ptb_InRec_Cur_FTECLEDSII[i]));
				++n_annee;
		}
	}
    n_WriteCols(Kp_Outputfile_FTECLEDSII, ptb_InRec_Cur_FTECLEDSII, '~', 0);

    RETURN_VAL (OK);
}
