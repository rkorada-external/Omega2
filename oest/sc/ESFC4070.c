/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1051.c  ==> ESFC4070.c
date de cr�ation              : 09/01/2025
auteur                        : MZM
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :SPIRA 112437   20.1 - I17 - Add conversion in EGPI currency of PA reclass
     

------------------------------------------------------------------------------
historique des modifications :
[001] 18/02/2025 MZM : SPIRA 112746   20.1 - I17 -Gap in Premium Adj reclass calculation
[002] 25/03/2025 MZM : SPIRA 112808   1Q25 PRD - Gaps between RA vs RR view on Reclass transactions
================================================================================*/

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
//[005]
#define Kn_MaxPostes 100000	/* Le nombre max de postes est fixe a 100000 */

#define FTTECLEDA_RETPAY_NF 38

#define PERI_CURQUOT_RATE 205
#define PERI_PCPCUR_CF    206
#define PERI_EGPCUR_CF    207

#define GTAR_CURQUOT_RATE 121   //001

#define GTAA_CURQUOT_RATE 120   //001

#define GTR_CURQUOT_RATE 71      // Format GTR 71 colonne

int  GTF_CURQUOT_RATE ;

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii; /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */


T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptStatGta; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */

T_TRSLNK Ktbd_TrsLnk[Kn_MaxPostes];
int Kn_NbLigTrslnk;
int Kn_FBOTRSLNK ;   		/* compteur du nombre ligne chargees dans Ktbd_FBOTRSLNK */


FILE *Kp_FBOTRSLNK;

int n_ChargerFBOTRSLNK();
//int n_RechTrn(char *sz_trn );
/* [09] */

int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_ActionLignePerUw     ( char **pbd_InRec_Cur );
int n_InitStatGta		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneStatGta   ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncStatGta ( char **ptb_InRecOwner, char **pbd_InRecChild );
int n_ActionFilsSansPere(char **  ptb_InRecChild);
int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner );

//int n_ChargerTRSLNK ( short s_TrtCod );
//int n_RechPoste     ( char *sz_poste );

char Ksz_Accret[2];          /* Type de fichier traité : Accept ou Retro (A/R) */
char Ksz_AnneeBilan[5];
char Ksz_GTF_CURQUOT_RATE[4];
short s_Prs;

