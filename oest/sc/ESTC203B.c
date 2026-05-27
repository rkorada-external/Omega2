/*==============================================================================
nom de l'application          : Mise au format bcp du pilotage
nom du source                 : ESTC203B.c
revision                      : $Revision: 1.2 $
date de creation              : 11/07/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
[XXX] 6/04/2014 JBG :spot:25773 Warnings suppress in compile
[XXX] 07/16/2014 R. BEN EZZINE :spot:25773 Ajout du champs PROPAG_RES_B
[003] 02/06/2016 S.Behague :spot:30300 EST39 Ajout du champs SEGUPD_B
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

int n_ChargerPilotYear(void);
int n_ChargerPilotQuarter(void);

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE			*Kp_PilotIFil,	/* Pointeur sur le fichier pilotage en entree */
				*Kp_PilotOFil;	/* Pointeur sur le fichier pilotage en sortie */

T_LIFDRI_ALL	Kbd_PILOT[500];/* Fichier pilotage charge en memoire */

char			ksz_quarter[2];

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	strcpy(ksz_quarter, psz_GetCharArgv(1));

	/* ouverture des fichiers */
	if ( n_OpenFileAppl ("ESTC203B_I1","rb",&Kp_PilotIFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC203B_O1","wt",&Kp_PilotOFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Chargement en memoire du fichier pilotage et reconduction */
	if (ksz_quarter[0] == '0')
		n_ChargerPilotYear();
	else
		n_ChargerPilotQuarter();

	if (n_CloseFileAppl ("ESTC203B_I1",&Kp_PilotIFil))
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTC203B_O1",&Kp_PilotOFil))
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(0) ;
}

/**************************************************************************/
/***									***/
/*** Objet :	Copie le contenu du fichier en entree dans un tableau	***/
/***									***/
/*** Nom:	n_ChargerPilot						***/
/***									***/
/*** Parametres:							***/
/***		Le pointeur du fichier					***/
/***		Le tableau de structures				***/
/***									***/
/*** Retour:								***/
/***		0							***/
/***									***/
/**************************************************************************/

int n_ChargerPilotYear(void)
{
	int n_EOF = 0;
	T_LIFDRI_ALL_QUARTER bd_Lu;
	char sz_cred[18] = "XXXXXXXXXXXXXXXXX";

	DEBUT_FCT("n_ChargerPilotYear");

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		/* ... lecture d'une ligne dans le fichier. */
		if (fread(&bd_Lu, sizeof(T_LIFDRI_ALL_QUARTER), 1, Kp_PilotIFil) <= 0)
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			strncpy(sz_cred,bd_Lu.CRE_D,17);
			/* Ecriture en sortie */
			fprintf(Kp_PilotOFil,
				"%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s~%d~%d\n",
				bd_Lu.CTR_NF,
				(int)bd_Lu.END_NT,
				(int)bd_Lu.SEC_NF,
				(int)bd_Lu.UWY_NF,
				(int)bd_Lu.UW_NT,
				sz_cred,
				(int)bd_Lu.BALSHEY_NF,
				(int)bd_Lu.BALSHTMTH_NF,
				(int)bd_Lu.ACY_NF,
				(int)bd_Lu.SSD_CF,
				(int)bd_Lu.AUTUPD_B,
				(int)bd_Lu.COMACC_B,
				(int)bd_Lu.CMT_NT,
				bd_Lu.CREUSR_CF,
				bd_Lu.LSTUPD_D,
				bd_Lu.LSTUPDUSR_CF,
				(int)bd_Lu.PROPAG_RES_B,
				(int)bd_Lu.SEGUPD_B);
		}
	}

	RETURN_VAL (0);
}

/**************************************************************************/
/***									***/
/*** Objet :	Copie le contenu du fichier en entree dans un tableau	***/
/***									***/
/*** Nom:	n_ChargerPilot						***/
/***									***/
/*** Parametres:							***/
/***		Le pointeur du fichier					***/
/***		Le tableau de structures				***/
/***									***/
/*** Retour:								***/
/***		0							***/
/***									***/
/**************************************************************************/


int n_ChargerPilotQuarter(void)
{
	int n_EOF = 0;
	T_LIFDRI_ALL_QUARTER bd_Lu;
	char sz_cred[18] = "XXXXXXXXXXXXXXXXX";

	DEBUT_FCT("n_ChargerPilotQuarter");

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		/* ... lecture d'une ligne dans le fichier. */
		if (fread(&bd_Lu, sizeof(T_LIFDRI_ALL_QUARTER), 1, Kp_PilotIFil) <= 0)
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			strncpy(sz_cred,bd_Lu.CRE_D,17);
			/* Ecriture en sortie */
			fprintf(Kp_PilotOFil,
				"%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s~%d~%d\n",
				bd_Lu.CTR_NF,
				(int)bd_Lu.END_NT,
				(int)bd_Lu.SEC_NF,
				(int)bd_Lu.UWY_NF,
				(int)bd_Lu.UW_NT,
				sz_cred,
				(int)bd_Lu.BALSHEY_NF,
				(int)bd_Lu.BALSHTMTH_NF,
				(int)bd_Lu.ACY_NF,
				(int)bd_Lu.ACM_NF,
				(int)bd_Lu.SSD_CF,
				(int)bd_Lu.AUTUPD_B,
				(int)bd_Lu.COMACC_B,
				(int)bd_Lu.CMT_NT,
				bd_Lu.CREUSR_CF,
				bd_Lu.LSTUPD_D,
				bd_Lu.LSTUPDUSR_CF,
				(int)bd_Lu.PROPAG_RES_B,
				(int)bd_Lu.SEGUPD_B);
		}
	}

	RETURN_VAL (0);
}
