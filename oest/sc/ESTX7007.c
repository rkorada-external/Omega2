/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
nom de l'application          : Estimations
nom du source                 : ESTX7007.c
revision                      : $Revision: 1.1.1.1 $
date de creation              : 29/11/2006
auteur                        : J.Ribot
references des specifications : transfert portefeuille - SPOT EST 13427
squelette de base             : extraction
------------------------------------------------------------------------------
description :
   TRAITEMENT DES TRANSFERTS DE PORTEFEUILLE  - partie GT -
description :
	Ce programme appelle 4 procedures. La 1ere lui retourne le contenu
	de la table TRFCROSSREF, la 2eme celui de TCLMCROSSREF, la 3eme celui
        de la table TDETTRS, la 4eme celui de TFACROSSREF,.
	Chaque ligne lue est enregistree sous la forme d'une structure dans
	un fichier binaire.
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 13/07/2011 R. cassis   :spot:22358 - SSD_emetteur en col 57 au lieu de 41
[003] 29/08/2012 Roger Cassis  :spot:29223 - Initialisation de variables pour Linux Omega2
[004] 06/11/2020 Shiva A     :Spira 91119 - Correct ESTD3000 issue that skips the first contract on the input list
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
/*#include <util.h>*/
#include "estm7gt.h"
#include "ESTX7007.h"
#define GT_SSD_EMET_CF 57   // [002]
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define NB_TRF_MAX   20000	/* Le nombre max de postes est fixe a 20000 */


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilGt ;		/* pointeur sur le fichier de sortie GT */
FILE 		*Kp_InputFilTrf ;		/* pointeur sur le fichier en entree T_TRFCROSSREF */
T_RUPTURE_VAR	bd_RuptGt ;			/* variable de gestion de la rupture sur le GT */

T_TRFCROSSREF	Ktbd_Trf[NB_TRF_MAX] ;
int		Kn_NbLigTrf=0 ;	/* nombre de lignes du tableau Ktbd_Trf */


int n_InitGt	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneGt		( char **pbd_InRec_Cur ) ;

int n_InitRecond		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRecond		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRecond	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_Processing (T_RUPTURE_VAR *);
/*int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );
*/
int n_ChargerTRF( );
int n_RechCtr( char *sz_ctr );


int  		n_parm_BALSHEY_NF;
char 		sz_parm_BLCSHT_D[8];
unsigned char	c_parm_ESTIM_B;   		/* 0/1 - si = 1 -> Postes estimations sont pris en compte */
int  		n_parm_FORCEBILAN;    /* MOD005 - Flag FORCEBILAN Forcé Bilan à à 31/12/N-1 (1=Oui par Défaut / 0= Bilan N préservé) */


char 		sz_CTR_NF[10]="";	/* zone travail pour test rupture Contrats */
int      n_indctr;      // [003]
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

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

/*	strcpy(sz_parm_BLCSHT_D, psz_GetCharArgv(1)) ;
	n_parm_BALSHEY_NF = atoi(psz_GetCharArgv(2)) ;
	c_parm_ESTIM_B = atoi(psz_GetCharArgv(3)) ;
  n_parm_FORCEBILAN = atoi(psz_GetCharArgv(4)) ;  */
/*printf("===========> ici 11 %d\n",c_parm_ESTIM_B);*/

	/* ouverture du fichier en entree TRF */
	if ( n_OpenFileAppl ( "ESTX7007_I2","rb",&Kp_InputFilTrf ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des transferts */
	if ( n_OpenFileAppl ( "ESTX7007_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

		/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

printf("Charegment des tables\n");

	/* Chargement des postes en memoire */
	if ( (Kn_NbLigTrf = n_ChargerTRF( )) == -1 )
		ExitPgm( ERR_XX , "" ) ;

	/* n_AfficheTables() */

	/* Lancement du traitement sans rupture */
	if ( n_Processing( &bd_RuptGt ) == ERR)
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTX7007_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTX7007_I2", &Kp_InputFilTrf ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTX7007_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitGt(T_RUPTURE_VAR  *pbd_Rupt)
{

	DEBUT_FCT( "n_InitGt" ) ;

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	/* ouverture du fichier maitre GT */
	if ( n_OpenFileAppl( "ESTX7007_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		RETURN_VAL(  ERR ) ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;
	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}

/*=============================================================================
objet :
 	fonction d'appel a la boucle de traitement.
      	lors de la sortie de la boucle impression dans fichier compte rendu.
        Ce programmme ne gere pas de rupture, un traitement sera lance a chaque
        ligne.
retour :
	ERR si on a rencontre un probleme.
=============================================================================*/
int n_Processing(T_RUPTURE_VAR *Kbd_ruptFIC_IN)
{
   int n_Resultat;

   DEBUT_FCT("n_Processing");

   n_Resultat = n_ProcessingRuptureVar (Kbd_ruptFIC_IN);

   return (n_Resultat);
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt( char **ptb_InRec_Cur )
{

   char sz_DESTSSD[5];
   //int  n_indctr;   // [003]
   int  i;

   DEBUT_FCT( "n_ActionLigneGt" ) ;

   /* Contrats retros exclus  */
   if((ptb_InRec_Cur[GT_TRNCOD_CF][0] !='1') &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][0] !='3'))
   {
      	return (OK);
   }

	if (strcmp(sz_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]) != 0)
	{
		strcpy (sz_CTR_NF, ptb_InRec_Cur[GT_CTR_NF]);

		/* recherche du contrat */
		i = n_RechCtr(ptb_InRec_Cur[GT_CTR_NF]);
		n_indctr = i;
   }

// if (n_indctr == 0)	return (OK);  // [003] [004]
   if (n_indctr == -1)	return (OK);  // [004]	 

//printf("Contrat traité %s - n_indctr %i \n",sz_CTR_NF,n_indctr);
	sprintf(sz_DESTSSD,"%d", Ktbd_Trf[n_indctr].DESTSSD_CF);

	ptb_InRec_Cur[GT_SSD_EMET_CF] = ptb_InRec_Cur[GT_SSD_CF] ;
	ptb_InRec_Cur[GT_SSD_CF] = sz_DESTSSD;

	/* reconduction du GT en sortie */
	n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	
	return (OK);

}


/*==============================================================================
object
	Lit le fichier binaire des contrats et les charge en memoire

==============================================================================*/
int n_ChargerTRF( )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerTRF");

	while ( fread( &Ktbd_Trf[i], sizeof( T_TRFCROSSREF ), 1, Kp_InputFilTrf ) == 1 )
	{
		i += 1 ;
		if ( i == NB_TRF_MAX )
		{
			printf( " max TRF atteint=20000 " );
			return (-1 )  ;
		}
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du contrat
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechCtr(char *sz_ctr)
{
        int i;

	DEBUT_FCT("n_RechCtr");

	for ( i = 0; i <  Kn_NbLigTrf ; i++ )
	{
		if ( strcmp( sz_ctr, Ktbd_Trf[i].CTR_NF ) == 0) RETURN_VAL(i);
	}

//	RETURN_VAL(0);  // [003] [004]
	RETURN_VAL(-1);  // [004]
}


