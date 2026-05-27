/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2313.c
révision                      : $Revision: 1.2 $
date de création              : 22/09/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   AFFECTATION DES AVENANTS ET NUMERO D'ORDRE

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
#include "ESTC2313.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilGt ; /* pointeur sur le fichier de sortie GT */
FILE           	*Kp_GTano; 	  /* fichier anomalie au format du GT */
T_RUPTURE_VAR  	   	bd_RuptGtrr ; /* variable de gestion de la rupture sur le GTRr */

T_RUPTURE_SYNC_VAR 	bd_RuptPerUw ; /* variable de gestion de la synchronisation avec
						le perimetre de souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptGtar ; /* variable de gestion de la synchronisation avec GTAr */


T_GT	Ktbd_Gta[NB_GT_MAX] ; 	/* tableau memorisant des lignes du GTAr */
short	Kn_Gta_Nbp ;		/* compteur du tableau Ktbd_Gta */

T_GT	Ktbd_Gtr[NB_GT_MAX] ; 	/* tableau memorisant des lignes du GTRr */
short	Kn_Gtr_Nbp ;		/* compteur du tableau Ktbd_Gtr */

short   Kn_PerUw_Pa ;		/* variable de participation du perimetre */
short	Kn_RetCtrCat ;		/* categorie de contrat retro */

double	Kd_GtaAmtCum ;		/* montant monnaie retrocession cumule du GTAr */
double	Kd_GtrAmtCum ;		/* montant monnaie retrocession cumule du GTRr */

short	Kn_RetCod = OK ;	/* code de retour en sortie de programme */
short   Kn_GtrRetAmt_b ;	/* variable permettant de savoir si un des RETAMT_M du tableau
					Ktbd_Gtr est non nul */

double Kd_Seuil;

int n_InitGtrr	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Gtrr			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_IsR2Gtrr			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt1Gtrr	( char **pbd_InRec_Cur ) ;
int n_ActionFirstRupt2Gtrr	( char **pbd_InRec_Cur ) ;
int n_ActionLigneGtrr		( char **pbd_InRec_Cur ) ;
int n_ActionLastRupt2Gtrr	( char **pbd_InRec_Cur ) ;

int n_InitPerUw			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerUw	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionPereSansFilsPerUw	( char **pbd_InRecOwner ) ;

