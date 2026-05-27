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
   PREPARATION de FTRAV1 (Resultat comptable)
            et de FTRAV3 (Ecart de placement et de change sur les rejets de retards)
FTRAV1 : selection des postes rapprochables
FTRAV3 : SELECTION DES POSTES TYPE REJET DE RETARD ET RAPPROCHABLES


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

FILE 			*Kp_OutputFilGt1 ; 	/* pointeur sur le fichier de sortie GT pour generer FTRAV1*/
FILE 			*Kp_OutputFilGt3 ; 	/* pointeur sur le fichier de sortie GT pour generer FTRAV3 */
FILE 			*Kp_InputFilDetTrs ; 	/* pointeur sur le fichier en entree FDETTRS */

T_RUPTURE_VAR  	   	bd_RuptGtar ; 		/* variable de gestion de la rupture sur le GTAr */

double  Kd_AmtCum ;		/* montant acceptation cumule */
double  Kd_RetAmtCum ;		/* montant retrocession cumule */
unsigned char Kc_Rappro ;	/* indicateur si un poste comptable est rapprochable */


int n_InitGtar	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtar			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Gtar			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Gtar	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2Gtar	( char **pbd_InRec_Cur ) ;
int n_ActionLigneGtar		( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt2Gtar        ( char **pbd_InRec_Cur ) ;

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
	if ( n_OpenFileAppl ( "ESTC2337_O1","wt",&Kp_OutputFilGt1 ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en sortie GT */
	if ( n_OpenFileAppl ( "ESTC2337_O2","wt",&Kp_OutputFilGt3 ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FDETTRS */
	if ( n_OpenFileAppl ( "ESTC2337_I2","rb",&Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtar */
	if ( n_InitGtar( &bd_RuptGtar ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier GTAr */
	if ( n_ProcessingRuptureVar( &bd_RuptGtar ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2337_I1", &( bd_RuptGtar.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2337_I2", &Kp_InputFilDetTrs ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2337_O1", &Kp_OutputFilGt1 ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2337_O2", &Kp_OutputFilGt3 ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC2337_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 2 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtar ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_IsR2Gtar ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Gtar ;

	/* fonction lancee en rupture seconde */
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Gtar ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtar ;

	/* Fonction lancee en rupture derniere seconde */
	pbd_Rupt->n_ActionLast[1] = n_ActionLastRupt2Gtar ;


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

	if ( ( ret = strcmp( ptb_InRec[GT_TRNCOD_CF], ptb_InRec_Cur[GT_TRNCOD_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Gtar(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR2Gtar" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_TRNCOD_CF], ptb_InRec_Cur[GT_TRNCOD_CF] ) ) != 0 ) return ret ;
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
int n_ActionFirstRupt1Gtar( char **pbd_InRec_Cur  )
{
	char	MsgAno[300] ;	/* message d'anomalie */
	int 	Comp_b ; 	/* retour de la fonction b_PosteRappro
					= TRUE si le poste est rapprochable
					= FALSE si le poste est non rapprochable
					= -1 si le poste n'est pas trouve dans la table */

	DEBUT_FCT( "n_ActionFirstRupt1Gtar" ) ;

	/* initialisation indicateur de rapprochement */
	Kc_Rappro = 0 ;

	Comp_b = b_PosteRappro( pbd_InRec_Cur[GT_TRNCOD_CF], Kp_InputFilDetTrs ) ;

	if ( Comp_b == TRUE )
	{
		/* positionnement de l'indicateur de rapprochment a 1 */
		Kc_Rappro = 1 ;
	}
	else if ( Comp_b == -1 )
	{
		/* generation d'une anomalie si la fonction ne trouve pas
		le poste comptable dans la table */
		sprintf( MsgAno, "The detailed transaction code ( %s ) doesn't exist in the table TDETTRS for the contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
			pbd_InRec_Cur[GT_TRNCOD_CF], pbd_InRec_Cur[GT_CTR_NF], pbd_InRec_Cur[GT_END_NT],
			pbd_InRec_Cur[GT_SEC_NF],  pbd_InRec_Cur[GT_UWY_NF], pbd_InRec_Cur[GT_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;
	}

	RETURN_VAL ( OK ) ;
}

/*==============================================================================
objet :
        fonction lancee en rupture premiere

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Gtar( char **pbd_InRec_Cur  )
{
        DEBUT_FCT( "n_ActionFirstRupt2Gtar" ) ;

        /* initialisation des montants et de l'indicateur de rapprochement */
        Kd_AmtCum = 0 ;
        Kd_RetAmtCum = 0 ;

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
	DEBUT_FCT( "n_ActionLigneGtar" ) ;

	/* ecriture d'une ligne du GT en sortie si l'indicateur de rapprochement est
	positionne a 1 */
	if ( Kc_Rappro == 1 )
	{
		Kd_AmtCum += atof( ptb_InRec_Cur[GT_AMT_M] ) ;
		Kd_RetAmtCum += atof( ptb_InRec_Cur[GT_RETAMT_M] ) ;
	}

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
 fonction lancee en rupture derniere

retour :OK ---> traitement correctement effectue
 ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt2Gtar( char **ptb_InRec_Cur  )
{
 char    sz_Amt[20] ;    /* zone de travail: montant acceptation */
 char    sz_RetAmt[20] ; /* zone de travail: montant retrocession */

 DEBUT_FCT( "n_ActionLastRupt2Gtar" ) ;

	/* ecriture d'une ligne du GT en sortie si l'indicateur de rapprochement est
	positionne a 1 */
	if ( Kc_Rappro == 1 )
	{
                ptb_InRec_Cur[GT_RETAMT_M] = sz_RetAmt ;
                sprintf( sz_RetAmt, "%-.3f", Kd_RetAmtCum ) ;

		n_WriteCols( Kp_OutputFilGt1, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

		/* Si poste de Rejet Retro (retard) ecriture dans le second GT en sortie */
		if ( ptb_InRec_Cur[GT_TRNCOD_CF][7] == '5' )
		{
		/*	ptb_InRec_Cur[GT_TRNCOD_CF] = "99999999" ; *//* Fait dans le ESTC2338 */
                	ptb_InRec_Cur[GT_AMT_M] = sz_Amt ;

			sprintf( sz_Amt, "%-.3f", Kd_AmtCum ) ;

			n_WriteCols( Kp_OutputFilGt3, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
		}
	}

        RETURN_VAL ( OK ) ;
}

