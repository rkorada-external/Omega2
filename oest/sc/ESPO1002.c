/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESPO1002.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 25/08/2005
auteur                        : J. Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   	Generation d'un fichier au format TCTRSTAT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[002] 13/07/2012 R. Cassis   :spot:23802  Ajout champ PRS_CF dans Synchro pour Solvency
[003] 20/03/2013 R. Cassis   :spot:24984  Relivraison ancienne version
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "ESPO1002.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
//#define STAT_CTR_NF	0
//#define STAT_END_NT	1
//#define STAT_SEC_NF	2
//#define STAT_UWY_NF	3
//#define STAT_UW_NT	4
//#define STAT_ACMTRS_NT	5
//#define STAT_COD_CT	6
//#define STAT_AMT_M	7

//#define ULTIM_CTR_NF	0
//#define ULTIM_END_NT	1
//#define ULTIM_SEC_NF	2
//#define ULTIM_UWY_NF	3
//#define ULTIM_UW_NT	4
//#define ULTIM_FACADMTYP_B 124

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFil ; /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR  	   	bd_RuptUltimates ; /* variable de gestion de la rupture sur le fichier maitre */
T_RUPTURE_SYNC_VAR 	bd_RuptStat ; 	   /* variable de gestion de la synchronisation avec le fichier versements */

double		Kd_Amt_Max = 999999999999999.000 ;

int n_InitUltimates	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneUltimates	( char **pbd_InRec_Cur ) ;

