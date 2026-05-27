/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2318.c
révision                      : $Revision: 1.2 $
date de création              : 09/10/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   SELECTION DES POSTES TYPE REJET DE RETARD ET RAPPROCHABLES; CUMUL
	TOUS POSTES CONFONDUS

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
#include "estserv.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 			*Kp_OutputFilGt ; 	/* pointeur sur le fichier de sortie GT */
FILE 			*Kp_InputFilDetTrs ; 	/* pointeur sur le fichier en entree FDETTRS */

T_RUPTURE_VAR  	   	bd_RuptGtar ; 		/* variable de gestion de la rupture sur le GTAr */

double	Kd_AmtCum ;		/* montant acceptation cumule */
double	Kd_RetAmtCum ;		/* montant retrocession cumule */
unsigned char Kc_Rappro ;	/* indicateur si un poste comptable est rapprochable */


int n_InitGtar	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtar			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptGtar	( char **pbd_InRec_Cur ) ;
int n_ActionLigneGtar		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptGtar	( char **pbd_InRec_Cur ) ;



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
	if ( n_OpenFileAppl ( "ESTC2318_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FDETTRS */
	if ( n_OpenFileAppl ( "ESTC2318_I2","rb",&Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtar */
	if ( n_InitGtar( &bd_RuptGtar ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier GTAr */
	if ( n_ProcessingRuptureVar( &bd_RuptGtar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2318_I1", &( bd_RuptGtar.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2318_I2", &Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2318_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitGtar(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtar" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre GTAr */
	if ( n_OpenFileAppl( "ESTC2318_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtar ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptGtar ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtar ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptGtar ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Gtar(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Gtar" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_SSD_CF], ptb_InRec_Cur[GT_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_ESB_CF], ptb_InRec_Cur[GT_ESB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_END_NT], ptb_InRec_Cur[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_SEC_NF], ptb_InRec_Cur[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_UWY_NF], ptb_InRec_Cur[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_UW_NT], ptb_InRec_Cur[GT_UW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_CUR_CF], ptb_InRec_Cur[GT_CUR_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETEND_NT], ptb_InRec_Cur[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSEC_NF], ptb_InRec_Cur[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETUW_NT], ptb_InRec_Cur[GT_RETUW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETCUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptGtar( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRuptGtar" ) ;

	/* initialisation des montants et de l'indicateur de rapprochement */
	Kd_AmtCum = 0 ;
	Kd_RetAmtCum = 0 ;
	Kc_Rappro = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtar( char **ptb_InRec_Cur )
{
	char	MsgAno[300] ;	/* message d'anomalie */
	int 	Comp_b ; 	/* retour de la fonction b_PosteRappro
					= TRUE si le poste est rapprochable
					= FALSE si le poste est non rapprochable
					= -1 si le poste n'est pas trouve dans la table */

	DEBUT_FCT( "n_ActionLigneGtar" ) ;

	/* chargement de la table TDETTRS et recherche de l'indicateur de rapprochement
	pour le poste comptable considere si son suffixe est 5 */
	if ( ptb_InRec_Cur[GT_TRNCOD_CF][7] == '5' )
	/* attention: modifier l'egalite apres les tests = '5' */
	{
		Comp_b = b_PosteRappro( ptb_InRec_Cur[GT_TRNCOD_CF], Kp_InputFilDetTrs ) ;

		if ( Comp_b == TRUE )
		{
			/* cumul des montants acceptation et retro; positionnement de
			l'indicateur de rapprochment a 1 */
			Kd_AmtCum += atof( ptb_InRec_Cur[GT_AMT_M] ) ;
			Kd_RetAmtCum += atof( ptb_InRec_Cur[GT_RETAMT_M] ) ;
			Kc_Rappro = 1 ;
		}

		if ( Comp_b == -1 )
		{
			/* generation d'une anomalie si la fonction ne trouve pas
			le poste comptable dans la table */
			sprintf( MsgAno, "The detailed transaction code ( %s ) doesn't exist in the table TDETTERS for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
				ptb_InRec_Cur[GT_TRNCOD_CF], ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT],
				ptb_InRec_Cur[GT_SEC_NF],  ptb_InRec_Cur[GT_UWY_NF], ptb_InRec_Cur[GT_UW_NT] ) ;
			n_WriteAno( MsgAno ) ;
		}
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptGtar( char **ptb_InRec_Cur  )
{
	char	sz_Amt[20] ;	/* zone de travail: montant acceptation */
	char	sz_RetAmt[20] ; /* zone de travail: montant retrocession */

	DEBUT_FCT( "n_ActionLastRuptGtar" ) ;

	/* ecriture d'une ligne du GT en sortie si l'indicateur de rapprochement est
	positionne a 1 */
	if ( Kc_Rappro == 1 )
	{
		ptb_InRec_Cur[GT_TRNCOD_CF] = "99999999" ;
		ptb_InRec_Cur[GT_AMT_M] = sz_Amt ;
		ptb_InRec_Cur[GT_RETAMT_M] = sz_RetAmt ;

		/* copie des montants cumules dans les zones de travail */
		sprintf( sz_Amt, "%-.3f", Kd_AmtCum ) ;
		sprintf( sz_RetAmt, "%-.3f", Kd_RetAmtCum ) ;

		n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	}

	RETURN_VAL ( OK ) ;
}



