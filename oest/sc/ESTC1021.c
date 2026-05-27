/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1021.c
révision                      : $Revision: 1.2 $
date de création              : 26/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   MISE A JOUR DES RESULTATS PAR AFFAIRE

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    27/01/1998    C.Soulier   suppression de la synchro avec le fichier
                              d'entree I4 CODGTA (synchro mise en commentaires)
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
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
#include "ESTC1021.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define Kn_MaxPostes 2000	/* Le nombre max de postes est fixe a 1000 */
#define AMTP_MAX 999999999999999.000	/* format maxi des montants en base */
#define AMTN_MAX -999999999999999.000	/* format maxi des montants en base */

char Ksz_vide[1];		/* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilResSum ; /* pointeur sur le fichier de sortie des resultats par affaire */
FILE 		*Kp_InputFilTrsLnk ; /* pointeur sur le fichier en entree des postes cumuls */

FILE         	*Kp_InputFilExc ; /* pointeur sur le fichier en entree des cours de change */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptTotGta ; /* variable de gestion de la synchronisation avec
						le fichier DXXTOTGTAaCUM */
/* synchro supprimee (27/01/98) : */
/*T_RUPTURE_SYNC_VAR 	bd_RuptGtaCod ;*/ /* variable de gestion de la synchronisation avec le fichier IDGTAacod */

short Ks_AcmTrs;
T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;

int Kn_GtPa ;	/* variable de gestion de la participation des fichiers GT */

