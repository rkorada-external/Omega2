/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC3606.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 07/10/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   	Generation d'un fichier au format TSEGSTAT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 24/07/2012 R. Cassis  :spot:23802 Solvency - Ajout colonne prs_cf
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "ESTC3606.h"


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

FILE 			*Kp_OutputFil ; /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR  	   	bd_RuptCtrStat ; /* variable de gestion de la rupture sur le fichier maitre */


double		Kd_RetEgp ;	/* variable de travail */
double		Kd_RetClm ;	/* variable de travail */

double		Kd_CaccPrm ;	/* variable de travail */
double		Kd_CaccEpp ;	/* variable de travail */
double		Kd_CaccRpp ;	/* variable de travail */
double		Kd_CaccPna ;	/* variable de travail */
double		Kd_CaccResPrm ;	/* variable de travail */
double		Kd_CaccRpccp ;	/* variable de travail */
double		Kd_CaccLoa ;	/* variable de travail */
double		Kd_CaccBrk ;	/* variable de travail */
double		Kd_CaccFar ;	/* variable de travail */
double		Kd_CaccFar2 ;	/* variable de travail */
double		Kd_CaccSp ;	/* variable de travail */
double		Kd_CaccEps ;	/* variable de travail */
double		Kd_CaccRps ;	/* variable de travail */
double		Kd_CaccSap ;	/* variable de travail */
double		Kd_CaccPbPap ;	/* variable de travail */
double		Kd_CaccLoss ;	/* variable de travail */
double		Kd_CaccSnem ;	/* variable de travail */
double		Kd_CaccRpccs ;	/* variable de travail */
double		Kd_CaccResn ;	/* variable de travail */
double		Kd_CaccRes ;	/* variable de travail */
double		Kd_CaccAcr ;	/* variable de travail */

double		Kd_IaccPrm ;	/* variable de travail */
double		Kd_IaccEpp ;	/* variable de travail */
double		Kd_IaccRpp ;	/* variable de travail */
double		Kd_IaccPna ;	/* variable de travail */
double		Kd_IaccResPrm ;	/* variable de travail */
double		Kd_IaccRpccp ;	/* variable de travail */
double		Kd_IaccLoa ;	/* variable de travail */
double		Kd_IaccBrk ;	/* variable de travail */
double		Kd_IaccFar ;	/* variable de travail */
double		Kd_IaccFar2 ;	/* variable de travail */
double		Kd_IaccSp ;	/* variable de travail */
double		Kd_IaccEps ;	/* variable de travail */
double		Kd_IaccRps ;	/* variable de travail */
double		Kd_IaccSap ;	/* variable de travail */
double		Kd_IaccPbPap ;	/* variable de travail */
double		Kd_IaccLoss ;	/* variable de travail */
double		Kd_IaccSnem ;	/* variable de travail */
double		Kd_IaccRpccs ;	/* variable de travail */
double		Kd_IaccResn ;	/* variable de travail */
double		Kd_IaccRes ;	/* variable de travail */
double		Kd_IaccAcr ;	/* variable de travail */

double		Kd_EstPrm ;	/* variable de travail */
double		Kd_EstEpp ;	/* variable de travail */
double		Kd_EstRpp ;	/* variable de travail */
double		Kd_EstPna ;	/* variable de travail */
double		Kd_EstResPrm ;	/* variable de travail */
double		Kd_EstRpccp ;	/* variable de travail */
double		Kd_EstLoa ;	/* variable de travail */
double		Kd_EstBrk ;	/* variable de travail */
double		Kd_EstFar ;	/* variable de travail */
double		Kd_EstFar2 ;	/* variable de travail */
double		Kd_EstSp ;	/* variable de travail */
double		Kd_EstEps ;	/* variable de travail */
double		Kd_EstRps ;	/* variable de travail */
double		Kd_EstSap ;	/* variable de travail */
double		Kd_EstPbPap ;	/* variable de travail */
double		Kd_EstLoss ;	/* variable de travail */
double		Kd_EstSnem ;	/* variable de travail */
double		Kd_EstRpccs ;	/* variable de travail */
double		Kd_EstBlkPl ;	/* variable de travail */
double		Kd_EstBlkOsl ;	/* variable de travail */
double		Kd_EstIbnr2 ;	/* variable de travail */
double		Kd_EstResn ;	/* variable de travail */
double		Kd_EstRes ;	/* variable de travail */
double		Kd_EstAcr ;	/* variable de travail */

