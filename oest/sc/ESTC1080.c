/*==============================================================================
nom de l'application          : ESTIMATION Solvency
nom du source                 : ESTC1080.c
révision                      : $Revision: 1.2 $
date de création              : 21/08/2018
auteur                        : Roger Cassis
references des specifications : :spira:62219
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spira:62219 - Suppression des mouvements sur postes ACMTRSL3 1018,1019,1022,1032,3087,3097 avec retro interne

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
#define Kn_MaxLigFBOTRSLNK   100000
#define Kn_MaxLigTCLIENT   1000

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_OutputFilFtecleda;       /* pointeur sur le fichier de sortie Ftecleda EBS */
FILE *Kp_TCLIENT;                 /* pointeur sur le fichier Fclient pour recherche si retro interne */
FILE *Kp_FBOTRSLNK;               /* pointeur sur le fichier en entree des postes cumuls */

T_RUPTURE_VAR  bd_RuptFtecleda;   /* variable de gestion de la rupture sur Ftecleda */
int n_InitFtecleda        ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLigneFtecleda ( char **pbd_InRec_Cur );

T_FBOTRSLNK Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK];  /* Structure du fichier FBOPRSLNK */
int Kn_FBOTRSLNK ;   		                         /* compteur du nombre ligne chargees dans Ktbd_FBOTRSLNK */
int n_ChargerFBOTRSLNK();
int n_RechTrn(char *sz_trn );

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
	if ( n_OpenFileAppl ( "ESTC1080_I2","rb",&Kp_TCLIENT ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Chargement du tableau TCLIENT */
	if ( ( Kn_TCLIENT = n_ChargerTCLIENT() ) == -1 )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FBOTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1080_I3","rb",&Kp_FBOTRSLNK ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Chargement du tableau FBOTRSLNK */
	if ( ( Kn_FBOTRSLNK = n_ChargerFBOTRSLNK() ) == -1 )
		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ;

	/* ouverture du fichier de sortie GT */
	if ( n_OpenFileAppl ( "ESTC1080_O1", "wt", &Kp_OutputFilFtecleda ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptFtecleda */
	if ( n_InitFtecleda( &bd_RuptFtecleda ) )
		ExitPgm( ERR_XX , "" );
	
	/* lancement du traitement du fichier Pere Ifrs */
	if ( n_ProcessingRuptureVar( &bd_RuptFtecleda ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1080_I1", &( bd_RuptFtecleda.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1080_I2", &Kp_TCLIENT ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1080_I3", &Kp_FBOTRSLNK ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1080_O1", &Kp_OutputFilFtecleda ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK);
}

/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.

retour : 0K
==============================================================================*/
int n_InitFtecleda(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitFtecleda" );

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

  /* ouverture du fichier Maitre */
  if ( n_OpenFileAppl( "ESTC1080_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneFtecleda;

  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}

/*==============================================================================
objet : fonction lancee pour chaque ligne

retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFtecleda( char **ptb_InRec_Cur )
{

	char   sz_Trncod[9];
	int    i_Rechtrn=0, i_recherche_CLISSD_CF=0;

	DEBUT_FCT( "n_ActionLigneFtecleda" );

	memset(sz_Trncod, 0, sizeof(sz_Trncod));
	sprintf( sz_Trncod, "%s", ptb_InRec_Cur[GT_TRNCOD_CF] );

	// Recherche si ACMTRS dans le scope
	i_Rechtrn=n_RechTrn(sz_Trncod);

	// Si poste dans scope et retrocessionnaire present
	if (i_Rechtrn>0 && atoi(ptb_InRec_Cur[GT_RTO_NF]) > 0)
	{
		// Recherche si rétro interne
		i_recherche_CLISSD_CF=n_recherche_CLISSD_CF(ptb_InRec_Cur);
		
		if (i_recherche_CLISSD_CF>0)
			// Si les 2 conditions sont satisfaites, on ne reconduit pas le record
			RETURN_VAL( OK );
	}
		
	// Sinon on reconduit le record
  n_WriteCols(Kp_OutputFilFtecleda, ptb_InRec_Cur, SEPARATEUR, 0);
  
	RETURN_VAL( OK );
}


/*==============================================================================
objet :
  Chargement du tableau FBOTRSLNK
retour :
  Taille du tableau
==============================================================================*/
int n_ChargerFBOTRSLNK()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerFBOTRSLNK");

  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
  {
    i += 1 ;
    if ( i > Kn_MaxLigFBOTRSLNK )
    {
      n_WriteAno("Depassement de capacite du tableau");
      RETURN_VAL(-1);
    }
  }
  if ( i == 0 )
  {
    n_WriteAno("Fichier FBOTRSLNK vide");
    RETURN_VAL(-1);
  }

  RETURN_VAL(i);
}


/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
 <  0     ---> Poste non trouve
 >= 0     ---> Poste trouve
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
  int i;

  DEBUT_FCT("n_RechTrn");
  
  for ( i = 0; i < Kn_FBOTRSLNK ; i++ )
  {
    if ( strcmp( sz_trn, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0  && Ktbd_FBOTRSLNK[i].TRNTYP_CT>100)
    {
    	// recherche si l'ACMTRS est dans le scope d'exclusion
    	if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==1018 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==1019 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==1022 ||
    		   Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==1032 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==3087 || Ktbd_FBOTRSLNK[i].ACMTRSL3_NT==3097 )
    		RETURN_VAL(i);
    	else
    		RETURN_VAL(-1);
    }
  }

  RETURN_VAL(-1);
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
  
  nc = atoi(ptb_InRec_Cur[GT_RTO_NF]);
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

