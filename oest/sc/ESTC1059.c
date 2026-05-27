/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1059.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : -=Dch=-
 References des specifications : SOLVENCY II
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
 Historique des modifications :
[002]  01/06/2012 	-=Dch=-  :spot:23937 SOLVENCY II
[003] 29/09/2012 R. Cassis :spot:24041  Solvency
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <estserv.h>
#include "ESTC1059.h"
#include <struct.h>
//à mettre après #include <struct.h>
#include "estutil.c"

/*------------*/
/* Constantes */
/*------------*/
const short ACM_PRESERVE_DISCOUNT = 310;
const short ACM_BAD_DEBT = 320;

T_RUPTURE_VAR Kbd_ruptRfrBatchIN; //Entree Maitre: ESTC1059_I1

// Variable de fichiers
FILE *Kp_OutputPRM;
FILE *Kp_OutputGTA;
FILE *Kp_OutputGTR;
FILE *Kp_InputPivot;
FILE *Kp_InputTRSLNK;
FILE *Kp_OutputANO;

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*--------------------------------------------*/
char gsz_clodat_d[9]; // Date de cloture Ex: 20111201
char gsz_annee[5], gsz_mois[3], gsz_jour[3];

/*--------------------------------------------------*/
/* Prototype des fonctions							*/
/*--------------------------------------------------*/
int n_InitRfrBatchIN(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRfrBatchIN(char **pbd_InRec_Cur);
int n_init_TRNCOD(int tflagRetro, const int ACM_PRESERVE_DISCOUNT, char *psz_NORME_CF, char *psz_DETTRS_CF);

/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
    // Initialisation des signaux
    InitSig () ;

    if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

  // Ouverture des fichiers binaires et des fichiers de sortie
	if (n_OpenFileAppl("ESTC1059_O1", "wt", &Kp_OutputPRM)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
	if (n_OpenFileAppl("ESTC1059_O2", "wt", &Kp_OutputGTA)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
	if (n_OpenFileAppl("ESTC1059_O3", "wt", &Kp_OutputGTR)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
	if (n_OpenFileAppl("ESTC1059_O4", "wt", &Kp_OutputANO)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );
	// TRSLNK est un fichier binaire
	if (n_OpenFileAppl("ESTC1059_I2", "rb", &Kp_InputTRSLNK)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du fichier de sortie." );


	// chargement de la date de clotûre fournie au programme
	strcpy(gsz_clodat_d, psz_GetCharArgv(1));
	sprintf(gsz_annee,"%.4s",gsz_clodat_d);
	sprintf(gsz_mois,"%.2s",&gsz_clodat_d[4]);
	sprintf(gsz_jour,"%.2s",&gsz_clodat_d[6]);

	// chargement des données du fichier binaire TRSLNK en memoire
	if ( n_ChargerTRSLNK(PRS_EBS_INVENT_ACCEP, Kp_InputTRSLNK) == -1 )
		ExitPgm( ERR_XX , "" ) ;

	// Initialisation des variables de gestion de ruptures
	if (n_InitRfrBatchIN(&Kbd_ruptRfrBatchIN)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");
	if (n_ProcessingRuptureVar(&Kbd_ruptRfrBatchIN) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

	// Fermeture des fichiers ouverts

	if (n_CloseFileAppl("ESTC1059_I1", &(Kbd_ruptRfrBatchIN.pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");
	if (n_CloseFileAppl("ESTC1059_O1", &Kp_OutputPRM)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");
	if (n_CloseFileAppl("ESTC1059_O2", &Kp_OutputGTA)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");
	if (n_CloseFileAppl("ESTC1059_O3", &Kp_OutputGTR)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");
	if (n_CloseFileAppl("ESTC1059_O4", &Kp_OutputANO)) ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier ESCOMPTE.");

	exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRfrBatchIN(T_RUPTURE_VAR  *pbd_Rupt)
{
     memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

     if (n_OpenFileAppl("ESTC1059_I1", "rt", &(pbd_Rupt->pf_InputFil)))
          return ERR;

     pbd_Rupt->n_NbRupture   = 0;
     pbd_Rupt->n_ActionLigne = n_ActionLigneRfrBatchIN;
     pbd_Rupt->c_Separ       = '~';

     return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneRfrBatchIN(char **pRec)
{
	static int n_last_col_FTSII = 0; //dernière colonnes du fichier FTSII en sortie
	static int col_filler1 = 0, col_annee = 0, col_mois = 0, col_jour = 0, col_amt_m = 0, col_retamt_m = 0, col_trncod_cf = 0, col_filler19_oricod = 0;
  FILE *fp_Output;
	double d_fpremium_m , d_ucr_r = 0, d_prco_m, d_prci_m, d_prmresd_m,  d_prmresb_m;  // colonnes calculées pour la sortie du fichier Pivot
	char sz_trncod[9] = "";
	int flagRetro = 0;
	char sz_fpremium_m[18] = "",sz_ucr_r[12] = "",sz_prco_m[18] = "",sz_prci_m[18] = "",sz_prmresd_m[18] = "",sz_prmresb_m[18] = ""

	DEBUT_FCT("n_ActionLigneRfrBatchIN");

	//pRec contient la ligne courante
	// On va sortir 2 fichiers à partir du fichier d'entrée :
	// 	-1 -  le fichier pivot avec les 6 colonnes calculées :
	// -2-    le fichier GT regénéré à partir des lignes du pivot et du paramètre d'entrée ( CLODAT ) et qui comportera une ligne par ligne pivot en accept,
	// et 2 lignes par ligne pivot en RETRO

	// 1ere étape , on calcul
	d_fpremium_m = atof(pRec[PIV_SCOEGP_M]) - atof(pRec[PIV_WPREMIUM_M]) ;
	if ( atof(pRec[PIV_WPREMIUM_M])!=0 )
		d_ucr_r = atof(pRec[PIV_WCHARGES_M]) / atof(pRec[PIV_WPREMIUM_M]) ;
	d_prco_m = (atof(pRec[PIV_UPR_R]) + d_fpremium_m ) * atof(pRec[PIV_ULR_R]);
	d_prci_m = d_fpremium_m * (1- d_ucr_r);
	d_prmresd_m = ((1- atof(pRec[PIV_CLMDSC_R]) ) * d_prco_m) + ((1- atof(pRec[PIV_PRMDSC_R])) * d_prci_m );
	d_prmresb_m = d_prco_m * atof(pRec[PIV_BDTRAT_R]);

	//2e étape , on remet le résultat du calcul dans les champs pour la sortie
	sprintf(sz_fpremium_m,"%.3f",d_fpremium_m);
	sprintf(sz_ucr_r,"%.8f", d_ucr_r);
	sprintf(sz_prco_m,"%.3f", d_prco_m);
	sprintf(sz_prci_m,"%.3f", d_prci_m);
	sprintf(sz_prmresd_m,"%.3f", d_prmresd_m);
	sprintf(sz_prmresb_m,"%.3f", d_prmresb_m);

	pRec[PIV_FPREMIUM_M] = sz_fpremium_m;
	pRec[PIV_UCR_R] = sz_ucr_r;
	pRec[PIV_PRCO_M] = sz_prco_m;
	pRec[PIV_PRCI_M] = sz_prci_m;
	pRec[PIV_PRMRESD_M] = sz_prmresd_m;
	pRec[PIV_PRMRESB_M] = sz_prmresb_m;

	// impression du fichier pivot en sortie
	n_WriteCols(Kp_OutputPRM,pRec,'~',0);

	if ( b_IsBlankOrEmpty(pRec[PIV_NORME_CF]) )
	{
		n_WriteCols( Kp_OutputANO, pRec, '~', 0 );
		RETURN_VAL( OK );
	}

	// sortie du fichier GT
  //Initialisation du nombre de colonnes du fichier périmètre, si pas déjà fait car n_last_col_FTSII est static
	if ( n_last_col_FTSII == 0)
	{
		int i = 0;/**Added for Phase1b migration **/
		/**for(int i=0; pRec[i] ;i++)**/  /** Commented for Phase1b migration**/
		for(i=0; pRec[i] ;i++) /** Added for Phase1b migration **/
		{
			n_last_col_FTSII = i + 1;
		}
		col_filler1 = n_last_col_FTSII;
		col_annee = n_last_col_FTSII + 1;
		col_mois = n_last_col_FTSII + 2;
		col_jour = n_last_col_FTSII + 3;
		col_amt_m = n_last_col_FTSII + 4;
		col_retamt_m = n_last_col_FTSII + 5;
		col_trncod_cf = n_last_col_FTSII + 6;
		col_filler19_oricod = n_last_col_FTSII + 7;
	}
	pRec[col_filler1] = "";
	pRec[col_annee] = gsz_annee;
	pRec[col_mois] = gsz_mois;
	pRec[col_jour] = gsz_jour;
	pRec[col_trncod_cf] = sz_trncod;
	pRec[col_filler19_oricod] = "~~~~~~~~~~~~~~~~~~~EBSGTA";

	//	on va vérifier si on a une valeur dans la colonne RETCTR_NF
	if ( b_IsBlankOrEmpty(pRec[PIV_RETCTR_NF]) )
	{
		pRec[col_amt_m] = sz_prmresd_m;
		pRec[col_retamt_m] = "";
		fp_Output = Kp_OutputGTA;
	}
	else
	{
		fp_Output = Kp_OutputGTR;
		pRec[col_retamt_m] = sz_prmresd_m;
		if ( b_IsBlankOrEmpty(pRec[PIV_CTR_NF]) )
			pRec[col_amt_m] = "";
		else
			pRec[col_amt_m] = sz_prmresd_m;
		flagRetro=1;
	}

	n_init_TRNCOD(flagRetro,ACM_BAD_DEBT,pRec[PIV_NORME_CF],sz_trncod);

  /* Ecriture du fichier en sortie */
  n_WriteCols(fp_Output,pRec,'~',38
		,PIV_SSD_CF
		,PIV_ESB_CF
		,col_annee
		,col_mois
		,col_jour
		,col_trncod_cf
		,col_filler1
		,PIV_CTR_NF
		,PIV_END_NT
		,PIV_SEC_NF
		,PIV_UWY_NF
		,PIV_UW_NT
		,col_annee
		,col_annee
		,col_mois
		,col_mois
		,col_filler1
		,PIV_ACMCUR_CF
		,col_amt_m
		,PIV_CED_NF
		,PIV_BRK_NF
		,PIV_PAY_NF
		,PIV_KEY_NF
		,PIV_RETCTR_NF
		,PIV_RETEND_NT
		,PIV_RETSEC_NF
		,PIV_RTY_NF
		,PIV_RETUW_NT
		,col_annee
		,col_annee
		,col_mois
		,col_mois
		,col_filler1
		,PIV_RETCUR_CF
		,col_retamt_m
		,PIV_PLC_NT
		,PIV_RTO_NF
		,col_filler19_oricod);

	//si Retro, ajout d'une 2ème ligne !
	if ( flagRetro == 1 )
	{
		n_init_TRNCOD(flagRetro,ACM_PRESERVE_DISCOUNT,pRec[PIV_NORME_CF],sz_trncod);
		pRec[col_retamt_m] = sz_prmresb_m;
		if ( b_IsBlankOrEmpty(pRec[PIV_CTR_NF]) )
			pRec[col_amt_m] = "";
		else
			pRec[col_amt_m] = sz_prmresb_m;

	  n_WriteCols(fp_Output,pRec,'~',38
			,PIV_SSD_CF
			,PIV_ESB_CF
			,col_annee
			,col_mois
			,col_jour
			,col_trncod_cf
			,col_filler1
			,PIV_CTR_NF
			,PIV_END_NT
			,PIV_SEC_NF
			,PIV_UWY_NF
			,PIV_UW_NT
			,col_annee
			,col_annee
			,col_mois
			,col_mois
			,col_filler1
			,PIV_ACMCUR_CF
			,col_amt_m
			,PIV_CED_NF
			,PIV_BRK_NF
			,PIV_PAY_NF
			,PIV_KEY_NF
			,PIV_RETCTR_NF
			,PIV_RETEND_NT
			,PIV_RETSEC_NF
			,PIV_RTY_NF
			,PIV_RETUW_NT
			,col_annee
			,col_annee
			,col_mois
			,col_mois
			,col_filler1
			,PIV_RETCUR_CF
			,col_retamt_m
			,PIV_PLC_NT
			,PIV_RTO_NF
			,col_filler19_oricod);
	}
    return OK;
}

/*==============================================================================
objet :
	fonction de recherche du poste à partir de la norme solvency
retour :
 >= 0 ok, c'est l'index dans le tableau
 < 0 pas trouvé
==============================================================================*/
int n_init_TRNCOD(int flagRetro, const int TYPE_ACMTRS, char *psz_NORME_CF, char *psz_DETTRS_CF)
{
	DEBUT_FCT("n_init_TRNCOD");

	short n_calc_acmtrs; //normalement en 5 chiffres
	short n_norme;
	short n_typeCTR_CPTA = 1;
	char TRNCOD_PRESERVE_DISCOUNT[] = "A416012";
	char TRNCOD_BAD_DEBT[] = "A416112";
	char *pTRN = &TRNCOD_PRESERVE_DISCOUNT[0];

	if (flagRetro == 1)
		n_typeCTR_CPTA = 2;

	if ( TYPE_ACMTRS == ACM_BAD_DEBT )
		pTRN = &TRNCOD_BAD_DEBT[0];

  n_norme = n_GetNormeTRN(psz_NORME_CF);
  if ( n_norme == -1 )
		RETURN_VAL( -1 );

	n_calc_acmtrs = n_typeCTR_CPTA * 10000 + TYPE_ACMTRS * 10 + n_norme;
  if ( n_RechPosteTRSLNK(PRS_EBS_INVENT_ACCEP,n_calc_acmtrs,psz_DETTRS_CF) == -1)
  	sprintf(psz_DETTRS_CF, "%d%s", n_typeCTR_CPTA, pTRN);

	RETURN_VAL( 0 );
}
