/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1016.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 31/07/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   DETERMINATION DES TAUX DE CHARGES

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

   27/08/1998	  M.HA-THUC   	EVOL - Commission origine multiple
				Suppression de la synchro de FURRDAC

   20/02/2006	  J. Ribot    	EVOL - augmentation taille table charges 50 a 90
				                             ajout message alerte de depassement de capacite de la table
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[004] 16/01/2012 Roger Cassis  :spot:23189  - Augmentation de la taille du tableau des familles de charges NB_FAM_MAX dans le ESTC1016.h de 90 a 500
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
[005] 11/04/2018 S.Behague     :spira 65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE
[006] 11/05/2018 M.NAJI        :SPIRA:61503  Calculation of Taxes (using a new "Based On" field added on TRT) 
[007] 20/05/2019 MZM           :spira 70815 Colonne TAX non renseignee
[008] 03/07/2019 R. Cassis     :spira:65656 - prs_cf is added as parameter for IFRS4 (710) or EBS (730)
[009] 21/10/2019 MZM           :spira:81824 Sliding commission - number of digits for commission rate  (Technical Change)
[010] 25/10/2019 MZM           Revert de spira:81824 Sliding commission - number of digits for commission rate  (Technical Change)
[011] 24/01/2020 HR            spira 81824: addition of variable sz_RetAmtBuff in order to have a format of 8 digit in the output file 
[012] 02/07/2020 KBagwe            spira 81022: REQ19.6 - NDIC discount 
[013] 30/09/2020 MZM           Spira 88836 : Rupture sur No Section numerique si le CHAIN est egale à ESFD2220)  
[017] 15/10/2025 MZM : US 5637 Fix ITK : Augmentation de NB_FAM_MAX de 500 A 1000 dans (ESTC1016.h)
[017] 22/01/2026 MZM : US 7847 Fix ITK : Augmentation de NB_FAM_MAX de 500 A 1000 dans (ESTC1016.h)
==============================================================================*/
 
/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "estserv.h"
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1016.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/ 
/* variables de travail */
/*----------------------*/
 
FILE 		*Kp_OutputFilCtrEst ; /* pointeur sur le fichier de sortie Estimations dommages */
FILE 		*Kp_OutputFilLoaRat ; /* pointeur sur le fichier de sortie Taux de charges */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le
					perimetre de souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFct ; /* variable de gestion de la synchronisation avec
					le fichier annexe du perimetre famille des charges taxes */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFci ; /* variable de gestion de la synchronisation avec
					le fichier annexe du perimetre famille de charges iterees */
T_RUPTURE_SYNC_VAR 	bd_RuptGtCum ; /* variable de gestion de la synchronisation avec
					le fichier GT cumule selectionne sur sinistres */
T_RUPTURE_SYNC_VAR 	bd_RuptGtPa ; /* variable de gestion de la synchronisation avec
					le fichier GT des Primes acquises */
T_RUPTURE_SYNC_VAR 	bd_RuptCtrEst ; /* variable de gestion de la synchronisation avec
					le fichier des estimations dommages */
T_RUPTURE_SYNC_VAR 	bd_RuptGtIbnr ; /* variable de gestion de la synchronisation avec
					le fichier GT des Ibnr */


char Ksz_CloDat[9] ;    /* parametre de la chaine: libelle d'inventaire */
char Ksz_Cre[20] ;    	/* date systeme */
char Ksz_TypInv[2] ;	/* parametre de la chaine: type d'inventaire P ou A */
char Ksz_Prs[4] ;	    /* parametre de la chaine: type de poste '710'(IFRS4) ou '730'(EBS) [008] */
char Ksz_NdicCalFlag[2] ;    /* NDIC Flag parameter. T means true and F means False [012]*/
char Ksz_Chain[10] ;	    /* parametre identifiant la chaine en cours d'execution  Par defaut CHAIN = ESFD2220*/