int  is_TRT(char *);
char * trim(char *); 
long   ligne=1;

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

	/* recuperation des arguments passes au programme */
	strcpy(Ksz_Accret,psz_GetCharArgv(1));
	strcpy(Ksz_AnneeBilan,psz_GetCharArgv(2));
	strcpy(Ksz_GTF_CURQUOT_RATE,psz_GetCharArgv(3));
	
	GTF_CURQUOT_RATE = atoi(Ksz_GTF_CURQUOT_RATE);
		
	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESFC4070_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptStatGta */
	if ( n_InitStatGta( &bd_RuptStatGta ) )
		ExitPgm( ERR_XX , "" );

	/* Chargement des postes en memoire */
	//Kn_NbLigTrslnk = n_ChargerTRSLNK( s_Prs );  // 750 remplace par variable

	//if ( Kn_NbLigTrslnk > Kn_MaxPostes )
	//		ExitPgm( ERR_XX , "" );

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC4070_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC4070_I2", &( bd_RuptStatGta.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	//if ( n_CloseFileAppl( "ESFC4070_I3", &Kp_InputFilTrsLnk ) == ERR )
	//	ExitPgm( ERR_XX , "" );
    //
	//if ( n_CloseFileAppl( "ESFC4070_I4", &Kp_InputFilExc ) == ERR )
	//	ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESFC4070_O1", &Kp_OutputFilResSii ) == ERR )
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
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerUw" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) );

	/* ouverture du fichier maitre Perimetre de souscription */
	if ( n_OpenFileAppl( "ESFC4070_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 0;

	/* fonction d'action sur la ligne courante du fichier maitre */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
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

	DEBUT_FCT( "n_ActionLignePerUw" );

	/* synchronisation avec le fichier DTSTATGTXX */
	n_ProcessingRuptureSyncVar( &bd_RuptStatGta, ptb_InRec_Cur );

	RETURN_VAL( OK );
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitStatGta( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitStatGta" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESFC4070_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncStatGta;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneStatGta;

	//if(*Ksz_Accret=='R')
		pbd_Rupt->n_FilsSansPere=n_ActionFilsSansPere;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}




/*==============================================================================
objet :
	fonction de test de synchronisation 

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncStatGta(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncStatGta" );


	if ( strcmp(Ksz_Accret, "A") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FTTECLEDA_CTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FTTECLEDA_END_NT] ) ) != 0 ) return ret;
		//if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FTTECLEDA_SEC_NF] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[FTTECLEDA_SEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FTTECLEDA_UWY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FTTECLEDA_UW_NT] ) ) != 0 ) return ret;
	}
	if ( strcmp(Ksz_Accret, "R") == 0)
	{
		if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FTTECLEDA_RETCTR_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FTTECLEDA_RETEND_NT] ) ) != 0 ) return ret;
		//if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FTTECLEDA_RETSEC_NF] ) ) != 0 ) return ret;
		if ( ( ret = atoi(pbd_InRecOwner[PER_SEC_NF]) - atoi(pbd_InRecChild[FTTECLEDA_RETSEC_NF]) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FTTECLEDA_RTY_NF] ) ) != 0 ) return ret;
		if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FTTECLEDA_RETUW_NT] ) ) != 0 ) return ret;
	}

	RETURN_VAL( 0 );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneStatGta(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char	 *FctrestSii[FTTECLEDA_NB_COL + 5]; /* tableau de pointeur a l'image du fichier en sortie */
	char   sz_Trncod[9];
	char   sz_RetAmt[25];
	char   sz_Amt[25];

	char   sz_RetAmtCur[4];
	char   sz_AmtCur[4];	

	double d_RetAmt = 0;     /* montant  retrocession */
	double d_Amt = 0 ;        /* montant acceptation*/	
	double d_Ratio;      /* ratio: cours montant de prime/cours aliment */
	char   MsgAno[300];  /* message anomalie*/

	
	int PER_PCPCUR_RATE=205; //206
	int PER_EGPCUR_RATE=206; //207
	
	//double rate = 1 ; //0 ;

	DEBUT_FCT( "n_ActionLigneStatGta" );

	memset( sz_RetAmtCur, 0, sizeof( sz_RetAmtCur ) ); 
	memset( sz_AmtCur, 0, sizeof( sz_AmtCur ) ); 	
	
	memset( sz_Amt, 0, sizeof( sz_Amt ) ); 	
	memset( sz_RetAmt, 0, sizeof( sz_RetAmt ) ); 		

		
	memset(sz_Trncod, 0, sizeof(sz_Trncod));
	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[FTTECLEDA_TRNCOD_CF] );
			
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	d_Ratio = 1;
	
		d_RetAmt = atof( ptb_InRecChild[FTTECLEDA_RETAMT_M] );
		d_Amt = atof( ptb_InRecChild[FTTECLEDA_AMT_M] );	
		
	//if ( ( strcmp(ptb_InRecChild[FTTECLEDA_RETCTR_NF], "01P000268" ) == 0 && strcmp(ptb_InRecChild[FTTECLEDA_RTY_NF], "2016" ) == 0) && ( strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110000I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2112000I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2110071I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "2410071I" ) == 0 )	 )
	//printf(" TRACE  retctr_nf = %s ;  %s; PERI_CUR=%s ; %-.3f ; %s \n", ptb_InRecChild[FTTECLEDA_RETCTR_NF], ptb_InRecChild[FTTECLEDA_RETCUR_CF], ptb_InRecOwner[PER_PCPCUR_CF], atof(ptb_InRecChild[FTTECLEDA_RETAMT_M]), ptb_InRecChild[FTTECLEDA_TRNCOD_CF]); //  GTF=%-.3f ; GTAR=%-.3f  , atof(ptb_InRecOwner[GTF_CURQUOT_RATE]), atof(ptb_InRecOwner[GTAR_CURQUOT_RATE]) 
		
			

	if (*ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '2' || *ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '4')
	{

			
		if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_PCPCUR_CF] ) )
		{ 
			sprintf( sz_RetAmtCur, "%s", "EUR" );
			sprintf( sz_AmtCur, "%s", "EUR" );			
		}
		else	
		{ 		
			sprintf( sz_RetAmtCur, "%s", ptb_InRecOwner[PER_PCPCUR_CF] );
			sprintf( sz_AmtCur, "%s", ptb_InRecOwner[PER_PCPCUR_CF] );			
		}
		
		// if ( ! b_IsBlankOrEmpty( ptb_InRecOwner[PER_PCPCUR_RATE])  )	rate = atof(ptb_InRecOwner[PER_PCPCUR_RATE]) ;

		//printf("PCP%s ; PER_PCPCUR_RATE=%d\n",ptb_InRecOwner[PER_PCPCUR_RATE], PER_PCPCUR_RATE);
		
		if ( strcmp(Ksz_Accret, "R") == 0 && strcmp( ptb_InRecChild[FTTECLEDA_RETCUR_CF], sz_RetAmtCur ) != 0 )
		{
			

			double 	taux_GT = 1 ;
			
			double 	taux_PERI = atof(ptb_InRecOwner[PERI_CURQUOT_RATE]) ; 
			
			if ( GTF_CURQUOT_RATE == 121 )
				taux_GT = atof(ptb_InRecChild[GTAR_CURQUOT_RATE]) ; 
			else 
				taux_GT = atof(ptb_InRecChild[GTR_CURQUOT_RATE]) ; 			

			if ( b_IsBlankOrEmpty( ptb_InRecOwner[PERI_CURQUOT_RATE])  || taux_PERI <= 0 ) 
				d_Ratio = 1 ;
			else 
				d_Ratio = taux_GT / taux_PERI  ;					 
			 
		}
		
    		d_RetAmt = atof( ptb_InRecChild[FTTECLEDA_RETAMT_M] );
    		d_RetAmt*= d_Ratio;
    		 
    		//sprintf( sz_RetAmtCur, "%s", ptb_InRecOwner[PERI_EGPCUR_CF]);
    		sprintf( sz_RetAmt, "%-.3f", d_RetAmt );	
    		
    		//Assume By Retro 
    		if ( ! b_IsBlankOrEmpty(ptb_InRecChild[FTTECLEDA_RETCUR_CF] ) )
    		{
    				d_Amt = atof( ptb_InRecChild[FTTECLEDA_AMT_M] );
    				d_Amt*= d_Ratio;
    		 
    				//sprintf( sz_AmtCur, "%s", ptb_InRecChild[FTTECLEDA_RETCUR_CF] );
    				sprintf( sz_Amt, "%-.3f", d_RetAmt );  
    		}  		
    				
		
	}
	else  // ONLY ACCEPT PER_EGPCUR_CF PER_PCPCUR_CF
	{
		
		if ( b_IsBlankOrEmpty( ptb_InRecOwner[PER_EGPCUR_CF] ) )
		{ 
			sprintf( sz_AmtCur, "%s", "EUR" );			
		}
		else	
		{ 		
			sprintf( sz_AmtCur, "%s", ptb_InRecOwner[PER_EGPCUR_CF] );			
		}
		
		
		if (strcmp( ptb_InRecChild[FTTECLEDA_CUR_CF], sz_AmtCur ) != 0 )
		{
			double 	taux_PERI = atof(ptb_InRecOwner[PERI_CURQUOT_RATE]) ; 
			double 	taux_GT = atof(ptb_InRecChild[GTAA_CURQUOT_RATE]) ; //GTAR_CURQUOT_RATE  GTF_CURQUOT_RATE

			if ( b_IsBlankOrEmpty( ptb_InRecOwner[PERI_CURQUOT_RATE])  || taux_PERI <= 0 ) 
				d_Ratio = 1 ;
			else 
					d_Ratio = taux_GT / taux_PERI  ;	
			 
		}	
		
		//if ( ( strcmp(ptb_InRecChild[FTTECLEDA_CTR_NF], "01F016583" ) == 0 && strcmp(ptb_InRecChild[FTTECLEDA_UWY_NF], "2024" ) == 0) && ( strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "1112000I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "1110000I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "1110071I" ) == 0 || strcmp(ptb_InRecChild[FTTECLEDA_TRNCOD_CF], "1410071I" ) == 0 )	 )
		//printf(" TRACE  ctr_nf = %s ;  %s; PERI_CUR=%s ; %-.3f ; %s \n", ptb_InRecChild[FTTECLEDA_CTR_NF], ptb_InRecChild[FTTECLEDA_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF], atof(ptb_InRecChild[FTTECLEDA_AMT_M]), ptb_InRecChild[FTTECLEDA_TRNCOD_CF]); //  GTF=%-.3f ; GTAR=%-.3f  , atof(ptb_InRecOwner[GTF_CURQUOT_RATE]), atof(ptb_InRecOwner[GTAR_CURQUOT_RATE]) 

    //printf("")

		 d_Amt = atof( ptb_InRecChild[FTTECLEDA_AMT_M] );
    	
     d_Amt*= d_Ratio;
    	
    // sprintf( sz_AmtCur, "%s", ptb_InRecChild[FTTECLEDA_CUR_CF] );
    	
     sprintf( sz_Amt, "%-.3f", d_Amt );	

	}

	/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
	if ( d_Ratio < 0 )
	{
		
			//Remettre les donnees initiales 
			
			//sprintf( sz_RetAmtCur, "%s", ptb_InRecChild[FTTECLEDA_RETCUR_CF] );
			//sprintf( sz_RetAmt, "%s", ptb_InRecChild[FTTECLEDA_RETAMT_M] );
			//
			//sprintf( sz_AmtCur, "%s", ptb_InRecChild[FTTECLEDA_CUR_CF] );
			//sprintf( sz_Amt, "%s", ptb_InRecChild[FTTECLEDA_AMT_M] );
					
		
		if (*ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '2' || *ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '4')
		{
			sprintf( MsgAno, "The rates of retro currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
			         ptb_InRecChild[FTTECLEDA_RETCUR_CF], ptb_InRecOwner[PER_PCPCUR_CF], ptb_InRecChild[FTTECLEDA_RETCTR_NF],  ptb_InRecChild[FTTECLEDA_RETEND_NT], ptb_InRecChild[FTTECLEDA_RETSEC_NF], ptb_InRecChild[FTTECLEDA_RTY_NF], ptb_InRecChild[FTTECLEDA_UW_NT], ptb_InRecChild[FTTECLEDA_BALSHEY_NF] );			       			
		}
		else
		{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", 
			         ptb_InRecChild[FTTECLEDA_CUR_CF], ptb_InRecOwner[PER_EGPCUR_CF], ptb_InRecChild[FTTECLEDA_CTR_NF],  ptb_InRecChild[FTTECLEDA_END_NT], ptb_InRecChild[FTTECLEDA_SEC_NF], ptb_InRecChild[FTTECLEDA_UWY_NF], ptb_InRecChild[FTTECLEDA_UW_NT], ptb_InRecChild[FTTECLEDA_BALSHEY_NF] );
		
		}
		n_WriteAno( MsgAno );
		/* montant positionne a zero */
		d_RetAmt = 0;
		d_Amt = 0;	
		
		RETURN_VAL( OK );	
	}



