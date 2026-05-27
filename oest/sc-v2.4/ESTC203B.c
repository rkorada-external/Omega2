/*==============================================================================
nom de l'application          : Mise au format bcp du pilotage
nom du source                 : ESTC203B.c
revision                      : $Revision:   1.3  $
date de creation              : 11/07/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE	*Kp_PilotIFil,	/* Pointeur sur le fichier pilotage en entree */
	*Kp_PilotOFil;	/* Pointeur sur le fichier pilotage en sortie */
T_LIFDRI Kbd_PILOT[500];/* Fichier pilotage charge en memoire */

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
void main(int argc ,char *argv[])
{
	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* ouverture des fichiers */
	if ( n_OpenFileAppl ("ESTC203B_I1","rb",&Kp_PilotIFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC203B_O1","wt",&Kp_PilotOFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	/* Chargement en memoire du fichier pilotage et reconduction */
	 n_ChargerPilot ();

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

int n_ChargerPilot()
{
	int n_EOF = 0;
	T_LIFDRI bd_Lu;

	DEBUT_FCT("n_ChargerPilot");

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		/* ... lecture d'une ligne dans le fichier. */
		if (fread(&bd_Lu,sizeof(T_LIFDRI),1,Kp_PilotIFil)<=0)
			/* Fin de fichier, mise a jour du flag */
			n_EOF = 1;
		else
		{
			/* Ecriture en sortie */
			fprintf(Kp_PilotOFil,
			"%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%s~%s~%s\n",
			bd_Lu.CTR_NF,
			(int)bd_Lu.END_NT,
			(int)bd_Lu.SEC_NF,
			(int)bd_Lu.UWY_NF,
			(int)bd_Lu.UW_NT,
			bd_Lu.CRE_D,
			(int)bd_Lu.BALSHEY_NF,
			(int)bd_Lu.BALSHTMTH_NF,
			(int)bd_Lu.ACY_NF,
			(int)bd_Lu.SSD_CF,
			(int)bd_Lu.AUTUPD_B,
			(int)bd_Lu.COMACC_B,
			(int)bd_Lu.CMT_NT,
			bd_Lu.CREUSR_CF,
			bd_Lu.LSTUPD_D,
			bd_Lu.LSTUPDUSR_CF);
		}
	}

	RETURN_VAL (0);
}

