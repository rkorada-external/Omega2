/*==============================================================================
nom de l'application          : MaoC
nom du source                 : ESFC3743.c
revision                      :
date de creation              : 15/10/2021
auteur                        : MiS
references des specifications : REQ.P.11.9
squelette de base             : batch
------------------------------------------------------------------------------
description :
   		Calcul des futures primes et futures sinistre
                avec Transformation des postes

------------------------------------------------------------------------------
historique des modifications :
[001] 15/10/2021 	MiS  :Spira 98877 : DAC I17 Selection and TRNCOD Update
[002] 21/04/2022	MZM  :Spira 103583 : DAC I17 NDIC Selection and DBLTRNCOD Update
[003] 05/07/2022  JBD  :spira 104778:  Build new closing for I17S norm
[004] 23/09/2022  MZM  :SPIRA:  106629 : generate PLC, RTO FOR DAC I17 for TECLEDR (desactivation des Montants < 1 pour Armoniser les écarts GTAR / GTR )
========================================================================================================*/
 
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include <estserv.h>
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESFC3743_C[150] = "__version__: ESFC3743.c version [004] 23/09/2022 ECARTS GTAR /  GTR" ;

#define NB_COL_GT2              73
#define SEPARATOR		"~"

/* Variable de gestion de Rupture */

T_RUPTURE_VAR			bd_RuptPer ;		/* Variable de gestion de la rupture du PERICASE */
T_RUPTURE_SYNC_VAR		bd_RuptGt ;		/* Variable de gestion de la rupture */

/* Variable de Travail */

FILE			*Kp_OutputFilGt ;		/* pointeur sur le Fichier de sortie */

char			Ksz_Norme[5] ;
char			Kc_Norme_Suf[2] ;

/* Fonctions */