//printf("%s %s %s %s\n",ptb_InRecChild[FTTECLEDA_RETCTR_NF],ptb_InRecOwner[PER_PCPCUR_CF],ptb_InRecChild[FTTECLEDA_RETCUR_CF],sz_RetAmtCur);

		FctrestSii[FTTECLEDA_SSD_CF]              		= ptb_InRecChild[FTTECLEDA_SSD_CF]             ;     
		FctrestSii[FTTECLEDA_ESB_CF]                  = ptb_InRecChild[FTTECLEDA_ESB_CF]             ;     
		FctrestSii[FTTECLEDA_BALSHEY_NF]              = ptb_InRecChild[FTTECLEDA_BALSHEY_NF]         ;     
		FctrestSii[FTTECLEDA_BALSHRMTH_NF]            = ptb_InRecChild[FTTECLEDA_BALSHRMTH_NF]       ;     
		FctrestSii[FTTECLEDA_BALSHRDAY_NF]            = ptb_InRecChild[FTTECLEDA_BALSHRDAY_NF]       ;     
		FctrestSii[FTTECLEDA_TRNCOD_CF]               = ptb_InRecChild[FTTECLEDA_TRNCOD_CF]          ;     
		FctrestSii[FTTECLEDA_DBLTRNCOD_CF]            = ptb_InRecChild[FTTECLEDA_DBLTRNCOD_CF]       ;     
		FctrestSii[FTTECLEDA_CTR_NF]                  = ptb_InRecChild[FTTECLEDA_CTR_NF]             ;     
		FctrestSii[FTTECLEDA_END_NT]                  = ptb_InRecChild[FTTECLEDA_END_NT]             ;     
		FctrestSii[FTTECLEDA_SEC_NF]                  = ptb_InRecChild[FTTECLEDA_SEC_NF]             ;     
		FctrestSii[FTTECLEDA_UWY_NF]                  = ptb_InRecChild[FTTECLEDA_UWY_NF]             ;     
		FctrestSii[FTTECLEDA_UW_NT]                   = ptb_InRecChild[FTTECLEDA_UW_NT]              ;     
		FctrestSii[FTTECLEDA_OCCYEA_NF]               = ptb_InRecChild[FTTECLEDA_OCCYEA_NF]          ;     
		FctrestSii[FTTECLEDA_ACY_NF]                  = ptb_InRecChild[FTTECLEDA_ACY_NF]             ;     
		FctrestSii[FTTECLEDA_SCOSTRMTH_NF]            = ptb_InRecChild[FTTECLEDA_SCOSTRMTH_NF]       ;     
		FctrestSii[FTTECLEDA_SCOENDMTH_NF]            = ptb_InRecChild[FTTECLEDA_SCOENDMTH_NF]       ;     
		FctrestSii[FTTECLEDA_CLM_NF]                  = ptb_InRecChild[FTTECLEDA_CLM_NF]             ;     
		FctrestSii[FTTECLEDA_CUR_CF]                  = sz_AmtCur    ; //ptb_InRecChild[FTTECLEDA_CUR_CF]             ;     
		FctrestSii[FTTECLEDA_AMT_M]                   = sz_Amt ; // ptb_InRecChild[FTTECLEDA_AMT_M]              ;     
		FctrestSii[FTTECLEDA_CED_NF]                  = ptb_InRecChild[FTTECLEDA_CED_NF]             ;     
		FctrestSii[FTTECLEDA_BRK_NF]                  = ptb_InRecChild[FTTECLEDA_BRK_NF]             ;     
		FctrestSii[FTTECLEDA_PAY_NF]                  = ptb_InRecChild[FTTECLEDA_PAY_NF]             ;     
		FctrestSii[FTTECLEDA_KEY_NF]                  = ptb_InRecChild[FTTECLEDA_KEY_NF]             ;     
		FctrestSii[FTTECLEDA_RETCTR_NF]               = ptb_InRecChild[FTTECLEDA_RETCTR_NF]          ;     
		FctrestSii[FTTECLEDA_RETEND_NT]               = ptb_InRecChild[FTTECLEDA_RETEND_NT]          ;     
		FctrestSii[FTTECLEDA_RETSEC_NF]               = ptb_InRecChild[FTTECLEDA_RETSEC_NF]          ;     
		FctrestSii[FTTECLEDA_RTY_NF]                  = ptb_InRecChild[FTTECLEDA_RTY_NF]             ;     
		FctrestSii[FTTECLEDA_RETUW_NT]                = ptb_InRecChild[FTTECLEDA_RETUW_NT]           ;     
		FctrestSii[FTTECLEDA_RETOCCYEA_NF]            = ptb_InRecChild[FTTECLEDA_RETOCCYEA_NF]       ;     
		FctrestSii[FTTECLEDA_RETACY_NF]               = ptb_InRecChild[FTTECLEDA_RETACY_NF]          ;     
		FctrestSii[FTTECLEDA_RETSCOSTRMTH_NF]         = ptb_InRecChild[FTTECLEDA_RETSCOSTRMTH_NF]    ;     
		FctrestSii[FTTECLEDA_RETSCOENDMTH_NF]         = ptb_InRecChild[FTTECLEDA_RETSCOENDMTH_NF]    ;     
		FctrestSii[FTTECLEDA_RCL_NF]                  = ptb_InRecChild[FTTECLEDA_RCL_NF]             ; 
		
		if ( strcmp(Ksz_Accret, "R") == 0)
		{		    
		FctrestSii[FTTECLEDA_RETCUR_CF]               = sz_RetAmtCur;     //ptb_InRecChild[FTTECLEDA_RETCUR_CF]          ;  
		FctrestSii[FTTECLEDA_RETAMT_M]                = sz_RetAmt ; //ptb_InRecChild[FTTECLEDA_RETAMT_M]           ;
		FctrestSii[FTTECLEDA_PLC_NT]                  = ptb_InRecChild[FTTECLEDA_PLC_NT]             ;
		FctrestSii[FTTECLEDA_RTO_NF]                  = ptb_InRecChild[FTTECLEDA_RTO_NF]             ;
		FctrestSii[FTTECLEDA_INT_NF]                  = ptb_InRecChild[FTTECLEDA_INT_NF]             ;
		FctrestSii[FTTECLEDA_RETPAY_NF]               = ptb_InRecChild[FTTECLEDA_RETPAY_NF]          ;
		FctrestSii[FTTECLEDA_RETKEY_CF]               = ptb_InRecChild[FTTECLEDA_RETKEY_CF]          ; 		
		}
		else
		{
		FctrestSii[FTTECLEDA_RETCUR_CF]               = " " ;
		FctrestSii[FTTECLEDA_RETAMT_M]                = " " ;	
		FctrestSii[FTTECLEDA_PLC_NT]                  = " " ; //ptb_InRecChild[FTTECLEDA_PLC_NT]             ;
		FctrestSii[FTTECLEDA_RTO_NF]                  = " " ; //ptb_InRecChild[FTTECLEDA_RTO_NF]             ;
		FctrestSii[FTTECLEDA_INT_NF]                  = " " ;//ptb_InRecChild[FTTECLEDA_INT_NF]             ;
		FctrestSii[FTTECLEDA_RETPAY_NF]               = " " ; //ptb_InRecChild[FTTECLEDA_RETPAY_NF]          ;
		FctrestSii[FTTECLEDA_RETKEY_CF]               = " " ; //ptb_InRecChild[FTTECLEDA_RETKEY_CF]          ; 		
	  }
    
		FctrestSii[FTTECLEDA_CRE_D]                   = ptb_InRecChild[FTTECLEDA_CRE_D]              ;     
		FctrestSii[FTTECLEDA_CREUSR_CF]               = ptb_InRecChild[FTTECLEDA_CREUSR_CF]          ;     
		FctrestSii[FTTECLEDA_LSTUPD_D]                = ptb_InRecChild[FTTECLEDA_LSTUPD_D]           ;     
		FctrestSii[FTTECLEDA_LSTUPDUSR_CF]            = ptb_InRecChild[FTTECLEDA_LSTUPDUSR_CF]       ;     
		FctrestSii[FTTECLEDA_LOBACC_CF]               = ptb_InRecChild[FTTECLEDA_LOBACC_CF]          ;     
		FctrestSii[FTTECLEDA_LOBRET_CF]               = ptb_InRecChild[FTTECLEDA_LOBRET_CF]          ;     
		FctrestSii[FTTECLEDA_SOBACC_CF]               = ptb_InRecChild[FTTECLEDA_SOBACC_CF]          ;     
		FctrestSii[FTTECLEDA_SOBRET_CF]               = ptb_InRecChild[FTTECLEDA_SOBRET_CF]          ;     
		FctrestSii[FTTECLEDA_TOPACC_CF]               = ptb_InRecChild[FTTECLEDA_TOPACC_CF]          ;     
		FctrestSii[FTTECLEDA_TOPRET_CF]               = ptb_InRecChild[FTTECLEDA_TOPRET_CF]          ;     
		FctrestSii[FTTECLEDA_NATACC_CF]               = ptb_InRecChild[FTTECLEDA_NATACC_CF]          ;     
		FctrestSii[FTTECLEDA_NATRET_CF]               = ptb_InRecChild[FTTECLEDA_NATRET_CF]          ;     
		FctrestSii[FTTECLEDA_GARACC_CF]               = ptb_InRecChild[FTTECLEDA_GARACC_CF]          ;     
		FctrestSii[FTTECLEDA_GARRET_CF]               = ptb_InRecChild[FTTECLEDA_GARRET_CF]          ;     
		FctrestSii[FTTECLEDA_PCPRSKTRYACC_CF]         = ptb_InRecChild[FTTECLEDA_PCPRSKTRYACC_CF]    ;     
		FctrestSii[FTTECLEDA_PCPRSKTRYRET_CF]         = ptb_InRecChild[FTTECLEDA_PCPRSKTRYRET_CF]    ;     
		FctrestSii[FTTECLEDA_USRCRTCODACC_CT]         = ptb_InRecChild[FTTECLEDA_USRCRTCODACC_CT]    ;     
		FctrestSii[FTTECLEDA_USRCRTCODRET_CT]         = ptb_InRecChild[FTTECLEDA_USRCRTCODRET_CT]    ;     
		FctrestSii[FTTECLEDA_USRCRTVALACC_LM]          = ptb_InRecChild[FTTECLEDA_USRCRTVALACC_LM]     ;     
		FctrestSii[FTTECLEDA_USRCRTVALRET_LM]          = ptb_InRecChild[FTTECLEDA_USRCRTVALRET_LM]     ;     
		FctrestSii[FTTECLEDA_CTRNAT_CT]               = ptb_InRecChild[FTTECLEDA_CTRNAT_CT]          ;     
		FctrestSii[FTTECLEDA_RETCTRCAT_CF]            = ptb_InRecChild[FTTECLEDA_RETCTRCAT_CF]       ;     
		FctrestSii[FTTECLEDA_WRKCAT_CT]               = ptb_InRecChild[FTTECLEDA_WRKCAT_CT]          ;     
		FctrestSii[FTTECLEDA_PRDCOD_CT]               = ptb_InRecChild[FTTECLEDA_PRDCOD_CT]          ;     
		FctrestSii[FTTECLEDA_ANLCTY_CF]               = ptb_InRecChild[FTTECLEDA_ANLCTY_CF]          ;     
		FctrestSii[FTTECLEDA_ACCADMTYP_CT]            = ptb_InRecChild[FTTECLEDA_ACCADMTYP_CT]       ;     
		FctrestSii[FTTECLEDA_RETACCTYP_CT]            = ptb_InRecChild[FTTECLEDA_RETACCTYP_CT]       ;     
		FctrestSii[FTTECLEDA_COMACC_B]                 = ptb_InRecChild[FTTECLEDA_COMACC_B]            ;     
		FctrestSii[FTTECLEDA_CPLACCUPD_D]             = ptb_InRecChild[FTTECLEDA_CPLACCUPD_D]        ;     
		FctrestSii[FTTECLEDA_CTRRET_B]                 = ptb_InRecChild[FTTECLEDA_CTRRET_B]            ;     
		FctrestSii[FTTECLEDA_UWGRP_CF]                = ptb_InRecChild[FTTECLEDA_UWGRP_CF]           ;     
		FctrestSii[FTTECLEDA_VRS_NF]                  = ptb_InRecChild[FTTECLEDA_VRS_NF]             ;     
		FctrestSii[FTTECLEDA_SEG_NF]                  = ptb_InRecChild[FTTECLEDA_SEG_NF]             ;     
		FctrestSii[FTTECLEDA_UWORG_CF]                = ptb_InRecChild[FTTECLEDA_UWORG_CF]           ;     
		FctrestSii[FTTECLEDA_ESTCRB_CT]               = ptb_InRecChild[FTTECLEDA_ESTCRB_CT]          ;     
		FctrestSii[FTTECLEDA_ESTCTR_NF]               = ptb_InRecChild[FTTECLEDA_ESTCTR_NF]          ;     
		FctrestSii[FTTECLEDA_ESBACC_NF]               = ptb_InRecChild[FTTECLEDA_ESBACC_NF]          ;     
		FctrestSii[FTTECLEDA_ORGCED_NF]               = ptb_InRecChild[FTTECLEDA_ORGCED_NF]          ;     
		FctrestSii[FTTECLEDA_CEDHORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_CEDHORDNBR_NT]      ;     
		FctrestSii[FTTECLEDA_CEDSORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_CEDSORDNBR_NT]      ;     
		FctrestSii[FTTECLEDA_ORGCEDHORDNBR_NT]        = ptb_InRecChild[FTTECLEDA_ORGCEDHORDNBR_NT]   ;     
		FctrestSii[FTTECLEDA_ORGCEDSORDNBR_NT]        = ptb_InRecChild[FTTECLEDA_ORGCEDSORDNBR_NT]   ;     
		FctrestSii[FTTECLEDA_BRKHORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_BRKHORDNBR_NT]      ;     
		FctrestSii[FTTECLEDA_BRKSORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_BRKSORDNBR_NT]      ;     
		FctrestSii[FTTECLEDA_FACADMTYP_CT]            = ptb_InRecChild[FTTECLEDA_FACADMTYP_CT]       ;     
		FctrestSii[FTTECLEDA_CLIIND_NF]               = ptb_InRecChild[FTTECLEDA_CLIIND_NF]          ;     
		FctrestSii[FTTECLEDA_HORDNBR_NT]              = ptb_InRecChild[FTTECLEDA_HORDNBR_NT]         ; 
		if ( strcmp(Ksz_Accret, "R") == 0)    
		FctrestSii[FTTECLEDA_RETINTAMT_M]             =  sz_RetAmt; 									// ptb_InRecChild[FTTECLEDA_RETINTAMT_M]         ; 
		else
		FctrestSii[FTTECLEDA_RETINTAMT_M]             = "" ;	   
		FctrestSii[FTTECLEDA_BUKRS_CF]                = ptb_InRecChild[FTTECLEDA_BUKRS_CF]           ;     
		FctrestSii[FTTECLEDA_RCOMP_CF]                = ptb_InRecChild[FTTECLEDA_RCOMP_CF]           ;     
		FctrestSii[FTTECLEDA_LDGRP_CF]                = ptb_InRecChild[FTTECLEDA_LDGRP_CF]           ;     
		FctrestSii[FTTECLEDA_HKONT_CF]                = ptb_InRecChild[FTTECLEDA_HKONT_CF]           ;     
		FctrestSii[FTTECLEDA_DBLHKONT_CF]             = ptb_InRecChild[FTTECLEDA_DBLHKONT_CF]        ;     
		FctrestSii[FTTECLEDA_GJAHR_NF]                = ptb_InRecChild[FTTECLEDA_GJAHR_NF]           ;     
		FctrestSii[FTTECLEDA_MONAT_NF]                = ptb_InRecChild[FTTECLEDA_MONAT_NF]           ;     
		FctrestSii[FTTECLEDA_VBUND_CF]                = ptb_InRecChild[FTTECLEDA_VBUND_CF]           ;     
		FctrestSii[FTTECLEDA_ZZCED_NF]                = ptb_InRecChild[FTTECLEDA_ZZCED_NF]           ;     
		FctrestSii[FTTECLEDA_SEGMENT_CF]              = ptb_InRecChild[FTTECLEDA_SEGMENT_CF]         ;     
		FctrestSii[FTTECLEDA_BEWAR_CF]                = ptb_InRecChild[FTTECLEDA_BEWAR_CF]           ;     
		FctrestSii[FTTECLEDA_ZZGAAPDIF_CF]            = ptb_InRecChild[FTTECLEDA_ZZGAAPDIF_CF]       ;     
		FctrestSii[FTTECLEDA_BLART_CF]                = ptb_InRecChild[FTTECLEDA_BLART_CF]           ;     
		FctrestSii[FTTECLEDA_ZZRECONKEY_CF]           = ptb_InRecChild[FTTECLEDA_ZZRECONKEY_CF]      ;     
		FctrestSii[FTTECLEDA_TRN_NT]                  = ptb_InRecChild[FTTECLEDA_TRN_NT]             ;     
		FctrestSii[FTTECLEDA_ORICOD_LS]               = ptb_InRecChild[FTTECLEDA_ORICOD_LS]          ;     
		FctrestSii[FTTECLEDA_RETROAUTO_B]             = ptb_InRecChild[FTTECLEDA_RETROAUTO_B]        ;     
		FctrestSii[FTTECLEDA_SPEENTNAT_CF]            = ptb_InRecChild[FTTECLEDA_SPEENTNAT_CF]       ;     
		FctrestSii[FTTECLEDA_EVT_CF]                  = ptb_InRecChild[FTTECLEDA_EVT_CF]             ;     
		FctrestSii[FTTECLEDA_REVT_CF]                 = ptb_InRecChild[FTTECLEDA_REVT_CF]            ;     
		FctrestSii[FTTECLEDA_RETARDRETINT_B]          = ptb_InRecChild[FTTECLEDA_RETARDRETINT_B]     ;     
		FctrestSii[FTTECLEDA_NEWCOLS1_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS1_NF]        ;     
		FctrestSii[FTTECLEDA_GAAPCOD_NT]              = ptb_InRecChild[FTTECLEDA_GAAPCOD_NT]         ;     
		FctrestSii[FTTECLEDA_I17PRDCOD_CT]            = ptb_InRecChild[FTTECLEDA_I17PRDCOD_CT]       ;     
		FctrestSii[FTTECLEDA_NEWCOLS4_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS4_NF]        ;     
		FctrestSii[FTTECLEDA_NEWCOLS5_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS5_NF]        ;     
		FctrestSii[FTTECLEDA_NEWCOLS6_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS6_NF]        ;     
		FctrestSii[FTTECLEDA_NEWCOLS7_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS7_NF]        ;     
		FctrestSii[FTTECLEDA_NEWCOLS8_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS8_NF]        ;     
		FctrestSii[FTTECLEDA_NEWCOLS9_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS9_NF]        ;     
		FctrestSii[FTTECLEDA_NB_COL]                  = ptb_InRecChild[FTTECLEDA_NB_COL]             ;      

    FctrestSii[FTTECLEDA_NB_COL]=0;

	
	n_WriteCols( Kp_OutputFilResSii, FctrestSii, SEPARATEUR, 0 );

	RETURN_VAL( OK );
}
 