double		Kd_SpePrm ;	/* variable de travail */
double		Kd_SpeEpp ;	/* variable de travail */
double		Kd_SpeRpp ;	/* variable de travail */
double		Kd_SpePna ;	/* variable de travail */
double		Kd_SpeResPrm ;	/* variable de travail */
double		Kd_SpeRpccp ;	/* variable de travail */
double		Kd_SpeLoa ;	/* variable de travail */
double		Kd_SpeBrk ;	/* variable de travail */
double		Kd_SpeFar ;	/* variable de travail */
double		Kd_SpeFar2 ;	/* variable de travail */
double		Kd_SpeSp ;	/* variable de travail */
double		Kd_SpeEps ;	/* variable de travail */
double		Kd_SpeRps ;	/* variable de travail */
double		Kd_SpeSap ;	/* variable de travail */
double		Kd_SpePbPap ;	/* variable de travail */
double		Kd_SpeLoss ;	/* variable de travail */
double		Kd_SpeSnem ;	/* variable de travail */
double		Kd_SpeRpccs ;	/* variable de travail */
double		Kd_SpeBlkPl ;	/* variable de travail */
double		Kd_SpeBlkOsl ;	/* variable de travail */
double		Kd_SpeIbnr2 ;	/* variable de travail */
double		Kd_SpeResn ;	/* variable de travail */
double		Kd_SpeRes ;	/* variable de travail */
double		Kd_SpeAcr ;	/* variable de travail */

double		Kd_Amt_Max = 999999999999999.000 ;


