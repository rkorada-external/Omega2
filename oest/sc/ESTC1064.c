/*==============================================================================
nom de l'application          : ESTIMATION SOLVENCY
nom du source                 : ESTC1064.c
révision                      : $Revision: 1.0 $
date de création              : 11/10/2012
auteur                        : Roger Cassis
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
   :spot:24041 - Calcul des primes et charges futures et des primes sinistre
                 avec Transformation des postes

1A100002 -> genere 1A100012 = Future Premium
         -> et 1A494302     = Future Claim
1A120002 -> genere 1A120012 = Future Charge

------------------------------------------------------------------------------
historique des modifications :
[01] 11/02/2013 R.Cassis :spot:24836 Gestion segment pas trouvé et bug dans recherche
[02] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_TRSLNK_MAX (+10000)
[XX] 06/04/2014 JBG      :spot:25773 Modify void main declaration to int main
[XX] 09/10/2014  JBG  :spot:25773  suppress warning: unused variables
[04] 05/05/2015 Florent :spot:26391 gestion du segment *
[05] 18/04/2016 -=Dch=- :spot:30465 Ajout des logs pour les utilisateurs 
[06] 04/05/2016 SAS   :spot:30534  EBS - Futures Premiums (42511) & Charges(42512)
[07] 23/06/2016 SAS      :spot:30534 42512: Charges Futures
[08] 07/07/2016 Florent  :spot:30890 EBS - Correction sur le calcul des futures pour traités NP
[09] 05/12/2016		PGA 	SPIRA 57431 renforcement restriction ligne 302
[010] 17/09/2018 MZM    :spira:68071 EBS - Future Premium - No estimates for fac : le montant des estimations sera  à 0
[011] 28/11/2018 MZM    :spira:68071 EBS - Future Premium - No estimates for fac : le montant des charges est daurevant calcule à partir du Futur Fixe Premium
[012] 19/12/2018 JYP	:spira:73946 EBS - bugfix previous spira - Future charges NOT calculated for FAC
================================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"
#include "estutil.c"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC1064_C[150] = "__version__: ESTC1064.c version [012] 19/12/2018 bugfix no charges for FAC" ;



/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_TRSLNK_MAX 30000   //  [002]
#define NB_SEGEST_MAX 10000
#define LGTH_SEGEST 100
#define SEPARATOR 	 "~"
#define SEG_SSD_CF     0
#define SEG_SEG_NF     1
#define SEG_UWY_NF     2
#define SEG_CUR_CF     3
#define SEG_SEGNAT_CT  4
#define SEG_CLMAMT_M   5
#define SEG_LOSRAT_R   6
#define SEG_AMORAT_CT  7

/*----------------------------------*/

// Ajout d'une structure pour stocker les colonnes de sorties de log
//
typedef struct T_FUT_LOGS{
		short SSD_CF; 
		short ESB_CF; 
		char* CTR_NF;
		short END_NT;
		short SEC_NF;
		short UWY_NF;
		char* SEG_NF;
		double SCOEGP_M;
		char* CUR_CF;
		double AMTCEXP_M;
		double AMTCPRM_M;
		double AMTCPNA;
		double LOSRAT_R;
		double TAUX;
		double FUPREMIUM;
		double FUCLAIM;
		double FUEXP;
		} T_FUTURES;


	T_FUTURES*	pFutures;
		


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE   *Kp_OutputFilResSii;    /* pointeur sur le fichier de sortie formaté avec les nouvelles colonnes */
FILE   *Kp_OutputFilResSiiAno; /* pointeur sur le fichier de sortie des lignes sans segment */
FILE   *Kp_InputFilTrsLnk;     /* pointeur sur le fichier en entree des postes cumuls */
FILE   *Kp_InputFilExc;        /* pointeur sur le fichier en entree des cours de change */
FILE   *Kp_InputFilSegest ;    /* pointeur sur le fichier binaire FSEGEST */
FILE   *p_OutputFutures; 	   /* Fichier de log pour les users [05] -=Dch=-  */

T_RUPTURE_VAR       bd_RuptPerUw;   /* variable de gestion de la rupture sur le perimetre de Accept ou Retro */
T_RUPTURE_SYNC_VAR  bd_RuptDlGtaa; /* variable de gestion de la synchronisation avec le fichier DTSTATGTx */

