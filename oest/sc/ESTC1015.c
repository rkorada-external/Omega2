/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1015.c
révision                      : $Revision: 1.2 $
date de création              : 20/07/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   ESTIMATIONS DE RECONSTITUTIONS ET DE BURNING COST POUR LES TRAITES NON
PROPORTIONNELS

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

	  29/01/03      J. Ribot    ajout 1 champs a NULL en sortie pour retintamt_m
        23/05/2005    M.DJELLOULI     Correction SPOT 11172 - 11175     MOD02
	                                           Conditionnement  Postes à Risques par
	                                           Chargement des Données de TFAMCFG, TFAMCOTP, TFAMLIA de PERICASE Etendue
        28/07/2005    M.DJELLOULI     Inclusion Modifications - SPOT 11184 - MOD03
                                                 Estimations Burning Cost Arrêtés Trimestriels/Semestriels
        28/07/2005    M.DJELLOULI     Inclusion Modifications - SPOT 11171 - MOD04
                                                 Minimum Premium in Burning Cost Calculation.
        25/10/2005    M.DJELLOULI     Inclusion ESTCOMTYP_CT, ESTCBTTYP_CT, ESTREITYP_CT, ESTPRMTYP_CT à Test NULL
                                      NULL Equivalence à Estimation Manuelle (Valeur = 1)
        16/01/2006    M.DJELLOULI     Correction ESTREITYP_CT, ESTPRMTYP_CT Valeur "Manuelle" = 3
        26/01/2006    M.DJELLOULI     Si ESTPRMTYP_CT not in (Null, 3, 0) -> N_check_Prov = 1 (donc calcul BurningCost)
        27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[009] 30/06/2014 R. cassis :spot:27057 Put 8 decimals to SHR_R rate than 3
