/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC3605.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 07/10/1998
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   	Generation d'un fichier au format TCTRSTAT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
   14/03/2000     O.GIRAUX    Rajout de 2 colonnes vides dans TCTRSTAT (CLIIND_NF et HORDNBR_NT )
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[003] 07/12/2012 R. Cassis   :spot:24041 Solvency : si colonne prs_cf existante, enregistrement créé
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "ESTC3605.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define STAT_CTR_NF	0
#define STAT_END_NT	1
#define STAT_SEC_NF	2
#define STAT_UWY_NF	3
#define STAT_UW_NT	4
#define STAT_ACMTRS_NT	5
#define STAT_COD_CT	6
#define STAT_AMT_M	7

#define ULTIM_CTR_NF	0
#define ULTIM_END_NT	1
#define ULTIM_SEC_NF	2
#define ULTIM_UWY_NF	3
#define ULTIM_UW_NT	4
#define ULTIM_FACADMTYP_B 124

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFil ; /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR  	   	bd_RuptUltimates ; /* variable de gestion de la rupture sur le fichier maitre */
T_RUPTURE_SYNC_VAR 	bd_RuptStat ; 	   /* variable de gestion de la synchronisation avec le fichier versements */

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

static char Ksz_Vide[2]="";                 /* spot 15219 */

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
	if ( n_OpenFileAppl ( "ESTC3605_O1","wt",&Kp_OutputFil ) == ERR )
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

	if ( n_CloseFileAppl( "ESTC3605_I1", &( bd_RuptUltimates.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3605_I2", &( bd_RuptStat.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC3605_O1", &Kp_OutputFil ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC3605_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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

	/* calcul des champs cumules */
	/*****************************/
	Kd_CaccResn = Kd_CaccPrm + Kd_CaccEpp + Kd_CaccRpp + Kd_CaccPna +
		Kd_CaccResPrm + Kd_CaccRpccp + Kd_CaccLoa + Kd_CaccFar +
		Kd_CaccSp + Kd_CaccEps + Kd_CaccRps + Kd_CaccSap +
		Kd_CaccLoss + Kd_CaccAcr + Kd_CaccSnem + Kd_CaccRpccs ;
	Kd_CaccRes = Kd_CaccResn + Kd_CaccBrk + Kd_CaccFar2 + Kd_CaccPbPap ;

	Kd_IaccResn = Kd_IaccPrm + Kd_IaccEpp + Kd_IaccRpp + Kd_IaccPna +
		Kd_IaccResPrm + Kd_IaccRpccp + Kd_IaccLoa + Kd_IaccFar +
		Kd_IaccSp + Kd_IaccEps + Kd_IaccRps + Kd_IaccSap +
		Kd_IaccLoss + Kd_IaccAcr + Kd_IaccSnem + Kd_IaccRpccs ;
	Kd_IaccRes = Kd_IaccResn + Kd_IaccBrk + Kd_IaccFar2 + Kd_IaccPbPap ;

	Kd_EstResn = Kd_EstPrm + Kd_EstEpp + Kd_EstRpp + Kd_EstPna +
		Kd_EstResPrm + Kd_EstRpccp + Kd_EstLoa + Kd_EstFar +
		Kd_EstSp + Kd_EstEps + Kd_EstRps + Kd_EstSap +
		Kd_EstLoss + Kd_EstAcr + Kd_EstSnem + Kd_EstRpccs +
		Kd_EstBlkPl + Kd_EstBlkOsl + Kd_EstIbnr2 ;
	Kd_EstRes = Kd_EstResn + Kd_EstBrk + Kd_EstFar2 + Kd_EstPbPap ;

	Kd_SpeResn = Kd_SpePrm + Kd_SpeEpp + Kd_SpeRpp + Kd_SpePna +
		Kd_SpeResPrm + Kd_SpeRpccp + Kd_SpeLoa + Kd_SpeFar +
		Kd_SpeSp + Kd_SpeEps + Kd_SpeRps + Kd_SpeSap +
		Kd_SpeLoss + Kd_SpeAcr + Kd_SpeSnem + Kd_SpeRpccs +
		Kd_SpeBlkPl + Kd_SpeBlkOsl + Kd_SpeIbnr2 ;
	Kd_SpeRes = Kd_SpeResn + Kd_SpeBrk + Kd_SpeFar2 + Kd_SpePbPap ;

	//[003]
	if (ptb_InRec_Cur[CTRSTAT2_PRS_CF] == 0 )
	{
		/* ecriture en sortie au format de TCTRSTAT */
		/********************************************/
		fprintf( Kp_OutputFil, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
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
			ptb_InRec_Cur[CTRSTAT_CEDHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT_CEDSORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT_ORGCEDHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT_ORGCEDSORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT_BRKHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT_BRKSORDNBR_NT],
		  	ptb_InRec_Cur[ULTIM_FACADMTYP_B],
   	             Ksz_Vide,   /* CLIIND_NF */
   	             Ksz_Vide) ;  /* HORDNBR_NT */
	}
	else
	{
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
			ptb_InRec_Cur[CTRSTAT2_CEDHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_CEDSORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_ORGCEDHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_ORGCEDSORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_BRKHORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_BRKSORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_FACADMTYP_B],
			ptb_InRec_Cur[CTRSTAT2_CLIIND_NF],
			ptb_InRec_Cur[CTRSTAT2_HORDNBR_NT],
			ptb_InRec_Cur[CTRSTAT2_PRS_CF]);
	}	
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
	if ( n_OpenFileAppl( "ESTC3605_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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

	if ( ( ret = strcmp( pbd_InRecOwner[ULTIM_CTR_NF], pbd_InRecChild[STAT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[ULTIM_END_NT], pbd_InRecChild[STAT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[ULTIM_SEC_NF], pbd_InRecChild[STAT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[ULTIM_UWY_NF], pbd_InRecChild[STAT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[ULTIM_UW_NT], pbd_InRecChild[STAT_UW_NT] ) ) != 0 ) return ret ;

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
	switch( atol( ptb_InRecChild[STAT_ACMTRS_NT] ) )
	{
	case 10000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccPrm = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccPrm = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstPrm = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpePrm = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 12000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 13000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeResPrm += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10020 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccEpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccEpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstEpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeEpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10010 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccRpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccRpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstRpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeRpp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccPna = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccPna = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstPna = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpePna = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 19000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccRpccp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccRpccp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstRpccp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeRpccp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10100 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccLoa = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccLoa = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstLoa = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeLoa = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10130 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccFar = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccFar = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstFar = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeFar = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 20000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccSp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccSp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstSp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeSp = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 20020 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccEps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccEps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstEps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeEps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 20010 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccRps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccRps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstRps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeRps = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 21000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccLoss = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccLoss = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstLoss = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeLoss = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 20030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccSap = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccSap = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstSap = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeSap = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 26030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccAcr = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccAcr = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstAcr = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeAcr = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 28030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccSnem = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccSnem = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstSnem = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeSnem = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 29000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccRpccs = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccRpccs = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstRpccs = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeRpccs = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 25000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstBlkPl = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeBlkPl = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 25030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstBlkOsl = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeBlkOsl = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 24030 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstIbnr2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeIbnr2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10400 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccBrk = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccBrk = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstBrk = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeBrk = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 10430 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccFar2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccFar2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstFar2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpeFar2 = atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 22000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpePbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}

	case 23000 :
		if ( *ptb_InRecChild[STAT_COD_CT] == 'C' )
		{
			Kd_CaccPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'I' )
		{
			Kd_IaccPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'E' )
		{
			Kd_EstPbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
		if ( *ptb_InRecChild[STAT_COD_CT] == 'S' )
		{
			Kd_SpePbPap += atof( ptb_InRecChild[STAT_AMT_M] ) ;
			break ;
		}
	}

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