T_TRSLNK          Ktbd_TrsLnk[NB_TRSLNK_MAX];
T_SEGEST_SOLVENCY Ktbd_Segest[NB_SEGEST_MAX]; 	/* tableau permettant de charger en memoire FSEGEST */

int Kn_NbLigTrslnk;     /* nombre de postes dans le tableau */
int Kn_NbLig_Segest;   /* nombre de postes dans le tableau */

int n_InitPerUw            ( T_RUPTURE_VAR  *pbd_Rupt );
int n_TestRupturePER       (char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRupturePER (char **pbd_InRec_Cur);
int n_InitDlGtaa		      ( T_RUPTURE_SYNC_VAR *pbd_Rupt );
int n_ActionLigneDlGtaa    ( char **pbd_InRecOwner, char **pbd_InRecChild );
int n_ConditionSyncDlGtaa  ( char **pbd_InRecOwner, char **pbd_InRecChild );

int n_ProcessingRuptureSyncVar (T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **pbd_InRecOwner );

int n_ChargerTRSLNK2   ( short s_TrtCod );
int n_RechPoste       ( char *sz_poste );
int n_ChargerTSEGEST  ( void ) ;
int n_RechPosteTSEGEST( char c_ssd, char *sz_seg, int n_uwy ) ;
void n_EcrireLog();  // sortie de la log FUTURES

char   kc_FlagAcc = 'N';
char   kc_FlagPNAseul = 'N';
char   kc_TRTNP_BILAN = 'N'; //quand TRTNP et année de souscription supèrieure à date bilan -2
double kd_AmtcPRM;             // Montant sauvegarde
double kd_AmtcPNA;             // Montant sauvegarde
double kd_AmtcPRT;             //[06]
int    kn_MIN_ICLODAT_A; //date bilan -2 (dans le ESID2003)

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

	printf("Running with %s \n ", VERSION_ESTC1064_C);

	kn_MIN_ICLODAT_A = atoi(psz_GetCharArgv(1));

	/* ouverture du fichier en entree des postes cumuls FTRSLNK */
	if ( n_OpenFileAppl ( "ESTC1064_I3","rb",&Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree des cours de change FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1064_I4","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier en entree FSEGEST */
	if ( n_OpenFileAppl ( "ESTC1064_I5","rb",&Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1064_O1","wt",&Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des resultats par affaire */
	if ( n_OpenFileAppl ( "ESTC1064_O2","wt",&Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );

	/* ouverture du fichier de sortie des logs */
	if ( n_OpenFileAppl ( "ESTC1064_O3","wt",&p_OutputFutures ) == ERR )
		ExitPgm( ERR_XX , "" );


	pFutures = (T_FUTURES *) calloc(1,sizeof(T_FUTURES)); 

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" );

	/* Initialisation de la variable bd_RuptDlGtaa */
	if ( n_InitDlGtaa( &bd_RuptDlGtaa ) )
		ExitPgm( ERR_XX , "" );

	/* Chargement des postes en memoire */
	Kn_NbLigTrslnk = n_ChargerTRSLNK2( 750 );

	if ( Kn_NbLigTrslnk > NB_TRSLNK_MAX )
		ExitPgm( ERR_XX , "" );

	/* Chargement de TSEGEST en memoire */
	Kn_NbLig_Segest = n_ChargerTSEGEST( ) ;

	if ( Kn_NbLig_Segest > NB_SEGEST_MAX )
		ExitPgm( ERR_XX , "" );

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_I2", &( bd_RuptDlGtaa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_I3", &Kp_InputFilTrsLnk ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_I4", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_I5", &Kp_InputFilSegest ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_O1", &Kp_OutputFilResSii ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1064_O2", &Kp_OutputFilResSiiAno ) == ERR )
		ExitPgm( ERR_XX , "" );
	
	if ( n_CloseFileAppl( "ESTC1064_O3", &p_OutputFutures ) == ERR )
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
	if ( n_OpenFileAppl( "ESTC1064_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR;

	pbd_Rupt->n_NbRupture = 1;

   pbd_Rupt->n_ConditionRupture[0]=n_TestRupturePER;
	pbd_Rupt->n_ActionFirst[0]=n_ActionFistRupturePER;

	pbd_Rupt->c_Separ = '~';

	RETURN_VAL( OK );
}

/*==============================================================================
objet :
	fonction lancée à la rupture sur le fichier maître

retour :
	0 ---> pas de rupture
	1 ---> rupture
==============================================================================*/
int n_TestRupturePER(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_TestRupturePER");

	if (strcmp(ptsz_LigneSuiv[PER_CTR_NF], ptsz_LigneCour[PER_CTR_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_END_NT], ptsz_LigneCour[PER_END_NT])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_SEC_NF], ptsz_LigneCour[PER_SEC_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_UWY_NF], ptsz_LigneCour[PER_UWY_NF])!=0) return(1);
	if (strcmp(ptsz_LigneSuiv[PER_UW_NT], ptsz_LigneCour[PER_UW_NT])!=0) return(1);

	return( 0 );
}

/*==============================================================================
objet : fonction lancée à la rupture première sur le fichier maître

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionFistRupturePER(char **pbd_InRec_Cur)
{
	DEBUT_FCT("n_ActionFistRupturePER");

	kc_FlagAcc = 'N';

	kc_TRTNP_BILAN = 'N'; //quand TRTNP et année de souscription supèrieure à date bilan -2
	if (atoi(pbd_InRec_Cur[PER_UWY_NF]) > kn_MIN_ICLODAT_A && pbd_InRec_Cur[PER_CTRNAT_CT][0] == 'N')
		kc_TRTNP_BILAN = 'Y';

	n_ProcessingRuptureSyncVar( &bd_RuptDlGtaa, pbd_InRec_Cur );

//printf("--> n_ActionFistRupturePER -- CTR_NF : %s - UWY_NF : %s - %s\n",pbd_InRec_Cur[PER_CTR_NF],pbd_InRec_Cur[PER_UWY_NF],pbd_InRec_Cur[PER_SEC_NF]);

	return OK ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « DTSTATGTXX »

retour :
	OK
==============================================================================*/
int n_InitDlGtaa( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
	DEBUT_FCT( "n_InitDlGtaa" );

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) );

	/* ouverture du fichier esclave */
	if ( n_OpenFileAppl( "ESTC1064_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 0;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncDlGtaa;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneDlGtaa;

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
int n_ConditionSyncDlGtaa(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncDlGtaa" );

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret;

//	if ( strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") == 0 )
//printf("--> n_ConditionSyncDlGtaa -- CTR_NF : %s - UWY_NF : %s - sec %s\n",pbd_InRecOwner[PER_CTR_NF],pbd_InRecOwner[PER_UWY_NF],pbd_InRecOwner[PER_SEC_NF]);

	RETURN_VAL( 0 );
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneDlGtaa(
	char **pbd_InRecOwner , /* adresse de la ligne du maitre */
	char **pbd_InRecChild ) /* adresse de la ligne de l'esclave */
{

	char   sz_Trncod[9];
	char   sz_Dblcod[2];
	char   sz_Seg[12];
	char   sz_Amt[21];
	char   sz_Cur[4];
	double d_Amt;
	double d_taux;      // Taux de conversion en devise
	double d_LOSRAT_R;
	char   MsgAno[300];
	int    n_indice;
	int	 n_Ssd = 0;
	int	 n_Uwy = 0;

	DEBUT_FCT( "n_ActionLigneDlGtaa" );

	memset( sz_Cur, 0, sizeof(sz_Cur) );
	memset( sz_Seg, 0, sizeof(sz_Seg) );
	

	memset(pFutures, 0 , sizeof (T_FUTURES));// on remet la structure a vide
// Alimentation de la structure 
//

	pFutures->SSD_CF= atoi(pbd_InRecChild[GT_SSD_CF]);
	pFutures->ESB_CF= atoi(pbd_InRecChild[GT_ESB_CF]); 
	pFutures->END_NT= atoi(pbd_InRecChild[GT_END_NT]); 
	pFutures->SEC_NF= atoi(pbd_InRecChild[GT_SEC_NF]); 
	pFutures->UWY_NF= atoi(pbd_InRecChild[GT_UWY_NF]); 

	pFutures->CTR_NF= pbd_InRecChild[GT_CTR_NF];
	pFutures->SEG_NF= pbd_InRecChild[GT_SEG_NF];
	pFutures->SCOEGP_M= atof(pbd_InRecChild[GT_SCOEGP_M]); 

	strcpy( sz_Dblcod, "" );
	//en cas de TRT NON PROPRE ne pas tenir compte du EBSACC quand l'année de souscription est supèrieure à la date de bilan -2
	if ( (strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") == 0 || kc_TRTNP_BILAN == 'Y') && kc_FlagAcc == 'N')
	{
		if (pbd_InRecOwner[PER_SECACCSTS_CT][0] == '9' && kc_TRTNP_BILAN == 'Y')
			kc_FlagAcc = 'N';
		else
			kc_FlagAcc = 'Y';

		if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "N")==0) 
			kc_FlagPNAseul = 'N';// forcer le flag à non pour les traités non prop
		else 
			kc_FlagPNAseul = (atof(pbd_InRecChild[GT_AMT_M]) - atof(pbd_InRecChild[GT_RETAMT_M]) == 0 ? 'Y' : 'N' );

		kd_AmtcPNA = 0;
		kd_AmtcPRM = 0;
		kd_AmtcPRT = 0;        //[06]
	}
	if (strcmp(pbd_InRecChild[GT_ORICOD_LS], "EBSACC") != 0)
	{
		if ( kc_FlagAcc == 'N' ) RETURN_VAL( OK );

		n_Ssd = (char) atoi( pbd_InRecOwner[PER_SSD_CF] );
		n_Uwy = atoi( pbd_InRecOwner[PER_UWY_NF] );
		strcpy(sz_Seg, pbd_InRecOwner[PER_SEG_NF]);
		if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, sz_Seg, n_Uwy) ) == -1 )
		{
			if ( (n_indice = n_RechPosteTSEGEST(n_Ssd, "*", n_Uwy) ) == -1 )
			{
				// Pas de segment en synchro
				pbd_InRecChild[GT_ORICOD_LS] = "PAS_SYNCHRO_SEG";
				n_WriteCols( Kp_OutputFilResSiiAno, pbd_InRecChild, SEPARATEUR, 0 );
				// RETURN_VAL( OK );  [001]
			}
		}
		// [001]
		if (n_indice == -1) d_LOSRAT_R = 0;
		else d_LOSRAT_R = Ktbd_Segest[n_indice].LOSRAT_R;

		pFutures->LOSRAT_R = d_LOSRAT_R;

		/* Recherche taux pour conversion du montant acceptation en devise aliment */
		d_taux = 1;

		sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
		if ( strcmp( pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] ) != 0 )
		{
			sprintf( sz_Cur, "%s", pbd_InRecOwner[PER_EGPCUR_CF] );
			d_taux = d_GetTaux( Kp_InputFilExc, (char) atoi( pbd_InRecChild[GT_SSD_CF] ), atoi( pbd_InRecChild[GT_BALSHEY_NF] ), pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF] );
		}

		/* generation d'une anomalie si la fonction ne trouve pas de cours de devises */
		if ( d_taux < 0 )
		{
			sprintf( MsgAno, "The rates of acceptation currency ( %s ) and EGPI currency ( %s ) aren't known for the perimeter contract ( CTR %s - END %s - SEC %s - UWY %s - UW %s ) and BALSHEY %s \n", pbd_InRecChild[GT_CUR_CF], pbd_InRecOwner[PER_EGPCUR_CF], pbd_InRecChild[GT_CTR_NF],  pbd_InRecChild[GT_END_NT], pbd_InRecChild[GT_SEC_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecChild[GT_UW_NT], pbd_InRecChild[GT_BALSHEY_NF] );
			n_WriteAno( MsgAno );
			/* montant positionne a zero */
			d_Amt = 0;
		}
		else
		{
//printf("==> ici 4 - %s - %s - %s - %s - %3f\n",pbd_InRecChild[GT_CTR_NF], pbd_InRecChild[GT_UWY_NF], pbd_InRecOwner[PER_EGPCUR_CF], pbd_InRecChild[GT_CUR_CF], d_taux);
			// Gestion prime futrure et sinistre
			//	kd_AmtcPNA =0;
			pFutures->TAUX= d_taux ;
			pFutures->CUR_CF= sz_Cur; 

			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100002") == 0 )
			{
				kd_AmtcPNA = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;
				pFutures->AMTCPNA = kd_AmtcPNA ;
			}
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A110002") == 0 )
			{
				kd_AmtcPRM = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;
				pFutures->AMTCPRM_M = kd_AmtcPRM ;

				// Calcul prime future
				//[010] Le montant d'estimaion de la Future Premium est 0 dans le cas des FAC.
				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)
					d_Amt = 0;
				else
					d_Amt = atof(pbd_InRecOwner[PER_SCOEGP_M]) - kd_AmtcPRM;
					
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A100012" );

				pFutures->FUPREMIUM = d_Amt; //[011]
				
				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;

				if ( fabs(atof(sz_Amt)) > 1 && kc_FlagPNAseul == 'N' )
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );


				// Calcul Sinistre futur
				if ( kc_FlagPNAseul == 'Y' ) d_Amt = 0;
				d_Amt -= kd_AmtcPNA;
				d_Amt *= (d_LOSRAT_R*100) * -1;
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A494302" );

				pFutures->FUCLAIM = d_Amt;

				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;

				if ( fabs(atof(sz_Amt)) > 1)
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
			}

      if (strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A110003") == 0 )
      {
				kd_AmtcPRT = atof(pbd_InRecChild[GT_AMT_M]) * d_taux;    //[06]
      }
			// gestion Charge future
			if ( strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A120002") == 0 && ((kd_AmtcPRM + kd_AmtcPRT) != 0) && kc_FlagPNAseul == 'N' )        //[06]
			{
				pFutures->AMTCEXP_M = atof(pbd_InRecChild[GT_AMT_M]);

				// Calcul charge future
				if (strcmp(pbd_InRecOwner[PER_CTRNAT_CT], "F")==0)  //[012]
					d_Amt = 0;
				else
				    d_Amt = (atof(pbd_InRecChild[GT_AMT_M]) * d_taux / (kd_AmtcPRM + kd_AmtcPRT)) * (atof(pbd_InRecOwner[PER_SCOEGP_M]) - kd_AmtcPRM); //[06]


			
				sprintf( sz_Amt, "%-.3f", d_Amt );
				strcpy( sz_Trncod, "1A120012" );
				
				pFutures->FUEXP = d_Amt; 


				pbd_InRecChild[GT_RETAMT_M] = "0";
				pbd_InRecChild[GT_RETINTAMT_M] = "0";
				pbd_InRecChild[GT_TRNCOD_CF] = sz_Trncod;
				pbd_InRecChild[GT_DBLTRNCOD_CF] = sz_Dblcod;
				pbd_InRecChild[GT_AMT_M] = sz_Amt;
				pbd_InRecChild[GT_CUR_CF] = sz_Cur;

				if ( fabs(atof(sz_Amt)) > 1)
					n_WriteCols( Kp_OutputFilResSii, pbd_InRecChild, SEPARATEUR, 0 );
			}
		}

		n_EcrireLog();
	}
	
	
	RETURN_VAL( OK );
}


/*==============================================================================
objet:
	Lit le fichier binaire des postes et les met en memoire

==============================================================================*/
int n_ChargerTRSLNK2( short s_TrtCod )
{
	int i = 0;
	char sz_message[200];

	DEBUT_FCT("n_ChargerTRSLNK2");

	while ( fread( &Ktbd_TrsLnk[i], sizeof( T_TRSLNK ), 1, Kp_InputFilTrsLnk ) == 1 )
	{
		if ( Ktbd_TrsLnk[i].PRS_CF == s_TrtCod )
			i += 1;
		if ( i > NB_TRSLNK_MAX )
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
	char Ksz_vide[1];		/* Chaine vide pour initialisation */

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
objet:
        Lit le fichier binaire FSEGEST et le charge en memoire

==============================================================================*/
int n_ChargerTSEGEST( void )
{
	int i = 0 ;
	char sz_message[200];

	DEBUT_FCT("n_ChargerTSEGEST");

	char buffer[LGTH_SEGEST];
	char **tab=NULL;
	while (fgets( buffer, LGTH_SEGEST, Kp_InputFilSegest)!= NULL)
	{
		tab = split(buffer, SEPARATOR ,1);
		Ktbd_Segest[i].SSD_CF = atoi(tab[SEG_SSD_CF]);
		//Pour le segment spéciale * on ne prend que ce caractère !
		if ( tab[SEG_SEG_NF][0] == '*')
			strcpy(Ktbd_Segest[i].SEG_NF, "*");
		else
			strcpy(Ktbd_Segest[i].SEG_NF, tab[SEG_SEG_NF]);
		Ktbd_Segest[i].UWY_NF = atoi(tab[SEG_UWY_NF]);
		strcpy(Ktbd_Segest[i].CUR_CF, tab[SEG_CUR_CF]);
		Ktbd_Segest[i].SEGNAT_CT = *tab[SEG_SEGNAT_CT];
		Ktbd_Segest[i].CLMAMT_M = atof(tab[SEG_CLMAMT_M]);
		Ktbd_Segest[i].LOSRAT_R = atof(tab[SEG_LOSRAT_R]);
		Ktbd_Segest[i].AMORAT_CT = *tab[SEG_AMORAT_CT];
		i++;
		if ( i > NB_SEGEST_MAX )
		{
			sprintf(sz_message,"la taille du tableau Ktbd_Segest depasse la taille allouee %d", i);
			n_WriteAno(sz_message);
			RETURN_VAL( i );
		}
	}

	RETURN_VAL( i );
}


/*==============================================================================
objet :
        fonction de recherche du segment
        1ere recherche avec exercice = 8888.
        Si pas trouve, recherche avec exercice du perimetre :
           soit le plus ancien, soit celui egal
retour :

==============================================================================*/
int n_RechPosteTSEGEST( char c_ssd, char *sz_seg, int n_uwy )
{
	int n_indice, n_indiceEx, n_ret;
	char c_flgSegest = 'N';

	DEBUT_FCT("n_RechPosteTSEGEST");

	for( n_indice = 0; n_indice < Kn_NbLig_Segest; n_indice++ )
	{
		// Localisation filiale
		n_ret = (int) c_ssd - Ktbd_Segest[n_indice].SSD_CF;

		if ( n_ret < 0 ) RETURN_VAL( -1 ) ;
		if ( n_ret > 0 ) continue ;
		else
		{
			// Localisation Segment
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'N' ) continue;
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) != 0 && c_flgSegest == 'Y' ) RETURN_VAL( n_indiceEx );
			if ( strcmp(sz_seg, Ktbd_Segest[n_indice].SEG_NF) == 0 )
			{
				// Localisation exercice
				if ( c_flgSegest == 'N' ) n_indiceEx = n_indice;                    // Plus ancien exercice trouvé
				if ( Ktbd_Segest[n_indice].UWY_NF == n_uwy ) n_indiceEx = n_indice; // Exercice exact trouvé
				c_flgSegest = 'Y';
				if ( Ktbd_Segest[n_indice].UWY_NF == 8888 ) RETURN_VAL( n_indice ); // Exercice 8888 trouvé prioritaire
			}
		}
	}
	if ( c_flgSegest == 'Y' ) RETURN_VAL( n_indiceEx );  // [001]
	else RETURN_VAL( -1 );	// Aucune occurence trouvée
}

/*==============================================================================
objet :
        fonction de sortie de la log FUTURES

==============================================================================*/
void n_EcrireLog()
{


	fprintf(p_OutputFutures ,"%i~%i~%s~%i~%i~%i~%s~%-.3f~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~\n",
pFutures->SSD_CF, 
pFutures->ESB_CF, 
pFutures->CTR_NF,
pFutures->END_NT,
pFutures->SEC_NF,
pFutures->UWY_NF,
pFutures->SEG_NF,
pFutures->SCOEGP_M,
pFutures->CUR_CF,
pFutures->AMTCEXP_M,
pFutures->AMTCPRM_M,
pFutures->AMTCPNA,
pFutures->LOSRAT_R,
pFutures->TAUX,
pFutures->FUPREMIUM,
pFutures->FUCLAIM,
pFutures->FUEXP);
}





















