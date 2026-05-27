/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC8800.c
revision                      : $Revision:   1.0  $
date de creation              : 10/1997
auteur                        : Le ROY  (C.G.I.)
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Ajout en en-tete d'un fichier quelconque, d'une colonne de type identity	avec pour valeur initiale le parametre passe au programme

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
#include <estserv.h>	

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define FTRTOSTAE_CNVAMT_M 16
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

char	sz_enreg[3000];		 /* sauvegarde de l'enregistrement en cours */
int	n_Identity;		 /* numero du premier enregistrement */
FILE	*Kp_InputFil;		 /* Fichier en entree */
FILE	*Kp_OutputFil;		 /* Fichier en sortie */

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

  /* Alimentation du nom en clair du programme */
  Gbd_Tech.psz_PgmLabel = "Multiplication par -1 champ CNVAMT_M";

  /* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm(argc,argv) == ERR)
    ExitPgm (ERR_XX , "");

  /* Recuperation de la valeur initiale de l'identity */
  n_Identity=n_GetIntArgv(1)+1;

  /* ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTC8800_I1","rt",&Kp_InputFil) == ERR )
  ExitPgm ( ERR_XX , "" );
  
  /* ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTC8800_O1","wt",&Kp_OutputFil) == ERR )
  ExitPgm ( ERR_XX , "" );
  
  /* Traitement principal */
  while (fgets(sz_enreg,3000,Kp_InputFil)){
	fprintf(Kp_OutputFil,"%d~%s",n_Identity,sz_enreg);
	n_Identity++;
	}

  if (n_CloseFileAppl("ESTC8800_I1",&Kp_InputFil) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTC8800_O1",&Kp_OutputFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");

  exit(OK) ;
}
