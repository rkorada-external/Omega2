/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1600.c
r'vision                      : $Revision: 1.2 $
date de cr'ation              : 02/06/1998
auteur                        : Yves BOURDAILLET
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  	PREPARATION DU FICHIER PERMANENT EST_FSEGACT
	(fichier des resultats de l'inventaire par segment)
	(fichier de sortie ACCMVT )
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
   1998/10/05     M.HA-THUC   Le fichier des regroupement d'affaires FCTRGRO0
				contient maintenant des lignes provenant du
				controle des estimations
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
	[001] 10/09/2018 add UWY_NF  spira 57605
	[002]  18/02/2019 sauvegarde des infos du maitre pendant la première synchro avec FCTRGROc, car  elle ne se fait pas sur la clé 
 
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "estserv.h"
#define CTRGRO_UWY_NF 20 //dernier champs

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* d'finition des constantes et macros priv'es */
/*---------------------------------------------*/

#define Kn_MaxPostes 2000       /* Le nombre max de postes est fixe a 2000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.)*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilAccMvt ;	/* pointeur sur le fichier de sortie ACCMVT */
FILE 		*Kp_InputFilSegment ;	/* pointeur sur le fichier binaire FSEGMENT */
FILE 		*Kp_InputFilTrsLnk ;	/* pointeur sur le fichier binaire FTRSLNK */
FILE		*Kp_InputFilCurQuot ;	/* pointeur sur le fichier FCURQUOT */

T_RUPTURE_VAR  	   	bd_RuptStatGtaa ;	/* variable de gestion de la rupture sur ARCSTATGTAA
							en entree */
T_RUPTURE_SYNC_VAR 	bd_RuptCplAcc ;	/* variable de gestion de la synchronisation avec
							le fichier FCPLACC en entree */
T_RUPTURE_SYNC_VAR 	bd_RuptCtrGro ;	/* variable de gestion de la synchronisation avec
							le fichier FCTRGRO en entree */
T_SEGMENT Ktbd_Segment[Kn_MaxPostes];
T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];

int Kn_NbLigSegment;
int Kn_NbLigTrsLnk;
char	Ksz_Acy[5];		/* annee de compte complet, vient de FCPLACC */
char	Ksz_Scoendmth[3];	/* mois de compte complet, vient de FCPLACC */
char	Ksz_Seg[11] ;		/* segment, vient de FCTRGRO */
short Ks_Vrs ;		/* version, vient de FCTRGRO */
short Ks_Prs ;		/* code de regroupement PRS_CF */

char CTRGRO_CTR_SYNC[10] ="";
char CTRGRO_END_SYNC[5]  ="";
char CTRGRO_SEC_SYNC[5]   ="";
char CTRGRO_UWY_SYNC[5] ="";