int n_InitCtrStat	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneCtrStat	( char **pbd_InRec_Cur ) ;
int n_IsR1CtrStat		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptCtrStat	( char **ptb_InRec_Cur ) ;
int n_ActionLastRuptCtrStat	( char **ptb_InRec_Cur ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_InitVariables( void ) ;

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

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC3606_O1","wt",&Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCtrStat */
	if ( n_InitCtrStat( &bd_RuptCtrStat ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptCtrStat ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3606_I1", &( bd_RuptCtrStat.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3606_O1", &Kp_OutputFil ) == ERR )
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
int n_InitCtrStat(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitCtrStat" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESTC3606_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1CtrStat ;

	/* Fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptCtrStat ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCtrStat ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptCtrStat ;

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
int n_IsR1CtrStat(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1CtrStat" ) ;

	if ( ( ret = strcmp( pbd_InRec[CTRSTAT_SSD_CF], pbd_InRec_Cur[CTRSTAT_SSD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRSTAT_ESB_CF], pbd_InRec_Cur[CTRSTAT_ESB_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRSTAT_ACTSEG_NF], pbd_InRec_Cur[CTRSTAT_ACTSEG_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRSTAT_UWY_NF], pbd_InRec_Cur[CTRSTAT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[CTRSTAT_EGPCUR_CF], pbd_InRec_Cur[CTRSTAT_EGPCUR_CF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptCtrStat( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRuptCtrStat" ) ;

	/* initialisation des variables de travail */
	n_InitVariables( ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrStat( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneCtrStat" ) ;

	/* cumul de tous les montants compta cedante comptes complets */
	/**************************************************************/
	Kd_CaccPrm += atof( ptb_InRec_Cur[CTRSTAT_CACCPRM_M] ) ;
	Kd_CaccEpp += atof( ptb_InRec_Cur[CTRSTAT_CACCEPP_M] ) ;
	Kd_CaccRpp += atof( ptb_InRec_Cur[CTRSTAT_CACCRPP_M] ) ;
	Kd_CaccPna += atof( ptb_InRec_Cur[CTRSTAT_CACCPNA_M] ) ;
	Kd_CaccResPrm += atof( ptb_InRec_Cur[CTRSTAT_CACCRESPRM_M] ) ;
	Kd_CaccRpccp += atof( ptb_InRec_Cur[CTRSTAT_CACCRPCCP_M] ) ;
	Kd_CaccLoa += atof( ptb_InRec_Cur[CTRSTAT_CACCLOA_M] ) ;
	Kd_CaccBrk += atof( ptb_InRec_Cur[CTRSTAT_CACCBRK_M] ) ;
	Kd_CaccFar += atof( ptb_InRec_Cur[CTRSTAT_CACCFAR_M] ) ;
	Kd_CaccFar2 += atof( ptb_InRec_Cur[CTRSTAT_CACCFAR2_M] ) ;
	Kd_CaccSp += atof( ptb_InRec_Cur[CTRSTAT_CACCSP_M] ) ;
	Kd_CaccEps += atof( ptb_InRec_Cur[CTRSTAT_CACCEPS_M] ) ;
	Kd_CaccRps += atof( ptb_InRec_Cur[CTRSTAT_CACCRPS_M] ) ;
	Kd_CaccSap += atof( ptb_InRec_Cur[CTRSTAT_CACCSAP_M] ) ;
	Kd_CaccPbPap += atof( ptb_InRec_Cur[CTRSTAT_CACCPBPAP_M] ) ;
	Kd_CaccLoss += atof( ptb_InRec_Cur[CTRSTAT_CACCLOSS_M] ) ;
	Kd_CaccSnem += atof( ptb_InRec_Cur[CTRSTAT_CACCSNEM_M] ) ;
	Kd_CaccRpccs += atof( ptb_InRec_Cur[CTRSTAT_CACCRPCCS_M] ) ;
	Kd_CaccResn += atof( ptb_InRec_Cur[CTRSTAT_CACCRESN_M] ) ;
	Kd_CaccRes += atof( ptb_InRec_Cur[CTRSTAT_CACCRES_M] ) ;
	Kd_CaccAcr += atof( ptb_InRec_Cur[CTRSTAT_CACCACR_M] ) ;

	/* cumul de tous les montants compta cedante comptes incomplets */
	/****************************************************************/
	Kd_IaccPrm += atof( ptb_InRec_Cur[CTRSTAT_IACCPRM_M] ) ;
	Kd_IaccEpp += atof( ptb_InRec_Cur[CTRSTAT_IACCEPP_M] ) ;
	Kd_IaccRpp += atof( ptb_InRec_Cur[CTRSTAT_IACCRPP_M] ) ;
	Kd_IaccPna += atof( ptb_InRec_Cur[CTRSTAT_IACCPNA_M] ) ;
	Kd_IaccResPrm += atof( ptb_InRec_Cur[CTRSTAT_IACCRESPRM_M] ) ;
	Kd_IaccRpccp += atof( ptb_InRec_Cur[CTRSTAT_IACCRPCCP_M] ) ;
	Kd_IaccLoa += atof( ptb_InRec_Cur[CTRSTAT_IACCLOA_M] ) ;
	Kd_IaccBrk += atof( ptb_InRec_Cur[CTRSTAT_IACCBRK_M] ) ;
	Kd_IaccFar += atof( ptb_InRec_Cur[CTRSTAT_IACCFAR_M] ) ;
	Kd_IaccFar2 += atof( ptb_InRec_Cur[CTRSTAT_IACCFAR2_M] ) ;
	Kd_IaccSp += atof( ptb_InRec_Cur[CTRSTAT_IACCSP_M] ) ;
	Kd_IaccEps += atof( ptb_InRec_Cur[CTRSTAT_IACCEPS_M] ) ;
	Kd_IaccRps += atof( ptb_InRec_Cur[CTRSTAT_IACCRPS_M] ) ;
	Kd_IaccSap += atof( ptb_InRec_Cur[CTRSTAT_IACCSAP_M] ) ;
	Kd_IaccPbPap += atof( ptb_InRec_Cur[CTRSTAT_IACCPBPAP_M] ) ;
	Kd_IaccLoss += atof( ptb_InRec_Cur[CTRSTAT_IACCLOSS_M] ) ;
	Kd_IaccSnem += atof( ptb_InRec_Cur[CTRSTAT_IACCSNEM_M] ) ;
	Kd_IaccRpccs += atof( ptb_InRec_Cur[CTRSTAT_IACCRPCCS_M] ) ;
	Kd_IaccResn += atof( ptb_InRec_Cur[CTRSTAT_IACCRESN_M] ) ;
	Kd_IaccRes += atof( ptb_InRec_Cur[CTRSTAT_IACCRES_M] ) ;
	Kd_IaccAcr += atof( ptb_InRec_Cur[CTRSTAT_IACCACR_M] ) ;

	/* cumul de tous les montants compta estimee */
	/*********************************************/
	Kd_EstPrm += atof( ptb_InRec_Cur[CTRSTAT_ESTPRM_M] ) ;
	Kd_EstEpp += atof( ptb_InRec_Cur[CTRSTAT_ESTEPP_M] ) ;
	Kd_EstRpp += atof( ptb_InRec_Cur[CTRSTAT_ESTRPP_M] ) ;
	Kd_EstPna += atof( ptb_InRec_Cur[CTRSTAT_ESTPNA_M] ) ;
	Kd_EstResPrm += atof( ptb_InRec_Cur[CTRSTAT_ESTRESPRM_M] ) ;
	Kd_EstRpccp += atof( ptb_InRec_Cur[CTRSTAT_ESTRPCCP_M] ) ;
	Kd_EstLoa += atof( ptb_InRec_Cur[CTRSTAT_ESTLOA_M] ) ;
	Kd_EstBrk += atof( ptb_InRec_Cur[CTRSTAT_ESTBRK_M] ) ;
	Kd_EstFar += atof( ptb_InRec_Cur[CTRSTAT_ESTFAR_M] ) ;
	Kd_EstFar2 += atof( ptb_InRec_Cur[CTRSTAT_ESTFAR2_M] ) ;
	Kd_EstSp += atof( ptb_InRec_Cur[CTRSTAT_ESTSP_M] ) ;
	Kd_EstEps += atof( ptb_InRec_Cur[CTRSTAT_ESTEPS_M] ) ;
	Kd_EstRps += atof( ptb_InRec_Cur[CTRSTAT_ESTRPS_M] ) ;
	Kd_EstSap += atof( ptb_InRec_Cur[CTRSTAT_ESTSAP_M] ) ;
	Kd_EstPbPap += atof( ptb_InRec_Cur[CTRSTAT_ESTPBPAP_M] ) ;
	Kd_EstLoss += atof( ptb_InRec_Cur[CTRSTAT_ESTLOSS_M] ) ;
	Kd_EstSnem += atof( ptb_InRec_Cur[CTRSTAT_ESTSNEM_M] ) ;
	Kd_EstRpccs += atof( ptb_InRec_Cur[CTRSTAT_ESTRPCCS_M] ) ;
	Kd_EstBlkPl += atof( ptb_InRec_Cur[CTRSTAT_ESTBLKPL_M] ) ;
	Kd_EstBlkOsl += atof( ptb_InRec_Cur[CTRSTAT_ESTBLKOSL_M] ) ;
	Kd_EstIbnr2 += atof( ptb_InRec_Cur[CTRSTAT_ESTIBNR2_M] ) ;
	Kd_EstResn += atof( ptb_InRec_Cur[CTRSTAT_ESTRESN_M] ) ;
	Kd_EstRes += atof( ptb_InRec_Cur[CTRSTAT_ESTRES_M] ) ;
	Kd_EstAcr += atof( ptb_InRec_Cur[CTRSTAT_ESTACR_M] ) ;

	/* cumul de tous les montants compta service */
	/*********************************************/
	Kd_SpePrm += atof( ptb_InRec_Cur[CTRSTAT_SPEPRM_M] ) ;
	Kd_SpeEpp += atof( ptb_InRec_Cur[CTRSTAT_SPEEPP_M] ) ;
	Kd_SpeRpp += atof( ptb_InRec_Cur[CTRSTAT_SPERPP_M] ) ;
	Kd_SpePna += atof( ptb_InRec_Cur[CTRSTAT_SPEPNA_M] ) ;
	Kd_SpeResPrm += atof( ptb_InRec_Cur[CTRSTAT_SPERESPRM_M] ) ;
	Kd_SpeRpccp += atof( ptb_InRec_Cur[CTRSTAT_SPERPCCP_M] ) ;
	Kd_SpeLoa += atof( ptb_InRec_Cur[CTRSTAT_SPELOA_M] ) ;
	Kd_SpeBrk += atof( ptb_InRec_Cur[CTRSTAT_SPEBRK_M] ) ;
	Kd_SpeFar += atof( ptb_InRec_Cur[CTRSTAT_SPEFAR_M] ) ;
	Kd_SpeFar2 += atof( ptb_InRec_Cur[CTRSTAT_SPEFAR2_M] ) ;
	Kd_SpeSp += atof( ptb_InRec_Cur[CTRSTAT_SPESP_M] ) ;
	Kd_SpeEps += atof( ptb_InRec_Cur[CTRSTAT_SPEEPS_M] ) ;
	Kd_SpeRps += atof( ptb_InRec_Cur[CTRSTAT_SPERPS_M] ) ;
	Kd_SpeSap += atof( ptb_InRec_Cur[CTRSTAT_SPESAP_M] ) ;
	Kd_SpePbPap += atof( ptb_InRec_Cur[CTRSTAT_SPEPBPAP_M] ) ;
	Kd_SpeLoss += atof( ptb_InRec_Cur[CTRSTAT_SPELOSS_M] ) ;
	Kd_SpeSnem += atof( ptb_InRec_Cur[CTRSTAT_SPESNEM_M] ) ;
	Kd_SpeRpccs += atof( ptb_InRec_Cur[CTRSTAT_SPERPCCS_M] ) ;
	Kd_SpeBlkPl += atof( ptb_InRec_Cur[CTRSTAT_SPEBLKPL_M] ) ;
	Kd_SpeBlkOsl += atof( ptb_InRec_Cur[CTRSTAT_SPEBLKOSL_M] ) ;
	Kd_SpeIbnr2 += atof( ptb_InRec_Cur[CTRSTAT_SPEIBNR2_M] ) ;
	Kd_SpeResn += atof( ptb_InRec_Cur[CTRSTAT_SPERESN_M] ) ;
	Kd_SpeRes += atof( ptb_InRec_Cur[CTRSTAT_SPERES_M] ) ;
	Kd_SpeAcr += atof( ptb_InRec_Cur[CTRSTAT_SPEACR_M] ) ;

	/* cumul de tous les montants ultimes */
	/**************************************/
        if ( *ptb_InRec_Cur[CTRSTAT_CTRNAT_CT] !=  'F')
        {
	    Kd_RetEgp += atof( ptb_InRec_Cur[CTRSTAT_RETAMTPRM_M] ) ;
        }
        else
        {
            Kd_RetEgp += atof( ptb_InRec_Cur[CTRSTAT_SCOEGP_M] ) ;
        }
	Kd_RetClm += atof( ptb_InRec_Cur[CTRSTAT_RETAMTCLM_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptCtrStat( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLastRuptCtrStat" ) ;

	/* ecriture en sortie du fichier FSEGSTAT */
	/******************************************/
	if ( *ptb_InRec_Cur[CTRSTAT_SSD_CF] != 0 &&
		*ptb_InRec_Cur[CTRSTAT_ESB_CF] != 0 &&
		*ptb_InRec_Cur[CTRSTAT_ACTSEG_NF] != 0 &&
		*ptb_InRec_Cur[CTRSTAT_UWY_NF] != 0 &&
		*ptb_InRec_Cur[CTRSTAT_EGPCUR_CF] != 0 )
	{
		fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s\n",
			ptb_InRec_Cur[CTRSTAT_SSD_CF],
			ptb_InRec_Cur[CTRSTAT_ESB_CF],
			ptb_InRec_Cur[CTRSTAT_ACTSEG_NF],
			ptb_InRec_Cur[CTRSTAT_UWY_NF],
			ptb_InRec_Cur[CTRSTAT_EGPCUR_CF],
			ptb_InRec_Cur[CTRSTAT_CTRNAT_CT],
			ptb_InRec_Cur[CTRSTAT_CTRRET_B],
			( fabs( Kd_RetEgp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_RetEgp ),
			( fabs( Kd_RetClm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_RetClm ),
			ptb_InRec_Cur[CTRSTAT_ACTVRS_NF],
			ptb_InRec_Cur[CTRSTAT_ACTCUR_CF],
			ptb_InRec_Cur[CTRSTAT_ACTAMORAT_CT],
			ptb_InRec_Cur[CTRSTAT_ACTPRMAMT_M],
			ptb_InRec_Cur[CTRSTAT_ACTCLMAMT_M],
			ptb_InRec_Cur[CTRSTAT_ACTLOSRAT_R],
			( fabs( Kd_CaccPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccPrm ),
			( fabs( Kd_CaccEpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccEpp ),
			( fabs( Kd_CaccRpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccRpp ),
			( fabs( Kd_CaccPna ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccPna ),
			( fabs( Kd_CaccResPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccResPrm ),
			( fabs( Kd_CaccRpccp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccRpccp ),
			( fabs( Kd_CaccLoa ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccLoa ),
			( fabs( Kd_CaccBrk ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccBrk ),
			( fabs( Kd_CaccFar ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccFar ),
			( fabs( Kd_CaccFar2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccFar2 ),
			( fabs( Kd_CaccSp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccSp ),
			( fabs( Kd_CaccEps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccEps ),
			( fabs( Kd_CaccRps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccRps ),
			( fabs( Kd_CaccSap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccSap ),
			( fabs( Kd_CaccPbPap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccPbPap ),
			( fabs( Kd_CaccLoss ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccLoss ),
			( fabs( Kd_CaccSnem ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccSnem ),
			( fabs( Kd_CaccRpccs ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccRpccs ),
			( fabs( Kd_CaccResn ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccResn ),
			( fabs( Kd_CaccRes ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccRes ),
			( fabs( Kd_CaccAcr ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_CaccAcr ),
			( fabs( Kd_IaccPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccPrm ),
			( fabs( Kd_IaccEpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccEpp ),
			( fabs( Kd_IaccRpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccRpp ),
			( fabs( Kd_IaccPna ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccPna ),
			( fabs( Kd_IaccResPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccResPrm ),
			( fabs( Kd_IaccRpccp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccRpccp ),
			( fabs( Kd_IaccLoa ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccLoa ),
			( fabs( Kd_IaccBrk ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccBrk ),
			( fabs( Kd_IaccFar ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccFar ),
			( fabs( Kd_IaccFar2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccFar2 ),
			( fabs( Kd_IaccSp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccSp ),
			( fabs( Kd_IaccEps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccEps ),
			( fabs( Kd_IaccRps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccRps ),
			( fabs( Kd_IaccSap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccSap ),
			( fabs( Kd_IaccPbPap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccPbPap ),
			( fabs( Kd_IaccLoss ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccLoss ),
			( fabs( Kd_IaccSnem ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccSnem ),
			( fabs( Kd_IaccRpccs ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccRpccs ),
			( fabs( Kd_IaccResn ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccResn ),
			( fabs( Kd_IaccRes ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccRes ),
			( fabs( Kd_IaccAcr ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_IaccAcr ),
			( fabs( Kd_EstPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstPrm ),
			( fabs( Kd_EstEpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstEpp ),
			( fabs( Kd_EstRpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstRpp ),
			( fabs( Kd_EstPna ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstPna ),
			( fabs( Kd_EstResPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstResPrm ),
			( fabs( Kd_EstRpccp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstRpccp ),
			( fabs( Kd_EstLoa ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstLoa ),
			( fabs( Kd_EstBrk ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstBrk ),
			( fabs( Kd_EstFar ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstFar ),
			( fabs( Kd_EstFar2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstFar2 ),
			( fabs( Kd_EstSp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstSp ),
			( fabs( Kd_EstEps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstEps ),
			( fabs( Kd_EstRps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstRps ),
			( fabs( Kd_EstSap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstSap ),
			( fabs( Kd_EstPbPap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstPbPap ),
			( fabs( Kd_EstLoss ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstLoss ),
			( fabs( Kd_EstSnem ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstSnem ),
			( fabs( Kd_EstRpccs ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstRpccs ),
			( fabs( Kd_EstBlkPl ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstBlkPl ),
			( fabs( Kd_EstBlkOsl ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstBlkOsl ),
			( fabs( Kd_EstIbnr2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstIbnr2 ),
			( fabs( Kd_EstResn ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstResn ),
			( fabs( Kd_EstRes ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstRes ),
			( fabs( Kd_EstAcr ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_EstAcr ),
			( fabs( Kd_SpePrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpePrm ),
			( fabs( Kd_SpeEpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeEpp ),
			( fabs( Kd_SpeRpp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeRpp ),
			( fabs( Kd_SpePna ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpePna ),
			( fabs( Kd_SpeResPrm ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeResPrm ),
			( fabs( Kd_SpeRpccp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeRpccp ),
			( fabs( Kd_SpeLoa ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeLoa ),
			( fabs( Kd_SpeBrk ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeBrk ),
			( fabs( Kd_SpeFar ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeFar ),
			( fabs( Kd_SpeFar2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeFar2 ),
			( fabs( Kd_SpeSp ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeSp ),
			( fabs( Kd_SpeEps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeEps ),
			( fabs( Kd_SpeRps ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeRps ),
			( fabs( Kd_SpeSap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeSap ),
			( fabs( Kd_SpePbPap ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpePbPap ),
			( fabs( Kd_SpeLoss ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeLoss ),
			( fabs( Kd_SpeSnem ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeSnem ),
			( fabs( Kd_SpeRpccs ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeRpccs ),
			( fabs( Kd_SpeBlkPl ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeBlkPl ),
			( fabs( Kd_SpeBlkOsl ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeBlkOsl ),
			( fabs( Kd_SpeIbnr2 ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeIbnr2 ),
			( fabs( Kd_SpeResn ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeResn ),
			( fabs( Kd_SpeRes ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeRes ),
			( fabs( Kd_SpeAcr ) > Kd_Amt_Max ? Kd_Amt_Max : Kd_SpeAcr ),
			ptb_InRec_Cur[CTRSTAT_PRS_CF] ) ;               // [002]
	}

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{
	DEBUT_FCT( "n_InitVariables" ) ;

	Kd_RetEgp = 0 ;
	Kd_RetClm = 0 ;

	Kd_CaccPrm = 0 ;
	Kd_CaccEpp = 0 ;
	Kd_CaccRpp = 0 ;
	Kd_CaccPna = 0 ;
	Kd_CaccResPrm = 0 ;
	Kd_CaccRpccp = 0 ;
	Kd_CaccLoa = 0 ;
	Kd_CaccBrk = 0 ;
	Kd_CaccFar = 0 ;
	Kd_CaccFar2 = 0 ;
	Kd_CaccSp = 0 ;
	Kd_CaccEps = 0 ;
	Kd_CaccRps = 0 ;
	Kd_CaccSap = 0 ;
	Kd_CaccPbPap = 0 ;
	Kd_CaccLoss = 0 ;
	Kd_CaccSnem = 0 ;
	Kd_CaccRpccs = 0 ;
	Kd_CaccResn = 0 ;
	Kd_CaccRes = 0 ;
	Kd_CaccAcr = 0 ;

	Kd_IaccPrm = 0 ;
	Kd_IaccEpp = 0 ;
	Kd_IaccRpp = 0 ;
	Kd_IaccPna = 0 ;
	Kd_IaccResPrm = 0 ;
	Kd_IaccRpccp = 0 ;
	Kd_IaccLoa = 0 ;
	Kd_IaccBrk = 0 ;
	Kd_IaccFar = 0 ;
	Kd_IaccFar2 = 0 ;
	Kd_IaccSp = 0 ;
	Kd_IaccEps = 0 ;
	Kd_IaccRps = 0 ;
	Kd_IaccSap = 0 ;
	Kd_IaccPbPap = 0 ;
	Kd_IaccLoss = 0 ;
	Kd_IaccSnem = 0 ;
	Kd_IaccRpccs = 0 ;
	Kd_IaccResn = 0 ;
	Kd_IaccRes = 0 ;
	Kd_IaccAcr = 0 ;

	Kd_EstPrm = 0 ;
	Kd_EstEpp = 0 ;
	Kd_EstRpp = 0 ;
	Kd_EstPna = 0 ;
	Kd_EstResPrm = 0 ;
	Kd_EstRpccp = 0 ;
	Kd_EstLoa = 0 ;
	Kd_EstBrk = 0 ;
	Kd_EstFar = 0 ;
	Kd_EstFar2 = 0 ;
	Kd_EstSp = 0 ;
	Kd_EstEps = 0 ;
	Kd_EstRps = 0 ;
	Kd_EstSap = 0 ;
	Kd_EstPbPap = 0 ;
	Kd_EstLoss = 0 ;
	Kd_EstSnem = 0 ;
	Kd_EstRpccs = 0 ;
	Kd_EstBlkPl = 0 ;
	Kd_EstBlkOsl = 0 ;
	Kd_EstIbnr2 = 0 ;
	Kd_EstResn = 0 ;
	Kd_EstRes = 0 ;
	Kd_EstAcr = 0 ;

	Kd_SpePrm = 0 ;
	Kd_SpeEpp = 0 ;
	Kd_SpeRpp = 0 ;
	Kd_SpePna = 0 ;
	Kd_SpeResPrm = 0 ;
	Kd_SpeRpccp = 0 ;
	Kd_SpeLoa = 0 ;
	Kd_SpeBrk = 0 ;
	Kd_SpeFar = 0 ;
	Kd_SpeFar2 = 0 ;
	Kd_SpeSp = 0 ;
	Kd_SpeEps = 0 ;
	Kd_SpeRps = 0 ;
	Kd_SpeSap = 0 ;
	Kd_SpePbPap = 0 ;
	Kd_SpeLoss = 0 ;
	Kd_SpeSnem = 0 ;
	Kd_SpeRpccs = 0 ;
	Kd_SpeBlkPl = 0 ;
	Kd_SpeBlkOsl = 0 ;
	Kd_SpeIbnr2 = 0 ;
	Kd_SpeResn = 0 ;
	Kd_SpeRes = 0 ;
	Kd_SpeAcr = 0 ;

	RETURN_VAL( OK ) ;
}