int n_ProcessingRuptureSyncVar 	(T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

int n_InitPer            	( T_RUPTURE_VAR  *pbd_Rupt );
int n_ConditionSyncPer       	(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionLignePer		(char **pbd_InRec_Cur);

int n_InitGt                 	( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneGt          	( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncGt        	( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_EcrireGt			( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account );
int n_EcrireGt2                 ( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account );

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
        InitSig ();

        if ( n_BeginPgm ( argc, argv ) == ERR )
                ExitPgm( ERR_XX , "" );

        printf("Running with %s  \n", VERSION_ESFC3743_C);

	/* Extraction Norme */
        strcpy(Ksz_Norme, psz_GetCharArgv( 1 ) ) ;

	printf("ARGUMENT RECUP Kn_Norme %s\n", Ksz_Norme);

        /* Determination du Suffice pour les TRNCOD Des Future At INCEPTION */

        if ( strncmp(Ksz_Norme, "I17G", 4) == 0 || strncmp(Ksz_Norme, "I17S", 4) == 0)  //[003]
                strcpy(Kc_Norme_Suf, "I"); //Kc_Norme_Suf = 'I';
        if ( strncmp(Ksz_Norme, "I17P", 4) == 0)
                strcpy(Kc_Norme_Suf, "K"); //Kc_Norme_Suf = 'K';
        if ( strncmp(Ksz_Norme, "I17L", 4) == 0)
                strcpy(Kc_Norme_Suf, "M"); //Kc_Norme_Suf = 'M' ;

        /* ouverture du fichier de sortie des resultats par affaire */
        if ( n_OpenFileAppl ( "ESFC3743_O1","wt",&Kp_OutputFilGt ) == ERR )
                ExitPgm( ERR_XX , "" );

        /* Initialisation de la variable bd_RuptPer */
        if ( n_InitPer( &bd_RuptPer ) )
                ExitPgm( ERR_XX , "" );

        /* Initialisation de la variable bd_RuptGt */
        if ( n_InitGt( &bd_RuptGt ) )
                ExitPgm( ERR_XX , "" );

        /* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
        if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3743_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_CloseFileAppl( "ESFC3743_I2", &( bd_RuptGt.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" );

        if ( n_EndPgm() == ERR )
                ExitPgm( ERR_XX , "" );

        exit(OK);
}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du fichier
        maitre.

retour :
        0K
==============================================================================*/
int n_InitPer(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT( "n_InitPer" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

        /* ouverture du fichier maitre Perimetre de souscription */
        if ( n_OpenFileAppl( "ESFC3743_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
                return ERR;

        pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0]=n_ConditionSyncPer;
	pbd_Rupt->n_ActionFirst[0]=n_ActionLignePer;

        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction lancÃ© a  la rupture sur le fichier maÃ®te

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionSyncPer(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_ConditionSyncPer");

        if (strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])!=0) return(1);
        if (strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT])!=0) return(1);

        return( 0 );
}

/*==============================================================================
objet : fonction lancÃ©ea rupturedu fichier maÃ®tr

retour :
        OK ---> traitement correctement effectuÃ©e
        ERR --> problÃ¨me rencontrÃ©on
==============================================================================*/
int n_ActionLignePer(char **pbd_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePer");

        n_ProcessingRuptureSyncVar( &bd_RuptGt, pbd_InRec_Cur );

        RETURN_VAL(OK) ;
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave
retour :    OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGt" );

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESFC3743_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0;
        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGt;
        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGt;


        pbd_Rupt->c_Separ = '~';

        RETURN_VAL( OK );
}

/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalitÃ© de rubrique a synchroniser)s
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild    < 0     ---> pbd_InRecOwne> < pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGt(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret;

        DEBUT_FCT( "n_ConditionSyncGt" );

        if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
        if ( ( ret = atoi( pbd_InRecOwner[PER_SEC_NF] ) - atoi( pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
        if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

        RETURN_VAL( 0 );
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
        char **pbd_InRecOwner , /* adresse de la ligne du maitre */
        char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGt" );	

	char sz_Trncod[9] = "";

	strncpy( sz_Trncod, pbd_InRecChild[GT_TRNCOD_CF], 7);
        strcat(sz_Trncod, Kc_Norme_Suf) ;

	if (strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) == 0
	&& strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) == 0
	&& strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) == 0
	&& strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) == 0
	&& strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) == 0)
        {
		n_EcrireGt(pbd_InRecChild , pbd_InRecChild[GT_CTR_NF], atof(pbd_InRecChild[GT_AMT_M]) , sz_Trncod);
	}
	RETURN_VAL( OK );
}

/*==============================================================================
objet :
        Ecrit en sortie

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_EcrireGt( char **pbd_InRec_Cur , char *CTR_NF, double d_Montant, char *account )
{
	DEBUT_FCT("n_EcrireGt");
	
	char  *Gt[NB_COL_GT2 + 1] ;	/* tableau de pointeurs a l'image du GT */
	char  sz_Amt[30] ;      	/* zone de travail */
	int i ;
	
	char sz_DblTrncod[9] = "" ;

	sprintf(sz_Amt,"%.3f", d_Montant);

	for(i=0; i < NB_COL_GT2+1; i++)
		Gt[i] = NULL;
	
	/******************************************************************/
	/* positionnement du tableau de pointeur avant ecriture en sortie */
	/******************************************************************/

	Gt[GT_SSD_CF] = pbd_InRec_Cur[GT_SSD_CF]  ;
	Gt[GT_ESB_CF] = pbd_InRec_Cur[GT_ESB_CF] ;
	Gt[GT_BALSHEY_NF] = pbd_InRec_Cur[GT_BALSHEY_NF] ;
	Gt[GT_BALSHRMTH_NF] = pbd_InRec_Cur[GT_BALSHRMTH_NF] ;
	Gt[GT_BALSHRDAY_NF] = pbd_InRec_Cur[GT_BALSHRDAY_NF] ;
	Gt[GT_CTR_NF] = pbd_InRec_Cur[GT_CTR_NF] ;
	Gt[GT_END_NT] = pbd_InRec_Cur[GT_END_NT]  ;
	Gt[GT_SEC_NF] = pbd_InRec_Cur[GT_SEC_NF];
	Gt[GT_UWY_NF] = pbd_InRec_Cur[GT_UWY_NF] ;
	Gt[GT_UW_NT]  = pbd_InRec_Cur[GT_UW_NT] ;
	Gt[GT_OCCYEA_NF] = pbd_InRec_Cur[GT_OCCYEA_NF] ;
	Gt[GT_ACY_NF] = pbd_InRec_Cur[GT_ACY_NF] ;
	Gt[GT_SCOSTRMTH_NF] = pbd_InRec_Cur[GT_SCOSTRMTH_NF] ;
	Gt[GT_SCOENDMTH_NF] = pbd_InRec_Cur[GT_SCOENDMTH_NF] ;
	Gt[GT_CLM_NF] = pbd_InRec_Cur[GT_CLM_NF];
	Gt[GT_CUR_CF] =  pbd_InRec_Cur[GT_CUR_CF] ;
	Gt[GT_CED_NF] = pbd_InRec_Cur[GT_CED_NF] ;
	Gt[GT_BRK_NF] = pbd_InRec_Cur[GT_BRK_NF] ;
	Gt[GT_PAY_NF] = pbd_InRec_Cur[GT_PAY_NF] ;
	Gt[GT_KEY_NF] = pbd_InRec_Cur[GT_KEY_NF] ;
	Gt[GT_RETCTR_NF] = pbd_InRec_Cur[GT_RETCTR_NF];
	Gt[GT_RETEND_NT] =  pbd_InRec_Cur[GT_RETEND_NT] ;
	Gt[GT_RETSEC_NF] =  pbd_InRec_Cur[GT_RETSEC_NF] ;
	Gt[GT_RTY_NF] = pbd_InRec_Cur[GT_RTY_NF] ;
	Gt[GT_RETUW_NT] = pbd_InRec_Cur[GT_RETUW_NT] ;
	Gt[GT_RETOCCYEA_NF] = pbd_InRec_Cur[GT_RETOCCYEA_NF] ;
	Gt[GT_RETACY_NF] = pbd_InRec_Cur[GT_RETACY_NF] ;
	Gt[GT_RETSCOSTRMTH_NF] = pbd_InRec_Cur[GT_RETSCOSTRMTH_NF] ;
	Gt[GT_RETSCOENDMTH_NF] = pbd_InRec_Cur[GT_RETSCOENDMTH_NF] ;
	Gt[GT_RCL_NF] = pbd_InRec_Cur[GT_RCL_NF] ;
	Gt[GT_RETCUR_CF] = pbd_InRec_Cur[GT_RETCUR_CF] ;
	Gt[GT_RETAMT_M] = pbd_InRec_Cur[GT_RETAMT_M] ;
	Gt[GT_PLC_NT] = pbd_InRec_Cur[GT_PLC_NT] ;
	Gt[GT_RTO_NF] = pbd_InRec_Cur[GT_RTO_NF] ;
	Gt[GT_INT_NF] = pbd_InRec_Cur[GT_RETPAY_NF] ;
	Gt[GT_RETPAY_NF] = pbd_InRec_Cur[GT_RETPAY_NF] ;
	Gt[GT_RETKEY_CF] = pbd_InRec_Cur[GT_RETKEY_CF] ;
	Gt[GT_RETINTAMT_M] = pbd_InRec_Cur[GT_RETINTAMT_M] ;
	Gt[GT_ESTCUR_CF] = pbd_InRec_Cur[GT_ESTCUR_CF] ;
        Gt[GT_ESTAMT_M] = pbd_InRec_Cur[GT_ESTAMT_M] ;
        Gt[GT_NAT_CF] = pbd_InRec_Cur[GT_NAT_CF] ;
        Gt[GT_ACMTRS_NT] = pbd_InRec_Cur[GT_ACMTRS_NT] ;
        Gt[GT_ESTCTR_NF] = pbd_InRec_Cur[GT_ESTCTR_NF] ;
        Gt[GT_ESTSEC_NF] = pbd_InRec_Cur[GT_ESTSEC_NF] ;
        Gt[GT_LOB_CF] = pbd_InRec_Cur[GT_LOB_CF] ;
        Gt[GT_SCOEGP_M] = pbd_InRec_Cur[GT_SCOEGP_M] ;
        Gt[GT_ESTCRB_CT] = pbd_InRec_Cur[GT_ESTCRB_CT] ;
        Gt[GT_LIFTRTTYP_CF] = pbd_InRec_Cur[GT_LIFTRTTYP_CF] ;
        Gt[GT_ACCADMTYP_CT] = pbd_InRec_Cur[GT_ACCADMTYP_CT] ;
        Gt[GT_SECSTS_CT] = pbd_InRec_Cur[GT_SECSTS_CT] ;
        Gt[GT_PRD_NF] = pbd_InRec_Cur[GT_PRD_NF] ;
        Gt[GT_SEG_NF] = pbd_InRec_Cur[GT_SEG_NF] ;
        Gt[GT_COMACC_B] = pbd_InRec_Cur[GT_COMACC_B] ;
	Gt[GT_ADJCOD_CT] = pbd_InRec_Cur[GT_ADJCOD_CT] ;
        Gt[GT_ORICOD_CF] = pbd_InRec_Cur[GT_ORICOD_CF] ;
        Gt[GT_DETTRS_CF] = pbd_InRec_Cur[GT_DETTRS_CF] ;
        Gt[GT_ACCRET_B] = pbd_InRec_Cur[GT_ACCRET_B] ;
        Gt[GT_ESTUWY_NF] = pbd_InRec_Cur[GT_ESTUWY_NF] ;
        Gt[GT_LSTENDMTH_NF] = pbd_InRec_Cur[GT_LSTENDMTH_NF] ;
        Gt[GT_PROPER_N] = pbd_InRec_Cur[GT_PROPER_N] ;
        Gt[GT_RTOCTY_CF] = pbd_InRec_Cur[GT_RTOCTY_CF] ;
        Gt[GT_GAAP_NF] = pbd_InRec_Cur[GT_GAAP_NF] ;
        Gt[GT_BRKSCOEGP_M] = pbd_InRec_Cur[GT_BRKSCOEGP_M] ;
        Gt[GT_UWGRP_CF] = pbd_InRec_Cur[GT_UWGRP_CF] ;
        Gt[GT_PROPAGRES_B] = pbd_InRec_Cur[GT_PROPAGRES_B] ;
        Gt[GT_PostBpc_B] = pbd_InRec_Cur[GT_PostBpc_B] ;
        Gt[GT_SPIMOD_CT] = pbd_InRec_Cur[GT_SPIMOD_CT] ;
        Gt[GT_RETAUTGEN_B] = pbd_InRec_Cur[GT_RETAUTGEN_B] ;
        Gt[GT_ACCTYP_NF] = pbd_InRec_Cur[GT_ACCTYP_NF] ;
	
	if (account[0] == '2')
	Gt[GT_ActivePlan_b] = pbd_InRec_Cur[GT_ActivePlan_b] ;

        Gt[GT_RETAMT_M] = pbd_InRec_Cur[GT_RETAMT_M] ;
        Gt[GT_RETINTAMT_M] = pbd_InRec_Cur[GT_RETINTAMT_M] ;
        Gt[GT_TRNCOD_CF] = account;
 
 //[002]       
	      strncpy( sz_DblTrncod, pbd_InRec_Cur[GT_DBLTRNCOD_CF], 7);
        strcat(sz_DblTrncod, Kc_Norme_Suf) ; 
        
        if (strcmp(pbd_InRec_Cur[GT_DBLTRNCOD_CF], "") != 0)     
        	Gt[GT_DBLTRNCOD_CF] = sz_DblTrncod;          
        else
        	Gt[GT_DBLTRNCOD_CF] = pbd_InRec_Cur[GT_DBLTRNCOD_CF] ;
        
        
        
        Gt[GT_AMT_M] = sz_Amt;

       //[004] if ( fabs(atof(sz_Amt)) > 1  )
        {
        	n_WriteCols( Kp_OutputFilGt, Gt, SEPARATEUR, 0 );
        }

	RETURN_VAL(OK);
}

