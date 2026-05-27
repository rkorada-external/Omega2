/*==============================================================================
nom de l'application          : ESTIMATION Solvency
nom du source                 : ESTC1081.c
révision                      : $Revision: 1.2 $
date de création              : 14/11/2018
auteur                        : Roger Cassis
references des specifications : :spira:62219
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spira:62219 - Suppression des mouvements dont le Patcat_ct est BDT et ont de la retro interne

------------------------------------------------------------------------------
historique des modifications :
[00] jj/mm/aaaa auteur      :spira:xxxxx description de la modification
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define Kn_MaxLigTCLIENT   1000

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_OutputFilFtecledSII;     /* pointeur sur le fichier de sortie FtecledSII EBS */
FILE *Kp_TCLIENT;                 /* pointeur sur le fichier Fclient pour recherche si retro interne */

T_RUPTURE_VAR  bd_RuptFtecledSII;   /* variable de gestion de la rupture sur FtecledSII */
int n_InitFtecledSII        ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLigneFtecledSII ( char **pbd_InRec_Cur );

T_TCLIENT Ktbd_TCLIENT[Kn_MaxLigTCLIENT] ;
int Kn_TCLIENT;                               /* compteur du nombre ligne chargees dans Ktbd_TCLIENT */
int n_ChargerTCLIENT            ( );          /* Chargement du fichier binaire dans le tableau Ktbd_TCLIENT */
int n_recherche_CLISSD_CF       ( char **);   /* Recherche si le client a de la retro interne */


/*==============================================================================
objet : Point d'entree du programme

retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
  /* Initialisation des signaux */
  InitSig ();

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree des Clients */
	if ( n_OpenFileAppl ( "ESTC1081_I2","rb",&Kp_TCLIENT ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Chargement du tableau TCLIENT */
	if ( ( Kn_TCLIENT = n_ChargerTCLIENT() ) == -1 )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie GT */
	if ( n_OpenFileAppl ( "ESTC1081_O1", "wt", &Kp_OutputFilFtecledSII ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptFtecledSII */
	if ( n_InitFtecledSII( &bd_RuptFtecledSII ) )
		ExitPgm( ERR_XX , "" );
	
	/* lancement du traitement du fichier Pere Ifrs */
	if ( n_ProcessingRuptureVar( &bd_RuptFtecledSII ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1081_I1", &( bd_RuptFtecledSII.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1081_I2", &Kp_TCLIENT ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1081_O1", &Kp_OutputFilFtecledSII ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.

retour : 0K
==============================================================================*/
int n_InitFtecledSII(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitFtecledSII" );

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

  /* ouverture du fichier Maitre */
  if ( n_OpenFileAppl( "ESTC1081_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneFtecledSII;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFtecledSII( char **ptb_InRec_Cur )
{
	
	int    i_recherche_CLISSD_CF=0;
		
	DEBUT_FCT( "n_ActionLigneFtecledSII" );

	// Si le patcat est BDT et le retrocessionnaire est present
	if (strcmp(ptb_InRec_Cur[TTECLEDSII_PATCAT_CT], "BDT") == 0 && atoi(ptb_InRec_Cur[TTECLEDSII_RTO_NF]) > 0)
	{
		// Recherche si rétro interne
		i_recherche_CLISSD_CF=n_recherche_CLISSD_CF(ptb_InRec_Cur);
		
		if (i_recherche_CLISSD_CF>0)
			// Si c'est de la retro interne, on ne reconduit pas le record
			RETURN_VAL( OK );
	}
		
	// Sinon on reconduit le record
  n_WriteCols(Kp_OutputFilFtecledSII, ptb_InRec_Cur, SEPARATEUR, 0);
  
	RETURN_VAL( OK );
}


/*==============================================================================
objet :
  Chargement du tableau TCLIENT
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerTCLIENT()
{
	int i = 0;
	char sz_message[300];

	DEBUT_FCT("n_ChargerTCLIENT");

	memset(&Ktbd_TCLIENT, 0, sizeof(T_TCLIENT) );
	while (fread(&Ktbd_TCLIENT[i], sizeof(T_TCLIENT), 1, Kp_TCLIENT) == 1)
	{
		if (i > Kn_MaxLigTCLIENT)
		{
			sprintf(sz_message, "Depassement de capacite du tableau Ktbd_TCLIENT[%d]", Kn_MaxLigTCLIENT);
			n_WriteAno(sz_message);
			RETURN_VAL(-1);
		}
		i += 1 ;
	}
	if ( i == 0 )
	{
		n_WriteAno("Aucune ligne Chargee dans le tableau TCLIENT");
		RETURN_VAL(-1);
	}

	RETURN_VAL(i);
}


/*==============================================================================
objet : Fonction de recherche du CLISSD_CF dans le tableau TCLIENT

retour : 0 non trouve
         CLISSD_CF
==============================================================================*/
int n_recherche_CLISSD_CF( char **ptb_InRec_Cur )
{
  int n_CurPos,
      clissd = 0,
      nc = 0;
  
  DEBUT_FCT("n_recherche_CLISSD_CF");
  
  nc = atoi(ptb_InRec_Cur[TTECLEDSII_RTO_NF]);
  for ( n_CurPos = 0; n_CurPos < Kn_TCLIENT; n_CurPos++ )
  {
    if (Ktbd_TCLIENT[n_CurPos].CLI_NF == nc)
    {
      clissd = Ktbd_TCLIENT[n_CurPos].CLISSD_NF;
      break;
    }
  }
  
  return (clissd);
}

