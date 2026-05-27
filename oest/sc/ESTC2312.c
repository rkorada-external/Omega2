/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2312.c
révision                      : $Revision: 1.2 $
date de création              : 19/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRANSFORMATION DES POSTES DE PROVISIONS EN ESTIMATIONS

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	   ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_POSTES_MAX 1000 /* Le nombre max de postes est fixe a 1000 */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */
FILE		*Kp_InputFilRetPar ; /* pointeur sur le fichier en entree des conversions de postes retrocession */

T_RUPTURE_VAR 			bd_RuptGt ; /* variable de gestion de la rupture sur le GT */

T_RETPAR Ktbd_RetPar[NB_POSTES_MAX] ; 	/* tableau des postes comptables */
int Kn_NbLigRetPar ;			/* nombre de lignes du tableau des postes comptables */

int n_InitGt	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneGt		( char **pbd_InRec_Cur ) ;


int n_ChargerRETPAR( short s_TrtCod ) ;
int n_RechPoste( char *sz_post ) ;


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

	/* ouverture du fichier en sortie GT */
	if ( n_OpenFileAppl ( "ESTC2312_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FRETPAR */
	if ( n_OpenFileAppl ( "ESTC2312_I2","rb",&Kp_InputFilRetPar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* chargement en memoire du tableau des postes comptables */
        /* modif O.Arik:29/05/2001 on sort en cas de dep. de memoire*/
	Kn_NbLigRetPar = n_ChargerRETPAR( 716 ) ;
        if ( Kn_NbLigRetPar > NB_POSTES_MAX )
        {
                 n_WriteAno( "depassement de capacite du tableau Ktbd_Retpar" );
                 ExitPgm( ERR_XX , "" ) ;
         }

	/* lancement du traitement du fichier Perimetre de souscription */
	if ( n_ProcessingRuptureVar( &bd_RuptGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2312_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2312_I2", &Kp_InputFilRetPar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2312_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

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

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESTC2312_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
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
	int i ;
	char sz_TrnCod[9] ; /* variable de travail : poste comptable */

	DEBUT_FCT( "n_ActionLigneGt" ) ;

	/* recherche de l'indice de la table */
	i = n_RechPoste( ptb_InRec_Cur[GT_TRNCOD_CF] ) ;

	if ( i != -1 )
	{
		/* on pointe sur une zone de travail */
		ptb_InRec_Cur[GT_TRNCOD_CF] = sz_TrnCod ;

		/* memorisation du poste comptable */
		strcpy( sz_TrnCod, Ktbd_RetPar[i].DETTRS_CF ) ;

		/* ecriture en sortie dans le GT */
		n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire et le charge en memoire

==============================================================================*/
int n_ChargerRETPAR( short s_TrtCod )
{
	int i = 0 ;

	DEBUT_FCT("n_ChargerRETPAR");

	while ( fread( &Ktbd_RetPar[i], sizeof( T_RETPAR ), 1, Kp_InputFilRetPar ) == 1 )
	{
		if ( Ktbd_RetPar[i].PRS_CF == s_TrtCod )
			i += 1 ;
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
	fonction de recherche du poste
retour :
	0		---> Pas de rupture
	< 0   	---> On n'est pas arrive au bloc synchrone
	> 0   	---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechPoste(char *sz_poste)
{
	int n_indice, ret;

	DEBUT_FCT("n_RechPoste");

	n_indice = 0 ;

	while ( 1 == 1 )
	{
		/* Comparaison des codes */
		ret = strcmp( sz_poste, Ktbd_RetPar[n_indice].TRNCOD_CF );

		/* S'ils sont egaux, retourner l'indice */
		if ( ret == 0 ) RETURN_VAL( n_indice );

		/* Si la ligne est passee, retourner -1 (echec) */
		if ( ret < 0 ) RETURN_VAL( -1 );

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if ( n_indice >= Kn_NbLigRetPar ) RETURN_VAL( -1 );
	}
}






