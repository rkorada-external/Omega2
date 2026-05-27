/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1028.c
révision                      : $Revision: 1.2 $
date de création              : 11/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   CALCUL DE PAP, PB, ET LOSS CORRIDOR

------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa><auteur>    <description de la modification>
27/08/1998	  M.HA-THUC	Evol - Commission originale multiple Nouveau poste cumul 10200 -> charges de surcommissions
14/10/2005 J. Ribot spot 11507 test sur traites terminés comptablement pour ne pas ecrire en sortie
07/04/2006 J. Ribot spot 11507 cumul des montants dans Kd_Prma pour acmtrs 10000 10010 10020 10030 10040 pour les traites terminés
27/03/2008 J. Ribot SPOT 15219  ASE15 : recompilation des programmes C
20/11/2014 Florent  :spot:27748 Loss Corridor  - ajout condition calcul si Automatique(1) ou à vérifier(2)
06/04/2014 JBG      :spot:25773 Modify void main declaration to int main
03/02/2015 F.MARAGNES :spot:28140 Modification appel calculExerciceSeuil nouveau prototype  n_CalculExerciceSeuil(short ssd_cf , short esb_cf, char *lob_cf, short nat_cf ); et ajout d'un test sur la sinistrabilite 
                         pour la determination du seuil appel des fonctions init_calculExerciceSeuil pour charger les données du fichier FTTHRHLDUWY en mémoire, ferme_calculExerciceSeuil pour liberer la mémoire 
[001] 08/02/2018 R. Cassis :spira:67327 Agrandissemnt du tableau NB_FAM_MAX et ajout controle de depassement de la taille maxi du tableau
[002] 11/04/2018 S.Behague     :spira 65703 FORCAGE IBNR : Ajouter l'obligation de renseigner un commentaire lorsque le mode de gestion est FORCE[003] 05/11/2018 MZM	         :spira 57585 Ajout d'une nouvelle valeur "Suivi Closing" dans la codification TRAITE / ESTCOMTYP_CT / ESTLOSCORTYP_CT
[003] 05/11/2018 MZM	         :spira 57585 Ajout d'une nouvelle valeur "Suivi Closing" dans la codification TRAITE / ESTCOMTYP_CT / ESTLOSCORTYP_CT
[004] 7/8/2019 RV				:spira:77465 mise en place de la REQ.P.10.12
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "estserv.h"
#include "struct.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1028.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilCtrEst ; /* pointeur sur le fichier de sortie Estimations dommages */
FILE 		*Kp_OutputFilGtPbPapLos ; /* pointeur sur le fichier de sortie GT des PB, PAP, Loss Corridor */

FILE    *Kp_CoursFil;   /* fichier des cours devise */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le
					perimetre de souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFci ; /* variable de gestion de la synchronisation avec
					le fichier annexe du perimetre famille de charges iterees */
T_RUPTURE_SYNC_VAR 	bd_RuptGtCumTot ; /* variable de gestion de la synchronisation avec
					le fichier GT des estimations */
T_RUPTURE_SYNC_VAR 	bd_RuptGtPa ; /* variable de gestion de la synchronisation avec
					le fichier GT des Primes acquises */
T_RUPTURE_SYNC_VAR 	bd_RuptGtCum ; /* variable de gestion de la synchronisation avec
					le fichier GT cumule toute Pc/Ac confondues */
T_RUPTURE_SYNC_VAR 	bd_RuptCtrEst ; /* variable de gestion de la synchronisation avec
					le fichier des estimations dommages */

T_RUPTURE_SYNC_VAR 	bd_RuptFUTUR; /* variable syncro futur */
T_RUPTURE_SYNC_VAR 	bd_RuptUPRDAC; /* variable syncro futur */

double				Kd_UPR; // [004]
double				Kd_FuClaim; // [004]
double				Kd_FuFixedPrem; // [004]
FILE				*Kp_FBOTRSLNK; // [004]
FILE				*Kp_UPR_DAC; // [004]
int					Kn_FBOTRSLNK; // [004]
T_FBOTRSLNK			Ktbd_FBOTRSLNK[Kn_MaxLigFBOTRSLNK]; // [004]

char Ksz_CloDat[9] ;    /* parametre de la chaine: libelle d'inventaire */
char Ksz_Cre[20] ;    	/* date systeme */
char Ksz_TypInv[2] ;	/* parametre de la chaine: type d'inventaire 'P' ou 'A' */
char	Annee_bilan[5] ;
char	Mois_bilan[3] ;
static char	Jour_bilan[3] ;

T_TabPart Ktbd_Par[NB_PAR_MAX] ; /* tableau des participations */
short Kn_Par_Nbp	;		 /* nombre de poste du tableau Ktbd_Par */
T_ESTGT	Ktbd_EstGt[NB_PAR_MAX] ; /* tableau des champs necessaires a l'ecriture en sortie */
T_TabFamCharIt Ktbd_FamCha[NB_UWY_MAX][NB_FAM_MAX] ; /* tableau des familles de charges iterees par exercice */
short Ktn_FamUwy[NB_UWY_MAX] ; /* tableau des nombres de postes du tableau Ktbd_FamCha par exercice */
short Kn_Fam_Nbp ;		 /* nombre de postes de Ktbd_FamCha pour un exercice */
short Kn_Fam_Nbl ;		 /* nombre de lignes de Ktbd_FamCha */

double Kd_Prme	;	/* prime estimee */
double Kd_Prmc	;	/* prime cedante */
double Kd_Prma	;	/* prime acquise estrimee et cedante */
double Kd_Clmc	;	/* sinistralite cedante */
double Kd_Ibnr	;	/* IBNR */
double Kd_Pb	;	/* PB cedante */
double Kd_Pap 	;	/* PAP cedante */
double Kd_Loss	;	/* Loss Corridor cedante */
double Kd_Rese	;	/* resultat estime */
double Kd_Resc	;	/* resultat cedante */

BOOL Kb_ReturnStatus=0; /* code de retour du pgm (=0 si OK, 1 sinon) */