int n_InitStat			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneStat		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncStat		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


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
	if ( n_OpenFileAppl ( "ESPO1002_O1","wt",&Kp_OutputFil ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUltimates */
	if ( n_InitUltimates( &bd_RuptUltimates ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptStat */
	if ( n_InitStat( &bd_RuptStat ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar( &bd_RuptUltimates ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1002_I1", &( bd_RuptUltimates.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1002_I2", &( bd_RuptStat.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESPO1002_O1", &Kp_OutputFil ) == ERR )
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
int n_InitUltimates(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitUltimates" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre */
	if ( n_OpenFileAppl( "ESPO1002_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUltimates ;

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
int n_ActionLigneUltimates( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionLigneUltimates" ) ;

	/* initialisation des variables de travail */
	/*******************************************/
	n_InitVariables( ) ;

	/* synchronisation avec le fichier fils */
	/****************************************/
	n_ProcessingRuptureSyncVar( &bd_RuptStat, ptb_InRec_Cur ) ;

	/* Cumul des montants */
			Kd_CACCPRM_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCPRM_M] ) ;
			Kd_CACCEPP_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCEPP_M] ) ;
			Kd_CACCRPP_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCRPP_M]) ;
			Kd_CACCPNA_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCPNA_M]) ;
			Kd_CACCRESPRM_M += atof( ptb_InRec_Cur[CTRSTAT_CACCRESPRM_M]) ;
			Kd_CACCRPCCP_M  += atof( ptb_InRec_Cur[CTRSTAT_CACCRPCCP_M ]) ;
			Kd_CACCLOA_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCLOA_M] ) ;
			Kd_CACCBRK_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCBRK_M] ) ;
			Kd_CACCFAR_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCFAR_M] ) ;
			Kd_CACCFAR2_M   += atof( ptb_InRec_Cur[CTRSTAT_CACCFAR2_M] ) ;
			Kd_CACCSP_M     += atof( ptb_InRec_Cur[CTRSTAT_CACCSP_M] ) ;
			Kd_CACCEPS_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCEPS_M] ) ;
			Kd_CACCRPS_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCRPS_M] ) ;
			Kd_CACCSAP_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCSAP_M] ) ;
			Kd_CACCPBPAP_M  += atof( ptb_InRec_Cur[CTRSTAT_CACCPBPAP_M] ) ;
			Kd_CACCLOSS_M   += atof( ptb_InRec_Cur[CTRSTAT_CACCLOSS_M] ) ;
			Kd_CACCSNEM_M   += atof( ptb_InRec_Cur[CTRSTAT_CACCSNEM_M ] ) ;
			Kd_CACCRPCCS_M  += atof( ptb_InRec_Cur[CTRSTAT_CACCRPCCS_M] ) ;
			Kd_CACCRESN_M   += atof( ptb_InRec_Cur[CTRSTAT_CACCRESN_M] ) ;
			Kd_CACCRES_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCRES_M] ) ;
			Kd_CACCACR_M    += atof( ptb_InRec_Cur[CTRSTAT_CACCACR_M] ) ;
			Kd_IACCPRM_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCPRM_M] ) ;
			Kd_IACCEPP_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCEPP_M] ) ;
			Kd_IACCRPP_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCRPP_M] ) ;
			Kd_IACCPNA_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCPNA_M] ) ;
			Kd_IACCRESPRM_M += atof( ptb_InRec_Cur[CTRSTAT_IACCRESPRM_M] ) ;
			Kd_IACCRPCCP_M  += atof( ptb_InRec_Cur[CTRSTAT_IACCRPCCP_M] ) ;
			Kd_IACCLOA_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCLOA_M] ) ;
			Kd_IACCBRK_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCBRK_M] ) ;
			Kd_IACCFAR_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCFAR_M] ) ;
			Kd_IACCFAR2_M   += atof( ptb_InRec_Cur[CTRSTAT_IACCFAR2_M] ) ;
			Kd_IACCSP_M     += atof( ptb_InRec_Cur[CTRSTAT_IACCSP_M] ) ;
			Kd_IACCEPS_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCEPS_M] ) ;
			Kd_IACCRPS_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCRPS_M] ) ;
			Kd_IACCSAP_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCSAP_M] ) ;
			Kd_IACCPBPAP_M  += atof( ptb_InRec_Cur[CTRSTAT_IACCPBPAP_M] ) ;
			Kd_IACCLOSS_M   += atof( ptb_InRec_Cur[CTRSTAT_IACCLOSS_M] ) ;
			Kd_IACCSNEM_M   += atof( ptb_InRec_Cur[CTRSTAT_IACCSNEM_M] ) ;
			Kd_IACCRPCCS_M  += atof( ptb_InRec_Cur[CTRSTAT_IACCRPCCS_M] ) ;
			Kd_IACCRESN_M   += atof( ptb_InRec_Cur[CTRSTAT_IACCRESN_M] ) ;
			Kd_IACCRES_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCRES_M] ) ;
			Kd_IACCACR_M    += atof( ptb_InRec_Cur[CTRSTAT_IACCACR_M] ) ;
			Kd_ESTPRM_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTPRM_M] ) ;
			Kd_ESTEPP_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTEPP_M] ) ;
			Kd_ESTRPP_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTRPP_M] ) ;
			Kd_ESTPNA_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTPNA_M] ) ;
			Kd_ESTRESPRM_M  += atof( ptb_InRec_Cur[CTRSTAT_ESTRESPRM_M] ) ;
			Kd_ESTRPCCP_M   += atof( ptb_InRec_Cur[CTRSTAT_ESTRPCCP_M] ) ;
			Kd_ESTLOA_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTLOA_M] ) ;
			Kd_ESTBRK_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTBRK_M] ) ;
			Kd_ESTFAR_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTFAR_M] ) ;
			Kd_ESTFAR2_M    += atof( ptb_InRec_Cur[CTRSTAT_ESTFAR2_M] ) ;
			Kd_ESTSP_M      += atof( ptb_InRec_Cur[CTRSTAT_ESTSP_M] ) ;
			Kd_ESTEPS_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTEPS_M] ) ;
			Kd_ESTRPS_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTRPS_M] ) ;
			Kd_ESTSAP_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTSAP_M] ) ;
			Kd_ESTPBPAP_M   += atof( ptb_InRec_Cur[CTRSTAT_ESTPBPAP_M] ) ;
			Kd_ESTLOSS_M    += atof( ptb_InRec_Cur[CTRSTAT_ESTLOSS_M] ) ;
			Kd_ESTSNEM_M    += atof( ptb_InRec_Cur[CTRSTAT_ESTSNEM_M] ) ;
			Kd_ESTRPCCS_M   += atof( ptb_InRec_Cur[CTRSTAT_ESTRPCCS_M] ) ;
			Kd_ESTBLKPL_M   += atof( ptb_InRec_Cur[CTRSTAT_ESTBLKPL_M] ) ;
			Kd_ESTBLKOSL_M  += atof( ptb_InRec_Cur[CTRSTAT_ESTBLKOSL_M] ) ;
			Kd_ESTIBNR2_M   += atof( ptb_InRec_Cur[CTRSTAT_ESTIBNR2_M] ) ;
			Kd_ESTRESN_M    += atof( ptb_InRec_Cur[CTRSTAT_ESTRESN_M] ) ;
			Kd_ESTRES_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTRES_M] ) ;
			Kd_ESTACR_M     += atof( ptb_InRec_Cur[CTRSTAT_ESTACR_M] ) ;
			Kd_SPEPRM_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEPRM_M] ) ;
			Kd_SPEEPP_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEEPP_M] ) ;
			Kd_SPERPP_M     += atof( ptb_InRec_Cur[CTRSTAT_SPERPP_M] ) ;
			Kd_SPEPNA_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEPNA_M] ) ;
			Kd_SPERESPRM_M  += atof( ptb_InRec_Cur[CTRSTAT_SPERESPRM_M] ) ;
			Kd_SPERPCCP_M   += atof( ptb_InRec_Cur[CTRSTAT_SPERPCCP_M] ) ;
			Kd_SPELOA_M     += atof( ptb_InRec_Cur[CTRSTAT_SPELOA_M] ) ;
			Kd_SPEBRK_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEBRK_M] ) ;
			Kd_SPEFAR_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEFAR_M] ) ;
			Kd_SPEFAR2_M    += atof( ptb_InRec_Cur[CTRSTAT_SPEFAR2_M] ) ;
			Kd_SPESP_M      += atof( ptb_InRec_Cur[CTRSTAT_SPESP_M] ) ;
			Kd_SPEEPS_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEEPS_M] ) ;
			Kd_SPERPS_M     += atof( ptb_InRec_Cur[CTRSTAT_SPERPS_M] ) ;
			Kd_SPESAP_M     += atof( ptb_InRec_Cur[CTRSTAT_SPESAP_M] ) ;
			Kd_SPEPBPAP_M   += atof( ptb_InRec_Cur[CTRSTAT_SPEPBPAP_M] ) ;
			Kd_SPELOSS_M    += atof( ptb_InRec_Cur[CTRSTAT_SPELOSS_M] ) ;
			Kd_SPESNEM_M    += atof( ptb_InRec_Cur[CTRSTAT_SPESNEM_M] ) ;
			Kd_SPERPCCS_M   += atof( ptb_InRec_Cur[CTRSTAT_SPERPCCS_M] ) ;
			Kd_SPEBLKPL_M   += atof( ptb_InRec_Cur[CTRSTAT_SPEBLKPL_M] ) ;
			Kd_SPEBLKOSL_M  += atof( ptb_InRec_Cur[CTRSTAT_SPEBLKOSL_M] ) ;
			Kd_SPEIBNR2_M   += atof( ptb_InRec_Cur[CTRSTAT_SPEIBNR2_M] ) ;
			Kd_SPERESN_M    += atof( ptb_InRec_Cur[CTRSTAT_SPERESN_M] ) ;
			Kd_SPERES_M     += atof( ptb_InRec_Cur[CTRSTAT_SPERES_M] ) ;
			Kd_SPEACR_M     += atof( ptb_InRec_Cur[CTRSTAT_SPEACR_M] ) ;

	/* ecriture en sortie au format de TCTRSTAT */
	/********************************************/
	fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
      ptb_InRec_Cur[CTRSTAT_CTR_NF],
      ptb_InRec_Cur[CTRSTAT_END_NT],
      ptb_InRec_Cur[CTRSTAT_SEC_NF],
      ptb_InRec_Cur[CTRSTAT_UWY_NF],
      ptb_InRec_Cur[CTRSTAT_UW_NT],

      ptb_InRec_Cur[CTRSTAT_SSD_CF],
      ptb_InRec_Cur[CTRSTAT_ESB_CF],
      ptb_InRec_Cur[CTRSTAT_SECINC_D],
      ptb_InRec_Cur[CTRSTAT_EXP_D],
      ptb_InRec_Cur[CTRSTAT_DIFMTH_NF],
      ptb_InRec_Cur[CTRSTAT_CTRNAT_CT],
      ptb_InRec_Cur[CTRSTAT_CTRRET_B],
      ptb_InRec_Cur[CTRSTAT_SECSTS_CT],
      ptb_InRec_Cur[CTRSTAT_LOB_CF],
      ptb_InRec_Cur[CTRSTAT_TOP_CF],
      ptb_InRec_Cur[CTRSTAT_SOB_CF],
      ptb_InRec_Cur[CTRSTAT_PRDCOD_CT],
      ptb_InRec_Cur[CTRSTAT_NAT_CF],
      ptb_InRec_Cur[CTRSTAT_GAR_CF],
      ptb_InRec_Cur[CTRSTAT_DIV_NT],
      ptb_InRec_Cur[CTRSTAT_PCPRSKTRY_CF],
      ptb_InRec_Cur[CTRSTAT_USRCRTCOD_CT],
      ptb_InRec_Cur[CTRSTAT_USRCRTVAL_LM],
      ptb_InRec_Cur[CTRSTAT_SECQUA_CF],
      ptb_InRec_Cur[CTRSTAT_SECQUA2_CF],
      ptb_InRec_Cur[CTRSTAT_SECQUA3_CF],
      ptb_InRec_Cur[CTRSTAT_SECQUA4_CF],
      ptb_InRec_Cur[CTRSTAT_SECQUA5_CF],
      ptb_InRec_Cur[CTRSTAT_WRKCAT_CT],
      ptb_InRec_Cur[CTRSTAT_UWGRP_CF],
      ptb_InRec_Cur[CTRSTAT_ADMGRP_CF],
      ptb_InRec_Cur[CTRSTAT_UWORG_CF],
      ptb_InRec_Cur[CTRSTAT_ANLCTY_NF],
      ptb_InRec_Cur[CTRSTAT_CED_NF],
      ptb_InRec_Cur[CTRSTAT_ORGCED_NF],
      ptb_InRec_Cur[CTRSTAT_PRD_NF],
      ptb_InRec_Cur[CTRSTAT_REITYP_CF],
      ptb_InRec_Cur[CTRSTAT_ACCADMTYP_CF],
      ptb_InRec_Cur[CTRSTAT_SECACCSTS_CT],
      ptb_InRec_Cur[CTRSTAT_ACCFRQ_CT],
      ptb_InRec_Cur[CTRSTAT_CMPACCPER_NF],
      ptb_InRec_Cur[CTRSTAT_LSTCEDPER_NF],
      ptb_InRec_Cur[CTRSTAT_PRMPRTSCL_B],
      ptb_InRec_Cur[CTRSTAT_ERNPRMADM_B],
      ptb_InRec_Cur[CTRSTAT_INSPOL_R],
      ptb_InRec_Cur[CTRSTAT_POLDURMTH_NF],
      ptb_InRec_Cur[CTRSTAT_COMTYP_CT],
      ptb_InRec_Cur[CTRSTAT_COM_R],
      ptb_InRec_Cur[CTRSTAT_MINCOM_R],
      ptb_InRec_Cur[CTRSTAT_OVRCOM_R],
      ptb_InRec_Cur[CTRSTAT_TAX_R],
      ptb_InRec_Cur[CTRSTAT_BRK_R],
      ptb_InRec_Cur[CTRSTAT_REIEXI_B],
      ptb_InRec_Cur[CTRSTAT_REIFRE_B],
      ptb_InRec_Cur[CTRSTAT_PRFCOMEXI_B],
      ptb_InRec_Cur[CTRSTAT_LOSCTBEXI_B],
      ptb_InRec_Cur[CTRSTAT_LOSCOREXI_B],
      ptb_InRec_Cur[CTRSTAT_CBIRETCED_R],
      ptb_InRec_Cur[CTRSTAT_PBIRETCED_R],
      ptb_InRec_Cur[CTRSTAT_CBERETCED_R],
      ptb_InRec_Cur[CTRSTAT_PBERETCED_R],
      ptb_InRec_Cur[CTRSTAT_EGPCUR_CF],
      ptb_InRec_Cur[CTRSTAT_SBJPRM_M],
      ptb_InRec_Cur[CTRSTAT_SBJPRMCPT_M],
      ptb_InRec_Cur[CTRSTAT_SBJCPTDEF_B],
      ptb_InRec_Cur[CTRSTAT_SCOSHA_R],
      ptb_InRec_Cur[CTRSTAT_PMLRAT_R],
      ptb_InRec_Cur[CTRSTAT_SCOEGP_M],
      ptb_InRec_Cur[CTRSTAT_QUOT_CT],
      ptb_InRec_Cur[CTRSTAT_PRMFINEFF_R],
      ptb_InRec_Cur[CTRSTAT_PRMMAXEFF_R],
      ptb_InRec_Cur[CTRSTAT_PRMFINACT_R],
      ptb_InRec_Cur[CTRSTAT_PRMMAXACT_R],
      ptb_InRec_Cur[CTRSTAT_CLMPRMACT_R],
      ptb_InRec_Cur[CTRSTAT_PRMPRT_M],
      ptb_InRec_Cur[CTRSTAT_EGPRPCC_M],
      ptb_InRec_Cur[CTRSTAT_CALAMTPRM_M],
      ptb_InRec_Cur[CTRSTAT_ENTAMTPRM_M],
      ptb_InRec_Cur[CTRSTAT_RETAMTPRM_M],
      ptb_InRec_Cur[CTRSTAT_ADMMODPRM_CT],
      ptb_InRec_Cur[CTRSTAT_CALAMTCLM_M],
      ptb_InRec_Cur[CTRSTAT_ENTAMTCLM_M],
      ptb_InRec_Cur[CTRSTAT_RETAMTCLM_M],
      ptb_InRec_Cur[CTRSTAT_ADMMODCLM_CT],
      ptb_InRec_Cur[CTRSTAT_RESPRM_M],
      ptb_InRec_Cur[CTRSTAT_ULTPMLRAT_R],
      ptb_InRec_Cur[CTRSTAT_ULTCRE_D],
      ptb_InRec_Cur[CTRSTAT_ULTORICOD_LS],
      ptb_InRec_Cur[CTRSTAT_ULTUPDUSR_CF],
      ptb_InRec_Cur[CTRSTAT_FLAPRM_M],
      ptb_InRec_Cur[CTRSTAT_PRVPRM_M],
      ptb_InRec_Cur[CTRSTAT_LAYCAP_M],
      ptb_InRec_Cur[CTRSTAT_ESTVRS_NF],
      ptb_InRec_Cur[CTRSTAT_ESTSEG_NF],
      ptb_InRec_Cur[CTRSTAT_ESTCUR_CF],
      ptb_InRec_Cur[CTRSTAT_ESTAMORAT_CT],
      ptb_InRec_Cur[CTRSTAT_ESTPRMAMT_M],
      ptb_InRec_Cur[CTRSTAT_ESTCLMAMT_M],
      ptb_InRec_Cur[CTRSTAT_ESTLOSRAT_R],
      ptb_InRec_Cur[CTRSTAT_ACTVRS_NF],
      ptb_InRec_Cur[CTRSTAT_ACTSEG_NF],
      ptb_InRec_Cur[CTRSTAT_ACTCUR_CF],
      ptb_InRec_Cur[CTRSTAT_ACTAMORAT_CT],
      ptb_InRec_Cur[CTRSTAT_ACTPRMAMT_M],
      ptb_InRec_Cur[CTRSTAT_ACTCLMAMT_M],
      ptb_InRec_Cur[CTRSTAT_ACTLOSRAT_R],
      Kd_CACCPRM_M,
      Kd_CACCEPP_M,
      Kd_CACCRPP_M,
      Kd_CACCPNA_M,
      Kd_CACCRESPRM_M,
      Kd_CACCRPCCP_M,
      Kd_CACCLOA_M,
      Kd_CACCBRK_M,
      Kd_CACCFAR_M,
      Kd_CACCFAR2_M,
      Kd_CACCSP_M,
      Kd_CACCEPS_M,
      Kd_CACCRPS_M,
      Kd_CACCSAP_M,
      Kd_CACCPBPAP_M,
      Kd_CACCLOSS_M,
      Kd_CACCSNEM_M,
      Kd_CACCRPCCS_M,
      Kd_CACCRESN_M,
      Kd_CACCRES_M,
      Kd_CACCACR_M,
      Kd_IACCPRM_M,
      Kd_IACCEPP_M,
      Kd_IACCRPP_M,
      Kd_IACCPNA_M,
      Kd_IACCRESPRM_M,
      Kd_IACCRPCCP_M,
      Kd_IACCLOA_M,
      Kd_IACCBRK_M,
      Kd_IACCFAR_M,
      Kd_IACCFAR2_M,
      Kd_IACCSP_M,
      Kd_IACCEPS_M,
      Kd_IACCRPS_M,
      Kd_IACCSAP_M,
      Kd_IACCPBPAP_M,
      Kd_IACCLOSS_M,
      Kd_IACCSNEM_M,
      Kd_IACCRPCCS_M,
      Kd_IACCRESN_M,
      Kd_IACCRES_M,
      Kd_IACCACR_M,
      Kd_ESTPRM_M,
      Kd_ESTEPP_M,
      Kd_ESTRPP_M,
      Kd_ESTPNA_M,
      Kd_ESTRESPRM_M,
      Kd_ESTRPCCP_M,
      Kd_ESTLOA_M,
      Kd_ESTBRK_M,
      Kd_ESTFAR_M,
      Kd_ESTFAR2_M,
      Kd_ESTSP_M,
      Kd_ESTEPS_M,
      Kd_ESTRPS_M,
      Kd_ESTSAP_M,
      Kd_ESTPBPAP_M,
      Kd_ESTLOSS_M,
      Kd_ESTSNEM_M,
      Kd_ESTRPCCS_M,
      Kd_ESTBLKPL_M,
      Kd_ESTBLKOSL_M,
      Kd_ESTIBNR2_M,
      Kd_ESTRESN_M,
      Kd_ESTRES_M,
      Kd_ESTACR_M,
      Kd_SPEPRM_M,
      Kd_SPEEPP_M,
      Kd_SPERPP_M,
      Kd_SPEPNA_M,
      Kd_SPERESPRM_M,
      Kd_SPERPCCP_M,
      Kd_SPELOA_M,
      Kd_SPEBRK_M,
      Kd_SPEFAR_M,
      Kd_SPEFAR2_M,
      Kd_SPESP_M,
      Kd_SPEEPS_M,
      Kd_SPERPS_M,
      Kd_SPESAP_M,
      Kd_SPEPBPAP_M,
      Kd_SPELOSS_M,
      Kd_SPESNEM_M,
      Kd_SPERPCCS_M,
      Kd_SPEBLKPL_M,
      Kd_SPEBLKOSL_M,
      Kd_SPEIBNR2_M,
      Kd_SPERESN_M,
      Kd_SPERES_M,
      Kd_SPEACR_M,
      ptb_InRec_Cur[CTRSTAT_CEDHORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_CEDSORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_ORGCEDHORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_ORGCEDSORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_BRKHORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_BRKSORDNBR_NT],
      ptb_InRec_Cur[CTRSTAT_FACADMTYP_B],
      ptb_InRec_Cur[CTRSTAT_CLIIND_NF],
      ptb_InRec_Cur[CTRSTAT_HORDNBR_NT],  
      ptb_InRec_Cur[CTRSTAT_PRS_CF] );

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l’esclave