double	Kd_Prm ;
double	Kd_UnePrm ;
double	Kd_LoaDin ;
double	Kd_DacOst ;
double	Kd_LosSes ;
double	Kd_OsIbnr ;
double	Kd_BroKer ;
double	Kd_DifBro ;
double	Kd_ProCom ;
double	Kd_LosCom ;
double	Kd_Ibnr ;


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitTotGta		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneTotGta		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncTotGta	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtaCod		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtaCod		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtaCod	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char *sz_poste) ;
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

        /* ouverture du fichier en entree des cours de change FCURQUOT */
        if ( n_OpenFileAppl ( "ESTC1021_I4","rb",&Kp_InputFilExc ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1021_I3","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1021_O1","wt",&Kp_OutputFilResSum ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptTotGta */
	if ( n_InitTotGta( &bd_RuptTotGta ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtaCod */
        /* synchronisation supprimee (21/01/98) */
	/*if ( n_InitGtaCod( &bd_RuptGtaCod ) )*/
		/*ExitPgm( ERR_XX , "" ) ;*/

	/* Chargement des postes en memoire */
	Kn_NbLigTrslnk = n_ChargerTRSLNK( 711 );

	if ( Kn_NbLigTrslnk > Kn_MaxPostes )
			ExitPgm( ERR_XX , "" ) ;


	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1021_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1021_I2", &( bd_RuptTotGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1021_I3", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

        if ( n_CloseFileAppl( "ESTC1021_I4", &Kp_InputFilExc ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

	/*if ( n_CloseFileAppl( "ESTC1021_I4", &( bd_RuptGtaCod.pf_InputFil ) ) == ERR )*/
        /* fichier d'entree I4 (CODGTA) supprime (21/01/98) */
		/*ExitPgm( ERR_XX , "" ) ;*/

	if ( n_CloseFileAppl( "ESTC1021_O1", &Kp_OutputFilResSum ) == ERR )
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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1021_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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
	char	*ResSum[NB_COL_RES + 1] ; /* tableau de pointeur a l'image du fichier des resultats par affaire */

	char	sz_Prm[25] ;
	char	sz_UnePrm[25] ;
	char	sz_LoaDin[25] ;
	char	sz_DacOst[25] ;
	char	sz_LosSes[25] ;
	char	sz_OsIbnr[25] ;
	char	sz_BroKer[25] ;
	char	sz_DifBro[25] ;
	char	sz_ProCom[25] ;
	char	sz_LosCom[25] ;
	char	sz_Ibnr[25] ;

	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* traitement pour les traites non vie */
	if ( ( atoi( ptb_InRec_Cur[PER_LOB_CF] ) != 30 ) && ( atoi( ptb_InRec_Cur[PER_LOB_CF] ) != 31 ) )
	{
		/* initialisation des montants */
		n_InitVariables( ) ;

		/* synchronisation avec le fichier DXXTOTGTAa */
		n_ProcessingRuptureSyncVar( &bd_RuptTotGta, ptb_InRec_Cur ) ;

		/* synchronisation avec le fichier IDGTAacod */
                /* synchronisation supprimee (27/01/98) */
		/* n_ProcessingRuptureSyncVar( &bd_RuptGtaCod, ptb_InRec_Cur ); */

		/* ecriture en sortie dans le fichier des resultats par affaire */
		if ( Kn_GtPa == 1 )
		{
			ResSum[RES_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
			ResSum[RES_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
			ResSum[RES_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
			ResSum[RES_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
			ResSum[RES_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
			ResSum[RES_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
			ResSum[RES_CUR_CF] = ptb_InRec_Cur[PER_EGPCUR_CF] ;
			ResSum[RES_PRM_M] = sz_Prm ;
			ResSum[RES_UNEPRM_M] = sz_UnePrm ;
			ResSum[RES_LOADIN_M] = sz_LoaDin ;
			ResSum[RES_DACOST_M] = sz_DacOst ;
			ResSum[RES_LOSSES_M] = sz_LosSes ;
			ResSum[RES_OSIBNR_M] = sz_OsIbnr ;
			ResSum[RES_BROKER_M] = sz_BroKer ;
			ResSum[RES_DIFBRO_M] = sz_DifBro ;
			ResSum[RES_PROCOM_M] = sz_ProCom ;
			ResSum[RES_LOSCOM_M] = sz_LosCom ;
			ResSum[RES_IBNR_M] = sz_Ibnr ;
			ResSum[RES_IBNR_M + 1] = NULL ;

			/* depacement du format des montants en base */
			if ( Kd_Prm > 0 && Kd_Prm > AMTP_MAX )
				Kd_Prm = AMTP_MAX ;
			if ( Kd_Prm < 0 && Kd_Prm < AMTN_MAX )
				Kd_Prm = AMTN_MAX ;

			if ( Kd_UnePrm > 0 && Kd_UnePrm > AMTP_MAX )
				Kd_UnePrm = AMTP_MAX ;
			if ( Kd_UnePrm < 0 && Kd_UnePrm < AMTN_MAX )
				Kd_UnePrm = AMTN_MAX ;

			if ( Kd_LoaDin > 0 && Kd_LoaDin > AMTP_MAX )
				Kd_LoaDin = AMTP_MAX ;
			if ( Kd_LoaDin < 0 && Kd_LoaDin < AMTN_MAX )
				Kd_LoaDin = AMTN_MAX ;

			if ( Kd_DacOst > 0 && Kd_DacOst > AMTP_MAX )
				Kd_DacOst = AMTP_MAX ;
			if ( Kd_DacOst < 0 && Kd_DacOst < AMTN_MAX )
				Kd_DacOst = AMTN_MAX ;

			if ( Kd_LosSes > 0 && Kd_LosSes > AMTP_MAX )
				Kd_LosSes = AMTP_MAX ;
			if ( Kd_LosSes < 0 && Kd_LosSes < AMTN_MAX )
				Kd_LosSes = AMTN_MAX ;

			if ( Kd_OsIbnr > 0 && Kd_OsIbnr > AMTP_MAX )
				Kd_OsIbnr = AMTP_MAX ;
			if ( Kd_OsIbnr < 0 && Kd_OsIbnr < AMTN_MAX )
				Kd_OsIbnr = AMTN_MAX ;

			if ( Kd_BroKer > 0 && Kd_BroKer > AMTP_MAX )
				Kd_BroKer = AMTP_MAX ;
			if ( Kd_BroKer < 0 && Kd_BroKer < AMTN_MAX )
				Kd_BroKer = AMTN_MAX ;

			if ( Kd_DifBro > 0 && Kd_DifBro > AMTP_MAX )
				Kd_DifBro = AMTP_MAX ;
			if ( Kd_DifBro < 0 && Kd_DifBro < AMTN_MAX )
				Kd_DifBro = AMTN_MAX ;

			if ( Kd_ProCom > 0 && Kd_ProCom > AMTP_MAX )
				Kd_ProCom = AMTP_MAX ;
			if ( Kd_ProCom < 0 && Kd_ProCom < AMTN_MAX )
				Kd_ProCom = AMTN_MAX ;

			if ( Kd_LosCom > 0 && Kd_LosCom > AMTP_MAX )
				Kd_LosCom = AMTP_MAX ;
			if ( Kd_LosCom < 0 && Kd_LosCom < AMTN_MAX )
				Kd_LosCom = AMTN_MAX ;

			if ( Kd_Ibnr > 0 && Kd_Ibnr > AMTP_MAX )
				Kd_Ibnr = AMTP_MAX ;
			if ( Kd_Ibnr < 0 && Kd_Ibnr < AMTN_MAX )
				Kd_Ibnr = AMTN_MAX ;

			sprintf( sz_Prm, "%-.3f", Kd_Prm ) ;
			sprintf( sz_UnePrm, "%-.3f", Kd_UnePrm ) ;
			sprintf( sz_LoaDin, "%-.3f", Kd_LoaDin ) ;
			sprintf( sz_DacOst, "%-.3f", Kd_DacOst ) ;
			sprintf( sz_LosSes, "%-.3f", Kd_LosSes ) ;
			sprintf( sz_OsIbnr, "%-.3f", Kd_OsIbnr ) ;
			sprintf( sz_BroKer, "%-.3f", Kd_BroKer ) ;
			sprintf( sz_DifBro, "%-.3f", Kd_DifBro ) ;
			sprintf( sz_ProCom, "%-.3f", Kd_ProCom ) ;
			sprintf( sz_LosCom, "%-.3f", Kd_LosCom ) ;
			sprintf( sz_Ibnr, "%-.3f", Kd_Ibnr ) ;

			n_WriteCols( Kp_OutputFilResSum, ResSum, SEPARATEUR, 0 ) ;
		}
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DXXTOTGTAaCUM »

retour :
	OK
==============================================================================*/
int n_InitTotGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitTotGta" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1021_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGta ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneTotGta ;

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
int n_ConditionSyncTotGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncTotGta" ) ;

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
int n_ActionLigneTotGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int i ;
	long l_AcmTrs ;
        double d_Amt ;   /* montant acceptation */
        double d_Ratio ; /* ratio: cours montant de prime/cours aliment */
        char MsgAno[300] ; /* message anomalie*/

	DEBUT_FCT( "n_ActionLigneTotGta" ) ;

	/* positionnement de la variable de participation du GT */
	Kn_GtPa = 1 ;

        /* affectation du montant acceptation */
        d_Amt = atof( ptb_InRecChild[GT_AMT_M] ) ;

	/* Synchro du fichier trslnk afin de recuperer ACMTRS_NT */
	i=n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]) ;

	if (i==-1) l_AcmTrs = 0 ;
	else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;

        /* conversion du montant acceptation en devise aliment */
        if ( strcmp( ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) != 0 )
        {
        	d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GT_SSD_CF] ), atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) ;

        	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
                if ( d_Ratio < 0 )
                {
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_CTR_NF],  ptb_InRecChild[GT_END_NT], ptb_InRecChild[GT_SEC_NF], ptb_InRecChild[GT_UWY_NF], ptb_InRecChild[GT_UW_NT], ptb_InRecChild[GT_BALSHEY_NF] ) ;

			n_WriteAno( MsgAno ) ;

                	/* montant positionne a zero */
                	d_Amt = 0 ;
                }
                else    d_Amt *= d_Ratio ;
        }

	/* recuperation du montant du GT */
	switch( l_AcmTrs )
	{
		case 10000 :
			Kd_Prm += d_Amt ;
			break ;
		case 10030 :
			Kd_UnePrm += d_Amt ;
			break ;
		case 10031 :
			Kd_UnePrm += d_Amt ;
			break ;
		case 10100 :
			Kd_LoaDin += d_Amt ;
			break ;
		case 10130 :
			Kd_DacOst += d_Amt ;
			break ;
		case 20000 :
			Kd_LosSes += d_Amt ;
			break ;
		case 20030 :
			Kd_OsIbnr += d_Amt ;
			break ;
		case 20031 :
			Kd_OsIbnr += d_Amt ;
			break ;
		case 24030 :
			Kd_OsIbnr += d_Amt ;
		        Kd_Ibnr += d_Amt ;
			break ;
		case 24031 :
			Kd_OsIbnr += d_Amt ;
                        Kd_Ibnr += d_Amt ;
			break ;
		case 10400 :
			Kd_BroKer += d_Amt ;
			break ;
		case 10430 :
			Kd_DifBro += d_Amt ;
			break ;
		case 22000 :
			Kd_ProCom += d_Amt ;
			break ;
		case 23000 :
			Kd_LosCom += d_Amt ;
			break ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « IDGTAacod »

retour :
	OK
      ==========================================================
	CETTE FONCTION N'EST PLUS APPELEE (modif du 27/01/98)
==============================================================================*/
int n_InitGtaCod( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGtaCod" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1021_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtaCod ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtaCod ;

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

       =======================================================
	CETTE FONCTION N'EST PLUS APPELEE (modif du 27/01/98)
==============================================================================*/
int n_ConditionSyncGtaCod(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtaCod" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GTE_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GTE_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GTE_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GTE_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GTE_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre

      =========================================================
	CETTE FONCTION N'EST PLUS APPELEE (modif du 27/01/98)
==============================================================================*/
int n_ActionLigneGtaCod(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

	DEBUT_FCT( "n_ActionLigneGtaCod" ) ;

	/* positionnement de la variable de participation du GT */
	Kn_GtPa = 1 ;

	/* recuperation du montant du GT */
	switch( atol( ptb_InRecChild[GTE_ACMTRS_NT] ) )
	{
	case 10000 :
		Kd_Prm += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10030 :
		Kd_UnePrm += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10031 :
		Kd_UnePrm += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10100 :
		Kd_LoaDin += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10130 :
		Kd_DacOst += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 20000 :
		Kd_LosSes += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 20030 :
		Kd_OsIbnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		Kd_Ibnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 20031 :
		Kd_OsIbnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		Kd_Ibnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 24030 :
		Kd_OsIbnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 24031 :
		Kd_OsIbnr += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10400 :
		Kd_BroKer += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10430 :
		Kd_DifBro += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 22000 :
		Kd_ProCom += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 23000 :
		Kd_LosCom += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet:
	Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK( short s_TrtCod )
{
	int i = 0 ;

	char sz_message[200];

	DEBUT_FCT("n_ChargerTRSLNK");

	while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
	{
		if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
			i += 1 ;
		if ( i > Kn_MaxPostes )
		    {

				sprintf(sz_message,"la taille du tableau Ktbd_TrsLnk depasse la taille allouee %d", i);
		         n_WriteAno(sz_message);
		         	RETURN_VAL( i );
		    }

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

	Ksz_vide[0]=0;
	n_indice=0;
	while (1==1)
	{
		/* Comparaison des codes */
		ret=strcmp(sz_poste,Ktbd_TrsLnk[n_indice].DETTRS_CF);

		/* S'ils sont egaux, retourner l'indice */
		if (ret==0) RETURN_VAL(n_indice);

		/* Si la ligne est passee, retourner -1 (echec) */
		if (ret<0) RETURN_VAL(-1);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigTrslnk) RETURN_VAL(-1);
	}
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

	/* initialisation des montants */
	Kd_Prm = 0 ;
	Kd_UnePrm = 0 ;
	Kd_LoaDin = 0 ;
	Kd_DacOst = 0 ;
	Kd_LosSes = 0 ;
	Kd_OsIbnr = 0 ;
	Kd_BroKer = 0 ;
	Kd_DifBro = 0 ;
	Kd_ProCom = 0 ;
	Kd_LosCom = 0 ;
	Kd_Ibnr = 0 ;

	/* initialisation de la variable de participation du GT */
	Kn_GtPa = 0 ;

	RETURN_VAL ( OK ) ;
}