[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main
[011]  20/11/2014 Florent :spot:27747 enlevé les define du PERExtend_ et mis dans le struc.h, ajout 2 devises tarif
[012]  29/01/2015 F.MARAGNES:spot:28140  Modification appel calculExerciceSeuil nouveau prototype  n_CalculExerciceSeuil(short ssd_cf , short esb_cf, char *lob_cf, short nat_cf ); et ajout d'un test sur la sinistrabilite 
                 pour la determination du seuil appel des fonctions init_calculExerciceSeuil pour charger les données du fichier FTTHRHLDUWY en mémoire, ferme_calculExerciceSeuil pour liberer la mémoire  
[013] 13/03/2020 M. NAJI   :SPIRA 84317 cr?ation d'un (#define ZERO 1 ) et teste < ZERO au lieu < 0.001 
[014] 24/06/2020 R. cassis :spira:84903 Le ZERO doit avoir la valeur 0.001 et pas 1 comme l'ancienne version
[015] 29/09/2020 MZM : spira 89714 INI - Variable Premiums : Ajout REIPRMPTP_R : Info de gratuite pour le calcul des Reinstatements Premiums
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
#include "ESTC1015.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE 		*Kp_OutputFilFt ; /* pointeur sur le fichier de sortie Fichier de travail */
FILE 		*Kp_OutputFilGtBcRec ; /* pointeur sur le fichier de sortie GT des primes de Burning
						cost et de reconstitutions estimées */
FILE 		*Kp_InputFilExc ; 	 /* MOD04 - pointeur sur le fichier binaire FCURQUOT */

T_RUPTURE_VAR  	   	bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre de
						souscription */
T_RUPTURE_SYNC_VAR 	bd_RuptUlt ; /* variable de gestion de la synchronisation avec
						le fichier des Primes et sinistres ultimes */
T_RUPTURE_SYNC_VAR 	bd_RuptFt ; /* variable de gestion de la synchronisation avec
						le fichier de Fichier de travail */
T_RUPTURE_SYNC_VAR 	bd_RuptGtCum ; /* variable de gestion de la synchronisation avec
						le fichier GT cumule selectionne sur sinistres */
T_RUPTURE_SYNC_VAR 	bd_RuptGtIbnr ; /* variable de gestion de la synchronisation avec
						le fichier GT des IBNR */
T_RUPTURE_SYNC_VAR 	bd_RuptPerFr ; /* variable de gestion de la synchronisation avec
						le fichier annexe du perimetre de souscription */

char Ksz_CloDat[9] ;    /* parametre de la chaîne: libelle d'inventaire */
char	Annee_bilan[5] ;
char	Mois_bilan[3] ;
char	Jour_bilan[3] ;

int Kn_Pa ;		/* variable de participations des fichiers esclaves */

int Kc_Pe ;		/* flag positionne a 1 si il existe au moins une prime  dans
				le Fichier de travail pour une affaire donnee */

/************************/
/* Variables de travail */
/************************/
double Kd_Ult_RetAmtPrm ; /* montant de sinistre du fichier Primes et sinistres ultimes */
double Kd_GtIbnr_Amt ;	/* montant de sinistre du fichier GT des IBNR */
double Kd_GtCum_Amt ;	/* montant de sinistre du fichier GT cumule */
T_LIGNEREC Ktbd_Rec[NB_REC_MAX] ;	/* tableau de reconstitution */
int Kn_RecRnk ;		/* variable correspondant au rang de reconstitutions par affaire */
T_FTBC Ktbd_Ft[NB_FT_MAX] ; /* tableau des lignes du fichier de travail par affaire */
int Kn_FtNum ;		/* variable correspondant au numero de poste du tableau */
double Kd_Pbc_Amt ; 	/* montant de Burning Cost calcule */
double Kd_Rec_Amt ; 	/* montant de la prime de reconstitution calcule */
char Ksz_GtBcRec_ScoStrMth[3] ; /* periode de compte mois debut */
char Ksz_GtBcRec_ScoEndMth[3] ; /* periode de compte mois fin */
char Ksz_GtBcRec_Acy[5] ; /* annee de compte */
double Kd_GtBcRec_Amt ;	/* montant ecrit en sortie dans le GT */
double Kd_Ft_TotAmt ; 	/* montant total des primes comptabilisees reçues et estimees par affaire */
double Kd_Ft_TotEstAmt ; /* montant total des primes comptabilisees estimees par affaire */
double Kd_Ft_RecAmt ;	/* montant de reconstitution reçu */
double Kd_Ft_BcAmt ;	/* montant de burning cost reçu */
double Kd_Tmp_Bilan ;	/* MOD03 - Taux Mini de BC * Assiette de Prime * Part SCOR */
char Ksz_GtBcRec_TrnCod[9] ; /* poste comptable ecrit en sortie dans le GT */
double Kd_Ft_Shr ; 	/* Part Scor provenant du fichier de travail */
int Kn_Ft_PrmNbr ;	/* nombre de lignes de primes "10000" estimee et cedante pour une affaire */


int n_InitPerUw	 		( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw		( char **pbd_InRec_Cur ) ;

int n_InitUlt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneUlt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncUlt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;






int n_InitGtIbnr			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtIbnr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtIbnr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtCum			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtCum		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtCum	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPerFr			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePerFr		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1PerFr			( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptPerFr	( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitFt			( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneFt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncFt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1Ft			( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionFirstRuptFt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLastRuptFt		( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
			T_RUPTURE_SYNC_VAR  *pbd_Rupt,
			char **ptb_InRecOwner );

int n_InitVariables( void ) ;
int n_CopyFt( char **ptb_InRecChild, T_FTBC *pbd_Ft ) ;
int n_WriteGtBcRec( FILE *Kp_OuputFil, char **ptb_InRecOwner ) ;
int n_InsertTabFt( T_FTBC *pbd_Ft, char **ptb_InRecOwner ) ;
int n_UpdateTabFt( T_FTBC *pbd_Ft, char **ptb_InRecOwner, int l ) ;
int n_WriteFt( FILE *Kp_OuputFil, T_FTBC *pbd_Ft, int l ) ;

enum TARIF_PREMIUM_TYPE { FLAT_PREMIUM=0, DEPOSIT_PREMIUM };
double GetPremium( char **pbd_PER_enr, int  iTarifPremium);

#define ZERO 0.001  // [014]

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

	/* recuperation du libelle d'inventaire passe en argument */
	strcpy( Ksz_CloDat, psz_GetCharArgv( 1 ) ) ;
	// strcpy( Ksz_CloDat, argv[1]) ;

	/* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
	sscanf( Ksz_CloDat, "%4s%2s%2s", Annee_bilan, Mois_bilan, Jour_bilan ) ;
	/* ouverture du fichier de sortie GT des primes de reconstitutions et Burning Cost estimees */
	if ( n_OpenFileAppl ( "ESTC1015_O1","wt",&Kp_OutputFilGtBcRec ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* ouverture du fichier de sortie Fichier de travail */
	if ( n_OpenFileAppl ( "ESTC1015_O2","wt",&Kp_OutputFilFt ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* MOD04 - ouverture du fichier en entree FCURQUOT */
	if ( n_OpenFileAppl ( "ESTC1015_I7","rb",&Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;
   if(n_initCalculExerciceSeuil("ESTC1015_I8"))
       	ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerUw */
	if ( n_InitPerUw( &bd_RuptPerUw ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptUlt */
	if ( n_InitUlt( &bd_RuptUlt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptFt */
	if ( n_InitFt( &bd_RuptFt ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtCum */
	if ( n_InitGtCum( &bd_RuptGtCum ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptGtIbnr */
	if ( n_InitGtIbnr( &bd_RuptGtIbnr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* Initialisation de la variable bd_RuptPerFr */
	if ( n_InitPerFr( &bd_RuptPerFr ) )
		ExitPgm( ERR_XX , "" ) ;

	/* lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat */
	if ( n_ProcessingRuptureVar( &bd_RuptPerUw ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I2", &( bd_RuptPerFr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I3", &( bd_RuptGtIbnr.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I4", &( bd_RuptGtCum.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I5", &( bd_RuptFt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_I6", &( bd_RuptUlt.pf_InputFil ) ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	/* MOD04 - Fermeture du fichier en entree FCURQUOT */
	if ( n_CloseFileAppl( "ESTC1015_I7", &Kp_InputFilExc ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_O1", &Kp_OutputFilGtBcRec ) == ERR )
		ExitPgm( ERR_XX , "" ) ;

	if ( n_CloseFileAppl( "ESTC1015_O2", &Kp_OutputFilFt ) == ERR )
		ExitPgm( ERR_XX , "" );

	if ( n_EndPgm() == ERR )
		ExitPgm( ERR_XX , "" );
 n_finCalculSeuil();
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
	if ( n_OpenFileAppl( "ESTC1015_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
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
	char	sz_DateDiff[9] ; /* date correspondant au libelle inventaire + decalage */
	char	MsgAno[300] ; /* message d'anomalie */
	int	n_compteur ;
	int	b_calculprimerec ; /* bit pour savoir si on fait un calcul de prim de reconstit */
	double  d_PrvPrm = 0; /* MOD04 - prime provisionnelle */
	char	c_Ssd = 0 ;		  /* MOD04 - filiale */
	int	n_Uwy = 0 ;		    /* MOD04 - exercice */
  double Kd_Tx_BC=0; 	  /* MOD04 - Montant Primes BC */
  double Kd_Tx_Prov=0; 	/* MOD04 - Montant Primes Provisionnelles */
  int n_Check_Prov=0; 	/* MOD04 - Flag (1-0) d'écritures de la Prime  */
  int ret;

	DEBUT_FCT( "n_ActionLignePerUw" ) ;

	/* initialisation de la variable de participation des fichiers */
	Kn_Pa = 0 ;

	/* Initialisation du bit de calcul de prime de recons */
	b_calculprimerec=1;

	/* initialisation des variables de travail */
	n_InitVariables( ) ;

	/* synchronisation avec le fichier annexe Perimetre de souscription */
	n_ProcessingRuptureSyncVar( &bd_RuptPerFr, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier GT des IBNR */
	n_ProcessingRuptureSyncVar( &bd_RuptGtIbnr, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier GT cumule sur sinistres */
	n_ProcessingRuptureSyncVar( &bd_RuptGtCum, ptb_InRec_Cur ) ;

	/* synchronisation avec le fichier de travail */
	n_ProcessingRuptureSyncVar( &bd_RuptFt, ptb_InRec_Cur ) ;

	/* generation d'une anomalie si la taille du tableau "Ktbd_Ft" est insuffisante */
	if ( ( Kn_FtNum - 1 ) > NB_FT_MAX )
	{
		sprintf( MsgAno, "Le nombre de lignes du fichier de travail liees a l'affaire (Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s) depasse la capacite de calcul",
			ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF],
			ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT] ) ;

                /* Modif 28/01/98 : ecriture dans le .ano au lieu du .log */
		/* n_WriteLog ( 'E', MsgAno ) ;*/
		n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMLIE */

		RETURN_VAL( ERR ) ;
	}

	/* synchronisation avec le fichier Primes et sinistres ultimes */
	n_ProcessingRuptureSyncVar( &bd_RuptUlt, ptb_InRec_Cur ) ;

/* Modif du 16/12/98 (Y.Bourdaillet) */
/* A-t-on du prorata temporis pour cette affaire ? */
/* Si oui on ne passe pas par la fonction de calcul de prime de reconstitution */
/* En cas de modif : les reporter sur les procs utilisées par PB */
/* Voir estserv.c et n_CalculPrimeReconstitution */
	for (n_compteur = 0; n_compteur < Kn_RecRnk; n_compteur++)
	{ if(Ktbd_Rec[n_compteur].REIPROTMP_B == 1 ||
		 ( strncmp(ptb_InRec_Cur[PER_CTR_NF],"11T000",6) == 0 &&
		    strstr("021_022_172_302_303_326",ptb_InRec_Cur[PER_CTR_NF] +6) != 0) ||
		  ( strncmp(ptb_InRec_Cur[PER_CTR_NF],"11Z090",6) == 0 &&
		    strstr("262_384_385_454_455_456_508_510_550_551_630_635_298_634_535",ptb_InRec_Cur[PER_CTR_NF] +6) != 0)
) b_calculprimerec=0; }

	/* calcul de la periode de compte et de l'annee de compte */
	n_AddMonths( sz_DateDiff, ( -1 * atoi( ptb_InRec_Cur[ PER_DIFMTH_NF ] ) ), '-', Ksz_CloDat ) ;
	sscanf( sz_DateDiff, "%4s%2s", Ksz_GtBcRec_Acy, Ksz_GtBcRec_ScoStrMth ) ;
	strcpy( Ksz_GtBcRec_ScoEndMth, Ksz_GtBcRec_ScoStrMth ) ;


/* -----------------------------------------------------------------------------------------------------
    Début MOD04 - M.DJELLOULI - 28/07/2005
    -----------------------------------------------------------------------------------------------------
    1. Calcul de la Prime Minimum (Previsionnelle) exprimée en Devise Aliment             = d_PrvPrm
    2. Calcul de la Prime Minimum : Taux Chargé * Assiette * part Scor (Burning Cost)   = Kd_Tx_BC
    3. Calcul de la Prime Minimum  (Previsionnelle) à la Part Scor                                = Kd_Tx_Prov
    4. Comparaison des Montants 2 et 3 : (n_Check_Prov = 1, on écrit) tel que :
                    .Si Kd_Tx_BC < Kd_Tx_Prov : aucune écriture du Poste 11101302 dans le GT
*/
	c_Ssd = (char) atoi( ptb_InRec_Cur[PER_SSD_CF] ) ;
	n_Uwy = atoi( ptb_InRec_Cur[PER_UWY_NF] ) ;

/*    1. Prime Minimum (Previsionnelle) en monnaie aliment
	¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨                              */
	if ( *ptb_InRec_Cur[PER_CTRNAT_CT] == 'N' && *ptb_InRec_Cur[PER_PRVPRM_B] == '1' )
	{
		/* prime provisionnelle totale */
		d_PrvPrm = GetPremium(ptb_InRec_Cur, DEPOSIT_PREMIUM);
	}

/*   2. Calcul de la Prime Minimum : Taux Chargé * Assiette * part Scor
	¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨                         */
	Kd_Tx_BC = d_CalculBurningCost( (char)( atoi( ptb_InRec_Cur[PER_SUPLOATYP_CT] ) ),
		atof( ptb_InRec_Cur[PER_SBJPRM_M] ), ( Kd_GtIbnr_Amt + Kd_GtCum_Amt ),
		atof( ptb_InRec_Cur[PER_PRMMINEFF_R] ), atof( ptb_InRec_Cur[PER_PRMMAXEFF_R] ),
		atof( ptb_InRec_Cur[PER_PRMEFFLOA_M] ), atof( ptb_InRec_Cur[PER_PRMEFFLOA_R] ),
		atof( ptb_InRec_Cur[PER_CUTSHA_R] ), atof( ptb_InRec_Cur[PER_RIDSHA_R] ),
		(char)( atoi( ptb_InRec_Cur[PER_LIARIDSHA_B] ) ) ) ;


/*   3. Calcul de la Prime Minimum  (Previsionnelle) à la Part Scor
	¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨                         */
	Kd_Tx_Prov = d_PrvPrm * atof(ptb_InRec_Cur[PER_CUTSHA_R]) * atof(ptb_InRec_Cur[PER_RIDSHA_R]);

/*    4. Comparaison des Montants 2 et 3 : (n_Check_Prov = 1
	¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨                         */
	if ( Kd_Tx_BC > Kd_Tx_Prov )
	{
	    n_Check_Prov = 1 ;
	}

	// N'effectuer le Calcul que si ESTPRMTYP_CT n'est pas Cochée Manuelle ou Nulle      modif JMH 15/02/2006

	if ( atoi(ptb_InRec_Cur[PERExtend_ESTPRMTYP_CT]) == 0 || atoi(ptb_InRec_Cur[PERExtend_ESTPRMTYP_CT]) == 3 || ptb_InRec_Cur[PERExtend_ESTPRMTYP_CT] == NULL)
	{
	    n_Check_Prov = 0 ;
  }

// FIN MOD04 --------------------------------------------------------------------------------------
	/* lancement du traitement principal */
	/*************************************/
	if ( Kn_Pa == 9 || Kn_Pa == 11 || Kn_Pa == 13 || Kn_Pa == 15 ||
		Kn_Pa == 25 || Kn_Pa == 27 || Kn_Pa == 29 || Kn_Pa == 31 )
	{

//	if ( ( ret = strcmp( "01T000682", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
// printf("\n\n OOKKKKK\n\n") ;

//	if ( ( ret = strcmp( "01T000682", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
//{
//// printf("\n\n OOKKKKK inter de if\n\n") ;
//printf("\n\n PER_UWY_NF %s, ExerciceSeuilPreN %d\n\n", ptb_InRec_Cur[PER_UWY_NF],n_ erciceSeuilPreN( atoi( ptb_InRec_Cur[PER_SSD_CF] ) )) ;
//}
		/****************************************************************/
		/* Modifs du 06/05/98 - M.HA-THUC				*/
		/* On ne calcule pas de Burning cost ou de reconstit si 	*/
		/* l'exercice est strictement inferieur a l'exercice seuil.	*/
		/* L'exercice seuil est defini dans la fonction 		*/
		/* 	n_CalculExerciceSeuilPreN ( estserv.c )			*/
		/****************************************************************/
// spot 28140 Modificaiton   des parametres d'appel de la fonction n_CalculExerciceSeuil et test du flag sinistrailte		
		if (*ptb_InRec_Cur[PER_CTRNAT_CT] == 'N'
		    && !( (strncmp(ptb_InRec_Cur[PER_CTR_NF],"11T000",6) == 0 &&
		   	   strstr("021_022_172_302_303_326",ptb_InRec_Cur[PER_CTR_NF] +6) != 0) ||
		  	  (strncmp(ptb_InRec_Cur[PER_CTR_NF],"11Z090",6) == 0 &&
		       	   strstr("262_384_385_454_455_456_508_510_550_551_630_635_298_634_535",ptb_InRec_Cur[PER_CTR_NF] +6)!=0)
	           	)
	   	    &&( ( atoi( ptb_InRec_Cur[PER_UWY_NF] ) >= n_CalculExerciceSeuil( atoi( ptb_InRec_Cur[PER_SSD_CF] ),atoi(ptb_InRec_Cur[PER_ACCESB_CF]),ptb_InRec_Cur[PER_LOB_CF],atoi(ptb_InRec_Cur[PER_NAT_CF]) ) ) ||
	   	    *ptb_InRec_Cur[PER_SEGSA_B] == '1' ))
		{
//	if ( ( ret = strcmp( "01T000682", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
//{
//// printf("\n\n OOKKKKK inter de if\n\n") ;
//
//}
			/* si taux de prime variable */
			if ( *ptb_InRec_Cur[PER_PRMFLCRAT_B] == '1' )
			{
				/* si prime non forfaitaire */
				if ( *ptb_InRec_Cur[PER_FLAPRM_B] == '0' )
				{

                         // MOD002 - MDJ 23/05/2005 - Conditionnement du Calcul
                        // selon ESTREITYP_CT = 1 ou REIVAR_B = 1

					/* si il existe une ligne au moins une prime estimee
					ou cedante pour l'affaire en cours */
//					if ( Kc_Pe==1 && strcmp(ptb_InRec_Cur[PERExtend_ESTPRMTYP_CT], "1")!=0)
					if ( Kc_Pe==1 && n_Check_Prov==1 )
					{
						/*********************************************/
						/* appel du module de calcul de Burning Cost */
						/*********************************************/
						Kd_Pbc_Amt = d_CalculBurningCost( (char)( atoi( ptb_InRec_Cur[PER_SUPLOATYP_CT] ) ),
 							atof( ptb_InRec_Cur[PER_SBJPRM_M] ), ( Kd_GtIbnr_Amt + Kd_GtCum_Amt ),
							atof( ptb_InRec_Cur[PER_PRMMINEFF_R] ), atof( ptb_InRec_Cur[PER_PRMMAXEFF_R] ),
							atof( ptb_InRec_Cur[PER_PRMEFFLOA_M] ), atof( ptb_InRec_Cur[PER_PRMEFFLOA_R] ),
							atof( ptb_InRec_Cur[PER_CUTSHA_R] ), atof( ptb_InRec_Cur[PER_RIDSHA_R] ),
							(char)( atoi( ptb_InRec_Cur[PER_LIARIDSHA_B] ) ) ) ;

						/* affectation du poste comptable correspondant au Burning Cost */
						strcpy( Ksz_GtBcRec_TrnCod, "11101302" ) ;

						/* calcul du montant du fichier de sortie GT Primes de reconstitutions et de
		 				Burning Cost */
                                       // Début MOD03 - M.DJELLOULI - 28/07/2005 - Contionnement de Kd_GtBcRec_Amt sur Annee_Bilan
						// Kd_GtBcRec_Amt = Kd_Pbc_Amt - Kd_Ft_TotAmt - Kd_Ft_BcAmt ;
						if ( strcmp(ptb_InRec_Cur[PER_UWY_NF] , Annee_bilan) == 0)
						{
                                            Kd_Tmp_Bilan = atof( ptb_InRec_Cur[PER_PRMMINEFF_R]) * atof( ptb_InRec_Cur[PER_SBJPRM_M])  * atof(ptb_InRec_Cur[PER_CUTSHA_R]) * atof(ptb_InRec_Cur[PER_RIDSHA_R]);
        						Kd_GtBcRec_Amt = Kd_Pbc_Amt - Kd_Tmp_Bilan - Kd_Ft_BcAmt ;
        				       }
        				      else
        				      {
        						Kd_GtBcRec_Amt = Kd_Pbc_Amt - Kd_Ft_TotAmt - Kd_Ft_BcAmt ;
        				      }
                                       // Fin MOD03
						if ( atof( Ksz_CloDat ) > atof( ptb_InRec_Cur[PER_EXP_D] ) )
						{
							/* ecriture d'une ligne dans le fichier en sortie GT primes de reconstitutions
							 et de Burning Cost */
							if ( fabs( Kd_GtBcRec_Amt ) >= ZERO )
								n_WriteGtBcRec( Kp_OutputFilGtBcRec, ptb_InRec_Cur ) ;

							/* insertion d'une ligne supplementaire dans le tableau du fichier de travail
							par affaire */
							n_InsertTabFt( &Ktbd_Ft[ Kn_FtNum++ ], ptb_InRec_Cur ) ;
						}
						else
						{
							/* mise a jour du tableau du fichier de travail pour les lignes "primes estimees */
							n_UpdateTabFt( Ktbd_Ft, ptb_InRec_Cur, Kn_FtNum ) ;
						}
					}
				}
				else
				{
					/********************************************************/
					/* appel du module de calcul de Prime de reconstitution */
					/********************************************************/
					Kd_Rec_Amt = ( d_CalculPrimeReconstitution( (char)( atoi( ptb_InRec_Cur[PER_REIEXI_B] ) ),
						(char)( atoi( ptb_InRec_Cur[PER_REIUNL_B] ) ), (char)( atoi( ptb_InRec_Cur[PER_REIFRE_B] ) ),
						(char)( atoi( ptb_InRec_Cur[PER_REINBR_N] ) ), atof( ptb_InRec_Cur[PER_SBJPRM_M] ),
						( Kd_GtIbnr_Amt + Kd_GtCum_Amt ), Kd_Ult_RetAmtPrm, atof( ptb_InRec_Cur[PER_LAYCAP_M] ),
						atof( ptb_InRec_Cur[PER_CUTSHA_R] ), atof( ptb_InRec_Cur[PER_RIDSHA_R] ),
						(char)( atoi( ptb_InRec_Cur[PER_LIARIDSHA_B] ) ), Ktbd_Rec ) - Kd_Ult_RetAmtPrm ) ;

					/* affectation du poste comptable correspondant a la reconstitution */
					strcpy( Ksz_GtBcRec_TrnCod, "11101202" ) ;

                                // MOD002 - MDJ 23/05/2005 - Conditionnement du Calcul
                                // selon ESTREITYP_CT = 1 ou REIVAR_B = 1   -- Ou ESTREITYP_CT = NULL (24/10/2005)
                                if (atoi(ptb_InRec_Cur[PERExtend_ESTREITYP_CT])==3 || ptb_InRec_Cur[PERExtend_ESTREITYP_CT]==NULL || atoi(ptb_InRec_Cur[PERExtend_ESTREITYP_CT])==0 || atoi(ptb_InRec_Cur[PERExtend_REIVAR_B])==1)
                                {
                                  b_calculprimerec=0;
                                  if ( ( ret = strcmp( "10ZA02739", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
                                  {
                               		  printf( "( * 1 * Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s /ESTREITYP_CT %s /REIVAR_B %s )",
  			                            ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF],ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT], ptb_InRec_Cur[PERExtend_ESTREITYP_CT], ptb_InRec_Cur[PERExtend_REIVAR_B] );
                                  }
                                }

                                if (atoi(ptb_InRec_Cur[PER_REIEXI_B])==0 || atoi(ptb_InRec_Cur[PER_REIUNL_B])==1)
                                {
                                  if ( ( ret = strcmp( "10ZA02739", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
                                  {
                               		  printf( "( * 2 * Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s /REIEXI_B %s /REIUNL_B %s )",
  			                            ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF],ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT], ptb_InRec_Cur[PER_REIEXI_B], ptb_InRec_Cur[PER_REIUNL_B] );
                                  }
                                  b_calculprimerec=0;
                                }

					/* calcul du montant du fichier de sortie GT Primes de reconstitutions et de
				 	Burning Cost */
					if (b_calculprimerec == 1) Kd_GtBcRec_Amt = Kd_Rec_Amt - Kd_Ft_RecAmt ;
					else Kd_GtBcRec_Amt = 0;

					/* ecriture d'une ligne dans le fichier en sortie GT primes de reconstitutions
					 et de Burning Cost */
					if ( fabs( Kd_GtBcRec_Amt ) >= ZERO )
						n_WriteGtBcRec( Kp_OutputFilGtBcRec, ptb_InRec_Cur ) ;

					/* insertion d'une ligne supplementaire dans le tableau du fichier de travail
					par affaire */
					n_InsertTabFt( &Ktbd_Ft[ Kn_FtNum++ ], ptb_InRec_Cur ) ;
				}
			}
			else
			{
				/********************************************************/
				/* appel du module de calcul de Prime de reconstitution */
				/********************************************************/
				Kd_Rec_Amt = ( d_CalculPrimeReconstitution( (char)( atoi( ptb_InRec_Cur[PER_REIEXI_B] ) ),
					(char)( atoi( ptb_InRec_Cur[PER_REIUNL_B] ) ), (char)( atoi( ptb_InRec_Cur[PER_REIFRE_B] ) ),
					(char)( atoi( ptb_InRec_Cur[PER_REINBR_N] ) ), atof( ptb_InRec_Cur[PER_SBJPRM_M] ),
					( Kd_GtIbnr_Amt + Kd_GtCum_Amt ), Kd_Ult_RetAmtPrm, atof( ptb_InRec_Cur[PER_LAYCAP_M] ),
					atof( ptb_InRec_Cur[PER_CUTSHA_R] ), atof( ptb_InRec_Cur[PER_RIDSHA_R] ),
					(char)( atoi( ptb_InRec_Cur[PER_LIARIDSHA_B] ) ), Ktbd_Rec ) - Kd_Ult_RetAmtPrm ) ;

				/* affectation du poste comptable correspondant a la reconstitution */
				strcpy( Ksz_GtBcRec_TrnCod, "11101202" ) ;

                        // MOD002 - MDJ 23/05/2005 - Conditionnement du Calcul
                        // selon ESTREITYP_CT = 1 ou REIVAR_B = 1
                        if (atoi(ptb_InRec_Cur[PERExtend_ESTREITYP_CT])==3 || ptb_InRec_Cur[PERExtend_ESTREITYP_CT]==NULL || atoi(ptb_InRec_Cur[PERExtend_ESTREITYP_CT])==0 || atoi(ptb_InRec_Cur[PERExtend_REIVAR_B])==1)
                        {
                          b_calculprimerec=0;
                          if ( ( ret = strcmp( "10ZA02739", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
                          {
                               		  printf( "( * 3 * Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s /ESTREITYP_CT %s /REIVAR_B %s )",
  			                            ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF],ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT], ptb_InRec_Cur[PERExtend_ESTREITYP_CT], ptb_InRec_Cur[PERExtend_REIVAR_B] );
                          }
                        }

                        if (atoi(ptb_InRec_Cur[PER_REIEXI_B])==0 || atoi(ptb_InRec_Cur[PER_REIUNL_B])==1)
                        {
                           if ( ( ret = strcmp( "10ZA02739", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
                              {
                               		  printf( "( * 4 * Contrat %s /Avenant %s /Section %s /Exercice %s /Numero ex %s /REIEXI_B %s /REIUNL_B %s )",
  			                            ptb_InRec_Cur[PER_CTR_NF], ptb_InRec_Cur[PER_END_NT], ptb_InRec_Cur[PER_SEC_NF],ptb_InRec_Cur[PER_UWY_NF], ptb_InRec_Cur[PER_UW_NT], ptb_InRec_Cur[PER_REIEXI_B], ptb_InRec_Cur[PER_REIUNL_B] );
                              }
                          b_calculprimerec=0;
                        }
				/* calcul du montant du fichier de sortie GT Primes de reconstitutions et de
				 Burning Cost */
				if (b_calculprimerec == 1) Kd_GtBcRec_Amt = Kd_Rec_Amt - Kd_Ft_RecAmt ;
				else Kd_GtBcRec_Amt = 0;

				/* ecriture d'une ligne dans le fichier en sortie GT primes de reconstitutions
				 et de Burning Cost */
				if ( fabs( Kd_GtBcRec_Amt ) >= ZERO )
					n_WriteGtBcRec( Kp_OutputFilGtBcRec, ptb_InRec_Cur ) ;

				/* insertion d'une ligne supplementaire dans le tableau du fichier de travail
				par affaire */
				n_InsertTabFt( &Ktbd_Ft[ Kn_FtNum++ ], ptb_InRec_Cur ) ;
			}

			/* ecriture dans le fichier en sortie de travail */
			n_WriteFt( Kp_OutputFilFt, Ktbd_Ft, Kn_FtNum ) ;
		}
		else
		{
//	if ( ( ret = strcmp( "01T000682", ptb_InRec_Cur[PER_CTR_NF] ) ) == 0 )
// printf("\n\n OOKKKKK inter de else\n\n") ;
			/* reconduction du fichier de travail en sortie */
			n_WriteFt( Kp_OutputFilFt, Ktbd_Ft, Kn_FtNum ) ;
		}
	}

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l’esclave « Primes et sinistres ultimes »

retour :
	OK
==============================================================================*/
int n_InitUlt( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitUlt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Primes et sinistres ultimes */
	if ( n_OpenFileAppl( "ESTC1015_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncUlt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneUlt ;

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
int n_ConditionSyncUlt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncUlt" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[ULT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[ULT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[ULT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[ULT_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[ULT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneUlt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneUlt" ) ;

	/* Positionnement de la variable de participation */
	Kn_Pa += 1 ;

	/* Affectation de la variable de travail: montant de prime ultime */
	Kd_Ult_RetAmtPrm = atof( ptb_InRecChild[ULT_RETAMTPRM_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription »
	avec l'esclave « GT des IBNR »

retour :
	OK
==============================================================================*/
int n_InitGtIbnr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtIbnr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave Mouvements comptables */
	if ( n_OpenFileAppl( "ESTC1015_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
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
int n_ActionLigneGtIbnr(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneSyncGtIbnr" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 2 ;

	/* Affectation de la variable de travail: montant de sinistre IBNR */
	Kd_GtIbnr_Amt = atof( ptb_InRecChild[GTE_AMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « GT cumule selectionne sur sinistres »

retour :
	OK
==============================================================================*/
int n_InitGtCum(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitGtCum" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT cumule sur sinistres */
	if ( n_OpenFileAppl( "ESTC1015_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

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
	DEBUT_FCT( "n_ActionLigneGtCum" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 4 ;

	/* Affectation de la variable de travail: montant de sinistres comptabilises */
	Kd_GtCum_Amt = atof( ptb_InRecChild[GTE_ACMAMT_M] ) ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « Fichier de travail »

retour :
	OK
==============================================================================*/
int n_InitFt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitFt" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT cumule sur sinistres */
	if ( n_OpenFileAppl( "ESTC1015_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1Ft ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncFt ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptFt ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLigneFt ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptFt ;

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
int n_ConditionSyncFt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncFt" ) ;



	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[FT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[FT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[FT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[FT_UWYDIS_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[FT_UW_NT] ) ) != 0 ) return ret ;

//	if ( ( ret = strcmp( "01T000682", pbd_InRecChild[FT_CTR_NF] ) ) == 0 )
// printf("\n\n OOKKKKK22222222222\n\n") ;
	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1Ft(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1Ft" ) ;

	if ( ( ret = strcmp( pbd_InRec[FT_CTR_NF], pbd_InRec_Cur[FT_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_END_NT], pbd_InRec_Cur[FT_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_SEC_NF], pbd_InRec_Cur[FT_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_UWYDIS_NF], pbd_InRec_Cur[FT_UWYDIS_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[FT_UW_NT], pbd_InRec_Cur[FT_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptFt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFirstRuptFt" ) ;

	/* Initialisation des variables */
 	Kn_FtNum = 0 ; 		/* numero de poste du tableau */
	Kd_Ft_TotAmt = 0 ; 	/* montant total de primes comptabilisees */
	Kc_Pe = 0 ; 		/* initialisation du flag Kc_Pe */
	Kd_Ft_RecAmt = 0 ; 	/* initialisation du montant de reconstitution reçu */
	Kd_Ft_BcAmt = 0 ;  	/* initialisation du montant de burning cost reçu */
	Kn_Ft_PrmNbr = 0 ; 	/* nombre de lignes de prime "10000" estimee et reçue */
	Kd_Ft_TotEstAmt = 0 ;	/* initialisation du montant de prime estimee */


	/* affectation de la Part Scor */
	Kd_Ft_Shr = atof( pbd_InRecChild[FT_SHR_R] ) ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFt(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLigneFt" ) ;

	/* traitement lance pour les lignes ou le poste de prime = PRIME (10000) */
	if ( strcmp( ptb_InRecChild[ FT_WFCOD_NT ], "10000" ) == 0 )
	{
		/* Cumul du montant total de primes comptabilisees reçues et estimees */
		Kd_Ft_TotAmt += atof( ptb_InRecChild[FT_PRM_M] ) ;

		/* Cumul du montant total de reconstitution reçue ou cedante */
		Kd_Ft_RecAmt += atof( ptb_InRecChild[FT_RECC_M] ) ;

		/* Cumul du montant total de reconstitution reçue ou cedante */
		Kd_Ft_BcAmt += atof( ptb_InRecChild[FT_BCC_M] ) ;

		/* Positionnement du flag Kc_Pe = 1 si il existe au moins une prime estimee
		ou reçue dans le fichier de travail pour l'affaire consideree */
		Kc_Pe = 1 ;

		/* calcul du nombre de lignes de poste de prime "10000", estimee et reçue
		dont le montant est non nulle */
		if ( atof( ptb_InRecChild[FT_PRM_M] ) != 0 )
			Kn_Ft_PrmNbr += 1 ;
	}

	/* Affectation du tableau contenant les lignes du Fichier de travail par affaire */
	n_CopyFt( ptb_InRecChild, &Ktbd_Ft[ Kn_FtNum++ ]) ;

//	if ( ( ret = strcmp( "01T000682", ptb_InRecChild[FT_CTR_NF] ) ) == 0 )
//{
//// printf("\n\n OOKKKKK\n\n") ;
//printf("\n%f\n",Kd_Ft_TotAmt) ;
//}
	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptFt(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLastRuptFt" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 8 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre « Perimetre de souscription » avec
	l'esclave « fichier annexe du Perimetre de souscription IADPERIFR.dat »

retour :
	OK
==============================================================================*/
int n_InitPerFr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT( "n_InitPerFr" ) ;

	memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

	/* ouverture du fichier esclave GT cumule sur sinistres */
	if ( n_OpenFileAppl( "ESTC1015_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
		return ERR ;

	/* nombre de rupture a gerer sur le fichier de travail */
	pbd_Rupt->n_NbRupture = 1 ;

	/* fonction du test de rupture de niveau 1 */
	pbd_Rupt->n_ConditionRupture[0] = n_IsR1PerFr ;

	/* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync = n_ConditionSyncPerFr ;

	/* fonction lancee en rupture premiere */
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPerFr ;

	/* fonction d'action sur la ligne courante */
	pbd_Rupt->n_ActionLigne = n_ActionLignePerFr ;

	/* Fonction lancee en rupture derniere */
	pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPerFr ;

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
int n_ConditionSyncPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	int ret ;

	DEBUT_FCT( "n_ConditionSyncPerFr" ) ;

	if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PERFR_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PERFR_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de test de rupture de niveau 1

retour :
	0	---> pas de rupture
	sinon   	---> rupture
==============================================================================*/
int n_IsR1PerFr(
	char **pbd_InRec ,  /* adresse de la ligne en avance */
	char **pbd_InRec_Cur  ) /* adresse de la ligne courante */
{
	int ret ;

	DEBUT_FCT( "n_IsR1PerFr" ) ;

	if ( ( ret = strcmp( pbd_InRec[PERFR_CTR_NF], pbd_InRec_Cur[PERFR_CTR_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_END_NT], pbd_InRec_Cur[PERFR_END_NT] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_SEC_NF], pbd_InRec_Cur[PERFR_SEC_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UWY_NF], pbd_InRec_Cur[PERFR_UWY_NF] ) ) != 0 ) return ret ;
	if ( ( ret = strcmp( pbd_InRec[PERFR_UW_NT], pbd_InRec_Cur[PERFR_UW_NT] ) ) != 0 ) return ret ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture premiere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionFirstRuptPerFr" ) ;

	/* initialisation de la variable du rang de reconstitution */
	Kn_RecRnk = 0 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerFr(
	char **ptb_InRecOwner , /* adresse de la ligne du maitre */
	char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLignePerFr" ) ;

	/* Affectation des postes du tableau de reconstitution par affaire */
	Ktbd_Rec[Kn_RecRnk].REIRNK_N = (char)( atoi( ptb_InRecChild[ PERFR_REIRNK_N ] ) ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRMBAS_R = atof( ptb_InRecChild[ PERFR_REIPRMBAS_R ] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRM_M = atof( ptb_InRecChild[ PERFR_REIPRM_M] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPRM_R = atof( ptb_InRecChild[ PERFR_REIPRM_R ] ) ;
	Ktbd_Rec[Kn_RecRnk].REIPROTMP_B = (char)( atoi( ptb_InRecChild[ PERFR_REIPROTMP_B ] ) ) ;
	
	if (strcmp(ptb_InRecChild[ PERFR_REIPRMPTP_R ], "") != 0)
		Ktbd_Rec[Kn_RecRnk].REIPRMPTP_R = atof( ptb_InRecChild[ PERFR_REIPRMPTP_R ]) ;      //[015]	 
	else 
	  Ktbd_Rec[Kn_RecRnk].REIPRMPTP_R = 1; //PERFR_REIPRMPTP_R est null alors positionne a 1 pour calcul du RIP 

	/* incrementation du nombre de poste du tableau */
	Kn_RecRnk += 1 ;

	RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
	fonction lancee en rupture derniere

retour :	OK ---> traitement correctement effectue
		ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerFr(
	char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
	char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
	DEBUT_FCT( "n_ActionLastRuptPerFr" ) ;

	/* Positionnememt de la variable de participation */
	Kn_Pa += 16 ;

	RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
	fonction d'initialisation des variables de travail

	retour :	0

==============================================================================*/
int n_InitVariables( void )

{
	DEBUT_FCT( "n_InitVariables" ) ;

	Kd_Ult_RetAmtPrm = 0 ;
	Kd_GtIbnr_Amt = 0 ;
	Kd_GtCum_Amt = 0 ;
	memset( Ktbd_Rec, 0, ( NB_REC_MAX * sizeof( T_LIGNEREC ) ) ) ;
	memset( Ktbd_Ft, 0, ( NB_FT_MAX * sizeof( T_FTBC ) ) ) ;
	Kd_Rec_Amt = 0 ;
	Kd_Pbc_Amt = 0 ;
	*Ksz_GtBcRec_ScoStrMth = '\0' ;
	*Ksz_GtBcRec_ScoEndMth = '\0' ;
	*Ksz_GtBcRec_Acy = '\0' ;
	Kd_GtBcRec_Amt = 0 ;
	*Ksz_GtBcRec_TrnCod = '\0' ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de copie des rubriques du Fichier de travail vers une variable intermediaire

retour :	0

==============================================================================*/
int n_CopyFt(
	char **ptb_InRecChild, /* adresse de la ligne courante du Fichier de travail */
	T_FTBC *pbd_Ft ) /* adresse de la variable intermediaire Fichier de travail */
{
	DEBUT_FCT( "n_CopyFt" ) ;

	strcpy( pbd_Ft->CLODAT_D, ptb_InRecChild[FT_CLODAT_D] ) ;
	strcpy( pbd_Ft->CTR_NF, ptb_InRecChild[FT_CTR_NF] ) ;
	pbd_Ft->END_NT = (char)( atoi( ptb_InRecChild[FT_END_NT] ) ) ;
	pbd_Ft->SEC_NF = (char)( atoi( ptb_InRecChild[FT_SEC_NF] ) ) ;
	pbd_Ft->UWY_NF = atoi( ptb_InRecChild[FT_UWY_NF] ) ;
	pbd_Ft->UW_NT = (char)( atoi( ptb_InRecChild[FT_UW_NT] ) ) ;
	strcpy( pbd_Ft->ACY_NF, ptb_InRecChild[FT_ACY_NF] ) ;
	strcpy( pbd_Ft->SCOSTRMTH_NF, ptb_InRecChild[FT_SCOSTRMTH_NF] ) ;
	strcpy( pbd_Ft->SCOENDMTH_NF, ptb_InRecChild[FT_SCOENDMTH_NF] ) ;
	pbd_Ft->UWYDIS_NF = atoi( ptb_InRecChild[FT_UWYDIS_NF] ) ;
	pbd_Ft->SSD_CF = (char)( atoi( ptb_InRecChild[FT_SSD_CF] ) ) ;
	strcpy( pbd_Ft->WFCOD_NT, ptb_InRecChild[FT_WFCOD_NT] ) ;
	pbd_Ft->WFTYP_CF = *ptb_InRecChild[FT_WFTYP_CF] ;
	strcpy( pbd_Ft->EGPCUR_CF, ptb_InRecChild[FT_EGPCUR_CF] ) ;
	pbd_Ft->PRM_M = atof( ptb_InRecChild[FT_PRM_M] ) ;
	pbd_Ft->PPNAC_M = atof( ptb_InRecChild[FT_PPNAC_M] ) ;
	pbd_Ft->PPNAEA_M = atof( ptb_InRecChild[FT_PPNAEA_M] ) ;
	pbd_Ft->RPPC_M = atof( ptb_InRecChild[FT_RPPC_M] ) ;
	pbd_Ft->RPPEA_M = atof( ptb_InRecChild[FT_RPPEA_M] ) ;
	pbd_Ft->LPPNAC_M = atof( ptb_InRecChild[FT_LPPNAC_M] ) ;
	pbd_Ft->EPPC_M = atof( ptb_InRecChild[FT_EPPC_M] ) ;
	pbd_Ft->EPPEA_M = atof( ptb_InRecChild[FT_EPPEA_M] ) ;
	pbd_Ft->RECC_M = atof( ptb_InRecChild[FT_RECC_M] ) ;
	pbd_Ft->RECE_M = atof( ptb_InRecChild[FT_RECE_M] ) ;
	pbd_Ft->BCC_M = atof( ptb_InRecChild[FT_BCC_M] ) ;
	pbd_Ft->BCE_M = atof( ptb_InRecChild[FT_BCE_M] ) ;
	pbd_Ft->SHR_R = atof( ptb_InRecChild[FT_SHR_R] ) ;
	pbd_Ft->ACCADMTYP_CT = (char)( atoi( ptb_InRecChild[FT_ACCADMTYP_CT] ) ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier GT Primes de reconstitution et de Burning Cost
en sortie

retour :	0

==============================================================================*/
int n_WriteGtBcRec( FILE *Kp_OuputFil, char **ptb_InRecOwner )
{
	DEBUT_FCT( "n_WriteGtBcRec" ) ;
/*ajout une colonne pour retintamt_m */
	fprintf( Kp_OuputFil, "%s~%s~%s~%s~%s~%s~~%s~%s~%s~%s~%s~%s~%s~%d~%d~~%s~%-.3f~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~\n",
		ptb_InRecOwner[PER_SSD_CF], ptb_InRecOwner[PER_ACCESB_CF], Annee_bilan, Mois_bilan, Jour_bilan, Ksz_GtBcRec_TrnCod, ptb_InRecOwner[PER_CTR_NF],
		ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF], ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT], ptb_InRecOwner[PER_UWY_NF],
		Ksz_GtBcRec_Acy, atoi( Ksz_GtBcRec_ScoStrMth ), atoi( Ksz_GtBcRec_ScoEndMth ), ptb_InRecOwner[PER_EGPCUR_CF], Kd_GtBcRec_Amt, ptb_InRecOwner[PER_CED_NF],
		 ptb_InRecOwner[PER_PRD_NF], ptb_InRecOwner[PER_GENPRMPAY_NF], ptb_InRecOwner[PER_GANPAYORD_NT] ) ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'insertion d'une ligne supplementaire dans le tableau du
Fichier de travail

retour :	0

==============================================================================*/
int n_InsertTabFt( T_FTBC *pbd_Ft, char **ptb_InRecOwner )
{
	DEBUT_FCT( "n_InsertTabFt" ) ;

	strcpy( pbd_Ft->CLODAT_D, Ksz_CloDat ) ;
	strcpy( pbd_Ft->CTR_NF, ptb_InRecOwner[PER_CTR_NF] ) ;
	pbd_Ft->END_NT = (char)( atoi( ptb_InRecOwner[PER_END_NT] ) ) ;
	pbd_Ft->SEC_NF = (char)( atoi( ptb_InRecOwner[PER_SEC_NF] ) ) ;
	pbd_Ft->UWY_NF = atoi( ptb_InRecOwner[PER_UWY_NF] ) ;
	pbd_Ft->UW_NT = (char)( atoi( ptb_InRecOwner[PER_UW_NT] ) ) ;
	strcpy( pbd_Ft->ACY_NF, Ksz_GtBcRec_Acy ) ;
	strcpy( pbd_Ft->SCOSTRMTH_NF, Ksz_GtBcRec_ScoStrMth ) ;
	strcpy( pbd_Ft->SCOENDMTH_NF,Ksz_GtBcRec_ScoEndMth ) ;
	pbd_Ft->UWYDIS_NF = atoi( ptb_InRecOwner[PER_UWY_NF] ) ;
	pbd_Ft->SSD_CF = (char)( atoi( ptb_InRecOwner[PER_SSD_CF] ) ) ;
	strcpy( pbd_Ft->WFCOD_NT, "10000" ) ;
	pbd_Ft->WFTYP_CF = 'E' ;
	strcpy( pbd_Ft->EGPCUR_CF, ptb_InRecOwner[PER_EGPCUR_CF] ) ;
	pbd_Ft->PRM_M = 0 ;
	pbd_Ft->SHR_R = Kd_Ft_Shr ;
	pbd_Ft->ACCADMTYP_CT = (char)( atoi( ptb_InRecOwner[PER_ACCADMTYP_CT] ) ) ;

	if ( *ptb_InRecOwner[PER_PRMFLCRAT_B] == '1' )
		/* si appel de la fonction de calcul de Burnig Cost */
		pbd_Ft->BCE_M = Kd_GtBcRec_Amt ;
	else
		/* si appel de la fonction de calcul de reconstitution */
		pbd_Ft->RECE_M = Kd_GtBcRec_Amt ;

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction de mise a jour d'une ligne dans le tableau du Fichier de travail

retour :	0

==============================================================================*/
int n_UpdateTabFt( T_FTBC *pbd_Ft, char **ptb_InRecOwner, int l )
{
	int i ;
	double d_GtBcRec_Amt ;

	DEBUT_FCT( "n_UpdateTabFt" ) ;

	/* memorisation du montant de BC - montant total primes comptabilisees - montant total de BC reçu */
	d_GtBcRec_Amt = Kd_GtBcRec_Amt ;

	for ( i = 0; i < l; i++ )
	{
		if ( strcmp( pbd_Ft[i].WFCOD_NT, "10000" ) == 0 )
		{
			if ( Kd_Ft_TotAmt == 0 )
			{
				if ( pbd_Ft[i].PRM_M != 0 )
					pbd_Ft[i].BCE_M = d_GtBcRec_Amt / Kn_Ft_PrmNbr ;
				else
					pbd_Ft[i].BCE_M = 0 ;
			}
			else
				pbd_Ft[i].BCE_M = ( d_GtBcRec_Amt * pbd_Ft[i].PRM_M ) / Kd_Ft_TotAmt ;
			Kd_GtBcRec_Amt = pbd_Ft[i].BCE_M ;
			strcpy( Ksz_GtBcRec_Acy, pbd_Ft[i].ACY_NF ) ;
			strcpy( Ksz_GtBcRec_ScoStrMth, pbd_Ft[i].SCOSTRMTH_NF ) ;
			strcpy( Ksz_GtBcRec_ScoEndMth, pbd_Ft[i].SCOENDMTH_NF ) ;

			/* ecriture de la ligne dans le fichier GT en sortie */
			if ( fabs( Kd_GtBcRec_Amt ) >= ZERO )
				n_WriteGtBcRec( Kp_OutputFilGtBcRec, ptb_InRecOwner ) ;
		}
	}

	RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
	fonction d'ecriture dans le fichier de travail en sortie

retour :	0

==============================================================================*/
int n_WriteFt( FILE *Kp_OuputFil, T_FTBC *pbd_Ft, int l )
{
	int i ;

	DEBUT_FCT( "n_WriteFt" ) ;

	for ( i = 0; i < l; i++ )
	{
		// [009]
		fprintf( Kp_OuputFil, "%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%d~%s~%c~%s~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.3f~%-.8f~%d\n",
			pbd_Ft[i].CLODAT_D, pbd_Ft[i].CTR_NF, pbd_Ft[i].END_NT, pbd_Ft[i].SEC_NF, pbd_Ft[i].UWY_NF,
			pbd_Ft[i].UW_NT, pbd_Ft[i].ACY_NF, atoi( pbd_Ft[i].SCOSTRMTH_NF ), atoi( pbd_Ft[i].SCOENDMTH_NF ), pbd_Ft[i].UWYDIS_NF,
			pbd_Ft[i].SSD_CF, pbd_Ft[i].WFCOD_NT, pbd_Ft[i].WFTYP_CF, pbd_Ft[i].EGPCUR_CF, pbd_Ft[i].PRM_M,
			pbd_Ft[i].PPNAC_M, pbd_Ft[i].PPNAEA_M, pbd_Ft[i].RPPC_M, pbd_Ft[i].RPPEA_M, pbd_Ft[i].LPPNAC_M,
			pbd_Ft[i].EPPC_M, pbd_Ft[i].EPPEA_M, pbd_Ft[i].RECC_M, pbd_Ft[i].RECE_M, pbd_Ft[i].BCC_M,
			pbd_Ft[i].BCE_M, pbd_Ft[i].SHR_R, pbd_Ft[i].ACCADMTYP_CT ) ;
	}

	RETURN_VAL( 0 ) ;
}

double GetPremium(char **pbd_PER_enr, int  iTarifPremium)
{
	char	c_Ssd = 0;
	int	n_Uwy = 0;
	char	MsgAno[300];
	double d_Premium_temp = 0;
	double d_Ratio = 1;
	int i = 0;
	const int MAX_PREMIUM = 5;
	int iFlat_Premium[] = {PER_FLAPRM1_M, PER_FLAPRM2_M, PER_FLAPRM3_M, PER_FLAPRM4_M, PER_FLAPRM5_M};
	int iFlat_Currency[] = {PER_FLAPRMCU1_CF, PER_FLAPRMCU2_CF, PER_FLAPRMCU3_CF, PER_FLAPRMCU4_CF, PER_FLAPRMCU5_CF};
	int iDeposit_Premium[] = {PER_MINPRVPR1_M, PER_MINPRVPR2_M, PER_MINPRVPR3_M, PER_MINPRVPR4_M, PER_MINPRVPR5_M};
	int iDeposit_Currency[] = {PER_PRVPRMCU1_CF, PER_PRVPRMCU2_CF, PER_PRVPRMCU3_CF, PER_PRVPRMCU4_CF, PER_PRVPRMCU5_CF};
	char *pszTypePremium[] = {"Flat", "Deposit"};
	int *iptPremium;
	int *iptCurrency;
	double d_Premium = 0;

	if ( iTarifPremium == FLAT_PREMIUM )
	{
		iptPremium = iFlat_Premium;
		iptCurrency = iFlat_Currency;
	}
	else
	{
		iptPremium = iDeposit_Premium;
		iptCurrency = iDeposit_Currency;
	}

	c_Ssd = (char) atoi( pbd_PER_enr[PER_SSD_CF] ) ;
	n_Uwy = atoi( pbd_PER_enr[PER_UWY_NF] ) ;

	for (i = 0; i < MAX_PREMIUM; i++)
	{
		d_Premium_temp = atof(pbd_PER_enr[ iptPremium[i] ]);
		
		if ( strcmp(pbd_PER_enr[PER_EGPCUR_CF], pbd_PER_enr[ iptCurrency[i] ]) != 0 && d_Premium_temp != 0 )
		{
			d_Ratio = d_GetTaux(Kp_InputFilExc, c_Ssd, n_Uwy - 1, pbd_PER_enr[ iptCurrency[i] ], pbd_PER_enr[PER_EGPCUR_CF]);
		}
		else	d_Ratio = 1 ;

		/* generation d'une anomalie si pas de cours trouve */
		if ( d_Ratio < 0 )
		{
			sprintf( MsgAno, "The rates of EGPI currency ( %s ) and %s premium n°%d currency ( %s ) aren't known in %d for the contract ( CTR_NF %s - END_NT %s - SEC_NF %s - UWY_NF %s - UW_NT %s )\n",
				pbd_PER_enr[PER_EGPCUR_CF],pszTypePremium[iTarifPremium],i+1,pbd_PER_enr[ iptCurrency[i] ],n_Uwy - 1,pbd_PER_enr[PER_CTR_NF],pbd_PER_enr[PER_END_NT],pbd_PER_enr[PER_SEC_NF],pbd_PER_enr[PER_UWY_NF],pbd_PER_enr[PER_UW_NT]);

			n_WriteAno( MsgAno ) ;
			d_Premium_temp = 0 ;
		}
		else 	d_Premium_temp *= d_Ratio;

		d_Premium += d_Premium_temp;
	}

	if ( fabs(d_Premium) > 999999999999999.000) d_Premium = 999999999999999.000;

	return d_Premium;
}