int n_InitGtar			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtar		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtar		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_CopyGt( char **ptb_InRec_Cur, T_GT *pbd_TabGt ) ;
int n_WriteGt( T_GT *pbd_Gta, T_GT *pbd_Gtr ) ;



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

       /* Recuperation du seuil */
        Kd_Seuil=d_GetFloatArgv(1);

	/* ouverture du fichier en sortie GT */
	if ( n_OpenFileAppl ( "ESTC2313_O1","wt",&Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier en sortie GTano */
	if ( n_OpenFileAppl ( "ESTC2313_O2","wt",&Kp_GTano ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtrr */
	if ( n_InitGtrr( &bd_RuptGtrr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtarr */
	if ( n_InitGtar( &bd_RuptGtar ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier GTRr */
	if ( n_ProcessingRuptureVar( &bd_RuptGtrr ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2313_I1", &( bd_RuptGtrr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2313_I2", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2313_I3", &( bd_RuptGtar.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2313_O1", &Kp_OutputFilGt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC2313_O2", &Kp_GTano ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit( Kn_RetCod ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitGtrr(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtrr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

	/* ouverture du fichier maitre GTRr */
	if ( n_OpenFileAppl( "ESTC2313_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 2 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtrr ;

	/* fonction du test de rupture de niveau 2 */
	pbd_Rupt->n_ConditionRupture[1] = n_IsR2Gtrr ;

	/* fonction lancee en rupture premiere de niveau 1 */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRupt1Gtrr ;

	/* fonction lancee en rupture premiere de niveau 2 */
	pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRupt2Gtrr ;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtrr ;

	/* Fonction lancee en rupture derniere de niveau 2 */
	pbd_Rupt->n_ActionLast[1] = n_ActionLastRupt2Gtrr ;

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
int n_IsR1Gtrr(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Gtrr" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_RETCTR_NF], ptb_InRec_Cur[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETEND_NT], ptb_InRec_Cur[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSEC_NF], ptb_InRec_Cur[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RTY_NF], ptb_InRec_Cur[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETUW_NT], ptb_InRec_Cur[GT_RETUW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 2

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR2Gtrr(
	char **ptb_InRec ,  /* adresse de la ligne en avance */
	char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Gtrr" ) ;

	if ( ( ret = strcmp( ptb_InRec[GT_TRNCOD_CF], ptb_InRec_Cur[GT_TRNCOD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETCUR_CF], ptb_InRec_Cur[GT_RETCUR_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETOCCYEA_NF], ptb_InRec_Cur[GT_RETOCCYEA_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RCL_NF], ptb_InRec_Cur[GT_RCL_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETACY_NF], ptb_InRec_Cur[GT_RETACY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSCOSTRMTH_NF], ptb_InRec_Cur[GT_RETSCOSTRMTH_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( ptb_InRec[GT_RETSCOENDMTH_NF], ptb_InRec_Cur[GT_RETSCOENDMTH_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 1

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt1Gtrr( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRupt1Gtrr" ) ;

	/* initialisation des variables de travail */
	Kn_PerUw_Pa = 0 ;
	Kn_RetCtrCat = 0 ;

	/* synchronisation avec le fichier Perimetre de souscription */
	n_ProcessingRuptureSyncVar( &bd_RuptPerUw, pbd_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere de niveau 2

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRupt2Gtrr( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRupt2Gtrr" ) ;

	/* initialisation des tableaux de GT et compteurs respectifs */
	memset( Ktbd_Gta, 0, sizeof( Ktbd_Gta ) ) ;
	Kn_Gta_Nbp = 0 ;
	memset( Ktbd_Gtr, 0, sizeof( Ktbd_Gtr ) ) ;
	Kn_Gtr_Nbp = 0 ;

	/* initialisation des variables de travail */
	Kn_GtrRetAmt_b = 0 ;

	/* initialisation des montants cumules */
	Kd_GtaAmtCum = 0 ;
	Kd_GtrAmtCum = 0 ;

	/* synchronisation avec le GTAr */
	if ( Kn_PerUw_Pa == 1 && ( Kn_RetCtrCat == 5 || Kn_RetCtrCat == 7 || Kn_RetCtrCat == 8 ) )
		n_ProcessingRuptureSyncVar( &bd_RuptGtar, pbd_InRec_Cur ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtrr( char **ptb_InRec_Cur )
{
	char	MsgAno[300] ;

	DEBUT_FCT( "n_ActionLigneGtrr" ) ;

	/* si le perimetre a participe */
	if ( Kn_PerUw_Pa == 1 )
	{
		if ( Kn_RetCtrCat == 5 || Kn_RetCtrCat == 7 || Kn_RetCtrCat == 8 )
		{
			/* stockage de la ligne du GTRr dans le tableau Ktbd_Gtr */
			n_CopyGt( ptb_InRec_Cur, &Ktbd_Gtr[Kn_Gtr_Nbp] )  ;

			/* incrementation du compteur de poste du tableau Ktbd_Gtr */
			Kn_Gtr_Nbp += 1 ;

			/* generation d'une anomalie si la taille du tableau est depasse */
			if ( Kn_Gtr_Nbp > NB_GT_MAX )
			{
				sprintf( MsgAno, "The LT records number ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s - TRNCOD_CF %s - RETCUR_CF %s - RETOCCYEA_NF %s - RCL_NF %s - RETACY_NF %s - RETSCOSTRMTH_NF %s - RETSCOENDMTH_NF %s ) overflows the memory capacity\n",
					ptb_InRec_Cur[GT_RETCTR_NF],  ptb_InRec_Cur[GT_RETEND_NT], ptb_InRec_Cur[GT_RETSEC_NF],
					ptb_InRec_Cur[GT_RTY_NF], ptb_InRec_Cur[GT_RETUW_NT], ptb_InRec_Cur[GT_TRNCOD_CF],
					ptb_InRec_Cur[GT_RETCUR_CF], ptb_InRec_Cur[GT_RETOCCYEA_NF], ptb_InRec_Cur[GT_RCL_NF],
					ptb_InRec_Cur[GT_RETACY_NF], ptb_InRec_Cur[GT_RETSCOSTRMTH_NF], ptb_InRec_Cur[GT_RETSCOENDMTH_NF] ) ;
				n_WriteAno( MsgAno ) ;
			}
		}
		else	n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRupt2Gtrr( char **ptb_InRec_Cur  )
{
	int i, j ;

	char	MsgAno[300] ;	/* message d'anomalie */

	DEBUT_FCT( "n_ActionLastRupt2Gtrr" ) ;

	/************************/
	/* traitement principal */
	/************************/
	if ( Kn_RetCtrCat == 5 || Kn_RetCtrCat == 7 || Kn_RetCtrCat == 8 )
	{
		/* cumul des montants des lignes du tableau Ktbd_Gta */
		for ( i = 0; i < Kn_Gta_Nbp; i++ )
			Kd_GtaAmtCum += Ktbd_Gta[i].RETAMT_M ;

		/* cumul des montants des lignes du tableau Ktbd_Gtr */
		for ( i = 0; i < Kn_Gtr_Nbp; i++ )
		{
			Kd_GtrAmtCum += Ktbd_Gtr[i].RETAMT_M ;
			if ( Ktbd_Gtr[i].RETAMT_M != 0 )
				Kn_GtrRetAmt_b = 1 ;	/* il exixte au moins un montant non nul dans Ktbd_Gtr */
		}

		if ( fabs(Kd_GtaAmtCum - Kd_GtrAmtCum) < Kd_Seuil )
		{
			if ( Kd_GtaAmtCum != 0 )
			{
				for ( i = 0; i < Kn_Gtr_Nbp; i++ )
				{
					for ( j = 0; j < Kn_Gta_Nbp; j++ )
					{
						/* ecriture en sortie dans le GT */
						n_WriteGt( &Ktbd_Gta[j], &Ktbd_Gtr[i] ) ;
					}
				}
			}
			else
			{
				/* generation d'une anomalie si un des montants de Ktbd_Gtr est non nul */
				if ( Kn_GtrRetAmt_b == 1 )
				{
					sprintf( MsgAno, "The split by retrocessionary ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s - TRNCOD_CF %s - RETCUR_CF %s - RETOCCYEA_NF %s - RCL_NF %s - RETACY_NF %s - RETSCOSTRMTH_NF %s - RETSCOENDMTH_NF %s ) is not in the same way for the retrocessionary as the others\n",
						ptb_InRec_Cur[GT_RETCTR_NF],  ptb_InRec_Cur[GT_RETEND_NT], ptb_InRec_Cur[GT_RETSEC_NF],
						ptb_InRec_Cur[GT_RTY_NF], ptb_InRec_Cur[GT_RETUW_NT], ptb_InRec_Cur[GT_TRNCOD_CF],
						ptb_InRec_Cur[GT_RETCUR_CF], ptb_InRec_Cur[GT_RETOCCYEA_NF], ptb_InRec_Cur[GT_RCL_NF],
						ptb_InRec_Cur[GT_RETACY_NF], ptb_InRec_Cur[GT_RETSCOSTRMTH_NF], ptb_InRec_Cur[GT_RETSCOENDMTH_NF] ) ;
					n_WriteAno( MsgAno ) ;

					/* l'anomalie n'est pas bloquante au niveau du programme mais
					celui-ci renvoie au script un code erreur */
					Kn_RetCod = ERR ;
				}
			}
		}
		else
		{
			/* generation d'une anomalie au format du GT */
                  fprintf(Kp_GTano,"~~~~~%s~~~~~~~~~~~~~~~~~~%s~%s~%s~%s~%s~~~~~~%s~%.3lf~~~~~\n",
                              ptb_InRec_Cur[GT_TRNCOD_CF],
                              ptb_InRec_Cur[GT_RETCTR_NF],
                              ptb_InRec_Cur[GT_RETEND_NT],
                              ptb_InRec_Cur[GT_RETSEC_NF],
                              ptb_InRec_Cur[GT_RTY_NF],
                              ptb_InRec_Cur[GT_RETUW_NT],
                              ptb_InRec_Cur[GT_RETCUR_CF],
		              (Kd_GtaAmtCum - Kd_GtrAmtCum));

			/* l'anomalie n'est pas bloquante au niveau du programme mais celui-ci renvoie au script un code erreur */
			Kn_RetCod = ERR ;
		}
	}

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GTRr »
	avec l’esclave « Perimetre de souscription »

retour :
	OK
==============================================================================*/
int n_InitPerUw( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitPerUw" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2313_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerUw ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	/* fonction d'action lancee quand l'esclave n'a pas de maitre */
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsPerUw ;

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
int n_ConditionSyncPerUw(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerUw" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[PER_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETEND_NT], pbd_InRecChild[PER_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSEC_NF], pbd_InRecChild[PER_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[PER_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETUW_NT], pbd_InRecChild[PER_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* positionnement de la variable de participation du perimetre */
	Kn_PerUw_Pa = 1 ;

	/* memorisation de la categorie de contrat retro */
	Kn_RetCtrCat = atoi( ptb_InRecChild[PER_RETCTRCAT_CF] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee quand l'esclave n'a pas de maitre

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFilsPerUw(
	char **ptb_InRecOwner ) /* adresse de la ligne du maitre */
{
	char	MsgAno[300] ; 	/* message d'anomalie */

	DEBUT_FCT( "n_ActionPereSansFilsPerUw" ) ;

	/* generation d'une anomalie */
	sprintf( MsgAno, "The retrocession LT contract ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s ) doesn't exist in the perimeter file\n",
			ptb_InRecOwner[GT_RETCTR_NF],  ptb_InRecOwner[GT_RETEND_NT],
			ptb_InRecOwner[GT_RETSEC_NF],  ptb_InRecOwner[GT_RTY_NF],
			ptb_InRecOwner[GT_RETUW_NT] ) ;
	n_WriteAno( MsgAno ) ;

	/* code retour du programme positionne a erreur */
	Kn_RetCod = ERR ;

	RETURN_VAL( OK ) ;
}



/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « GTRr »
	avec l’esclave « GTAr »

retour :
	OK
==============================================================================*/
int n_InitGtar( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitGtar" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC2313_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtar ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtar ;

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
int n_ConditionSyncGtar(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtar" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETEND_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETUW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_TRNCOD_CF], pbd_InRecChild[GT_TRNCOD_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETCUR_CF], pbd_InRecChild[GT_RETCUR_CF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETOCCYEA_NF], pbd_InRecChild[GT_RETOCCYEA_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RCL_NF], pbd_InRecChild[GT_RCL_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETACY_NF], pbd_InRecChild[GT_RETACY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSCOSTRMTH_NF], pbd_InRecChild[GT_RETSCOSTRMTH_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[GT_RETSCOENDMTH_NF], pbd_InRecChild[GT_RETSCOENDMTH_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtar(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	char	MsgAno[300] ;

	DEBUT_FCT( "n_ActionLigneGtar" ) ;

	/* stockage de la ligne du GTAr dans le tableau Ktbd_Gta */
	n_CopyGt( ptb_InRecChild, &Ktbd_Gta[Kn_Gta_Nbp] )  ;

	/* incrementation du compteur de poste du tableau Ktbd_Gta */
	Kn_Gta_Nbp += 1 ;

	/* generation d'une anomalie si la taille du tableau est depasse */
	if ( Kn_Gta_Nbp > NB_GT_MAX )
	{
		sprintf( MsgAno, "The LT records number ( RETCTR %s - RETEND %s - RETSEC %s - RTY %s - RETUW %s - TRNCOD_CF %s - RETCUR_CF %s - RETOCCYEA_NF %s - RCL_NF %s - RETACY_NF %s - RETSCOSTRMTH_NF %s - RETSCOENDMTH_NF %s ) overflows the memory capacity\n",
			ptb_InRecChild[GT_RETCTR_NF],  ptb_InRecChild[GT_RETEND_NT], ptb_InRecChild[GT_RETSEC_NF],
			ptb_InRecChild[GT_RTY_NF], ptb_InRecChild[GT_RETUW_NT], ptb_InRecChild[GT_TRNCOD_CF],
			ptb_InRecChild[GT_RETCUR_CF], ptb_InRecChild[GT_RETOCCYEA_NF], ptb_InRecChild[GT_RCL_NF],
			ptb_InRecChild[GT_RETACY_NF], ptb_InRecChild[GT_RETSCOSTRMTH_NF], ptb_InRecChild[GT_RETSCOENDMTH_NF] ) ;
		n_WriteAno( MsgAno ) ;
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de sauvegarde d'une ligne du GT dans le tableau correspondant

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_CopyGt( char **ptb_InRec_Cur, T_GT *pbd_TabGt )
{
	DEBUT_FCT( "n_CopyGt" ) ;

	strcpy( pbd_TabGt->SSD_CF, ptb_InRec_Cur[GT_SSD_CF] ) ;
	strcpy( pbd_TabGt->ESB_CF, ptb_InRec_Cur[GT_ESB_CF] ) ;
	strcpy( pbd_TabGt->BALSHEY_NF, ptb_InRec_Cur[GT_BALSHEY_NF] ) ;
	strcpy( pbd_TabGt->BALSHRMTH_NF, ptb_InRec_Cur[GT_BALSHRMTH_NF] ) ;
	strcpy( pbd_TabGt->BALSHRDAY_NF, ptb_InRec_Cur[GT_BALSHRDAY_NF] ) ;
	strcpy( pbd_TabGt->TRNCOD_CF, ptb_InRec_Cur[GT_TRNCOD_CF] ) ;
	strcpy( pbd_TabGt->DBLTRNCOD_CF, ptb_InRec_Cur[GT_DBLTRNCOD_CF] ) ;
	strcpy( pbd_TabGt->CTR_NF, ptb_InRec_Cur[GT_CTR_NF] ) ;
	strcpy( pbd_TabGt->END_NT, ptb_InRec_Cur[GT_END_NT] ) ;
	strcpy( pbd_TabGt->SEC_NF, ptb_InRec_Cur[GT_SEC_NF] ) ;
	strcpy( pbd_TabGt->UWY_NF, ptb_InRec_Cur[GT_UWY_NF] ) ;
	strcpy( pbd_TabGt->UW_NT, ptb_InRec_Cur[GT_UW_NT] ) ;
	strcpy( pbd_TabGt->OCCYEA_NF, ptb_InRec_Cur[GT_OCCYEA_NF] ) ;
	strcpy( pbd_TabGt->ACY_NF, ptb_InRec_Cur[GT_ACY_NF] ) ;
	strcpy( pbd_TabGt->SCOSTRMTH_NF, ptb_InRec_Cur[GT_SCOSTRMTH_NF] ) ;
	strcpy( pbd_TabGt->SCOENDMTH_NF, ptb_InRec_Cur[GT_SCOENDMTH_NF] ) ;
	strcpy( pbd_TabGt->CLM_NF, ptb_InRec_Cur[GT_CLM_NF] ) ;
	strcpy( pbd_TabGt->CUR_CF, ptb_InRec_Cur[GT_CUR_CF] ) ;
	pbd_TabGt->AMT_M = atof( ptb_InRec_Cur[GT_AMT_M] ) ;
	strcpy( pbd_TabGt->CED_NF, ptb_InRec_Cur[GT_CED_NF] ) ;
	strcpy( pbd_TabGt->BRK_NF, ptb_InRec_Cur[GT_BRK_NF] ) ;
	strcpy( pbd_TabGt->PAY_NF, ptb_InRec_Cur[GT_PAY_NF] ) ;
	strcpy( pbd_TabGt->KEY_NF, ptb_InRec_Cur[GT_KEY_NF] ) ;
	strcpy( pbd_TabGt->RETCTR_NF, ptb_InRec_Cur[GT_RETCTR_NF] ) ;
	strcpy( pbd_TabGt->RETEND_NT, ptb_InRec_Cur[GT_RETEND_NT] ) ;
	strcpy( pbd_TabGt->RETSEC_NF, ptb_InRec_Cur[GT_RETSEC_NF] ) ;
	strcpy( pbd_TabGt->RTY_NF, ptb_InRec_Cur[GT_RTY_NF] ) ;
	strcpy( pbd_TabGt->RETUW_NT, ptb_InRec_Cur[GT_RETUW_NT] ) ;
	strcpy( pbd_TabGt->RETOCCYEA_NF, ptb_InRec_Cur[GT_RETOCCYEA_NF] ) ;
	strcpy( pbd_TabGt->RETACY_NF, ptb_InRec_Cur[GT_RETACY_NF] ) ;
	strcpy( pbd_TabGt->RETSCOSTRMTH_NF, ptb_InRec_Cur[GT_RETSCOSTRMTH_NF] ) ;
	strcpy( pbd_TabGt->RETSCOENDMTH_NF, ptb_InRec_Cur[GT_RETSCOENDMTH_NF] ) ;
	strcpy( pbd_TabGt->RCL_NF, ptb_InRec_Cur[GT_RCL_NF] ) ;
	strcpy( pbd_TabGt->RETCUR_CF, ptb_InRec_Cur[GT_RETCUR_CF] ) ;
	pbd_TabGt->RETAMT_M = atof( ptb_InRec_Cur[GT_RETAMT_M] ) ;
	strcpy( pbd_TabGt->PLC_NT, ptb_InRec_Cur[GT_PLC_NT] ) ;
	strcpy( pbd_TabGt->RTO_NF, ptb_InRec_Cur[GT_RTO_NF] ) ;
	strcpy( pbd_TabGt->INT_NF, ptb_InRec_Cur[GT_INT_NF] ) ;
	strcpy( pbd_TabGt->RETPAY_NF, ptb_InRec_Cur[GT_RETPAY_NF] ) ;
	strcpy( pbd_TabGt->RETKEY_CF, ptb_InRec_Cur[GT_RETKEY_CF] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture d'une ligne du GT en sortie

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_WriteGt( T_GT *pbd_Gta, T_GT *pbd_Gtr )
{
	DEBUT_FCT( "n_WriteGt" ) ;

	fprintf( Kp_OutputFilGt, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3f~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-3.f~%s~%s~%s~%s~%s\n",
		pbd_Gtr->SSD_CF, pbd_Gtr->ESB_CF, pbd_Gtr->BALSHEY_NF, pbd_Gtr->BALSHRMTH_NF,
		pbd_Gtr->BALSHRDAY_NF, pbd_Gtr->TRNCOD_CF, pbd_Gtr->DBLTRNCOD_CF, pbd_Gtr->CTR_NF,
		pbd_Gtr->END_NT, pbd_Gtr->SEC_NF, pbd_Gtr->UWY_NF, pbd_Gtr->UW_NT, pbd_Gtr->OCCYEA_NF,
		pbd_Gtr->ACY_NF, pbd_Gtr->SCOSTRMTH_NF, pbd_Gtr->SCOENDMTH_NF, pbd_Gtr->CLM_NF,
		pbd_Gtr->CUR_CF, pbd_Gtr->AMT_M, pbd_Gtr->CED_NF, pbd_Gtr->BRK_NF, pbd_Gtr->PAY_NF,
		pbd_Gtr->KEY_NF, pbd_Gtr->RETCTR_NF, pbd_Gta->END_NT, pbd_Gtr->RETSEC_NF,
		pbd_Gtr->RTY_NF, pbd_Gta->UW_NT, pbd_Gtr->RETOCCYEA_NF, pbd_Gtr->RETACY_NF,
		pbd_Gtr->RETSCOSTRMTH_NF, pbd_Gtr->RETSCOENDMTH_NF, pbd_Gtr->RCL_NF, pbd_Gtr->RETCUR_CF,
		( pbd_Gtr->RETAMT_M * pbd_Gta->RETAMT_M / Kd_GtaAmtCum ), pbd_Gtr->PLC_NT, pbd_Gtr->RTO_NF,
		pbd_Gtr->INT_NF, pbd_Gtr->RETPAY_NF, pbd_Gtr->RETKEY_CF ) ;

	RETURN_VAL( OK ) ;
}