int n_InitStatGtaa	 	( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_TestRupt1			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_TestRupt2			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionLigneStatGtaa	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1		( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2		( char **pbd_InRec_Cur ) ;

int n_InitCplAcc			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCplAcc		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCplAcc	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCtrGro			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCtrGro		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCtrGro	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_ChargerTSEGMENT( void ) ;
int n_RechPosteTSEGMENT(char *sz_ssd, char *sz_seg );

int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPosteTTRSLNK(char *sz_poste);


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

	/* Recuperation du PRS_CF passe en argument */
        Ks_Prs = n_GetIntArgv(1) ;

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1600_I3","rb",&Kp_InputFilCurQuot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1600_I4","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree FSEGMENT */
	if ( n_OpenFileAppl ( "ESTC1600_I5","rb",&Kp_InputFilSegment ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie */
	if ( n_OpenFileAppl ( "ESTC1600_O1","wt",&Kp_OutputFilAccMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptStatGtaa */
	if ( n_InitStatGtaa( &bd_RuptStatGtaa ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCplAcc */
	if ( n_InitCplAcc( &bd_RuptCplAcc ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptCtrGro */
	if ( n_InitCtrGro( &bd_RuptCtrGro ) )
		ExitPgm( ERR_XX , "" ) ;

        /* initialisation des tableaux  issus de FSEGMENT et FTRSLNK */
        memset( Ktbd_Segment, 0, sizeof( Ktbd_Segment ));
        memset( Ktbd_TrsLnk, 0, sizeof( Ktbd_TrsLnk));

	/* Chargement de FTRSLNK en memoire */
	Kn_NbLigTrsLnk = n_ChargerTRSLNK( Ks_Prs );
        if ( Kn_NbLigTrsLnk > Kn_MaxPostes )
                        ExitPgm( ERR_XX , "" ) ;


	/* Chargement de FSEGMENT en memoire */
	Kn_NbLigSegment = n_ChargerTSEGMENT( );
        if ( Kn_NbLigSegment > Kn_MaxPostes )
                        ExitPgm( ERR_XX , "" ) ;


	/* lancement du traitement du fichier Perimetre de souscription IADVPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptStatGtaa ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I1", &( bd_RuptStatGtaa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I2", &( bd_RuptCtrGro.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I3", &Kp_InputFilCurQuot ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I4", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I5", &Kp_InputFilSegment ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_I6", &( bd_RuptCplAcc.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1600_O1", &Kp_OutputFilAccMvt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(OK) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre ARCSTATGTAA

retour :
	0K
==============================================================================*/
int n_InitStatGtaa(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitStatGtaa" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESTC1600_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	pbd_Rupt->n_NbRupture = 2 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_TestRupt1 ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_TestRupt2 ;

	/* fonction d'action sur la rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1 ;

	/* fonction d'action sur la rupture premiere */
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2 ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneStatGtaa ;

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
int n_TestRupt1(
	char **pbd_InRec ,  	/* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "TestRupt1" ) ;

	if ( ( ret = strcmp( pbd_InRec[GT_CTR_NF], pbd_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}
/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_TestRupt2(
	char **pbd_InRec ,  	/* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "TestRupt2" ) ;

	if ( ( ret = strcmp( pbd_InRec[GT_CTR_NF], pbd_InRec_Cur[GT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[GT_END_NT], pbd_InRec_Cur[GT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[GT_SEC_NF], pbd_InRec_Cur[GT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[GT_UWY_NF], pbd_InRec_Cur[GT_UWY_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}
/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt1" ) ;

	/* initialisation des variables de travail */
	strcpy ( Ksz_Acy, "" ) ;
	strcpy ( Ksz_Scoendmth, "" ) ;

	/* synchronisation avec le fichier FCPLACC */

	n_ProcessingRuptureSyncVar( &bd_RuptCplAcc, ptb_InRec_Cur ) ;

	RETURN_VAL( OK ) ;
}
/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 2

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2( char **ptb_InRec_Cur )
{
	DEBUT_FCT( "n_ActionFirstRupt2" ) ;

	if (strcmp(CTRGRO_CTR_SYNC,ptb_InRec_Cur[GT_CTR_NF]) == 0 &&
		strcmp(CTRGRO_END_SYNC,ptb_InRec_Cur[GT_END_NT])== 0 &&
		strcmp(CTRGRO_SEC_SYNC,ptb_InRec_Cur[GT_SEC_NF])== 0 &&
		(   *CTRGRO_UWY_SYNC == 0 || 
		*CTRGRO_UWY_SYNC == '0'  ||
		strcmp(CTRGRO_UWY_SYNC,ptb_InRec_Cur[GT_UWY_NF])==0) ) // on garde le même segment car l'exrcice na pas changé ou  il est vide
		RETURN_VAL(OK);
	else  /* Synchronisation avec le fichier TCTRGRO pour recuperer le segment */
	{
		/* initialisation des variables de travail */
		strcpy ( Ksz_Seg, "" ) ;
		Ks_Vrs = 0;

		/* synchronisation avec le fichier FCTRGRO */

		n_ProcessingRuptureSyncVar( &bd_RuptCtrGro, ptb_InRec_Cur ) ;
	}
	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneStatGtaa( char **ptb_InRec_Cur )
{
	int	i1, i2;
	char	MsgAno[300] ;/* message d'anomalie */
	char	sz_Cur[4] ;  /* devise du segment de l affaire */
	char	c_Segnat ;  /* nature de l affaire (prop, non prop facs) */
	long	l_Acmtrs ;   /* poste de regroupement de l affaire */
	double d_Amtstat ; /* montant stat converti */
	double d_Amtbil ;  /* montant bilan converti */
        double d_Ratio ;

	DEBUT_FCT( "n_ActionLigneStatGtaa" ) ;

	/* pour la filiale 4, on sort sans traitement */
	if ( atoi( ptb_InRec_Cur[GT_SSD_CF] ) == 4 ) RETURN_VAL( OK ) ;

	/* si le montant n est pas renseigne on sort de la fonction */
	if ( atof( ptb_InRec_Cur[GT_AMT_M] ) == 0 ) RETURN_VAL (OK) ;

	/* recherche de ACMTRS_NT dans la table T_TRSLNK */
	i1=n_RechPosteTTRSLNK(ptb_InRec_Cur[GT_TRNCOD_CF]) ;
	if (i1==-1)
	{
		/* on ne sort pas de lignes en sortie */
		RETURN_VAL( OK ) ;
	}
	else l_Acmtrs = Ktbd_TrsLnk[i1].ACMTRS_NT ;

	/* lorsque le segment n'est pas renseigne, on recupere la monnaie du GT */
	if ( strcmp( Ksz_Seg, "") == 0 )
	{
		strcpy( sz_Cur, ptb_InRec_Cur[GT_CUR_CF]);

		/* generation d une anomalie lorsque le fichier des regroupements d'affaires */
		/*  ne synchronise pas avec le fichier en entree  */
		if ( *ptb_InRec_Cur[GT_CTR_NF] != 0 )
		{
		sprintf( MsgAno, " The contract ( CTR %s - END %s - SEC %s - UWY %s - SSD %s ) is not in the TCTRGRO0 table. \n",
			ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT],
			ptb_InRec_Cur[GT_SEC_NF], ptb_InRec_Cur[GT_UWY_NF],
			ptb_InRec_Cur[GT_SSD_CF] ) ;
		n_WriteAno( MsgAno ) ;
		} ;
	}
	else
	{
		/* recherche de la devise du poste de regroupement dans TSEGMENT */
		i2 = n_RechPosteTSEGMENT ( ptb_InRec_Cur[GT_SSD_CF] , Ksz_Seg) ;
		if (i2 == -1)
		{
			/* generation d'une anomalie */
			sprintf( MsgAno, "The segment ( SEG %s - SSD %s - VRS %d ) is not in the TSEGMENT table. \n",
				Ksz_Seg, ptb_InRec_Cur[GT_SSD_CF], Ks_Vrs ) ;
			n_WriteAno( MsgAno ) ;

			strcpy( sz_Cur, ptb_InRec_Cur[GT_CUR_CF] ) ;
		}
		else
		{
		strcpy( sz_Cur, Ktbd_Segment[i2].CUR_CF);
		c_Segnat = Ktbd_Segment[i2].SEGNAT_CT  ;
		}
	} ;


        /* cas particulier des comptes complets */
	/* distinction Prop, Non Prop, Facs */
        if ( l_Acmtrs == 20000 && c_Segnat == 'P' )
        {       if (   ( atoi( ptb_InRec_Cur[GT_ACY_NF] ) < atoi( Ksz_Acy) )
                    ||  (  (  atoi( ptb_InRec_Cur[GT_ACY_NF] ) == atoi( Ksz_Acy)        )
                          && ( atoi( ptb_InRec_Cur[GT_SCOENDMTH_NF] ) <= atoi( Ksz_Scoendmth) )
                        )
                   )
                {
                        l_Acmtrs = -20000 ;
                }
                else
                {
                        if (strncmp ( &ptb_InRec_Cur[GT_TRNCOD_CF][2], "32999", 5) > 0 )
                        RETURN_VAL( OK ) ;
                }
        };

	if ( l_Acmtrs == 20000 && ( c_Segnat == 'N' || c_Segnat == 'F' ) )
	{
	l_Acmtrs = -20000 ;
	}

	/* affectation des montants */
	d_Amtstat = atof ( ptb_InRec_Cur[GT_AMT_M] );
	d_Amtbil = d_Amtstat ;


	/* Conversion vers la devise de l affaire */
	/* si les deux monnaies sont identiques pas de conversion */
if ( strcmp( ptb_InRec_Cur[GT_CUR_CF], sz_Cur )!=0 )
{
	/* cours STAT */
	d_Ratio = d_GetTaux( Kp_InputFilCurQuot, (char) atoi(ptb_InRec_Cur[GT_SSD_CF]) ,
			(atoi( ptb_InRec_Cur[GT_UWY_NF] ) - 1 ), ptb_InRec_Cur[GT_CUR_CF],
                        sz_Cur) ;

	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if ( d_Ratio < 0 )
	{
	sprintf( MsgAno, "For the contract ( CTR %s - END %s - SEC %s - UWY %s - SSD %s ), the conversion between acceptance currency ( %s ) and the segment currency ( %s ) isn't known for the year %d \n",
			ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT],
			ptb_InRec_Cur[GT_SEC_NF], ptb_InRec_Cur[GT_UWY_NF],
			ptb_InRec_Cur[GT_SSD_CF],
			ptb_InRec_Cur[GT_CUR_CF],
			sz_Cur,
			(atoi (ptb_InRec_Cur[GT_UWY_NF]) - 1) ) ;
		n_WriteAno( MsgAno ) ;

		/* montants positionnes a zero */
		d_Amtstat = 0 ;
	}
	else d_Amtstat *= d_Ratio ;	/* Calcul du montant STAT */


	/* cours BILAN */
	d_Ratio = d_GetTaux( Kp_InputFilCurQuot, (char) atoi(ptb_InRec_Cur[GT_SSD_CF]) ,
			atoi( ptb_InRec_Cur[GT_BALSHEY_NF] ), ptb_InRec_Cur[GT_CUR_CF],
                        sz_Cur) ;

        /* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if ( d_Ratio < 0 )
	{
	sprintf( MsgAno, "For the contract ( CTR %s - END %s - SEC %s - UWY %s - SSD %s ), the conversion between acceptance currency ( %s ) and the segment currency ( %s ) isn't known for the year %s \n",
			ptb_InRec_Cur[GT_CTR_NF], ptb_InRec_Cur[GT_END_NT],
			ptb_InRec_Cur[GT_SEC_NF], ptb_InRec_Cur[GT_UWY_NF],
			ptb_InRec_Cur[GT_SSD_CF],
			ptb_InRec_Cur[GT_CUR_CF],
			sz_Cur,
			ptb_InRec_Cur[GT_BALSHEY_NF] ) ;
		n_WriteAno( MsgAno ) ;

		/* montants positionnes a zero */
		d_Amtbil = 0 ;
	}
	else d_Amtbil *= d_Ratio ;	/* Calcul du montant BILAN */
} ;
	/* Ecriture dans le fichier de sortie */

	fprintf ( Kp_OutputFilAccMvt, "%s~%s~%s~%s~%ld~%d~%-.3f~%-.3f\n",
		 ptb_InRec_Cur[GT_SSD_CF], Ksz_Seg,
		 ptb_InRec_Cur[GT_UWY_NF], sz_Cur,
		 l_Acmtrs, (int) Ks_Vrs, d_Amtstat, d_Amtbil );


	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du fichier pere ARCSTATGTAA
	avec le fils FCPLACC

retour :
	OK
==============================================================================*/
int n_InitCplAcc( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCplAcc" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier fils */
	if ( n_OpenFileAppl( "ESTC1600_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCplAcc ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCplAcc ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalit' de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCplAcc(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCplAcc" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCplAcc(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCplAcc" ) ;

	/* Recuperation de la derniere periode de compte complet pour l affaire */

       if	(
		 ( atoi( Ksz_Acy ) < atoi( ptb_InRecChild[CMP_ACY_NF] ))
		||	( atoi( Ksz_Acy ) == atoi( ptb_InRecChild[CMP_ACY_NF] )
			 && atoi( Ksz_Scoendmth ) < atoi( ptb_InRecChild[CMP_SCOENDMTH_NF] ) )
		)
       {
            	strcpy( Ksz_Acy, ptb_InRecChild[CMP_ACY_NF] ) ;
		strcpy( Ksz_Scoendmth, ptb_InRecChild[CMP_SCOENDMTH_NF] ) ;

       }

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du fichier pere ARCSTATGTAA
	avec le fils FCTRGRO

retour :
	OK
==============================================================================*/
int n_InitCtrGro( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitCtrGro" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier fils */
	if ( n_OpenFileAppl( "ESTC1600_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncCtrGro ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneCtrGro ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalit' de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncCtrGro(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncCtrGro" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[CTRGRO_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_END_NT], pbd_InRecChild[CTRGRO_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_SEC_NF], pbd_InRecChild[CTRGRO_SEC_NF] ) ) != 0 ) return ret ;
	
	
	// si l'exercice dans CTRGRO est vide ou égale 0 , on considère qu'il y a synchro pour n'importe quel exercice
	if (   *pbd_InRecChild[CTRGRO_UWY_NF] == 0 || *pbd_InRecChild[CTRGRO_UWY_NF] == '0' ) return 0 ;
	// sinon il faut que l'exercie synchronise 

	if ( ( ret = strcmp( pbd_InRecOwner[GT_UWY_NF], pbd_InRecChild[CTRGRO_UWY_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCtrGro(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneCtrGro" ) ;

	if ( *ptb_InRecChild[CTRGRO_SEGTYP_CT] == 'A' )
	{
		strcpy ( Ksz_Seg, ptb_InRecChild[CTRGRO_SEG_NF] ) ;
		Ks_Vrs = atoi ( ptb_InRecChild[CTRGRO_VRS_NF] );
		strcpy(CTRGRO_CTR_SYNC,ptb_InRecChild[CTRGRO_CTR_NF]);
		strcpy(CTRGRO_END_SYNC,ptb_InRecChild[CTRGRO_END_NT]);
		strcpy(CTRGRO_SEC_SYNC,ptb_InRecChild[CTRGRO_SEC_NF]);
		strcpy(CTRGRO_UWY_SYNC,ptb_InRecChild[CTRGRO_UWY_NF]);
	}

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet:
        Lit le fichier binaire FTRSLNK et le charge en memoire

==============================================================================*/
int n_ChargerTRSLNK( short s_TrtCod )
{
        int i = 0 ;
        char  MsgAno[300] ; /* message d'anomalie */

        DEBUT_FCT("n_ChargerTRSLNK");

        while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
        {
                if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
                        i += 1 ;
                if ( i > Kn_MaxPostes )
                    {

                                sprintf(MsgAno,"la taille du tableau Ktbd_TrsLnk depasse la taille allouee %d", i);
                         n_WriteAno(MsgAno);
                                RETURN_VAL( i );
                    }

        }

        RETURN_VAL( i );
}


/*==============================================================================
objet:
        Lit le fichier binaire FSEGMENT et le charge en memoire

==============================================================================*/
int n_ChargerTSEGMENT( void )
{
        int i = 0 ;
        char  MsgAno[300] ; /* message d'anomalie */

        DEBUT_FCT("n_ChargerTSEGMENT");

        while ( fread( &Ktbd_Segment[i], sizeof( T_SEGMENT ), 1, Kp_InputFilSegment ) == 1 )
	{
                i += 1 ;
                if ( i > Kn_MaxPostes )
                    {

                                sprintf(MsgAno,"la taille du tableau Ktbd_Segment depasse la taille allouee %d", i);
                         n_WriteAno(MsgAno);
                                RETURN_VAL( i );
                    }

	}

        RETURN_VAL( i );
}

/*==============================================================================
objet :
        fonction de recherche du poste de regroupement ACMTRS
retour :

==============================================================================*/
int n_RechPosteTTRSLNK(char *sz_poste)
{
        int n_indice, ret;

        DEBUT_FCT("n_RechPosteTTRSLNK");

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
                if (n_indice>=Kn_NbLigTrsLnk) RETURN_VAL(-1);
        }
}


/*==============================================================================
objet :
        fonction de recherche de la devise du segment
retour :

==============================================================================*/
int n_RechPosteTSEGMENT( char *sz_ssd, char *sz_seg )
{
        int n_indice, ret_ssd ;

        DEBUT_FCT("n_RechPosteTSEGMENT");

        n_indice=0;

        while (1==1)
        {
		/* Comparaison des codes filiales */
		ret_ssd = atoi (sz_ssd) -  Ktbd_Segment[n_indice].SSD_CF ;

		if (ret_ssd < 0) RETURN_VAL(-1);

		/* comparaison des segments */
		if (ret_ssd == 0 && strcmp(sz_seg,Ktbd_Segment[n_indice].SEG_NF)==0 )
		RETURN_VAL(n_indice);

		/* Ligne suivante */
		n_indice++;

		/* Si on est a la fin du tableau, echec */
		if (n_indice>=Kn_NbLigSegment) RETURN_VAL(-1);
        }
}