int Kn_CtrEstPa ;	/* variable de participation du fichier des Estimations dommages */

//[005]double	Kd_TaxGlo ; 	/* taux global de taxes par affaire */
double	Kd_TaxGloWP ; 	// taux global de taxes par affaire avec protefzuille   [005]
double	Kd_TaxGloWO ; 	// taux global de taxes par affaire sans portefeuille 	 [005]
char	Kc_AdmMod ;	/* mode de gestion de l'affaire */
double  Kd_RetAmt ;     /* montant retenu */
double  Kd_EntAmt ;	/* montant manuel */
double	Kd_ClmAmt ; 	/* sinistralites actuarielles comptabilisees */
double  Kd_PrmAmt ;	/* primes acquises comptabilisees */
T_TabFamCharIt  Ktbd_FamCha[NB_FAM_MAX] ; /* tableau des familles de charges iterees */
int	Kn_NbFam  ; 	/* nombre de postes du tableau Ktbd_FamCha */
char 	Ksz_ComRat_i[20] ; 	/* zone de travail intermediaire */

int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitCtrEst 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCtrEst		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCtrEst	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtPa			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPa		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPa		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtIbnr		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtIbnr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtIbnr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtCum			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtCum		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtCum	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerFct		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFct		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFct	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerFci 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFci		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFci	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


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
	char	sz_SysTime[9] ;
	
	//char sz_Chain[11];

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* recuperation des parametres de la chaine */
	/* strcpy( Ksz_Cre, psz_GetCharArgv( 1 ) ) ; modification du 03/02/98 */
	strcpy( Ksz_CloDat, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_TypInv, psz_GetCharArgv( 3 ) ) ;
	strcpy( Ksz_Prs, psz_GetCharArgv( 4 ) ) ;  // [008]
	strcpy( Ksz_NdicCalFlag, psz_GetCharArgv( 5 ) ) ;  // [012]
	strcpy( Ksz_Chain, psz_GetCharArgv( 6 ) ) ;  // [013]	
	
	
	//printf(" TEST Ksz_Chain = %s\n", Ksz_Chain) ;
	
	/* modification et formatage de la date de creation */
	RecSysDate( Ksz_Cre, sz_SysTime ) ;
	FormatTime( sz_SysTime, sz_SysTime ) ;
	strcat( Ksz_Cre, " " ) ;
	strcat( Ksz_Cre, sz_SysTime ) ;


	/* ouverture du fichier de sortie Estimations des dommages */
	if ( n_OpenFileAppl ( "ESTC1016_O1","wt",&Kp_OutputFilCtrEst ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des taux de charges */
	if ( n_OpenFileAppl ( "ESTC1016_O2","wt",&Kp_OutputFilLoaRat ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCtrEst */
	if ( n_InitCtrEst( &bd_RuptCtrEst ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtCum */
	if ( n_InitGtCum( &bd_RuptGtCum ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtPa */
	if ( n_InitGtPa( &bd_RuptGtPa ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtIbnr */
	if ( n_InitGtIbnr( &bd_RuptGtIbnr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFct */
	if ( n_InitPerFct( &bd_RuptPerFct ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFci */
	if ( n_InitPerFci( &bd_RuptPerFci ) )
		ExitPgm( ERR_XX , "" ) ;


/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I2", &( bd_RuptPerFct.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I3", &( bd_RuptPerFci.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I4", &( bd_RuptGtCum.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I5", &( bd_RuptGtPa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I6", &( bd_RuptCtrEst.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_I7", &( bd_RuptGtIbnr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_O2", &Kp_OutputFilLoaRat ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1016_O1", &Kp_OutputFilCtrEst ) == ERR )
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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1016_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **ptb_InRec_Cur )
{
	char *LoaRat[NB_COL_LOARAT + 1] ; /* tableau de pointeur a l'image du fichier de sortie
		Taux de charge */
	char sz_ComRat[20] ; /* zone de travail intermediaire */
	char sz_SurComRat[20] ; /* zone de travail intermediaire */
//[005]	char sz_ResRat[20] ; /* zone de travail intermediaire */
	char sz_ResRatWP[20] ; // zone de travail intermediaire  avec portefeuille  [005]
	char sz_ResRatWO[20] ; // zone de travail intermediaire  sans portefeuille  [005]
	char sz_GloCouRat[20] ; /* zone de travail intermediaire */
	char *CtrEst[NB_COL_CTREST + 1] ; /* tableau de pointeur a l'image du fichier de sortie
		des Estimations dommages */
	char sz_EntAmt[20] ; /* zone de travail intermediaire */
	char sz_RetAmt[20] ; /* zone de travail intermediaire */
        char sz_RetAmtBuff[20] ; /*modif spira 81824 HR */
	char sz_AdmMod[2] ; /* zone de travail intermediaire */
	double d_ComRat = 0 ; /* taux de commission cacule */
	double d_SurComRat = 0 ; /* taux de surcommission */
//[005]	double d_ResRat = 0 ; /* taux restitue */
	double d_ResRatWP = 0 ; //[005]
	double d_ResRatWO = 0 ; //[005]
	double d_GloCouRat = 0 ; /* taux de courtage global */

	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* initialisation des variables de travail */
	n_InitVariables( ) ;

	/* synchronisation avec le fichier Estimation Dommages */
	n_ProcessingRuptureSyncVar( &bd_RuptCtrEst, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier annexe famille des charges iterees */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFci, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier GT cumule selectionne sur sinistres */
	n_ProcessingRuptureSyncVar( &bd_RuptGtCum, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier GT des primes acquises */
	n_ProcessingRuptureSyncVar( &bd_RuptGtPa, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier GT des IBNR */
	n_ProcessingRuptureSyncVar( &bd_RuptGtIbnr, ptb_InRec_Cur ) ;


	if (strcmp(Ksz_NdicCalFlag, "T") == 0){	//[012]
		Kd_ClmAmt = 0;
		Kd_PrmAmt = 0;
	}

	/********************************************************/
	/* calcul de commissions fixes, variables ou originales */
	/********************************************************/
	d_ComRat = d_CalculChargesCommissions(
		(char)( atoi( ptb_InRec_Cur[PER_PRMNETCOM_B] ) ),
		( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'F' ? 1 : (char)( atoi( ptb_InRec_Cur[PER_COMTYP_CT] ) ) ),
		atof( ptb_InRec_Cur[PER_FIXCOM_R] ),
		atof( ptb_InRec_Cur[PER_MAXCOM_R] ),
		atof( ptb_InRec_Cur[PER_MINRATCLP_R] ),
		atof( ptb_InRec_Cur[PER_MINCOM_R] ),
		atof( ptb_InRec_Cur[PER_MAXRATCLP_R] ),
		Kd_ClmAmt, Kd_PrmAmt, Kn_NbFam, Ktbd_FamCha ) ;

	/* positionnement de la variable intermediaire */
	sprintf( Ksz_ComRat_i, "%-.8f", d_ComRat ) ;

	/***********************************************************/
	/* ecriture dans le fichier en sortie Estimations dommages */
	/***********************************************************/
	if ( *Ksz_TypInv == 'P' && atoi( ptb_InRec_Cur[PER_COMTYP_CT] ) == 2 )
	{
		CtrEst[EST_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
		CtrEst[EST_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
		CtrEst[EST_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
		CtrEst[EST_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
		CtrEst[EST_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
		CtrEst[EST_CRE_D] = Ksz_Cre ;
		CtrEst[EST_PRS_CF] = Ksz_Prs ;  // [008] "710" ;
		CtrEst[EST_ACMTRS_NT] = "10100" ;
		CtrEst[EST_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
		CtrEst[EST_DIV_NT] = ptb_InRec_Cur[PER_DIV_NT] ;
		CtrEst[EST_CUR_CF] = ptb_InRec_Cur[PER_EGPCUR_CF] ;
		CtrEst[EST_CALAMT_M] = sz_ComRat ;
		CtrEst[EST_ENTAMT_M] = sz_EntAmt ;
		CtrEst[EST_RETAMT_M] = sz_RetAmt ;
		CtrEst[EST_ADMMOD_CT] = sz_AdmMod ;
		CtrEst[EST_CLODAT_D] = Ksz_CloDat ;
		CtrEst[EST_ORICOD_LS] = "CloP" ;
		CtrEst[EST_UPDUSR_CF] = "ESTC1016" ;
		CtrEst[EST_CREUSR_CF] = "" ;
		CtrEst[EST_LSTUPD_D] = Ksz_Cre ;
		CtrEst[EST_LSTUPDUSR_CF] = "" ;
		CtrEst[EST_LSTUPDUSR_CF + 1] = NULL ;


		/* PB: les champs CALAMT_M, ENTAMT_M et RETAMT_M de la table TCTREST ont un format avec 3 decimales */

		sprintf( sz_ComRat, "%-.3f", d_ComRat ) ; //[009] [010] "%-.3f" --> "%-.5f"
		sprintf( sz_AdmMod, "%c", Kc_AdmMod ) ;

		/* si le fichier des Estimations dommages a participe */
		if ( Kn_CtrEstPa == 1 )
		{
			sprintf( sz_EntAmt, "%-.3f", Kd_EntAmt ) ;   //[009][010] "%-.3f" --> "%-.5f"
			if ( Kc_AdmMod == 'F' ) {
				sprintf( sz_RetAmt, "%-.3f", Kd_RetAmt ) ;  //[009][010] "%-.3f" --> "%-.5f"
                                sprintf( sz_RetAmtBuff, "%-.8f", Kd_RetAmt ) ; //modif spira 81824 HR
                        }
			else {
				sprintf( sz_RetAmt, "%-.3f", d_ComRat ) ; //[009][010] "%-.3f" --> "%-.5f"
                                sprintf( sz_RetAmtBuff, "%-.8f", d_ComRat ) ; //modif spira 81824 HR
                        }
		}
		else
		{
			sprintf( sz_EntAmt, "%-.3f", 0.0 ) ; //[009][010] "%-.3f" --> "%-.5f"
			sprintf( sz_RetAmt, "%-.3f", d_ComRat ) ; /* sprintf( sz_RetAmt, "%-.8f", d_ComRat ) ; */ //[009][010] "%-.3f" --> "%-.5f" 
                        sprintf( sz_RetAmtBuff, "%-.8f", d_ComRat ) ; //modif spira 81824 HR
			strcpy( sz_AdmMod, "A" ) ;
		}

		/* modification de la variable intermediaire */
		strcpy( Ksz_ComRat_i, sz_RetAmtBuff ) ; //modif spira 81824 HR sz_RetAmt --> sz_RetAmtBuff

		n_WriteCols( Kp_OutputFilCtrEst, CtrEst, SEPARATEUR, 0 ) ;
	}

	/****************************/
	/* calcul de surcommissions */
	/****************************/
	if ( atof( ptb_InRec_Cur[PER_OVRCOM_R] ) == 0 )
		d_SurComRat = 0 ;
	else
	{
		if ( atoi( ptb_InRec_Cur[PER_OVRCOMTYP_CT] ) == 0 )
			d_SurComRat = atof ( ptb_InRec_Cur[PER_OVRCOM_R] ) ;
		if ( atoi( ptb_InRec_Cur[PER_OVRCOMTYP_CT] ) == 1 )
			d_SurComRat = atof ( ptb_InRec_Cur[PER_OVRCOM_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ;
	}

	/* synchronisation avec le fichier Perimetre annexe famille des charges taxes */
	/* Remarque: la place de cette synchro est importante car le taux de commission retenu
	doit etre calcule au prealable */
	
	n_ProcessingRuptureSyncVar( &bd_RuptPerFct, ptb_InRec_Cur ) ;
	/*******************/
	/* calcul de taxes */
	/*******************/
//[005]	d_ResRat = Kd_TaxGlo ;
	d_ResRatWP = Kd_TaxGloWP ; //[005]
	d_ResRatWO = Kd_TaxGloWO ; //[005]
	

	/**********************/
	/* calcul de courtage */
	/**********************/
	/* cas ou le taux de courtage 1 est exprime sur prime brute */
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '0' )
		d_GloCouRat = atof( ptb_InRec_Cur[PER_PRDBRK_R] ) ;

	/* cas ou le taux de courtage 1 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_PRDBRKTYP_CT] == '1' )
		d_GloCouRat = ( atof( ptb_InRec_Cur[PER_PRDBRK_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime brute */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '0' )
		d_GloCouRat += atof( ptb_InRec_Cur[PER_ACCBRK_R] ) ;

	/* cas ou le taux de courtage 2 est exprime sur prime nette */
	if ( *ptb_InRec_Cur[PER_ACCBRKTYP_CT] == '1' )
		d_GloCouRat += ( atof( ptb_InRec_Cur[PER_ACCBRK_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
		
	
	/********************************************************/
	/* ecriture dans le fichier en sortie Taux statistiques */
	/********************************************************/
	LoaRat[LOA_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
	LoaRat[LOA_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
	LoaRat[LOA_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
	LoaRat[LOA_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
	LoaRat[LOA_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
	LoaRat[LOA_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
	LoaRat[LOA_COMMIS_R] = Ksz_ComRat_i ;
	LoaRat[LOA_OVECOM_R] = sz_SurComRat ;
	LoaRat[LOA_TAX_R] = sz_ResRatWP ; //  [005]
	LoaRat[LOA_BROKER_R] = sz_GloCouRat ;
	LoaRat[LOA_TAXWO_R] = sz_ResRatWO ; //[005]
	LoaRat[LOA_TAXWO_R + 1] = NULL ;

//007
	sprintf( sz_SurComRat, "%-.8f", d_SurComRat ) ;
//[005]		sprintf( sz_ResRat, "%-.8f", d_ResRat ) ;
	sprintf( sz_ResRatWP, "%-.8f", d_ResRatWP ) ; //[005]
	sprintf( sz_ResRatWO, "%-.8f", d_ResRatWO ) ; // [005]
	sprintf( sz_GloCouRat, "%-.8f", d_GloCouRat ) ;	

	n_WriteCols( Kp_OutputFilLoaRat, LoaRat, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « Estimations dommages »

retour :
	OK
==============================================================================*/
int n_InitCtrEst( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitCtrEst" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Estimations dommages */
	if ( n_OpenFileAppl( "ESTC1016_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCtrEst ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCtrEst ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncCtrEst(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCtrEst" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[EST_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[EST_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[EST_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[EST_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[EST_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrEst(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCtrEst" ) ;

	/* Positionnement de la variable de participation */
	Kn_CtrEstPa = 1 ;

	/* positionnement du mode de gestion */
	if ( *Ksz_TypInv == 'P' )
	{
		if ( strcmp( Ksz_CloDat, ptb_InRecChild[EST_CLODAT_D] ) == 0 &&
			*ptb_InRecChild[EST_ADMMOD_CT] == 'F' )
			Kc_AdmMod = 'F' ;
		else 	Kc_AdmMod = 'A' ;

		/* sauvegarde du montant manuel et retenu */
		Kd_EntAmt = atof( ptb_InRecChild[EST_ENTAMT_M] ) ;
		Kd_RetAmt = atof( ptb_InRecChild[EST_RETAMT_M] ) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l'esclave « GT cumule selectionne sur sinistres »

retour :
	OK
==============================================================================*/
int n_InitGtCum(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtCum" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Gt selectionne sur sinistres */
	if ( n_OpenFileAppl( "ESTC1016_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier GT des Ibnr */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtCum ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtCum ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncGtCum(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtCum" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
		
//[013]	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;

	if (strcmp(Ksz_Chain, "ESFD2220") != 0) 
	{ 	
		if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
  }
  else 
  	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
		
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtCum(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneSyncGtCum" ) ;

	/* positionnement des sinistralites actuarielles comptabilisees */
	Kd_ClmAmt += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « GT des primes acquises »

retour :
	OK
==============================================================================*/
int n_InitGtPa(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtPa" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT des primes acquises */
	if ( n_OpenFileAppl( "ESTC1016_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtPa ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtPa ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncGtPa(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtPa" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
		
		
	//[013]if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
	
	if (strcmp(Ksz_Chain, "ESFD2220") != 0) 
	{ 	
		if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
  }
  else 
  	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
			
		
		
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtPa(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtPa" ) ;

	/* positionnement des primes acquises comptabilisees */
	Kd_PrmAmt = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l'esclave « GT des Ibnr »

retour :
	OK
==============================================================================*/
int n_InitGtIbnr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtIbnr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Gt des Ibnr */
	if ( n_OpenFileAppl( "ESTC1016_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier GT des Ibnr */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtIbnr ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtIbnr ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncGtIbnr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtIbnr" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtIbnr(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneSyncGtIbnr" ) ;

	/* positionnement des sinistralites actuarielles comptabilisees */
	Kd_ClmAmt += atof( ptb_InRecChild[GT_AMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « Perimetre annexe famille des charges taxes »

retour :
	OK
==============================================================================*/
int n_InitPerFct(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFct" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave famille des charges taxes */
	if ( n_OpenFileAppl( "ESTC1016_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFct ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFct ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncPerFct(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFct" ) ;
	
	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFCT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFCT_END_NT] ) ) != 0 ) return ret ;
		
//[013]		if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCT_SEC_NF] ) ) != 0 ) return ret ;
	
	if (strcmp(Ksz_Chain, "ESFD2220") != 0) 
	{ 	
		if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCT_SEC_NF] ) ) != 0 ) return ret ;
  }
  else 
  	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[PERFCT_SEC_NF] ) ) != 0 ) return ret ;
		
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFCT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFCT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFct(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePerFct" ) ;

	/* CALCUL DU TAUX GLOBAL DE TAXE avec portefuille */
	
	if (  *ptb_InRecChild[PERFCT_TAXBAS_CF] == '0' || *ptb_InRecChild[PERFCT_TAXBAS_CF] == '1' )
	{
		/* cas ou le taux de taxe est exprime sur prime brute */
		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '0' )
//[005]		Kd_TaxGlo += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;
			Kd_TaxGloWP += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;
	
		/* cas ou le taux de taxe est exprime sur prime nette */
		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '1' )
//[005]		Kd_TaxGlo += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
			Kd_TaxGloWP += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
	}

	/* CALCUL DU TAUX GLOBAL DE TAXE sans portefuille */
	else if (  *ptb_InRecChild[PERFCT_TAXBAS_CF] == '2' )
	{
		/* cas ou le taux de taxe est exprime sur prime brute */
		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '0' )
//[005]		Kd_TaxGlo += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;
			Kd_TaxGloWO += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;
	
		/* cas ou le taux de taxe est exprime sur prime nette */
		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '1' )
//[005]		Kd_TaxGlo += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
			Kd_TaxGloWO += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
	}

//007			
	else /* 007 Cette Partie est a modifieé / supprimée une fois que la valeur cu champ PERICASE "PERFCT_TAX_R" sera systematiquement renseignée*/
	{

		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '0' )
    { 
			Kd_TaxGloWP += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;
			Kd_TaxGloWO += atof( ptb_InRecChild[PERFCT_TAX_R] ) ;			
		}
	
		/* cas ou le taux de taxe est exprime sur prime nette */
		if ( *ptb_InRecChild[PERFCT_TAXTYP_CT] == '1' )
		{ 
			Kd_TaxGloWP += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
			Kd_TaxGloWO += ( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ) ;
		}			
	}	

/*  if (strcmp("20F038833", ptb_InRecOwner[PER_CTR_NF]) == 0 ) 
   	printf(" DANS n_ActionLignePerFct : PERFCT_TAXBAS_CF [%s] ; PERFCT_TAXTYP_CT %s; PERFCT_TAX_R %f; Kd_TaxGloWP %f ; Kd_TaxGloWO %f\n",ptb_InRecChild[PERFCT_TAXBAS_CF], ptb_InRecChild[PERFCT_TAXTYP_CT], atof( ptb_InRecChild[PERFCT_TAX_R] ), 
   	( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ),
   	( atof( ptb_InRecChild[PERFCT_TAX_R] ) * ( 1 - atof( Ksz_ComRat_i ) ) ));
   }
*/
	
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre famille de charges iterees  »

retour :
	OK
==============================================================================*/
int n_InitPerFci(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFci" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave famille de charges iterees  */
	if ( n_OpenFileAppl( "ESTC1016_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFci ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFci ;

	pbd_Rupt->c_Separ = '~' ;

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
int n_ConditionSyncPerFci(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFci" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFCI_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFCI_END_NT] ) ) != 0 ) return ret ;
		
		
//	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;
		
	if (strcmp(Ksz_Chain, "ESFD2220") != 0)  
	{ 	
		if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;
  }
  else 
  	if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;		
		
		
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFCI_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFCI_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFci(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

char  MsgAno[300];

	DEBUT_FCT( "n_ActionLignePerFci" ) ;

	/* constitution du tableau des familles de charges iterees */
	Ktbd_FamCha[Kn_NbFam].CHGTYP_B = (char)( atoi( ptb_InRecChild[PERFCI_CHGTYP_B] ) ) ;
	Ktbd_FamCha[Kn_NbFam].MAX_R = atof( ptb_InRecChild[PERFCI_MAX_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MINRAT_R = atof( ptb_InRecChild[PERFCI_MINRAT_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MIN_R = atof( ptb_InRecChild[PERFCI_MIN_R] ) ;
	Ktbd_FamCha[Kn_NbFam].MAXRAT_R = atof( ptb_InRecChild[PERFCI_MAXRAT_R] ) ;

	/* incrementation du compteur de poste du tableau */
	Kn_NbFam += 1 ;

/* Ecriture dans log si depassement du tableau */
  if ( Kn_NbFam > NB_FAM_MAX) {
          sprintf(MsgAno,"The number of Driving records (/CTR %s /SEC %s /UWY %s) overflows the program's storage capacity %d",
                  ptb_InRecChild[PERFCI_CTR_NF],
                  ptb_InRecChild[PERFCI_SEC_NF],
                  ptb_InRecChild[PERFCI_UWY_NF],
                  NB_FAM_MAX);
          n_WriteAno(MsgAno);
          RETURN_VAL(ERR);
  }


	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation des variables de travail

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{
	DEBUT_FCT( "n_InitVariables" ) ;

 	Kc_AdmMod = 0 ;
	Kd_EntAmt = 0 ;
	Kd_RetAmt = 0 ;
	Kd_ClmAmt = 0 ;
	Kd_PrmAmt = 0 ;
//[005]	Kd_TaxGlo = 0 ;
	Kd_TaxGloWP = 0 ; //[005]
	Kd_TaxGloWO = 0 ; //[005]
	memset( Ktbd_FamCha, 0, ( NB_FAM_MAX * sizeof( T_TabFamCharIt ) ) ) ;
	Kn_CtrEstPa = 0 ;
	Kn_NbFam = 0 ;
	*Ksz_ComRat_i = 0 ;

	RETURN_VAL ( OK ) ;
}



 
 