retour :
	OK
==============================================================================*/
int n_InitStat( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStat" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESPO1002_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncStat ;

/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneStat ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncStat(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncStat" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_CTR_NF], pbd_InRecChild[CTRSTAT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_END_NT], pbd_InRecChild[CTRSTAT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_SEC_NF], pbd_InRecChild[CTRSTAT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_UWY_NF], pbd_InRecChild[CTRSTAT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_UW_NT],  pbd_InRecChild[CTRSTAT_UW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[CTRSTAT_PRS_CF], pbd_InRecChild[CTRSTAT_PRS_CF]) ) !=0  ) return ret ;  // [002]

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneStat(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneStat" ) ;

	/* Cumul des montants */
			Kd_CACCPRM_M    += atof( ptb_InRecChild[CTRSTAT_CACCPRM_M] ) ;
			Kd_CACCEPP_M    += atof( ptb_InRecChild[CTRSTAT_CACCEPP_M] ) ;
			Kd_CACCRPP_M    += atof( ptb_InRecChild[CTRSTAT_CACCRPP_M]) ;
			Kd_CACCPNA_M    += atof( ptb_InRecChild[CTRSTAT_CACCPNA_M]) ;
			Kd_CACCRESPRM_M += atof( ptb_InRecChild[CTRSTAT_CACCRESPRM_M]) ;
			Kd_CACCRPCCP_M  += atof( ptb_InRecChild[CTRSTAT_CACCRPCCP_M ]) ;
			Kd_CACCLOA_M    += atof( ptb_InRecChild[CTRSTAT_CACCLOA_M] ) ;
			Kd_CACCBRK_M    += atof( ptb_InRecChild[CTRSTAT_CACCBRK_M] ) ;
			Kd_CACCFAR_M    += atof( ptb_InRecChild[CTRSTAT_CACCFAR_M] ) ;
			Kd_CACCFAR2_M   += atof( ptb_InRecChild[CTRSTAT_CACCFAR2_M] ) ;
			Kd_CACCSP_M     += atof( ptb_InRecChild[CTRSTAT_CACCSP_M] ) ;
			Kd_CACCEPS_M    += atof( ptb_InRecChild[CTRSTAT_CACCEPS_M] ) ;
			Kd_CACCRPS_M    += atof( ptb_InRecChild[CTRSTAT_CACCRPS_M] ) ;
			Kd_CACCSAP_M    += atof( ptb_InRecChild[CTRSTAT_CACCSAP_M] ) ;
			Kd_CACCPBPAP_M  += atof( ptb_InRecChild[CTRSTAT_CACCPBPAP_M] ) ;
			Kd_CACCLOSS_M   += atof( ptb_InRecChild[CTRSTAT_CACCLOSS_M] ) ;
			Kd_CACCSNEM_M   += atof( ptb_InRecChild[CTRSTAT_CACCSNEM_M ] ) ;
			Kd_CACCRPCCS_M  += atof( ptb_InRecChild[CTRSTAT_CACCRPCCS_M] ) ;
			Kd_CACCRESN_M   += atof( ptb_InRecChild[CTRSTAT_CACCRESN_M] ) ;
			Kd_CACCRES_M    += atof( ptb_InRecChild[CTRSTAT_CACCRES_M] ) ;
			Kd_CACCACR_M    += atof( ptb_InRecChild[CTRSTAT_CACCACR_M] ) ;
			Kd_IACCPRM_M    += atof( ptb_InRecChild[CTRSTAT_IACCPRM_M] ) ;
			Kd_IACCEPP_M    += atof( ptb_InRecChild[CTRSTAT_IACCEPP_M] ) ;
			Kd_IACCRPP_M    += atof( ptb_InRecChild[CTRSTAT_IACCRPP_M] ) ;
			Kd_IACCPNA_M    += atof( ptb_InRecChild[CTRSTAT_IACCPNA_M] ) ;
			Kd_IACCRESPRM_M += atof( ptb_InRecChild[CTRSTAT_IACCRESPRM_M] ) ;
			Kd_IACCRPCCP_M  += atof( ptb_InRecChild[CTRSTAT_IACCRPCCP_M] ) ;
			Kd_IACCLOA_M    += atof( ptb_InRecChild[CTRSTAT_IACCLOA_M] ) ;
			Kd_IACCBRK_M    += atof( ptb_InRecChild[CTRSTAT_IACCBRK_M] ) ;
			Kd_IACCFAR_M    += atof( ptb_InRecChild[CTRSTAT_IACCFAR_M] ) ;
			Kd_IACCFAR2_M   += atof( ptb_InRecChild[CTRSTAT_IACCFAR2_M] ) ;
			Kd_IACCSP_M     += atof( ptb_InRecChild[CTRSTAT_IACCSP_M] ) ;
			Kd_IACCEPS_M    += atof( ptb_InRecChild[CTRSTAT_IACCEPS_M] ) ;
			Kd_IACCRPS_M    += atof( ptb_InRecChild[CTRSTAT_IACCRPS_M] ) ;
			Kd_IACCSAP_M    += atof( ptb_InRecChild[CTRSTAT_IACCSAP_M] ) ;
			Kd_IACCPBPAP_M  += atof( ptb_InRecChild[CTRSTAT_IACCPBPAP_M] ) ;
			Kd_IACCLOSS_M   += atof( ptb_InRecChild[CTRSTAT_IACCLOSS_M] ) ;
			Kd_IACCSNEM_M   += atof( ptb_InRecChild[CTRSTAT_IACCSNEM_M] ) ;
			Kd_IACCRPCCS_M  += atof( ptb_InRecChild[CTRSTAT_IACCRPCCS_M] ) ;
			Kd_IACCRESN_M   += atof( ptb_InRecChild[CTRSTAT_IACCRESN_M] ) ;
			Kd_IACCRES_M    += atof( ptb_InRecChild[CTRSTAT_IACCRES_M] ) ;
			Kd_IACCACR_M    += atof( ptb_InRecChild[CTRSTAT_IACCACR_M] ) ;
			Kd_ESTPRM_M     += atof( ptb_InRecChild[CTRSTAT_ESTPRM_M] ) ;
			Kd_ESTEPP_M     += atof( ptb_InRecChild[CTRSTAT_ESTEPP_M] ) ;
			Kd_ESTRPP_M     += atof( ptb_InRecChild[CTRSTAT_ESTRPP_M] ) ;
			Kd_ESTPNA_M     += atof( ptb_InRecChild[CTRSTAT_ESTPNA_M] ) ;
			Kd_ESTRESPRM_M  += atof( ptb_InRecChild[CTRSTAT_ESTRESPRM_M] ) ;
			Kd_ESTRPCCP_M   += atof( ptb_InRecChild[CTRSTAT_ESTRPCCP_M] ) ;
			Kd_ESTLOA_M     += atof( ptb_InRecChild[CTRSTAT_ESTLOA_M] ) ;
			Kd_ESTBRK_M     += atof( ptb_InRecChild[CTRSTAT_ESTBRK_M] ) ;
			Kd_ESTFAR_M     += atof( ptb_InRecChild[CTRSTAT_ESTFAR_M] ) ;
			Kd_ESTFAR2_M    += atof( ptb_InRecChild[CTRSTAT_ESTFAR2_M] ) ;
			Kd_ESTSP_M      += atof( ptb_InRecChild[CTRSTAT_ESTSP_M] ) ;
			Kd_ESTEPS_M     += atof( ptb_InRecChild[CTRSTAT_ESTEPS_M] ) ;
			Kd_ESTRPS_M     += atof( ptb_InRecChild[CTRSTAT_ESTRPS_M] ) ;
			Kd_ESTSAP_M     += atof( ptb_InRecChild[CTRSTAT_ESTSAP_M] ) ;
			Kd_ESTPBPAP_M   += atof( ptb_InRecChild[CTRSTAT_ESTPBPAP_M] ) ;
			Kd_ESTLOSS_M    += atof( ptb_InRecChild[CTRSTAT_ESTLOSS_M] ) ;
			Kd_ESTSNEM_M    += atof( ptb_InRecChild[CTRSTAT_ESTSNEM_M] ) ;
			Kd_ESTRPCCS_M   += atof( ptb_InRecChild[CTRSTAT_ESTRPCCS_M] ) ;
			Kd_ESTBLKPL_M   += atof( ptb_InRecChild[CTRSTAT_ESTBLKPL_M] ) ;
			Kd_ESTBLKOSL_M  += atof( ptb_InRecChild[CTRSTAT_ESTBLKOSL_M] ) ;
			Kd_ESTIBNR2_M   += atof( ptb_InRecChild[CTRSTAT_ESTIBNR2_M] ) ;
			Kd_ESTRESN_M    += atof( ptb_InRecChild[CTRSTAT_ESTRESN_M] ) ;
			Kd_ESTRES_M     += atof( ptb_InRecChild[CTRSTAT_ESTRES_M] ) ;
			Kd_ESTACR_M     += atof( ptb_InRecChild[CTRSTAT_ESTACR_M] ) ;
			Kd_SPEPRM_M     += atof( ptb_InRecChild[CTRSTAT_SPEPRM_M] ) ;
			Kd_SPEEPP_M     += atof( ptb_InRecChild[CTRSTAT_SPEEPP_M] ) ;
			Kd_SPERPP_M     += atof( ptb_InRecChild[CTRSTAT_SPERPP_M] ) ;
			Kd_SPEPNA_M     += atof( ptb_InRecChild[CTRSTAT_SPEPNA_M] ) ;
			Kd_SPERESPRM_M  += atof( ptb_InRecChild[CTRSTAT_SPERESPRM_M] ) ;
			Kd_SPERPCCP_M   += atof( ptb_InRecChild[CTRSTAT_SPERPCCP_M] ) ;
			Kd_SPELOA_M     += atof( ptb_InRecChild[CTRSTAT_SPELOA_M] ) ;
			Kd_SPEBRK_M     += atof( ptb_InRecChild[CTRSTAT_SPEBRK_M] ) ;
			Kd_SPEFAR_M     += atof( ptb_InRecChild[CTRSTAT_SPEFAR_M] ) ;
			Kd_SPEFAR2_M    += atof( ptb_InRecChild[CTRSTAT_SPEFAR2_M] ) ;
			Kd_SPESP_M      += atof( ptb_InRecChild[CTRSTAT_SPESP_M] ) ;
			Kd_SPEEPS_M     += atof( ptb_InRecChild[CTRSTAT_SPEEPS_M] ) ;
			Kd_SPERPS_M     += atof( ptb_InRecChild[CTRSTAT_SPERPS_M] ) ;
			Kd_SPESAP_M     += atof( ptb_InRecChild[CTRSTAT_SPESAP_M] ) ;
			Kd_SPEPBPAP_M   += atof( ptb_InRecChild[CTRSTAT_SPEPBPAP_M] ) ;
			Kd_SPELOSS_M    += atof( ptb_InRecChild[CTRSTAT_SPELOSS_M] ) ;
			Kd_SPESNEM_M    += atof( ptb_InRecChild[CTRSTAT_SPESNEM_M] ) ;
			Kd_SPERPCCS_M   += atof( ptb_InRecChild[CTRSTAT_SPERPCCS_M] ) ;
			Kd_SPEBLKPL_M   += atof( ptb_InRecChild[CTRSTAT_SPEBLKPL_M] ) ;
			Kd_SPEBLKOSL_M  += atof( ptb_InRecChild[CTRSTAT_SPEBLKOSL_M] ) ;
			Kd_SPEIBNR2_M   += atof( ptb_InRecChild[CTRSTAT_SPEIBNR2_M] ) ;
			Kd_SPERESN_M    += atof( ptb_InRecChild[CTRSTAT_SPERESN_M] ) ;
			Kd_SPERES_M     += atof( ptb_InRecChild[CTRSTAT_SPERES_M] ) ;
			Kd_SPEACR_M     += atof( ptb_InRecChild[CTRSTAT_SPEACR_M] ) ;


	RETURN_VAL( OK ) ;
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

	Kd_CACCPRM_M    = 0;
	Kd_CACCEPP_M    = 0;
	Kd_CACCRPP_M    = 0;
	Kd_CACCPNA_M    = 0;
	Kd_CACCRESPRM_M = 0;
	Kd_CACCRPCCP_M  = 0;
	Kd_CACCLOA_M    = 0;
	Kd_CACCBRK_M    = 0;
	Kd_CACCFAR_M    = 0;
	Kd_CACCFAR2_M   = 0;
	Kd_CACCSP_M     = 0;
	Kd_CACCEPS_M    = 0;
	Kd_CACCRPS_M    = 0;
	Kd_CACCSAP_M    = 0;
	Kd_CACCPBPAP_M  = 0;
	Kd_CACCLOSS_M   = 0;
	Kd_CACCSNEM_M   = 0;
	Kd_CACCRPCCS_M  = 0;
	Kd_CACCRESN_M   = 0;
	Kd_CACCRES_M    = 0;
	Kd_CACCACR_M    = 0;
  Kd_IACCPRM_M    = 0;
	Kd_IACCEPP_M    = 0;
	Kd_IACCRPP_M    = 0;
	Kd_IACCPNA_M    = 0;
	Kd_IACCRESPRM_M = 0;
	Kd_IACCRPCCP_M  = 0;
	Kd_IACCLOA_M    = 0;
	Kd_IACCBRK_M    = 0;
	Kd_IACCFAR_M    = 0;
	Kd_IACCFAR2_M   = 0;
	Kd_IACCSP_M     = 0;
	Kd_IACCEPS_M    = 0;
	Kd_IACCRPS_M    = 0;
	Kd_IACCSAP_M    = 0;
	Kd_IACCPBPAP_M  = 0;
	Kd_IACCLOSS_M   = 0;
	Kd_IACCSNEM_M   = 0;
	Kd_IACCRPCCS_M  = 0;
	Kd_IACCRESN_M   = 0;
	Kd_IACCRES_M    = 0;
	Kd_IACCACR_M    = 0;
	Kd_ESTPRM_M     = 0;
  Kd_ESTEPP_M     = 0;
	Kd_ESTRPP_M     = 0;
	Kd_ESTPNA_M     = 0;
	Kd_ESTRESPRM_M  = 0;
	Kd_ESTRPCCP_M   = 0;
	Kd_ESTLOA_M     = 0;
	Kd_ESTBRK_M     = 0;
	Kd_ESTFAR_M     = 0;
	Kd_ESTFAR2_M    = 0;
	Kd_ESTSP_M      = 0;
	Kd_ESTEPS_M     = 0;
	Kd_ESTRPS_M     = 0;
	Kd_ESTSAP_M     = 0;
	Kd_ESTPBPAP_M   = 0;
	Kd_ESTLOSS_M    = 0;
	Kd_ESTSNEM_M    = 0;
	Kd_ESTRPCCS_M   = 0;
	Kd_ESTBLKPL_M   = 0;
	Kd_ESTBLKOSL_M  = 0;
	Kd_ESTIBNR2_M   = 0;
	Kd_ESTRESN_M    = 0;
	Kd_ESTRES_M     = 0;
	Kd_ESTACR_M     = 0;
	Kd_SPEPRM_M     = 0;
	Kd_SPEEPP_M     = 0;
  Kd_SPERPP_M     = 0;
	Kd_SPEPNA_M     = 0;
	Kd_SPERESPRM_M  = 0;
	Kd_SPERPCCP_M   = 0;
	Kd_SPELOA_M     = 0;
	Kd_SPEBRK_M     = 0;
	Kd_SPEFAR_M     = 0;
	Kd_SPEFAR2_M    = 0;
	Kd_SPESP_M      = 0;
	Kd_SPEEPS_M     = 0;
	Kd_SPERPS_M     = 0;
	Kd_SPESAP_M     = 0;
	Kd_SPEPBPAP_M   = 0;
	Kd_SPELOSS_M    = 0;
	Kd_SPESNEM_M    = 0;
	Kd_SPERPCCS_M   = 0;
	Kd_SPEBLKPL_M   = 0;
	Kd_SPEBLKOSL_M  = 0;
	Kd_SPEIBNR2_M   = 0;
	Kd_SPERESN_M    = 0;
	Kd_SPERES_M     = 0;
	Kd_SPEACR_M     = 0;

	RETURN_VAL( OK ) ;
}