/*==============================================================================
// renvoi 1 si TRT, 0 si FAC, -1 si pas une lettre !
==============================================================================*/
int is_TRT(char *contract)
{ 
  char thirdCar;
	thirdCar = toupper(contract[2]);
	
  char firstCar;
	firstCar = toupper(contract[0]);
		
  //[004]
	if(( thirdCar >= 'A' && thirdCar <= 'M') || firstCar == 'F') //'FAC' 
		return 0; 

	if(( thirdCar >= 'N' && thirdCar <= 'Z') || firstCar == 'T')  // Traité
		return 1; 
		
	if( firstCar == 'R')  // Rétro
		return 2; 
		
	
	return -1; 
} 


/*
	Trim permet de supprimer les espaces dans une chaine de caractères,
	si la chaine est vide (longueur =0), elle est retournée tel que.
	si la chaine contient des blancs, ils sont remplacés par des \0 et la chaine est renvoyée
*/
char *trim(char *s) 
{
    char *ptr;
    
	/*if (!s)
        return (char*) NULL;   // handle NULL string
	*/	
    if (!*s)
        return s;      // handle empty string
    for (ptr = s + strlen(s) - 1; (ptr >= s) && isspace(*ptr); --ptr);
    ptr[1] = '\0';
    return s;
}