int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1PerUw		( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPerUw	( char **pbd_InRec_Cur ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptPerUw	( char **pbd_InRec_Cur ) ;

int n_InitCtrEst 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneCtrEst		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncCtrEst	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtPa			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPa		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPa		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtCum			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtCum		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtCum	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtCumTot		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtCumTot	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtCumTot	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerFci 		( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFci		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFci	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitFutur(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncFutur(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneFutur(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_InitUPR_DAC(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncUPR(char **ptb_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneUPR(char **ptb_InRecOwner, char **pbd_InRecChild);



static int n_check_trncd_cf(char *sz_TrnCd, int *n_est_ITDP);
int n_ChargerFBOTRSLNK();                        //[11]
int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR  *pbd_Rupt, char **ptb_InRecOwner);

int n_InitVariables( void ) ;
int n_WriteGt( char **Gt, char **ptb_InRec_Cur, double d_Amt ) ;
int n_WriteCtrEst( char **CtrEst, char **ptb_InRec_Cur, double d_ClmRed, double d_RetAmt ) ;


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

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm ( argc, argv ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* recuperation des parametres de la chaine 
	 strcpy( Ksz_Cre, psz_GetCharArgv( 1 ) ) ; modification du 03/02/98 */
	strcpy( Ksz_CloDat, psz_GetCharArgv( 2 ) ) ;
	strcpy( Ksz_TypInv, psz_GetCharArgv( 3 ) ) ;

	/* modification et formatage de la date de creation */
  RecSysDate( Ksz_Cre, sz_SysTime ) ;
  FormatTime( sz_SysTime, sz_SysTime ) ;
  strcat( Ksz_Cre, " " ) ;
  strcat( Ksz_Cre, sz_SysTime ) ;

	/* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Annee_bilan, Mois_bilan, Jour_bilan ) ;

    if (n_OpenFileAppl("ESTC1028_I10", "rb", &Kp_FBOTRSLNK) == ERR )
        ExitPgm(ERR_XX ,"cannot open Kp_FBOTRSLNK ");
 
	Kn_FBOTRSLNK = n_ChargerFBOTRSLNK();                         //[11]
    if ( Kn_FBOTRSLNK == -1 )                                    //[11]
    		ExitPgm( ERR_XX , "Taille tableau FBOTRSLNK insuffisante " ) ; //[11]
		
	/* ouverture du fichier de sortie Estimations des dommages */
	if ( n_OpenFileAppl ( "ESTC1028_O2","wt",&Kp_OutputFilCtrEst ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier des devises */
   if ( n_OpenFileAppl ("ESTC1028_I7","rb",&Kp_CoursFil) == ERR )
     ExitPgm ( ERR_XX , "" );

	/* ouverture du fichier de sortie GT des PAP, PB, Loss Corridor */
	if ( n_OpenFileAppl ( "ESTC1028_O1","wt",&Kp_OutputFilGtPbPapLos ) == ERR )
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

	/* Initialisation de la variable bd_RuptGtCumTot */
	if ( n_InitGtCumTot( &bd_RuptGtCumTot ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtPa */
	if ( n_InitGtPa( &bd_RuptGtPa ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFci */
	if ( n_InitPerFci( &bd_RuptPerFci ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptFUTUR */
	 // [004]
	if ( n_InitFutur(&bd_RuptFUTUR))
		ExitPgm( ERR_XX , "" ) ;

//Spot 28140 Initialisation fonction n_CalculExerciceSeuil		
	if(n_initCalculExerciceSeuil("ESTC1028_I8"))
       		 ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtCum */
	 // [004]
	if (n_InitUPR_DAC(&bd_RuptUPRDAC))
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I2", &( bd_RuptPerFci.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I3", &( bd_RuptGtCumTot.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I4", &( bd_RuptGtPa.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I5", &( bd_RuptGtCum.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_I6", &( bd_RuptCtrEst.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl ("ESTC1028_I7",&Kp_CoursFil)== ERR)
    	ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl( "ESTC1028_O1", &Kp_OutputFilGtPbPapLos ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1028_O2", &Kp_OutputFilCtrEst ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );

	exit(Kb_ReturnStatus) ;
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
	if ( n_OpenFileAppl( "ESTC1028_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
		return ERR ;

	/* nombre de rupture a gerer */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1PerUw ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPerUw ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPerUw ;

	pbd_Rupt->c_Separ = '~' ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1PerUw(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1PerUw" ) ;

	if ( ( ret = strcmp( pbd_InRec[PER_CTR_NF], pbd_InRec_Cur[PER_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PER_END_NT], pbd_InRec_Cur[PER_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PER_SEC_NF], pbd_InRec_Cur[PER_SEC_NF] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPerUw( char **pbd_InRec_Cur  )
{
	DEBUT_FCT( "n_ActionFirstRuptPerUw" ) ;

	/* initialisation du tableau Ktbd_Par et du nombre de postes */
	memset( Ktbd_Par, 0, sizeof( T_TabPart ) * NB_PAR_MAX) ;
	Kn_Par_Nbp = NB_PAR_MAX - 1 ;

	/* initialisation du tableau Ktbd_EstGt */
	memset( Ktbd_EstGt, 0, sizeof( T_ESTGT ) * NB_PAR_MAX) ;

	/* initialisation du tableau Ktn_FamUwy et du compteur de postes*/
	memset( Ktn_FamUwy, 0, sizeof( short ) * NB_UWY_MAX) ;
	Kn_Fam_Nbl = NB_UWY_MAX - 1 ;

	/* initialisation du tableau des familles de charges iterees */
	memset( Ktbd_FamCha, 0, sizeof( T_TabFamCharIt ) * NB_UWY_MAX * NB_FAM_MAX) ;

	RETURN_VAL ( OK ) ;
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
	double 	d_ClmRed ;	/* reduction de sinistres du au Loss Corridor */
	double  d_RetAmt = 0 ;	/* montant retenu initialise a zero */
	char 	*CtrEst[NB_COL_CTREST + 1] ; /* tableau de pointeur a l'image du fichier de sortie des Estimations dommages */
	char	*Gt[NB_COL_GT + 1] ; /* tableau de pointeurs a l'image du GT */
	Kd_UPR = 0.0;


	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* initialisation des variables de travail */
	n_InitVariables( ) ;

	/* affectation des postes du tableau Ktbd_EstGt */
	Ktbd_EstGt[Kn_Par_Nbp].UWY_NF = atoi( ptb_InRec_Cur[PER_UWY_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].UW_NT = (char)( atoi( ptb_InRec_Cur[PER_UW_NT] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SSD_CF = (char)( atoi( ptb_InRec_Cur[PER_SSD_CF] ) ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].DIV_NT, ptb_InRec_Cur[PER_DIV_NT] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].EGPCUR_CF, ptb_InRec_Cur[PER_EGPCUR_CF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].ACCESB_CF = (char)( atoi( ptb_InRec_Cur[PER_ACCESB_CF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].CED_NF = atoi( ptb_InRec_Cur[PER_CED_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].PRD_NF = atoi( ptb_InRec_Cur[PER_PRD_NF] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].GENPRMPAY_NF = atoi( ptb_InRec_Cur[PER_GENPRMPAY_NF] ) ;
	strcpy( Ktbd_EstGt[Kn_Par_Nbp].GANPAYORD_NT, ptb_InRec_Cur[PER_GANPAYORD_NT] ) ;
	Ktbd_EstGt[Kn_Par_Nbp].DIFMTH_NF = (char)( atoi( ptb_InRec_Cur[PER_DIFMTH_NF] ) ) ;
	Ktbd_EstGt[Kn_Par_Nbp].SEGSA_B = *ptb_InRec_Cur[PER_SEGSA_B]; //sinistralité

	/* affectation des postes du tableau des participations */
	Ktbd_Par[Kn_Par_Nbp].UWY_NF = atoi( ptb_InRec_Cur[PER_UWY_NF] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTCOM_B = (char)( atoi( ptb_InRec_Cur[PER_CTBCOM_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOMEXI_B = (char)( atoi( ptb_InRec_Cur[PER_PRFCOMEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTBEXI_B = (char)( atoi( ptb_InRec_Cur[PER_LOSCTBEXI_B] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBTYP_CT = (char)( atoi( ptb_InRec_Cur[PER_CTBTYP_CT] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOM_R = atof( ptb_InRec_Cur[PER_PRFCOM_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTB_R = atof( ptb_InRec_Cur[PER_LOSCTB_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].CTBGENFEE_R = atof( ptb_InRec_Cur[PER_CTBGENFEE_R] ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFTYP_CF = (char)( atoi( ptb_InRec_Cur[PER_RESTRFTYP_CF] ) ) ;
	Ktbd_Par[Kn_Par_Nbp].RESTRFDUR_N = (char)( atoi( ptb_InRec_Cur[PER_RESTRFDUR_N] ) ) ;
  Ktbd_Par[Kn_Par_Nbp].SSD_CF = (char)( atoi( ptb_InRec_Cur[PER_SSD_CF] ) ) ;
  strcpy( Ktbd_Par[Kn_Par_Nbp].EGPCUR_CF, ptb_InRec_Cur[PER_EGPCUR_CF] ) ;

  Ktbd_Par[Kn_Par_Nbp].SECACCSTS_CT = (char)( atoi( ptb_InRec_Cur[PER_SECACCSTS_CT] ) ) ;

	/* valeur par defaut si le fichier des estimations dommages ne participe pas */
	Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].LOSENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PBENTAMT_M = 0 ; /* montant manuel par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPADMMOD_CT = 'A' ; /* mode de gestion par defaut */
	Ktbd_EstGt[Kn_Par_Nbp].PAPENTAMT_M = 0 ; /* montant manuel par defaut */

	/* synchronisation avec le fichier Estimation Dommages */
	n_ProcessingRuptureSyncVar( &bd_RuptCtrEst, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier annexe famille des charges iterees */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFci, ptb_InRec_Cur ) ;

	/* affectation de la longueur du tableau des familles de charges iterees */
	Ktn_FamUwy[Kn_Fam_Nbl] = Kn_Fam_Nbp ;

	/* synchronisation avec le fichier GT des estimations */
	n_ProcessingRuptureSyncVar( &bd_RuptGtCumTot, ptb_InRec_Cur ) ;

	/* calcul du resultat estime */
	Kd_Rese += Kd_Ibnr ;

	/* synchronisation avec le fichier GT cumule */
	n_ProcessingRuptureSyncVar( &bd_RuptGtCum, ptb_InRec_Cur ) ;

	/* calcul du resultat cedante */
	Kd_Resc += Kd_Clmc + Kd_Loss ;

	/* synchronisation avec le fichier GT des primes acquises */
	n_ProcessingRuptureSyncVar( &bd_RuptGtPa, ptb_InRec_Cur ) ;


	/* complement des affectations des postes du tableau Ktbd_EstGt */
	Ktbd_EstGt[Kn_Par_Nbp].PB_M = Kd_Pb ; /* montant de PB recu */
	Ktbd_EstGt[Kn_Par_Nbp].PAP_M = Kd_Pap ; /* montant de PAP recu */

	/***************************************/
	/* fonction de calcul de Loss Corridor */
	/***************************************/

	/********************************************************/
	/* Modifs du 06/05/98 - M.HA-THUC			*/
	/* On ne calcule pas de Loss corridor si l'exercice est	*/
	/* strictement inferieur a l'exercice seuil.		*/
	/* L'exercice seuil est defini dans la fonction 	*/
	/* 	n_CalculExerciceSeuil ( estserv.c )		*/
	/********************************************************/
// Spot 28140 Modification des parametes d'appel de la fonction n_CalculExerciceSeuil et Ajout du  test sur le champ sinistralite
	if ( *ptb_InRec_Cur[PER_LOSCOREXI_B] == '1' && (( atoi( ptb_InRec_Cur[PER_UWY_NF] ) >= n_CalculExerciceSeuil( atoi( ptb_InRec_Cur[PER_SSD_CF] ),atoi(ptb_InRec_Cur[PER_ACCESB_CF]),ptb_InRec_Cur[PER_LOB_CF],atoi(ptb_InRec_Cur[PER_NAT_CF]) ) ) ||
	   	    *ptb_InRec_Cur[PER_SEGSA_B] == '1' ))
	{
		//Si Calcul estimation du Loss corridor: automatique ou à vérifier [003] ou Suivi Closing
    // [003] if ( strchr("1/2",*ptb_InRec_Cur[PER_ESTLOSCORTYP_CT]) != 0 ) 
    
    if (atoi(ptb_InRec_Cur[PER_ESTLOSCORTYP_CT]) == 1 || atoi(ptb_InRec_Cur[PER_ESTLOSCORTYP_CT]) == 2 || atoi(ptb_InRec_Cur[PER_ESTLOSCORTYP_CT]) == 4)
    {
		// --------------------------- DEBUT [004] --------------------------------
		/* synchronisation avec le fichier des UPR */
		n_ProcessingRuptureSyncVar(&bd_RuptUPRDAC, ptb_InRec_Cur);
		/* synchronisation avec le fichier des Futur */
		n_ProcessingRuptureSyncVar(&bd_RuptFUTUR, ptb_InRec_Cur);

	    /* Modif OG 07/05/2002, on multiplie par 10 car le montant stocke est divise par 1000 */
			d_ClmRed = d_CalculReducLossCorr( (char)( atoi( ptb_InRec_Cur[PER_LOSCOREXI_B] ) ),
				atof( ptb_InRec_Cur[PER_LOSCORLOW_R] ) * 10.0, atof( ptb_InRec_Cur[PER_LOSCORHIG_R] ) * 10.0,
				atof( ptb_InRec_Cur[PER_LOSCORRAT_R] ) * 10.0, Kd_FuClaim, (-Kd_UPR + Kd_FuFixedPrem)) ; // [004]
				//atof( ptb_InRec_Cur[PER_LOSCORRAT_R] ) * 10.0, ( Kd_Ibnr + Kd_Clmc ), Kd_Prma ) ;
	
			/* determination du montant retenu */
			if ( Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT == 'F' )
				d_RetAmt = Ktbd_EstGt[Kn_Par_Nbp].LOSRETAMT_M ;
			else
				d_RetAmt = d_ClmRed ;
	
			/* 1er cas: inventaire principal */
			if ( *Ksz_TypInv == 'P' )
			{
				/* ecriture dans le fichier des estimations dommages du Loss Corridor */
				n_WriteCtrEst( CtrEst, ptb_InRec_Cur, d_ClmRed, d_RetAmt ) ;
			}
	
			/* ecriture dans le GT du Loss Corridor */
		//	if ( ( d_RetAmt - Kd_Loss ) != 0 )
			if (d_RetAmt != 0) // [004]
				n_WriteGt( Gt, ptb_InRec_Cur, d_RetAmt) ; // [004]
				//n_WriteGt( Gt, ptb_InRec_Cur, ( d_RetAmt - Kd_Loss ) );
			// --------------------------- FIN [004] --------------------------------
			
		}
		//Si Calcul estimation du Loss corridor: Manuel
    if ( atoi(ptb_InRec_Cur[PER_ESTLOSCORTYP_CT]) == 3 && *Ksz_TypInv == 'P' )
    {
			/* ecriture dans le fichier des estimations dommages du Loss Corridor */
			n_WriteCtrEst( CtrEst, ptb_InRec_Cur, 0.0, 0.0);
		}
	}
		
	/* complement des affectations des postes du tableau des participations */
	Ktbd_Par[Kn_Par_Nbp].PRMAMT_M = Kd_Prme + Kd_Prmc ;
	Ktbd_Par[Kn_Par_Nbp].ACCRES_M = Kd_Rese + Kd_Resc + ( d_RetAmt - Kd_Loss ) + Kd_Prma ;
	Ktbd_Par[Kn_Par_Nbp].PRFCOMAMT_M = Kd_Pb ;
	Ktbd_Par[Kn_Par_Nbp].LOSCTBAMT_M = Kd_Pap ;

	/* incrementation du nombre de postes du tableau Ktbd_Par */
	Kn_Par_Nbp -= 1 ;

	/* incrementation du nombre de postes du tableau Ktbd_FamCha */
	if ( atoi( ptb_InRec_Cur[PER_CTBTYP_CT] ) == 2 )
		Kn_Fam_Nbl -= 1 ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerUw( char **pbd_InRec_Cur  )
{
	char	sz_DateDiff[9] ; /* date correspondant au libelle inventaire + decalage */
	char	sz_Acy[5] ;
	char	sz_ScoStrMth[3] ;
	char	sz_ScoEndMth[3] ;
	double 	d_PbCalAmt = 0 ;	/* montant calcule de PB */
	double  d_PapCalAmt = 0 ;	/* montant calcule de PAP */
	double  d_PbRetAmt = 0 ;	/* montant retenu de PB */
	double  d_PapRetAmt = 0 ;	/* montant retenu de PAP */
	char	sz_PbOriCod[25] ;
	char	sz_PapOriCod[25] ;
	int 	i;
	T_TabPbPap tbd_PbPap[NB_PAR_MAX] ; /* tableau des montants de participations aux pertes
		et benefices */
	int 	n_PbPap_Nbp ; 	/* nombre de poste du tableau resultant de la fonction de calcul */

	char	MsgAno[300] ; 	/* message d'anomalie */

	DEBUT_FCT( "n_ActionLastRuptPerUw" ) ;


	/****************************************************************************/
	/* tests de depassement de tableau et generation d'anomalies eventuellement */
	/****************************************************************************/

	/* tableaux des participations Ktbd_Par et Ktbd_EstGt */
	if ( Kn_Par_Nbp < 0 )
	{
		sprintf( MsgAno, "The participation records number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}

	/* tableaux des familles de charges iterees Ktbd_FamCha et Ktn_FamUwy */
	if ( Kn_Fam_Nbl < 0 )
	{
		sprintf( MsgAno, "The underwriting year number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}

	/* tableau des familles de charges iterees Ktbd_FamCha */
	if ( Kn_Fam_Nbp >= NB_FAM_MAX )
	{
		sprintf( MsgAno, "The reiterated charges families number for the contract ( CTR %s /END %s /SEC %s ) overflows the program memory capacity",
			pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF] ) ;

		RETURN_VAL ( OK ) ;
	}

	/**************************************/
	/* fonction de calcul de PAP et de PB */
	/**************************************/

	/********************************************************/
	/* Modifs du 06/05/98 - M.HA-THUC			*/
	/* On n'ecrit pas en sortie de PB ou PAP si l'exercice 	*/
	/* est strictement inferieur a l'exercice seuil.	*/
	/* L'exercice seuil est defini dans la fonction 	*/
	/* 	n_CalculExerciceSeuil ( estserv.c )		*/
	/********************************************************/
	n_PbPap_Nbp = n_CalculPartBenefPert( ( NB_PAR_MAX - Kn_Par_Nbp - 1 ), &Ktbd_Par[Kn_Par_Nbp + 1],
		&Ktn_FamUwy[Kn_Fam_Nbl + 1], &Ktbd_FamCha[Kn_Fam_Nbl + 1], tbd_PbPap ) ;

	for ( i = 0; i < n_PbPap_Nbp ; i++ )
	{
		/* positionnement du montant calcule PB */
		if ( tbd_PbPap[i].PBEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PbOriCod, "Account" ) ;
				d_PbCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PB_M ;
			}
			else
			{
				strcpy( sz_PbOriCod, "CloP" ) ;
				d_PbCalAmt = tbd_PbPap[i].PB ;
			}
		}

		/* positionnement du montant calcule PAP */
		if ( tbd_PbPap[i].PAPEX == 1 )
		{
			/* cas ou les PB/PAP ne sont pas calculables */
			if ( tbd_PbPap[i].CTCOM_B == 0 )
			{
				strcpy( sz_PapOriCod, "Account" ) ;
				d_PapCalAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAP_M ;
			}
			else
			{
				strcpy( sz_PapOriCod, "CloP" ) ;
				d_PapCalAmt = tbd_PbPap[i].PAP ;
			}
		}

		/* positionnement du montant retenu PB */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBADMMOD_CT == 'A' )
			d_PbRetAmt = d_PbCalAmt ;
		else	d_PbRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBENTAMT_M ;

		/* positionnement du montant retenu PAP */
		if ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPADMMOD_CT == 'A' )
			d_PapRetAmt = d_PapCalAmt ;
		else	d_PapRetAmt = Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PAPENTAMT_M ;

		/* ecriture dans le fichier des estimations dommages des PB et PAP */
		if ( *Ksz_TypInv == 'P' )
		{
			/* PB */

			/********************************************************/
			/* Modifs du 06/05/98 - M.HA-THUC			*/
			/* On n'ecrit pas en sortie de PB ou PAP si l'exercice 	*/
			/* est strictement inferieur a l'exercice seuil.	*/
			/* L'exercice seuil est defini dans la fonction 	*/
			/* 	n_CalculExerciceSeuil ( estserv.c )		*/
			/********************************************************/
// Spot 28140 Modification des parametes d'appel de la fonction n_CalculExerciceSeuil et Ajout du  test sur le champ sinistralite
      if ( tbd_PbPap[i].PBEX == 1 && tbd_PbPap[i].PAPEX == 0  && d_PbRetAmt != 0
				&& (( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UWY_NF >= n_CalculExerciceSeuil( atoi( pbd_InRec_Cur[PER_SSD_CF] ),atoi(pbd_InRec_Cur[PER_ACCESB_CF]),pbd_InRec_Cur[PER_LOB_CF],atoi(pbd_InRec_Cur[PER_NAT_CF]) ) ) ||
	   	    Ktbd_EstGt[Kn_Par_Nbp].SEGSA_B == '1')  
        && ( tbd_PbPap[i].SECACCSTS_CT ) != 9
        && (tbd_PbPap[i].CTBTYP_CT) != 4 )    // JR 29/06/2006
				fprintf( Kp_OutputFilCtrEst, "%s~%s~%s~%d~%d~%s~%s~%s~%d~%s~%s~%-.3f~%-.3f~%-.3f~%c~%s~%s~%s~~%s~~\n",
					pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF],
					Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UWY_NF, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UW_NT, Ksz_Cre, "710",
					"22000", Ktbd_EstGt[Kn_Par_Nbp + 1 + i].SSD_CF, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].DIV_NT,
					Ktbd_EstGt[Kn_Par_Nbp + 1 + i].EGPCUR_CF, d_PbCalAmt, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBENTAMT_M,
					d_PbRetAmt, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PBADMMOD_CT, Ksz_CloDat, sz_PbOriCod, "ESTC1028", Ksz_Cre ) ;
		}

		/* calcul de la periode de compte et de l'annee de compte */
		n_AddMonths( sz_DateDiff, ( -1 * Ktbd_EstGt[Kn_Par_Nbp + 1 + i].DIFMTH_NF ), '-', Ksz_CloDat ) ;
		sscanf( sz_DateDiff, "%4s%2s", sz_Acy, sz_ScoStrMth ) ;
		strcpy( sz_ScoEndMth, sz_ScoStrMth ) ;

// Spot 28140 Modification des parametes d'appel de la fonction n_CalculExerciceSeuil et Ajout du  test sur le champ sinistralite
		if ( tbd_PbPap[i].PBEX == 1 && tbd_PbPap[i].PAPEX == 0  && ( d_PbRetAmt - Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PB_M ) != 0
			&& ( Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UWY_NF >= n_CalculExerciceSeuil( atoi( pbd_InRec_Cur[PER_SSD_CF]) ,atoi(pbd_InRec_Cur[PER_ACCESB_CF]),pbd_InRec_Cur[PER_LOB_CF],atoi(pbd_InRec_Cur[PER_NAT_CF]) ) 
			|| Ktbd_EstGt[Kn_Par_Nbp].SEGSA_B == '1') 
        && ( tbd_PbPap[i].SECACCSTS_CT ) != 9
        && (tbd_PbPap[i].CTBTYP_CT) != 4 )    // JR 29/06/2006
		{
			// [007] annee de compte fausse
		if (atoi(sz_Acy) == 0) 
					strcpy(sz_Acy,Annee_bilan);
		if (atoi(sz_ScoStrMth) == 0) 
					strcpy(sz_ScoStrMth,Mois_bilan);
		if (atoi(sz_ScoEndMth) == 0) 
				strcpy(sz_ScoEndMth,Mois_bilan);
			fprintf( Kp_OutputFilGtPbPapLos, "%d~%d~%s~%s~%s~%s~~%s~%s~%s~%d~%d~%d~%s~%s~%s~~%s~%-.3f~%d~%d~%d~%s~~~~~~~~~~~~~~~~~~\n",
				Ktbd_EstGt[Kn_Par_Nbp + 1 + i].SSD_CF, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].ACCESB_CF,
				Annee_bilan, Mois_bilan, Jour_bilan, "11150002", pbd_InRec_Cur[PER_CTR_NF],
				pbd_InRec_Cur[PER_END_NT], pbd_InRec_Cur[PER_SEC_NF], Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UWY_NF,
				Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UW_NT, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].UWY_NF, sz_Acy,
				sz_ScoStrMth, sz_ScoEndMth, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].EGPCUR_CF,
				( d_PbRetAmt - Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PB_M ), Ktbd_EstGt[Kn_Par_Nbp + 1 + i].CED_NF,
				Ktbd_EstGt[Kn_Par_Nbp + 1 + i].PRD_NF, Ktbd_EstGt[Kn_Par_Nbp + 1 + i].GENPRMPAY_NF,
				Ktbd_EstGt[Kn_Par_Nbp + 1 + i].GANPAYORD_NT ) ;
		}
	}

	RETURN_VAL ( OK ) ;
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
	if ( n_OpenFileAppl( "ESTC1028_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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

	/* positionnement du mode de gestion */
	if ( *Ksz_TypInv == 'P' )
	{
		/* LOSS CORRIDOR */
		if ( strcmp( "21000", ptb_InRecChild[EST_ACMTRS_NT] ) == 0 )
		{
			if ( strcmp( Ksz_CloDat, ptb_InRecChild[EST_CLODAT_D] ) == 0 &&
				*ptb_InRecChild[EST_ADMMOD_CT] == 'F' )
				Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT = 'F' ;
			else 	Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT = 'A' ;

			/* sauvegarde du montant manuel et retenu */
			Ktbd_EstGt[Kn_Par_Nbp].LOSENTAMT_M = atof( ptb_InRecChild[EST_ENTAMT_M] ) ;
			Ktbd_EstGt[Kn_Par_Nbp].LOSRETAMT_M = atof( ptb_InRecChild[EST_RETAMT_M] ) ;
		}

		/* PB */
		if ( strcmp( "22000", ptb_InRecChild[EST_ACMTRS_NT] ) == 0 )
		{
			if ( strcmp( Ksz_CloDat, ptb_InRecChild[EST_CLODAT_D] ) == 0 &&
				*ptb_InRecChild[EST_ADMMOD_CT] == 'F' )
				Ktbd_EstGt[Kn_Par_Nbp].PBADMMOD_CT = 'F' ;
			else 	Ktbd_EstGt[Kn_Par_Nbp].PBADMMOD_CT = 'A' ;

			/* sauvegarde du montant manuel et retenu */
			Ktbd_EstGt[Kn_Par_Nbp].PBENTAMT_M = atof( ptb_InRecChild[EST_ENTAMT_M] ) ;
			Ktbd_EstGt[Kn_Par_Nbp].PBRETAMT_M = atof( ptb_InRecChild[EST_RETAMT_M] ) ;
		}

		/* PAP */
		if ( strcmp( "23000", ptb_InRecChild[EST_ACMTRS_NT] ) == 0 )
		{
			if ( strcmp( Ksz_CloDat, ptb_InRecChild[EST_CLODAT_D] ) == 0 &&
				*ptb_InRecChild[EST_ADMMOD_CT] == 'F' )
				Ktbd_EstGt[Kn_Par_Nbp].PAPADMMOD_CT = 'F' ;
			else 	Ktbd_EstGt[Kn_Par_Nbp].PAPADMMOD_CT = 'A' ;

			/* sauvegarde du montant manuel et retenu */
			Ktbd_EstGt[Kn_Par_Nbp].PAPENTAMT_M = atof( ptb_InRecChild[EST_ENTAMT_M] ) ;
			Ktbd_EstGt[Kn_Par_Nbp].PAPRETAMT_M = atof( ptb_InRecChild[EST_RETAMT_M] ) ;
		}
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l'esclave « des regroupements de GT »

retour :
	OK
==============================================================================*/
int n_InitGtCumTot(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtCumTot" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Gt selectionne sur sinistres */
	if ( n_OpenFileAppl( "ESTC1028_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier GT des Ibnr */
	pbd_Rupt->n_NbRupture = 0 ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGtCumTot ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneGtCumTot ;

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
int n_ConditionSyncGtCumTot(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncGtCumTot" ) ;

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
int n_ActionLigneGtCumTot(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtCumTot" ) ;

	/* cumul du montant de prime estime */
	if ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "1110", 4 ) == 0 && ptb_InRecChild[GT_TRNCOD_CF][7] == '2' )
		Kd_Prme += atof( ptb_InRecChild[GT_AMT_M] ) ;

	/* cumul du montant d'IBNR estime */
	if ( strcmp( ptb_InRecChild[GT_TRNCOD_CF], "11494002" ) == 0 ||
		strcmp( ptb_InRecChild[GT_TRNCOD_CF], "11494052" ) == 0 ||
		strcmp( ptb_InRecChild[GT_TRNCOD_CF], "11494102" ) == 0 )
		Kd_Ibnr += atof( ptb_InRecChild[GT_AMT_M] ) ;

	/* cumul du resultat estime */
	if ( ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "1112", 4 ) == 0 && ptb_InRecChild[GT_TRNCOD_CF][7] == '2' ) ||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "11310", 5 ) == 0 && (ptb_InRecChild[GT_TRNCOD_CF][7] == '2'  || (ptb_InRecChild[GT_TRNCOD_CF][7] == '6' )))||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "1110120", 7 ) == 0 && ptb_InRecChild[GT_TRNCOD_CF][7] == '2' ) ||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "1110130", 7 ) == 0 && ptb_InRecChild[GT_TRNCOD_CF][7] == '2' ) ||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "11311", 5 ) == 0 && (ptb_InRecChild[GT_TRNCOD_CF][7] == '2' || (ptb_InRecChild[GT_TRNCOD_CF][7] == '6' ))) ||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "11312", 5 ) == 0 && (ptb_InRecChild[GT_TRNCOD_CF][7] == '2' || (ptb_InRecChild[GT_TRNCOD_CF][7] == '6' ))) ||
	   ( strncmp( ptb_InRecChild[GT_TRNCOD_CF], "11430", 5 ) == 0 && (ptb_InRecChild[GT_TRNCOD_CF][7] == '2' || (ptb_InRecChild[GT_TRNCOD_CF][7] == '6' ))) )
		Kd_Rese += atof( ptb_InRecChild[GT_AMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l'esclave « GT cumule toute Pc/Ac confondues »

retour :
	OK
==============================================================================*/
int n_InitGtCum(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtCum" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Gt selectionne sur sinistres */
	if ( n_OpenFileAppl( "ESTC1028_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
==============================================================================*/
int n_ActionLigneGtCum(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneSyncGtCum" ) ;

	/* affectation des montants de prime, sinistralite, PAP, PB, Loss Corridor et resultat */
	switch( atol( ptb_InRecChild[GTE_ACMTRS_NT] ) )
	{
	case 10000 :
		Kd_Prmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
   if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9  )    /*   (spot 11507) */
    {
		Kd_Prma += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
    }
		break ;
	case 12000 :
		Kd_Prmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 13000 :
		Kd_Prmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case -20000 :
		Kd_Clmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
        case -20030 :
                Kd_Clmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
                break ;
	case 20000 :
		Kd_Clmc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10100 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	/****************************************/
	/* Evol - Commission originale multiple */
	/****************************************/
	case 10200 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10300 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10110 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10120 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10130 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10140 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10310 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 10320 :
		Kd_Resc += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 22000 :
		Kd_Pb = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 23000 :
		Kd_Pap = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	case 21000 :
		Kd_Loss = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		break ;
	/****************************************/
	/* Evol - Prise en compte des traites termines (spot 11507) */
	/****************************************/

case 10010 :
   if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9  )
    {
		Kd_Prma += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
    }
		break ;

case 10020 :
      if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9  )
    {
		Kd_Prma += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
		}
    break ;
case 10030 :
      if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9  )
    {
		Kd_Prma += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
    }
		break ;
case 10040 :
      if ( atoi( ptb_InRecOwner[PER_SECACCSTS_CT] ) == 9  )
    {
		Kd_Prma += atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;
    }
		break ;
	}

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
	if ( n_OpenFileAppl( "ESTC1028_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
==============================================================================*/
int n_ActionLigneGtPa(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneGtPa" ) ;

	/* affectation du montant de prime acquise estimee et cedante */
	Kd_Prma = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;

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
	if ( n_OpenFileAppl( "ESTC1028_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFCI_SEC_NF] ) ) != 0 ) return ret ;
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
	DEBUT_FCT( "n_ActionLignePerFci" ) ;
	char sz_message[300];

	/* constitution du tableau des familles de charges iterees */
	if ( atoi( ptb_InRecOwner[PER_CTBTYP_CT] ) == 2 )
	{
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].CHGTYP_B = (char)( atoi( ptb_InRecChild[PERFCI_CHGTYP_B] ) ) ;
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].MAX_R = atof( ptb_InRecChild[PERFCI_MAX_R] ) ;
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].MINRAT_R = atof( ptb_InRecChild[PERFCI_MINRAT_R] ) ;
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].MIN_R = atof( ptb_InRecChild[PERFCI_MIN_R] ) ;
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].MAXRAT_R = atof( ptb_InRecChild[PERFCI_MAXRAT_R] ) ;
		Ktbd_FamCha[Kn_Fam_Nbl][Kn_Fam_Nbp].RATTYP_B = atof( ptb_InRecChild[PERFCI_RATTYP_B] ) ;

		/* incrementation du compteur de poste du tableau */
		Kn_Fam_Nbp += 1 ;
		
		//[001]
		if ( Kn_Fam_Nbp >= NB_FAM_MAX )
		{
			sprintf(sz_message, "Depassement de capacite du tableau Ktbd_FamCha, agrandir le nombre de postes NB_FAM_MAX dans ESTC1028.h et estserv.*");
    	n_WriteAno(sz_message);
    	ExitPgm( ERR_XX , "" ) ;
		}
	}

	RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre famille de charges iterees  »

retour :
	OK
==============================================================================*/
int n_InitUPR_DAC(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitUPR_DAC");

	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	/* ouverture du fichier esclave famille de charges iterees  */
	if (n_OpenFileAppl("ESTC1028_I11", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		return ERR;
	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0;
	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUPR;
	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUPR;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncUPR(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncPerFci" ) ;
	if ((ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0)
		return ret;
	if ((ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT])) != 0)
		return ret;
	if ((ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0)
		return ret;
	if ((ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0)
		return ret;
	if ((ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT])) != 0)
		return ret;
	RETURN_VAL(0);
}


int n_ActionLigneUPR(char **ptb_InRecOwner, char **pbd_InRecChild)
{
	int		n_type_trn_cd;
	int		kn_est_ITDP;

	//Kd_UPR = 0.0;
	n_type_trn_cd = n_check_trncd_cf(pbd_InRecChild[GT_TRNCOD_CF], &kn_est_ITDP); 
	if (n_type_trn_cd == UPR)
	{
		Kd_UPR += atol(pbd_InRecChild[GT_AMT_M]);
	}
	return 0;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre famille de charges iterees  »

retour :
	OK
==============================================================================*/
int n_InitFutur(T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitFutur");

	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR));
	/* ouverture du fichier esclave famille de charges iterees  */
	if (n_OpenFileAppl("ESTC1028_I9", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		return ERR;
	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 0;
	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncFutur;
	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFutur;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
	> 0   	---> pbd_InRecOwne> > pbd_InRecChild
	< 0   	---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncFutur(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret;

	DEBUT_FCT( "n_ConditionSyncPerFci" ) ;
	if ((ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0)
		return ret ;
	if ((ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT])) != 0)
		return ret ;
	if ((ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0)
		return ret ;
	if ((ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0)
		return ret ;
	if ((ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT])) != 0)
		return ret ;
	RETURN_VAL( 0 ) ;
}


int n_ActionLigneFutur(char **ptb_InRecOwner, char **pbd_InRecChild)
{
	if (!strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A100012"))
		Kd_FuFixedPrem += atol(pbd_InRecChild[GT_AMT_M]);
	if (!strcmp(pbd_InRecChild[GT_TRNCOD_CF], "1A494302"))
		Kd_FuClaim += atol(pbd_InRecChild[GT_AMT_M]);
	return 0;
}

/*==============================================================================
objet :
 fonction de recherche du trncod
retour :
         UPR   1  UPR
         DAC   2  DAC
         COME  3  Commission Estimates
         PRME  4  Premium Estimates
         ITDP  5  ITD Written Premium
         OTHER 6  Others

==============================================================================*/
static int n_check_trncd_cf(char *sz_TrnCd, int *n_est_ITDP)
{
        int i;
        //n_est_ITDP = 0 ;

        DEBUT_FCT("n_check_trncd_cf");


        for ( i = 0; i <  Kn_FBOTRSLNK ; i++ )
        {
        if ( strcmp( sz_TrnCd, Ktbd_FBOTRSLNK[i].DETTRS_CF ) == 0 )
        {
			if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 ) // ITDP ITD Written Premium 1010
		  	{
				*n_est_ITDP = (int) ITDP ;
			}			        	
        	
        	
		  if  ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 101  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == '2' ) // Premium Estimates
			  RETURN_VAL(PRME);			    
		  else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 201  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 )  // Commission Estimates
			  RETURN_VAL(COME);			    
		  else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103 )  // UPR
			  RETURN_VAL(UPR);			    
		  else if ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 203 )  // DAC
			  RETURN_VAL(DAC);	
		  else if ( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 ) // ITDP ITD Written Premium 1010
		  {
		  	printf(" UN CAS : Ktbd_FBOTRSLNK[i].ACMTRSL2_NT=%d ; Ktbd_FBOTRSLNK[i].ACMTRSL3_NT=%d \n", Ktbd_FBOTRSLNK[i].ACMTRSL2_NT, Ktbd_FBOTRSLNK[i].ACMTRSL3_NT) ;
			  RETURN_VAL(ITDP);
			}			  				  
		  else RETURN_VAL(OTHER);	// OTHERS	 
		}
	   }

        RETURN_VAL(OTHER);
}

int n_ChargerFBOTRSLNK()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerFBOTRSLNK");

  while (fread(&Ktbd_FBOTRSLNK[i], sizeof(T_FBOTRSLNK), 1, Kp_FBOTRSLNK) == 1)
    {
		if (  
			     ( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 101  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 && Ktbd_FBOTRSLNK[i].DETTRS_CF[7] == '2' ) // Premium Estimates 
			   ||( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 201  && Ktbd_FBOTRSLNK[i].TRSTYP_NT ==3 ) // Commission Estimates 
			   ||( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 103 ) // UPR
			   ||( Ktbd_FBOTRSLNK[i].ACMTRSL2_NT == 203 ) // DAC
			   ||( Ktbd_FBOTRSLNK[i].ACMTRSL3_NT == 1010 ) // ITDP			                 		  
		 )
		 {		
		  i += 1;				
         }


  
        if ( i > Kn_MaxLigFBOTRSLNK )
        {
            n_WriteAno("Depassement de capacite du tableau Ktbd_FBOTRSLNK");
            RETURN_VAL(-1);
        }

    }
  if ( i == 0 )
  {
     n_WriteAno("Fichier FBOTRSLNK vide");
     RETURN_VAL(-1);
  }
  
  RETURN_VAL(i);
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

	/* initialisation des montants de prime, sinistralite, ... */
	Kd_Prme = 0 ;
	Kd_Prmc = 0 ;
	Kd_Prma	= 0 ;
	Kd_Clmc = 0 ;
	Kd_Ibnr = 0 ;
	Kd_Pb = 0 ;
	Kd_Pap = 0 ;
	Kd_Loss	= 0 ;
	Kd_Rese = 0 ;
	Kd_Resc = 0 ;
	Kd_UPR = 0;
	Kd_FuClaim = 0;
	Kd_FuFixedPrem = 0;
 

	/* initialisation du nombre de postes du tableau des familles de charges iterees */
	Kn_Fam_Nbp = 0 ;

 	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier des estimations dommages

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_WriteCtrEst( char **CtrEst, char **ptb_InRec_Cur, double d_ClmRed, double d_RetAmt )
{
	char	sz_AdmMod[2] ;	/* mode de gestion */
	char 	sz_CalAmt[20] ; /* montant propose */
	char 	sz_EntAmt[20] ; /* montant manuel */
	char 	sz_RetAmt[20] ; /* montant retenu */

	DEBUT_FCT( "n_WriteCtrEst" ) ;

	CtrEst[EST_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
	CtrEst[EST_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
	CtrEst[EST_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
	CtrEst[EST_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
	CtrEst[EST_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
	CtrEst[EST_CRE_D] = Ksz_Cre ;
	CtrEst[EST_PRS_CF] = "710" ;
	CtrEst[EST_ACMTRS_NT] = "21000" ;
	CtrEst[EST_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
	CtrEst[EST_DIV_NT] = ptb_InRec_Cur[PER_DIV_NT] ;
	CtrEst[EST_CUR_CF] = ptb_InRec_Cur[PER_EGPCUR_CF] ;
	CtrEst[EST_CALAMT_M] = sz_CalAmt ;
	CtrEst[EST_ENTAMT_M] = sz_EntAmt ;
	CtrEst[EST_RETAMT_M] = sz_RetAmt ;
	CtrEst[EST_ADMMOD_CT] = sz_AdmMod ;
	CtrEst[EST_CLODAT_D] = Ksz_CloDat ;
	CtrEst[EST_ORICOD_LS] = "CloP" ;
	CtrEst[EST_UPDUSR_CF] = "ESTC1028" ;
	CtrEst[EST_CREUSR_CF] = "" ;
	CtrEst[EST_LSTUPD_D] = Ksz_Cre ;
	CtrEst[EST_LSTUPDUSR_CF] = "" ;
	CtrEst[EST_CMT_NT] = "" ;
	CtrEst[EST_CMT_NT + 1] = NULL ;

	sprintf( sz_CalAmt, "%-.3f", d_ClmRed ) ;
	sprintf( sz_AdmMod, "%c", Ktbd_EstGt[Kn_Par_Nbp].LOSADMMOD_CT ) ;
	sprintf( sz_EntAmt, "%-.3f", Ktbd_EstGt[Kn_Par_Nbp].LOSENTAMT_M ) ;
	sprintf( sz_RetAmt, "%-.3f", d_RetAmt ) ;

	n_WriteCols( Kp_OutputFilCtrEst, CtrEst, SEPARATEUR, 0 ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier GT

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_WriteGt( char **Gt, char **ptb_InRec_Cur, double d_Amt )
{
	char	sz_DateDiff[9] ; /* date correspondant au libelle inventaire + decalage */
	char	sz_Vide[2] = "" ;
	char	sz_Acy[5] ;
	char	sz_ScoStrMth[3] ;
	char	sz_ScoEndMth[3] ;
	char	sz_Amt[20] ;

	DEBUT_FCT( "n_WriteGt" ) ;

	/* calcul de la periode de compte et de l'annee de compte */
	n_AddMonths( sz_DateDiff, ( -1 * atoi( ptb_InRec_Cur[PER_DIFMTH_NF] ) ), '-', Ksz_CloDat ) ;
	sscanf( sz_DateDiff, "%4s%2s", sz_Acy, sz_ScoStrMth ) ;
	strcpy( sz_ScoEndMth, sz_ScoStrMth ) ;
	
	// [007] annee de compte fausse
	if (atoi(sz_Acy) == 0) 
				strcpy(sz_Acy,Annee_bilan);
	if (atoi(sz_ScoStrMth) == 0) 
				strcpy(sz_ScoStrMth,Mois_bilan);
	if (atoi(sz_ScoEndMth) == 0) 
			strcpy(sz_ScoEndMth,Mois_bilan);

	Gt[GT_SSD_CF] = ptb_InRec_Cur[PER_SSD_CF] ;
	Gt[GT_ESB_CF] = ptb_InRec_Cur[PER_ACCESB_CF] ;
	Gt[GT_BALSHEY_NF] = Annee_bilan ;
	Gt[GT_BALSHRMTH_NF] = Mois_bilan ;
	Gt[GT_BALSHRDAY_NF] = Jour_bilan ;
	Gt[GT_TRNCOD_CF] = "11200702" ;
	Gt[GT_DBLTRNCOD_CF] = sz_Vide ;
	Gt[GT_CTR_NF] = ptb_InRec_Cur[PER_CTR_NF] ;
	Gt[GT_END_NT] = ptb_InRec_Cur[PER_END_NT] ;
	Gt[GT_SEC_NF] = ptb_InRec_Cur[PER_SEC_NF] ;
	Gt[GT_UWY_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
	Gt[GT_UW_NT] = ptb_InRec_Cur[PER_UW_NT] ;
	Gt[GT_OCCYEA_NF] = ptb_InRec_Cur[PER_UWY_NF] ;
	Gt[GT_ACY_NF] = sz_Acy ;
	Gt[GT_SCOSTRMTH_NF] = sz_ScoStrMth ;
	Gt[GT_SCOENDMTH_NF] = sz_ScoEndMth ;
	Gt[GT_CLM_NF] = sz_Vide ;
	Gt[GT_CUR_CF] = ptb_InRec_Cur[PER_EGPCUR_CF] ;
	Gt[GT_AMT_M] = sz_Amt ;
	Gt[GT_CED_NF] = ptb_InRec_Cur[PER_CED_NF] ;
	Gt[GT_BRK_NF] = ptb_InRec_Cur[PER_PRD_NF] ;
	Gt[GT_PAY_NF] = ptb_InRec_Cur[PER_GENPRMPAY_NF] ;
	Gt[GT_KEY_NF] = ptb_InRec_Cur[PER_GANPAYORD_NT] ;
	Gt[GT_RETCTR_NF] = sz_Vide ;
	Gt[GT_RETEND_NT] = sz_Vide ;
	Gt[GT_RETSEC_NF] = sz_Vide ;
	Gt[GT_RTY_NF] = sz_Vide ;
	Gt[GT_RETUW_NT] = sz_Vide ;
	Gt[GT_RETOCCYEA_NF] = sz_Vide ;
	Gt[GT_RETACY_NF] = sz_Vide ;
	Gt[GT_RETSCOSTRMTH_NF] = sz_Vide ;
	Gt[GT_RETSCOENDMTH_NF] = sz_Vide ;
	Gt[GT_RCL_NF] = sz_Vide ;
	Gt[GT_RETCUR_CF] = sz_Vide ;
	Gt[GT_RETAMT_M] = sz_Vide ;
	Gt[GT_PLC_NT] = sz_Vide ;
	Gt[GT_RTO_NF] = sz_Vide ;
	Gt[GT_INT_NF] = sz_Vide ;
	Gt[GT_RETPAY_NF] = sz_Vide ;
	Gt[GT_RETKEY_CF] = sz_Vide ;
  Gt[GT_RETINTAMT_M] = sz_Vide ;              /* ajout 29/01/03 */
  Gt[GT_RETINTAMT_M + 1] = NULL ;

/*	Gt[GT_RETKEY_CF + 1] = NULL ;  */

	sprintf( sz_Amt, "%-.3f", d_Amt ) ;

	n_WriteCols( Kp_OutputFilGtPbPapLos, Gt, SEPARATEUR, 0 ) ;

	RETURN_VAL ( OK ) ;
}
