/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1023.c
révision                      : $Revision: 1.2 $
date de création              : 27/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   INTRODUCTION DES POSTES CUMULS ET CONVERSION EN DEVISE ALIMENT

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

#define Kn_MaxPostes 2000	/* Le nombre max de postes est fixe a 1000 (modif O.Arik:28/05/2001 1000->2000 suite au dep. de mem.) */

char Ksz_vide[1];		/* Chaine vide pour initialisation */

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/


FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT enrichi */
FILE 		*Kp_OutputFilPerUw ; /* pointeur sur le fichier de sortie Perimetre */
FILE 		*Kp_InputFilExc ; /* pointeur sur le fichier en entree des cours de change */
FILE 		*Kp_InputFilTrsLnk ; /* pointeur sur le fichier en entree des postes cumuls */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptGt ; /* variable de gestion de la synchronisation avec
						le fichier GT */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitGt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );


int n_ChargerTRSLNK ( short s_TrtCod ) ;
int n_RechPoste(char *sz_poste) ;




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
	if ( n_OpenFileAppl ( "ESTC1023_I3","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1023_I4","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie GT enrichi */
	if ( n_OpenFileAppl ( "ESTC1023_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie perimetre */
	if ( n_OpenFileAppl ( "ESTC1023_O2","wt",&Kp_OutputFilPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGt */
	if ( n_InitGt( &bd_RuptGt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Chargement des postes en memoire */
	Kn_NbLigTrslnk = n_ChargerTRSLNK( 710 );
        if ( Kn_NbLigTrslnk > Kn_MaxPostes )
                        ExitPgm( ERR_XX , "" ) ;


	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_I2", &( bd_RuptGt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_I4", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_I3", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1023_O2", &Kp_OutputFilPerUw ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC1023_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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
	double	d_Ratio ; /* ratio: devise origine/devise cible */
	double	d_SbjPrmAmt ; /* montant de l'assiette de prime */
	double  d_LayCapAmt ; /* montant de la portee */
	double  d_ClmActAmt ;    /* montant de sinistralite actuarielle */
	char	sz_SbjPrmAmt[30] ; /* variable de travail */
	char    sz_LayCapAmt[30] ; /* variable de travail */
	char	sz_ClmActAmt[30] ; /* variable de travail */

	char	MsgAno[300] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* synchronisation avec le fichier GT */
	n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur ) ;

	/* affectation des montants assiette de prime, portee et sinistralite actuarielle */
	d_SbjPrmAmt = atof( ptb_InRec_Cur[PER_SBJPRM_M] ) ;
	d_LayCapAmt = atof( ptb_InRec_Cur[PER_LAYCAP_M] ) ;
	d_ClmActAmt = atof( ptb_InRec_Cur[PER_CLMACT_M] ) ;

	ptb_InRec_Cur[PER_SBJPRM_M] = sz_SbjPrmAmt ;
	ptb_InRec_Cur[PER_LAYCAP_M] = sz_LayCapAmt ;
	ptb_InRec_Cur[PER_CLMACT_M] = sz_ClmActAmt ;

	/* conversion de montant d'assiette de prime au cours stat et de sinistralite actuarielle */
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && strcmp( ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_SBJPRMCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ),
			( atoi( ptb_InRec_Cur[PER_UWY_NF] ) - 1 ), ptb_InRec_Cur[PER_SBJPRMCUR_CF],
			ptb_InRec_Cur[PER_EGPCUR_CF] ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
		sprintf( MsgAno, "The rates of EGPI currency ( %s ) and subject premium currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
			ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_SBJPRMCUR_CF],
			ptb_InRec_Cur[PER_CTR_NF],  ptb_InRec_Cur[PER_END_NT],
			ptb_InRec_Cur[PER_SEC_NF],  ptb_InRec_Cur[PER_UWY_NF],
			ptb_InRec_Cur[PER_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		/* montants positionnes a zero */
		d_SbjPrmAmt = 0 ;
		d_ClmActAmt = 0 ;
		}
		else
		{
			d_SbjPrmAmt *= d_Ratio ;
			d_ClmActAmt *= d_Ratio ;
		}
	}

	/* conversion du montant de portee au cours stat */
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && strcmp( ptb_InRec_Cur[PER_LIACUR_CF], ptb_InRec_Cur[PER_EGPCUR_CF] ) != 0 )
	{
		d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ),
			( atoi( ptb_InRec_Cur[PER_UWY_NF] ) - 1 ), ptb_InRec_Cur[PER_LIACUR_CF],
			ptb_InRec_Cur[PER_EGPCUR_CF] ) ;

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_Ratio < 0 )
		{
		sprintf( MsgAno, "The rates of EGPI currency ( %s ) and Layer capacity currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) \n",
			ptb_InRec_Cur[PER_EGPCUR_CF], ptb_InRec_Cur[PER_LIACUR_CF],
			ptb_InRec_Cur[PER_CTR_NF],  ptb_InRec_Cur[PER_END_NT],
			ptb_InRec_Cur[PER_SEC_NF],  ptb_InRec_Cur[PER_UWY_NF],
			ptb_InRec_Cur[PER_UW_NT] ) ;
		n_WriteAno( MsgAno ) ;

		/* montant positionne a zero */
		d_LayCapAmt = 0 ;
		}
		else	d_LayCapAmt *= d_Ratio ;
	}

	/* affectation des montants ( convertits ou non ) avant ecriture */
	sprintf( sz_SbjPrmAmt, "%-.3f", d_SbjPrmAmt ) ;
	sprintf( sz_LayCapAmt, "%-.3f", d_LayCapAmt ) ;
	sprintf( sz_ClmActAmt, "%-.3f", d_ClmActAmt ) ;

	/* ecriture dans le Perimetre de souscription en sortie */
	n_WriteCols( Kp_OutputFilPerUw, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « GT »

retour :
	OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1023_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

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
int n_ConditionSyncGt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGt" ) ;

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
int n_ActionLigneGt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	int i ;
	double d_Amt ;   /* montant acceptation */
	double d_Ratio ; /* ratio: devise acceptation/devise aliment */
	long	l_AcmTrs ; /* poste cumul */
	char	**Gt ;	/* tableau de pointeur permettant de sauvegarder la ligne du GT en cours */
	char	sz_AcmTrs[10] ;
	char	sz_AcmAmt[30] ;
	char	sz_AcmCur[4] ;

	char	MsgAno[300] ; /* message d'anomalie */

	DEBUT_FCT( "n_ActionLigneGt" ) ;

	/* sauvegarde de la ligne courante */
	Gt = ptb_InRecChild ;
	Gt[GT_RETKEY_CF +1] = sz_AcmTrs ;
	Gt[GT_RETKEY_CF +2] = sz_AcmAmt ;
	Gt[GT_RETKEY_CF +3] = sz_AcmCur ;

	/* affectation du montant acceptation */
	d_Amt = atof( ptb_InRecChild[GT_AMT_M] ) ;

	/* Synchronisation du fichier trslnk afin de recuperer ACMTRS_NT */
	i=n_RechPoste(ptb_InRecChild[GT_TRNCOD_CF]) ;
	if (i==-1) l_AcmTrs = 0 ;
	else l_AcmTrs = Ktbd_TrsLnk[i].ACMTRS_NT ;

	if ( l_AcmTrs == 20000 )
	{
		/* conversion du montant acceptation en devise aliment */
		if ( strcmp( ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) != 0 )
		{
			d_Ratio = d_GetTaux( Kp_InputFilExc, (char) atoi( ptb_InRecChild[GT_SSD_CF] ),
				atoi( ptb_InRecChild[GT_BALSHEY_NF] ), ptb_InRecChild[GT_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF] ) ;

			/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
			if ( d_Ratio < 0 )
			{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the accounting transaction ( SSD %s - CTR %s - END %s - SEC %s - UWY %s - UW %s - Balance sheet date %s/%s/%s - TRNCOD %s - ACY %s - accounting period %s/%s ) \n",
				ptb_InRecChild[GT_CUR_CF],  ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[GT_SSD_CF],
				ptb_InRecChild[GT_CTR_NF],  ptb_InRecChild[GT_END_NT], ptb_InRecChild[GT_SEC_NF],
				ptb_InRecChild[GT_UWY_NF],  ptb_InRecChild[GT_UW_NT] , ptb_InRecChild[GT_BALSHRDAY_NF],
				ptb_InRecChild[GT_BALSHRMTH_NF], ptb_InRecChild[GT_BALSHEY_NF], ptb_InRecChild[GT_TRNCOD_CF],
				ptb_InRecChild[GT_ACY_NF], ptb_InRecChild[GT_SCOSTRMTH_NF], ptb_InRecChild[GT_SCOENDMTH_NF] ) ;
			n_WriteAno( MsgAno ) ;

			/* montant positionne a zero */
			d_Amt = 0 ;
			}
			else	d_Amt *= d_Ratio ;
		}

		sprintf( sz_AcmTrs, "%ld", l_AcmTrs ) ;
		sprintf( sz_AcmAmt, "%-.3f", d_Amt ) ;
		sprintf( sz_AcmCur, "%s", ptb_InRecOwner[PER_EGPCUR_CF] ) ;

		/* ecriture dans le GT en sortie */
		n_WriteCols( Kp_OutputFilGt, Gt, SEPARATEUR, 0 ) ;
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