/*==============================================================================
objet : fonction lancee quand le Fils n'a pas de Pere

retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
dans ce cas on reporte telle quelle la ligne dans le fichier en sortie
==============================================================================*/
int n_ActionFilsSansPere(char ** ptb_InRecChild)
{
	char   sz_Trncod[9];
	char   sz_RetAmt[25];
	char   sz_Amt[25];	

	char   sz_RetAmtCur[4];
	char   sz_AmtCur[4];	

	double d_RetAmt = 0 ;     /* montant  retrocession */
	double d_Amt = 0;     /* montant acceptation  */	

	char   *FctrestSii[FTTECLEDA_NB_COL+ 1]; /* tableau de pointeur a l'image du fichier en sortie */
//    int    n_indice_trn = 0;
    
	char BufferAno[100];

	memset( sz_RetAmtCur, 0, sizeof( sz_RetAmtCur ) );
	memset( sz_AmtCur, 0, sizeof( sz_AmtCur ) );	

	memset( sz_Trncod , 0 , sizeof(sz_Trncod) );
	memset( BufferAno,0,sizeof(BufferAno));


    	
	if ((*Ksz_Accret=='R') && ((*ptb_InRecChild[FTTECLEDA_TRNCOD_CF]=='1') || (*ptb_InRecChild[FTTECLEDA_TRNCOD_CF]=='3')))
	{
		n_WriteCols( Kp_OutputFilResSii, ptb_InRecChild, SEPARATEUR, 0 );
 		RETURN_VAL(OK);
	}


	/* Si retro, on force le 1er car à 1 et le dernier à 0 pour extraction du bon regroupement */
	sprintf( sz_Trncod, "%s", ptb_InRecChild[FTTECLEDA_TRNCOD_CF] );
	sz_Trncod[8]=0;


		
	/* Recherche taux pour conversion du montant acceptation en devise aliment */
	if (*ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '2' || *ptb_InRecChild[FTTECLEDA_TRNCOD_CF] == '4')
	{
		d_RetAmt = atof( ptb_InRecChild[FTTECLEDA_RETAMT_M] );
		sprintf( sz_RetAmtCur, "%s", ptb_InRecChild[FTTECLEDA_RETCUR_CF] );
		
		sprintf( sz_RetAmt, "%-.3f", d_RetAmt );

		d_Amt = atof( ptb_InRecChild[FTTECLEDA_AMT_M] );
		sprintf( sz_AmtCur, "%s", ptb_InRecChild[FTTECLEDA_CUR_CF] );
		
		sprintf( sz_Amt, "%-.3f", d_Amt );		
		
	}
	else
	if((*ptb_InRecChild[FTTECLEDA_TRNCOD_CF]=='1') || (*ptb_InRecChild[FTTECLEDA_TRNCOD_CF]=='3'))
	{	
		d_Amt = atof( ptb_InRecChild[FTTECLEDA_AMT_M] );
		sprintf( sz_AmtCur, "%s", ptb_InRecChild[FTTECLEDA_CUR_CF] );
		
		sprintf( sz_Amt, "%-.3f", d_Amt );
		
		d_RetAmt = 0;
		sprintf( sz_RetAmtCur, "%s", "" );		
	}


	

		FctrestSii[FTTECLEDA_SSD_CF]              		= ptb_InRecChild[FTTECLEDA_SSD_CF]             ;
		FctrestSii[FTTECLEDA_ESB_CF]                  = ptb_InRecChild[FTTECLEDA_ESB_CF]             ;
		FctrestSii[FTTECLEDA_BALSHEY_NF]              = ptb_InRecChild[FTTECLEDA_BALSHEY_NF]         ;
		FctrestSii[FTTECLEDA_BALSHRMTH_NF]            = ptb_InRecChild[FTTECLEDA_BALSHRMTH_NF]       ;
		FctrestSii[FTTECLEDA_BALSHRDAY_NF]            = ptb_InRecChild[FTTECLEDA_BALSHRDAY_NF]       ;
		FctrestSii[FTTECLEDA_TRNCOD_CF]               = ptb_InRecChild[FTTECLEDA_TRNCOD_CF]          ;
		FctrestSii[FTTECLEDA_DBLTRNCOD_CF]            = ptb_InRecChild[FTTECLEDA_DBLTRNCOD_CF]       ;
		FctrestSii[FTTECLEDA_CTR_NF]                  = ptb_InRecChild[FTTECLEDA_CTR_NF]             ;
		FctrestSii[FTTECLEDA_END_NT]                  = ptb_InRecChild[FTTECLEDA_END_NT]             ;
		FctrestSii[FTTECLEDA_SEC_NF]                  = ptb_InRecChild[FTTECLEDA_SEC_NF]             ;
		FctrestSii[FTTECLEDA_UWY_NF]                  = ptb_InRecChild[FTTECLEDA_UWY_NF]             ;
		FctrestSii[FTTECLEDA_UW_NT]                   = ptb_InRecChild[FTTECLEDA_UW_NT]              ;
		FctrestSii[FTTECLEDA_OCCYEA_NF]               = ptb_InRecChild[FTTECLEDA_OCCYEA_NF]          ;
		FctrestSii[FTTECLEDA_ACY_NF]                  = ptb_InRecChild[FTTECLEDA_ACY_NF]             ;
		FctrestSii[FTTECLEDA_SCOSTRMTH_NF]            = ptb_InRecChild[FTTECLEDA_SCOSTRMTH_NF]       ;
		FctrestSii[FTTECLEDA_SCOENDMTH_NF]            = ptb_InRecChild[FTTECLEDA_SCOENDMTH_NF]       ;
		FctrestSii[FTTECLEDA_CLM_NF]                  = ptb_InRecChild[FTTECLEDA_CLM_NF]             ;
		FctrestSii[FTTECLEDA_CUR_CF]                  = sz_AmtCur ; //ptb_InRecChild[FTTECLEDA_CUR_CF]             ;
		FctrestSii[FTTECLEDA_AMT_M]                   = sz_Amt ; //ptb_InRecChild[FTTECLEDA_AMT_M]              ;
		FctrestSii[FTTECLEDA_CED_NF]                  = ptb_InRecChild[FTTECLEDA_CED_NF]             ;
		FctrestSii[FTTECLEDA_BRK_NF]                  = ptb_InRecChild[FTTECLEDA_BRK_NF]             ;
		FctrestSii[FTTECLEDA_PAY_NF]                  = ptb_InRecChild[FTTECLEDA_PAY_NF]             ;
		FctrestSii[FTTECLEDA_KEY_NF]                  = ptb_InRecChild[FTTECLEDA_KEY_NF]             ;
		FctrestSii[FTTECLEDA_RETCTR_NF]               = ptb_InRecChild[FTTECLEDA_RETCTR_NF]          ;
		FctrestSii[FTTECLEDA_RETEND_NT]               = ptb_InRecChild[FTTECLEDA_RETEND_NT]          ;
		FctrestSii[FTTECLEDA_RETSEC_NF]               = ptb_InRecChild[FTTECLEDA_RETSEC_NF]          ;
		FctrestSii[FTTECLEDA_RTY_NF]                  = ptb_InRecChild[FTTECLEDA_RTY_NF]             ;
		FctrestSii[FTTECLEDA_RETUW_NT]                = ptb_InRecChild[FTTECLEDA_RETUW_NT]           ;
		FctrestSii[FTTECLEDA_RETOCCYEA_NF]            = ptb_InRecChild[FTTECLEDA_RETOCCYEA_NF]       ;
		FctrestSii[FTTECLEDA_RETACY_NF]               = ptb_InRecChild[FTTECLEDA_RETACY_NF]          ;
		FctrestSii[FTTECLEDA_RETSCOSTRMTH_NF]         = ptb_InRecChild[FTTECLEDA_RETSCOSTRMTH_NF]    ;
		FctrestSii[FTTECLEDA_RETSCOENDMTH_NF]         = ptb_InRecChild[FTTECLEDA_RETSCOENDMTH_NF]    ;
		FctrestSii[FTTECLEDA_RCL_NF]                  = ptb_InRecChild[FTTECLEDA_RCL_NF]             ;
		if ( strcmp(Ksz_Accret, "R") == 0)
		{
		FctrestSii[FTTECLEDA_RETCUR_CF]               = sz_RetAmtCur ; //ptb_InRecChild[FTTECLEDA_RETCUR_CF]          ;
 
		FctrestSii[FTTECLEDA_RETAMT_M]                = sz_RetAmt ; //ptb_InRecChild[FTTECLEDA_RETAMT_M]           ;
		FctrestSii[FTTECLEDA_PLC_NT]                  = ptb_InRecChild[FTTECLEDA_PLC_NT]             ;
		FctrestSii[FTTECLEDA_RTO_NF]                  = ptb_InRecChild[FTTECLEDA_RTO_NF]             ;
		FctrestSii[FTTECLEDA_INT_NF]                  = ptb_InRecChild[FTTECLEDA_INT_NF]             ;
		FctrestSii[FTTECLEDA_RETPAY_NF]               = ptb_InRecChild[FTTECLEDA_RETPAY_NF]          ;
		FctrestSii[FTTECLEDA_RETKEY_CF]               = ptb_InRecChild[FTTECLEDA_RETKEY_CF]          ;		
		}
		else
		{
		FctrestSii[FTTECLEDA_RETCUR_CF]               = " " ;			
		FctrestSii[FTTECLEDA_RETAMT_M]                = " " ;	
		FctrestSii[FTTECLEDA_PLC_NT]                  = " " ; //ptb_InRecChild[FTTECLEDA_PLC_NT]             ;
		FctrestSii[FTTECLEDA_RTO_NF]                  = " " ; //ptb_InRecChild[FTTECLEDA_RTO_NF]             ;
		FctrestSii[FTTECLEDA_INT_NF]                  = " " ;//ptb_InRecChild[FTTECLEDA_INT_NF]             ;
		FctrestSii[FTTECLEDA_RETPAY_NF]               = " " ; //ptb_InRecChild[FTTECLEDA_RETPAY_NF]          ;
		FctrestSii[FTTECLEDA_RETKEY_CF]               = " " ; //tb_InRecChild[FTTECLEDA_RETKEY_CF]          ;		
	  }

		FctrestSii[FTTECLEDA_CRE_D]                   = ptb_InRecChild[FTTECLEDA_CRE_D]              ;
		FctrestSii[FTTECLEDA_CREUSR_CF]               = ptb_InRecChild[FTTECLEDA_CREUSR_CF]          ;
		FctrestSii[FTTECLEDA_LSTUPD_D]                = ptb_InRecChild[FTTECLEDA_LSTUPD_D]           ;
		FctrestSii[FTTECLEDA_LSTUPDUSR_CF]            = ptb_InRecChild[FTTECLEDA_LSTUPDUSR_CF]       ;
		FctrestSii[FTTECLEDA_LOBACC_CF]               = ptb_InRecChild[FTTECLEDA_LOBACC_CF]          ;
		FctrestSii[FTTECLEDA_LOBRET_CF]               = ptb_InRecChild[FTTECLEDA_LOBRET_CF]          ;
		FctrestSii[FTTECLEDA_SOBACC_CF]               = ptb_InRecChild[FTTECLEDA_SOBACC_CF]          ;
		FctrestSii[FTTECLEDA_SOBRET_CF]               = ptb_InRecChild[FTTECLEDA_SOBRET_CF]          ;
		FctrestSii[FTTECLEDA_TOPACC_CF]               = ptb_InRecChild[FTTECLEDA_TOPACC_CF]          ;
		FctrestSii[FTTECLEDA_TOPRET_CF]               = ptb_InRecChild[FTTECLEDA_TOPRET_CF]          ;
		FctrestSii[FTTECLEDA_NATACC_CF]               = ptb_InRecChild[FTTECLEDA_NATACC_CF]          ;
		FctrestSii[FTTECLEDA_NATRET_CF]               = ptb_InRecChild[FTTECLEDA_NATRET_CF]          ;
		FctrestSii[FTTECLEDA_GARACC_CF]               = ptb_InRecChild[FTTECLEDA_GARACC_CF]          ;
		FctrestSii[FTTECLEDA_GARRET_CF]               = ptb_InRecChild[FTTECLEDA_GARRET_CF]          ;
		FctrestSii[FTTECLEDA_PCPRSKTRYACC_CF]         = ptb_InRecChild[FTTECLEDA_PCPRSKTRYACC_CF]    ;
		FctrestSii[FTTECLEDA_PCPRSKTRYRET_CF]         = ptb_InRecChild[FTTECLEDA_PCPRSKTRYRET_CF]    ;
		FctrestSii[FTTECLEDA_USRCRTCODACC_CT]         = ptb_InRecChild[FTTECLEDA_USRCRTCODACC_CT]    ;
		FctrestSii[FTTECLEDA_USRCRTCODRET_CT]         = ptb_InRecChild[FTTECLEDA_USRCRTCODRET_CT]    ;
		FctrestSii[FTTECLEDA_USRCRTVALACC_LM]          = ptb_InRecChild[FTTECLEDA_USRCRTVALACC_LM]     ;
		FctrestSii[FTTECLEDA_USRCRTVALRET_LM]          = ptb_InRecChild[FTTECLEDA_USRCRTVALRET_LM]     ;
		FctrestSii[FTTECLEDA_CTRNAT_CT]               = ptb_InRecChild[FTTECLEDA_CTRNAT_CT]          ;
		FctrestSii[FTTECLEDA_RETCTRCAT_CF]            = ptb_InRecChild[FTTECLEDA_RETCTRCAT_CF]       ;
		FctrestSii[FTTECLEDA_WRKCAT_CT]               = ptb_InRecChild[FTTECLEDA_WRKCAT_CT]          ;
		FctrestSii[FTTECLEDA_PRDCOD_CT]               = ptb_InRecChild[FTTECLEDA_PRDCOD_CT]          ;
		FctrestSii[FTTECLEDA_ANLCTY_CF]               = ptb_InRecChild[FTTECLEDA_ANLCTY_CF]          ;
		FctrestSii[FTTECLEDA_ACCADMTYP_CT]            = ptb_InRecChild[FTTECLEDA_ACCADMTYP_CT]       ;
		FctrestSii[FTTECLEDA_RETACCTYP_CT]            = ptb_InRecChild[FTTECLEDA_RETACCTYP_CT]       ;
		FctrestSii[FTTECLEDA_COMACC_B]                 = ptb_InRecChild[FTTECLEDA_COMACC_B]            ;
		FctrestSii[FTTECLEDA_CPLACCUPD_D]             = ptb_InRecChild[FTTECLEDA_CPLACCUPD_D]        ;
		FctrestSii[FTTECLEDA_CTRRET_B]                 = ptb_InRecChild[FTTECLEDA_CTRRET_B]            ;
		FctrestSii[FTTECLEDA_UWGRP_CF]                = ptb_InRecChild[FTTECLEDA_UWGRP_CF]           ;
		FctrestSii[FTTECLEDA_VRS_NF]                  = ptb_InRecChild[FTTECLEDA_VRS_NF]             ;
		FctrestSii[FTTECLEDA_SEG_NF]                  = ptb_InRecChild[FTTECLEDA_SEG_NF]             ;
		FctrestSii[FTTECLEDA_UWORG_CF]                = ptb_InRecChild[FTTECLEDA_UWORG_CF]           ;
		FctrestSii[FTTECLEDA_ESTCRB_CT]               = ptb_InRecChild[FTTECLEDA_ESTCRB_CT]          ;
		FctrestSii[FTTECLEDA_ESTCTR_NF]               = ptb_InRecChild[FTTECLEDA_ESTCTR_NF]          ;
		FctrestSii[FTTECLEDA_ESBACC_NF]               = ptb_InRecChild[FTTECLEDA_ESBACC_NF]          ;
		FctrestSii[FTTECLEDA_ORGCED_NF]               = ptb_InRecChild[FTTECLEDA_ORGCED_NF]          ;
		FctrestSii[FTTECLEDA_CEDHORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_CEDHORDNBR_NT]      ;
		FctrestSii[FTTECLEDA_CEDSORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_CEDSORDNBR_NT]      ;
		FctrestSii[FTTECLEDA_ORGCEDHORDNBR_NT]        = ptb_InRecChild[FTTECLEDA_ORGCEDHORDNBR_NT]   ;
		FctrestSii[FTTECLEDA_ORGCEDSORDNBR_NT]        = ptb_InRecChild[FTTECLEDA_ORGCEDSORDNBR_NT]   ;
		FctrestSii[FTTECLEDA_BRKHORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_BRKHORDNBR_NT]      ;
		FctrestSii[FTTECLEDA_BRKSORDNBR_NT]           = ptb_InRecChild[FTTECLEDA_BRKSORDNBR_NT]      ;
		FctrestSii[FTTECLEDA_FACADMTYP_CT]            = ptb_InRecChild[FTTECLEDA_FACADMTYP_CT]       ;
		FctrestSii[FTTECLEDA_CLIIND_NF]               = ptb_InRecChild[FTTECLEDA_CLIIND_NF]          ;
		FctrestSii[FTTECLEDA_HORDNBR_NT]              = ptb_InRecChild[FTTECLEDA_HORDNBR_NT]         ;
		if ( strcmp(Ksz_Accret, "R") == 0)
		FctrestSii[FTTECLEDA_RETINTAMT_M]             = sz_RetAmt ; //ptb_InRecChild[FTTECLEDA_RETINTAMT_M]         ;
		else
		FctrestSii[FTTECLEDA_RETINTAMT_M]             = "" ;
		
		FctrestSii[FTTECLEDA_BUKRS_CF]                = ptb_InRecChild[FTTECLEDA_BUKRS_CF]           ;
		FctrestSii[FTTECLEDA_RCOMP_CF]                = ptb_InRecChild[FTTECLEDA_RCOMP_CF]           ;
		FctrestSii[FTTECLEDA_LDGRP_CF]                = ptb_InRecChild[FTTECLEDA_LDGRP_CF]           ;
		FctrestSii[FTTECLEDA_HKONT_CF]                = ptb_InRecChild[FTTECLEDA_HKONT_CF]           ;
		FctrestSii[FTTECLEDA_DBLHKONT_CF]             = ptb_InRecChild[FTTECLEDA_DBLHKONT_CF]        ;
		FctrestSii[FTTECLEDA_GJAHR_NF]                = ptb_InRecChild[FTTECLEDA_GJAHR_NF]           ;
		FctrestSii[FTTECLEDA_MONAT_NF]                = ptb_InRecChild[FTTECLEDA_MONAT_NF]           ;
		FctrestSii[FTTECLEDA_VBUND_CF]                = ptb_InRecChild[FTTECLEDA_VBUND_CF]           ;
		FctrestSii[FTTECLEDA_ZZCED_NF]                = ptb_InRecChild[FTTECLEDA_ZZCED_NF]           ;
		FctrestSii[FTTECLEDA_SEGMENT_CF]              = ptb_InRecChild[FTTECLEDA_SEGMENT_CF]         ;
		FctrestSii[FTTECLEDA_BEWAR_CF]                = ptb_InRecChild[FTTECLEDA_BEWAR_CF]           ;
		FctrestSii[FTTECLEDA_ZZGAAPDIF_CF]            = ptb_InRecChild[FTTECLEDA_ZZGAAPDIF_CF]       ;
		FctrestSii[FTTECLEDA_BLART_CF]                = ptb_InRecChild[FTTECLEDA_BLART_CF]           ;
		FctrestSii[FTTECLEDA_ZZRECONKEY_CF]           = ptb_InRecChild[FTTECLEDA_ZZRECONKEY_CF]      ;
		FctrestSii[FTTECLEDA_TRN_NT]                  = ptb_InRecChild[FTTECLEDA_TRN_NT]             ;
		FctrestSii[FTTECLEDA_ORICOD_LS]               = ptb_InRecChild[FTTECLEDA_ORICOD_LS]          ;
		FctrestSii[FTTECLEDA_RETROAUTO_B]             = ptb_InRecChild[FTTECLEDA_RETROAUTO_B]        ;
		FctrestSii[FTTECLEDA_SPEENTNAT_CF]            = ptb_InRecChild[FTTECLEDA_SPEENTNAT_CF]       ;
		FctrestSii[FTTECLEDA_EVT_CF]                  = ptb_InRecChild[FTTECLEDA_EVT_CF]             ;
		FctrestSii[FTTECLEDA_REVT_CF]                 = ptb_InRecChild[FTTECLEDA_REVT_CF]            ;
		FctrestSii[FTTECLEDA_RETARDRETINT_B]          = ptb_InRecChild[FTTECLEDA_RETARDRETINT_B]     ;
		FctrestSii[FTTECLEDA_NEWCOLS1_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS1_NF]        ;
		FctrestSii[FTTECLEDA_GAAPCOD_NT]              = ptb_InRecChild[FTTECLEDA_GAAPCOD_NT]         ;
		FctrestSii[FTTECLEDA_I17PRDCOD_CT]            = ptb_InRecChild[FTTECLEDA_I17PRDCOD_CT]       ;
		FctrestSii[FTTECLEDA_NEWCOLS4_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS4_NF]        ;
		FctrestSii[FTTECLEDA_NEWCOLS5_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS5_NF]        ;
		FctrestSii[FTTECLEDA_NEWCOLS6_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS6_NF]        ;
		FctrestSii[FTTECLEDA_NEWCOLS7_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS7_NF]        ;
		FctrestSii[FTTECLEDA_NEWCOLS8_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS8_NF]        ;
		FctrestSii[FTTECLEDA_NEWCOLS9_NF]             = ptb_InRecChild[FTTECLEDA_NEWCOLS9_NF]        ;
		FctrestSii[FTTECLEDA_NB_COL]                  = ptb_InRecChild[FTTECLEDA_NB_COL]             ;



	FctrestSii[FTTECLEDA_NB_COL] =0; 

	n_WriteCols( Kp_OutputFilResSii, FctrestSii, SEPARATEUR, 0 );
	


 	RETURN_VAL(OK);
}

///*==============================================================================
//objet :
//   Traitement d'une ligne, r▒sultat du SELECT de la proc. ps_UTCTLIB_Example_out
//
//retour :
//        retourne le cours de la devise d'origine sur le cours de la devise
//        destination.
//        si la devise destination est nulle la fonction retourne le cours de
//        la devise d'origine
//        elle retourne une valeur negative ou nulle en cas de probleme
//==============================================================================*/
//double d_GetTaux(
//        char* sz_RateOrig, /* Cours d'origine */
//        char* sz_RateDest  /* Cours destination */
//        )
//{
//// [010]p
//
//    DEBUT_FCT ( "d_GetTaux" );
//
//    if( *sz_RateOrig == 0 || atof(sz_RateOrig) <= 0)
//        RETURN_VAL ( (double)(-1));
//    if( *sz_RateDest == 0 || atof(sz_RateDest) <= 0)
//        RETURN_VAL ( (double)(-1));
//
//  RETURN_VAL(  atof(sz_RateDest)/atof(sz_RateOrig));
//}
