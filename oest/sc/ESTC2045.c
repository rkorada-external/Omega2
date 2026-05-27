/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Calculs automatiques
nom du source                 : ESTC2045.c
revision                      :
date de creation              : 22/04/2014
auteur                        : S. Behague
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :
------------------------------------------------------------------------------
historique des modifications :
<modif> <jj/mm/aaaa>   <auteur>  <SPOT>  	<description de la modification>
         22/04/2014     SBE         		Création
         15/04/2015     DFI       28742 	Finalisation pour EST41
         01/05/2015     PGA       28742 	Finalisation pour EST41
         03/06/2015     DFI       28742   	Test unitaires OK
         19/08/2015     DFI       29239   	Modif affectation ACMTRS et DETTRNCOD
         01/10/2015     DFI       29239   	Attibution code DETTRS
         17/11/2015     DFI       29239   	Inversion du test usgaap (1=Long Term, 2+=Short Term)
         04/01/2016     DFI       29239   	spira 40754 PB toujours negatif (ou nul)
[001]    05/01/2016     DFI       29239   	spira 40754 retrait du calcul des sinistres payes (poste 20000)
[002]    07/01/2016     DFI       29239   	Correction du calcul des liberations (ajout structure)
[003]    13/01/2016     DFI       29239   	spira 43419 correction bug sur nettoyage ksz_ref
[004]    14/06/2016     SAS       30741   	Traité segmenté : Date bilan fausse dans Hstorique des maj
[005]	 21/09/2016		PGA 	  31375	  	Correction pour singer le comportement GUI
								 <SPIRA>
[006]	 11/01/2017		MMA 	  31375	  	Correction, calcule des libérations non effectué
[007]    18/01/2017		MMA/PGA   56877		Correction, du calcul des libérations et correction de l'initialisation des structures
[008]    23/02/2017     DFI       59450     Correction formule de calcul primes acquises
[009]    03/05/2017     DFI       59450     Evolution calcul automatique si absence de prime (on neutralise toutes les liberations)
[010]    11/05/2017     DFI       59450     + correction fonction mise a zero des postes
[011]    23/05/2017     DFI       59450     + calcul poste 1340 meme si pas de primes
[012]	 29/06/2018    HHH       64222	    Modification calcul interet poste 1340 wiki EX-ESTLIFE-815138 (d'apres spira 62184)
[013]	 01/08/2018    HHH       64222	    Trace les noms des fichiers d'entree dans le fichier anomalie
[014]    24/09/2018    HHH       64222      bloque l'ecriture tableau lors de mise a zero des postes en 1ere passe (poste 1340)
[015]    20/02/2019    B.LAGHA   64222      ajout d'un appel a la fct n_WriteCols afin d'�crire les resultat de calculs dans la fichier de sortie
[016]    15/03/2019    B.LAGHA   64222      Modification du calcul Interet Depot (Poste 82100) selon la sepec v14.1
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>
#include <ESTC2045.h>
/*------------------------------*/
/* 	position champ FACCPAR0 */
/*------------------------------*/
#define ACCPAR_URRCAL_R
#define ACCPAR_FIXCOM_R
#define ACCPAR_ACCBRK_R
#define ACCPAR_PRFCOM_R
#define ACCPAR_CTBGENFEE_R
#define ACCPAR_CLMFUNINT_R
#define ACCPAR_URRFUNINT_R
#define ACCPAR_URRFUN_R
#define ACCPAR_URRFUNCAS_R

/*------------------------------------------------*/
/* Structure utilisee les ruptures des previsions */
/*------------------------------------------------*/
typedef struct {
	char 	ACMTRS[5];
	char 	DETTRNCOD[6];
	char 	GAAP;
	double 	ESTAMT_M;
	int    	ACY;
	int    	UWY;
	int 	iswrite;
} T_ClePrevision;


/*------------------------------------------------*/
/* Structure pour stocker la prevision precedente */
/*------------------------------------------------*/
typedef struct {
	char 	PRE_CTR_NF[100];
	char 	PRE_SEC_NF[100];
	char 	PRE_UWY_NF[100];
	char 	PRE_GAAP_NF[100];
	char 	PRE_ACY_NF[100];
} T_PrevPrec;

/*------------------------------------------------*/
/* Structure pour obtimisation des parametres fnc */
/*------------------------------------------------*/
typedef struct {
	char 	ACMTRS[5];
	char 	DETTRNCOD[6];
	char 	GAAP;
	double 	ESTAMT_M;
} T_ProtoPoste;

/*------------------------------------------------*/
/* Structure utilisee pour stocker les infos peri */
/*------------------------------------------------*/
typedef struct {
	char 	LOB_CF[3];
	char 	NAT_CF[3];
	char 	SSD[2];
	char 	ESB[2];
	char 	ACCTYP;
	char 	USGAAP;
	double 	TPNA;
	double 	TCOM;
	double 	TSURCOM;
	double 	TCOURTAGE1;
	double 	TCOURTAGE2;
	double 	TPB;
	double 	TFG;
	double 	TCLMINT_R;
	double 	TURRINT_R;
	double 	TCLMFUN;
	double 	TURRFUN;
	double 	TCLMCAS;
	double 	TURRCAS;
	double  TANNINT_R;	// [012]
	/* Modification [016] START */
	int     TCLMVAR_B;	// [016]
	int     TURRVAR_B;	// [016]
	int     TLIFVAR_B;	// [016]
	int     TANNVAR_B;	// [016]
	float   TURREST_R;	// [016]
	float   TANNCAS_R;	// [016]
	float   TANNEST_R;	// [016]
	float   TLIFCAS_R;	// [016]
	float   TLIFINT_R;	// [016]
	float   TLIFEST_R;	// [016]
	float   TCLMEST_R;	// [016]
	float   TANNFUN_R;	// [016]
	float   TLIFRES_R;	// [016]
	/* Modification [016] END */
} T_ClePerimetre;

//Macro de determination du type de contrat
#define	UNUSED 	0
#define	TYPE1 	1
#define	TYPE2345 2


#define NB_MAX_TRSLNK 20000

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE        *Kp_PrevIFil;                		 	 // Pointeur sur le fichier Lifest en entree
FILE        *Kp_PilotIFil;               		 	 // Pointeur sur le fichier pilotage en entree
FILE        *Kp_PerimetreIFil;           		 	 // Pointeur sur le fichier perimetre en entree
FILE        *Kp_TACCPAR;         	     		 	 // Pointeur sur le fichier accpar en entree
FILE        *Kp_SubTRSAssoFil;				 	 // Pointeur sur le fichier subtrsasso en entree
FILE        *Kp_LifestAutoO1Fil;         		 	 // Pointeur sur le fichier de sortie de calculs automatiques
FILE        *Kp_LifestPAO2Fil;           		 	 // Pointeur sur le fichier de sortie contenant les Primes Acquises (PA)
FILE        *Kp_TrslnkFil;
FILE 	    *Kp_SubTrsesBrop;

T_RUPTURE_SYNC_VAR  bd_RuptSyncPrevisionFil;   	 	 // Gestion rupture fichier prevision
T_RUPTURE_VAR 		bd_RuptPerimPere;   	 	 	 // Gestion synchro fichier perimetre
T_SUBTRSESBPROP 	pbd_SubTrsesBrop;
T_SUBTRSASSO        pbd_SubTrsAsso;				 	 // table TsubtrsAcco pour DETTERNCOD liberation
T_ACCPAR		    pbd_TACCPAR;					 // table Taccpar pour les autre DETTERNCOD
T_ACCPAR            Kbd_TACCPAR[2000];
int                 Kn_NbLigTACCPARFile = 0;
int                 Kn_NbLigTrslnk = 0;
T_TRSLNK            Kbd_TRSLNK[NB_MAX_TRSLNK];

T_ClePrevision 		Kbd_ClePrevision[500];       	 // Tableau pour stocker chaque ligne de la rupture
int            		Kn_ClePrevision = 0;         	 // Nombre de lignes dans ce tableau
T_ClePrevision 		Kbd_ClePrevisionAcyPrec[500];   	 // Tableau pour stocker chaque ligne de la rupture pour ACY-1
int            		Kn_ClePrevisionAcyPrec = 0;     	 // Nombre de lignes dans ce tableau
T_ClePrevision 		Kbd_ClePrevisionUWYPrec[4500]; // [002] Tableau pour stocker chaque ligne de la rupture pour UWY-1
int            		Kn_ClePrevisionUWYPrec = 0;    // [002] Nombre de lignes dans ce tableau
short             	ACYPrec = 0;                   // ACY precedente
T_PrevPrec			 bd_PrevPrec;					         // Stocke les infos de la prevision precedente
T_ClePerimetre 		Kbd_ClePerimetre;            	 // Structure pour stocker les infos perimetre utile au traitement

int            		kn_indexPilot = 0;         		 // Index pour RechPilot5000
T_LIFDRI_ALL   		Kbd_PILOT[NB_MAX_PILOT];    	 // Fichier pilotage charge en memoire

T_LIFDRI_ALL   		*Kpbd_CPPILOT = NULL;       	 // Tableau des complement PILOT
int            		Kn_NbLigCPPilot = 0;        	 // nombre de complement PILOT

char 				*Ksz_passage;					 // passage avant segmentation (1) aprés (2)
char 				Ksz_CRE_D[22] = {'\0'};
char                *ksz_blsmth;
int 				Kn_ACY = 0; // [002]
int 				Kn_UWY = 0; // [002]
char 				*Ksz_ref[PRE_NBCOL + 1] = {NULL};
char 				Ke_ModeContrat = UNUSED;		// [005] dertermine le type du contrat.
char	**ptb_Perim;
// Fonctions de ruptures et synchronisation
int n_InitSyncPrev       		(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLastRuptPrev 		(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPerim		(char **ptb_InRec_Cur);
int n_InitPerimPere      		(T_RUPTURE_VAR *pbd_Rupt);
int n_ConditionRuptPerim 		(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ConditionRuptPrevType1	(char **pbd_InRec, char **pbd_InRec_Cur);			//[005]
int n_ActionLastRuptPrevType1	(char **ptb_InRec, char **ptb_InRec_Cur);			//[005]
int n_ActionLastRuptPrevType2345	(char **ptb_InRec, char **ptb_InRec_Cur);			//[005]
int n_ConditionRuptPrevType2345	(char **pbd_InRec, char **pbd_InRec_Cur);			//[005]
int n_ActionLignePrev    		(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionFilsSansPere 		(char **ptb_InRec_Cur);
int n_ConditionSyncPrev  		(char **ptb_InRec_Master, char **ptb_InRec_Slave);

// Fonctions utilitaires
void  MemoPrev              (char **ptb_InRec);
void  AffichageTabPrev      (); // débug
int   n_UpdatePoste         (T_ProtoPoste poste, int nWrite);					//[007]
void  ajouterPosteClean  	(T_ProtoPoste poste);			
void  setPoste              (T_ProtoPoste poste, int indexPoste); //[007]
int   findPoste				(char *acmtrs, char *dettrncod);											//[007]
void  EcritureTableau       (char **ptb_InRec, char crible);
void  ChargeClePerim        (char **ptb_Perim);
int   n_GetACMTRS_TRSLNK    (char dettrncod[5], char idx0ACMTRS);
int   n_FindTACCPAR         (T_ACCPAR *pbd_lu, short Acmtrs);
int   n_GetDETTRS           (char * dettrncod, char idx0ACMTRS);
void  MiseAZeroDesPostes    ();
int   n_ChargerTRSLNK		(FILE* Kp_TrslnkFil);
char* n_FindACMTRS			(char* dettrncod);
int   i_LiberationExeP1		(int iAcmtrs, int iAcadmtyp);  // [002] renvoie 1 si la liberation se fait sur l'exercice + 1 an sinon 0
void  n_SaveUWYPrec			(); // [002]
void  ReinitSAV				(char **ptb_InRec_Cur);	//[005]
void  AjustSAVPrev1			(char **ptb_InRec_Cur);
void  AjustSAVPrev2345		(char **ptb_InRec_Cur);	//[007]
int   n_IsCompleteAccount	(char **ptb_InRec);		//[005]
int   n_DetectType			(char **Pericase_line);	//[005]
T_ProtoPoste initProtoPoste(char *acmtrs, char *dettrncod, double montant, char gaap);

// Fonctions de Traitement en fonction des cas
void TraitementLob30ST31Survenance(char **ptb_InRec, char crible);
void TraitementLob30ST31Autre     (char **ptb_InRec, char crible);
void TraitementLob30LTSurvenance  (char **ptb_InRec, char crible);
void TraitementLob30LTAutre       (char **ptb_InRec, char crible);

// Fonctions de Calculs
void CalculLiberations();
void NeutraliserLiberations(); //[009]
void CalculPrimeNonAcquise();
void CalculPrimeAcquise();
void CalculCommissions();
void CalculCourtage();
void CalculFARconst();
void CalculProvisionConstSurvenance();
void CalculProvisionConstAutr();
void CalculSAPConstSurvenance();
void CalculSAPConstAutre();
void CalculInteretDepot();
void CalculDepotPrimeConst();
void CalculDepotSAPConst();
void CalculResultatAvtPBSurvenance();
void CalculResultatAvtPBAutre();
void CalculPB();
void CalculResultatSurvenance();
void CalculResultatAutre();
void CalculSinistresSurvenance();
void CalculSinistresAutre();
double n_CalculPoste82100 (double poste_81300, double poste_81100);
double n_CalculPoste82200 (double poste_81500, double poste_81510);

/*----------------------*/
/* variables Constante  */
/*----------------------*/
#define HEURE_TRAITEMENT "23:59:51"
#define ORICOD_LS        "AUTO CALC"

char pathENV[500];
char chTraite[300];
/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc, char *argv[])
{
printf("avant teste de la new struct PER_GANPAYORD_NT : %d\n", PER_GANPAYORD_NT);
printf("avant teste de la new struct NBCOL : %d\n", PER_NBCOL);
printf("avant teste de la new struct PER_ANNFUNESTINT_R : %d\n", PER_ANNFUNESTINT_R);


	// Initialisation des signaux
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

	sprintf(Ksz_CRE_D, "%s %s", psz_GetCharArgv(2), HEURE_TRAITEMENT);
	Ksz_passage = psz_GetCharArgv(3);
	ksz_blsmth = psz_GetCharArgv(4);   //[004]

	// trace les fichiers input
	sprintf(pathENV,"EST_VLIFEST_AUTOSEG:<%s>", getenv("ESTC2045_I1"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_IARVPERICASE4_AUTOSEG:<%s>", getenv("ESTC2045_I2"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_CPLIFDRI:<%s>", getenv("ESTC2045_I3"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_SUBTRSASSO:<%s>", getenv("ESTC2045_I4"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_TACCPAR:<%s>", getenv("ESTC2045_I5"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_FTRSLNK:<%s>", getenv("ESTC2045_I6"));
	n_WriteAno(pathENV);
	sprintf(pathENV,"EST_SUBTRSESBPROP:<%s>", getenv("ESTC2045_I7"));
	n_WriteAno(pathENV);
	//
	//
	// Ouverture des fichiers
	if (n_OpenFileAppl("ESTC2045_O1", "wt", &Kp_LifestAutoO1Fil) == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_O2", "wt", &Kp_LifestPAO2Fil)   == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_I3", "rb", &Kp_PilotIFil)       == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_I4", "rb", &Kp_SubTRSAssoFil) 	 == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_I5", "rb", &Kp_TACCPAR) 		 == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_I6", "rb", &Kp_TrslnkFil) 		 == ERR) ExitPgm(ERR_XX, "");
	if (n_OpenFileAppl("ESTC2045_I7", "rb", &Kp_SubTrsesBrop) 	 == ERR) ExitPgm(ERR_XX, "");

	/* 			Initialisation des structures 			*/
	memset(&Kbd_ClePerimetre, 	0, sizeof(Kbd_ClePerimetre));
	memset(&pbd_SubTrsesBrop, 	0, sizeof(pbd_SubTrsesBrop));
	memset(&pbd_SubTrsAsso, 	0, sizeof(pbd_SubTrsAsso));
	memset(&pbd_TACCPAR, 		0, sizeof(pbd_TACCPAR));

	if (n_InitSyncPrev(&bd_RuptSyncPrevisionFil) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_InitPerimPere(&bd_RuptPerimPere) 			== ERR) ExitPgm(ERR_XX, "");

	// Chargement en memoire du fichier pilotage

	if (n_ChargerPilot5000(Kp_PilotIFil) 		== -1) ExitPgm(ERR_XX, "");
	if (n_ChargerTRSLNK(Kp_TrslnkFil) 		== ERR) ExitPgm(ERR_XX, "");
	if (n_ChargerTsubTAACCPAR(Kp_TACCPAR) 		== ERR) ExitPgm(ERR_XX, "");
	if (n_ChargerTsubTRSAsso(Kp_SubTRSAssoFil) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_ChargerSUBTRSESBPROP(Kp_SubTrsesBrop) == ERR) ExitPgm(ERR_XX, "");

	// lancement du traitement du fichier
	if (n_ProcessingRuptureVar(&bd_RuptPerimPere) == ERR) ExitPgm(ERR_XX, "");

	// Fermeture des fichiers
	if (n_CloseFileAppl("ESTC2045_I1", &(bd_RuptSyncPrevisionFil.pf_InputFil)) 	== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2045_I2", &(bd_RuptPerimPere.pf_InputFil)) 		== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2038_I3", &Kp_PilotIFil) 							== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2135_I4", &Kp_SubTRSAssoFil) 						== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2135_I5", &Kp_TACCPAR) 							== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2135_I6", &Kp_TrslnkFil) 							== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2135_I7", &Kp_SubTrsesBrop) 						== ERR)	ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2045_O1", &Kp_LifestAutoO1Fil) 					== ERR) ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2045_O2", &Kp_LifestPAO2Fil) 						== ERR) ExitPgm(ERR_XX, "");


	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

	exit(OK);
}
/*************** Fin Main ****************/

/*============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier prevision.
============================================================================================*/
int n_InitSyncPrev (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitSyncPrev");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl("ESTC2045_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 2;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPrevType1;	//[005]
	pbd_Rupt->n_ConditionRupture[1] = n_ConditionRuptPrevType2345;	//[005]
	pbd_Rupt->n_ActionLast[0] 		= n_ActionLastRuptPrevType1;	//[005]
	pbd_Rupt->n_ActionLast[1] 		= n_ActionLastRuptPrevType2345;	//[005]
	pbd_Rupt->ConditionEndSync 		= n_ConditionSyncPrev;
	pbd_Rupt->n_ActionLigne 		= n_ActionLignePrev;
	pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================================
objet :     fonction d'initialisation de la variable de gestion de rupture du fichier perimetre.
==============================================================================================*/
int n_InitPerimPere(T_RUPTURE_VAR *pbd_Rupt)
{
	DEBUT_FCT("n_InitPerimPere");

	memset(pbd_Rupt, 0, sizeof(*pbd_Rupt));
	if (n_OpenFileAppl ("ESTC2045_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);

	pbd_Rupt->n_NbRupture 			= 1;
	pbd_Rupt->n_ConditionRupture[0] = n_ConditionRuptPerim;
	pbd_Rupt->n_ActionLast[0] 		= n_ActionLastRuptPerim;
	pbd_Rupt->c_Separ 				= SEPARATEUR;

	RETURN_VAL (OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionSyncPrev(char **ptb_InRec_Master, char **ptb_InRec_Slave)
{
	int ret = 0;
	DEBUT_FCT("n_ConditionSyncPrev");

	if ((ret = strcmp(ptb_InRec_Master[PER_CTR_NF] , ptb_InRec_Slave[PRE_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Master[PER_SEC_NF] , ptb_InRec_Slave[PRE_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(ptb_InRec_Master[PER_UWY_NF] , ptb_InRec_Slave[PRE_UWY_NF])) != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLignePrev(char **ptb_InRec_Master, char **ptb_InRec_Slave)
{
	DEBUT_FCT("n_ActionLignePrev");

	if (atoi(ptb_InRec_Slave[PRE_ACY_NF]) < atoi(ptb_InRec_Slave[PRE_UWY_NF]))
		RETURN_VAL(OK);

	if ((Ke_ModeContrat = n_DetectType(ptb_InRec_Master)) == -1)
		RETURN_VAL(OK);


	n_WriteCols(Kp_LifestAutoO1Fil, ptb_InRec_Slave, SEPARATEUR, 0);
	MemoPrev(ptb_InRec_Slave);

	RETURN_VAL(OK);
}

/*==============================================================================
objet : [005]
==============================================================================*/
int n_ConditionRuptPrevType1(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPrev");


	if ((ret = strcmp(pbd_InRec[PRE_CTR_NF],  pbd_InRec_Cur[PRE_CTR_NF]))  != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_SEC_NF],  pbd_InRec_Cur[PRE_SEC_NF]))  != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_GAAP_NF], pbd_InRec_Cur[PRE_GAAP_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_ACY_NF],  pbd_InRec_Cur[PRE_ACY_NF]))  != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :	[005]
==============================================================================*/
int n_ConditionRuptPrevType2345(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPrev");


	if ((ret = strcmp(pbd_InRec[PRE_CTR_NF],  pbd_InRec_Cur[PRE_CTR_NF]))  != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_SEC_NF],  pbd_InRec_Cur[PRE_SEC_NF]))  != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_GAAP_NF], pbd_InRec_Cur[PRE_GAAP_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_UWY_NF],  pbd_InRec_Cur[PRE_UWY_NF]))  != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PRE_ACY_NF],  pbd_InRec_Cur[PRE_ACY_NF]))  != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ConditionRuptPerim(char **pbd_InRec, char **pbd_InRec_Cur)
{
	int ret;

	DEBUT_FCT("n_ConditionRuptPerim");

	if ((ret = strcmp(pbd_InRec[PER_CTR_NF],  pbd_InRec_Cur[PER_CTR_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_SEC_NF],  pbd_InRec_Cur[PER_SEC_NF])) != 0) RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRec[PER_UWY_NF],  pbd_InRec_Cur[PER_UWY_NF])) != 0) RETURN_VAL(ret);

	RETURN_VAL (ret);
}

/*==============================================================================
objet :
        fonction lancee pour chaque prevision ne participant
        pas a aucun placement

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionFilsSansPere");

	n_WriteCols(Kp_LifestAutoO1Fil, ptb_InRec_Cur, SEPARATEUR, 0);
	RETURN_VAL(OK);
}

/*==============================================================================
objet :
==============================================================================*/
int n_ActionLastRuptPerim(char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLastRuptPerim");
	/*					filtre crible 						*/

	if (strcmp(ptb_InRec_Cur[PER_ESTCRB_CT], "A") != 0 &&
	    strcmp(ptb_InRec_Cur[PER_ESTCRB_CT], "E") != 0)
		RETURN_VAL(OK);

	ChargeClePerim(ptb_InRec_Cur);
	ptb_Perim = ptb_InRec_Cur;	// [016]
	n_ProcessingRuptureSyncVar(&bd_RuptSyncPrevisionFil, ptb_InRec_Cur);

	RETURN_VAL (OK);
}

/*==============================================================================
objet :	Initialisation de la structure contenant les infos de la prevision prec
==============================================================================*/
void InitPrevPrec(char ** ptb_prevision)
{
	strcpy(bd_PrevPrec.PRE_CTR_NF, ptb_prevision[PRE_CTR_NF]);
	strcpy(bd_PrevPrec.PRE_SEC_NF, ptb_prevision[PRE_SEC_NF]);
	strcpy(bd_PrevPrec.PRE_UWY_NF, ptb_prevision[PRE_UWY_NF]);
	strcpy(bd_PrevPrec.PRE_GAAP_NF, ptb_prevision[PRE_GAAP_NF]);
	strcpy(bd_PrevPrec.PRE_ACY_NF, ptb_prevision[PRE_ACY_NF]);
}

/*==============================================================================
objet :	recuperation de la grille	[005]
		mise a jour de celle-ci en fonction des crible A et E
		Ce traitement ci ne s'applique que dans le cadre des contrat
		type 1 et 4.

		On récupères les infos utiles pour le traitement :
        --> LOB               : PER_LOB_CF
        --> Nature du contrat : PER_NAT_CF
        --> Ke_ModeContrat	  : Cet valeur est set pendant n_ActionLignePrev
        						et correspond à PER_ACCADMTYP_CT
==============================================================================*/
int n_ActionLastRuptPrevType1(char **ptb_InRec, char **ptb_InRec_Cur)
{
	char  crible;
	int i;

	DEBUT_FCT("n_ActionLastRuptPrevType1");

	if (Ke_ModeContrat == TYPE1)
	{
		AjustSAVPrev1(ptb_InRec_Cur); 				//[006]
		crible = ptb_InRec_Cur[PRE_ESTCRB_CT][0];

		if (n_IsCompleteAccount(ptb_InRec_Cur) == -1)
		{
			ReinitSAV(ptb_InRec_Cur);
			//memset(&Kbd_ClePrevision, 	0, sizeof(Kbd_ClePrevision));
			RETURN_VAL(OK);
		}

		// Calculs automatiques uniquement si poste 1010 present
		if (Ksz_ref[PRE_ACMTRS_NT] && strcmp(Ksz_ref[PRE_ACMTRS_NT], "1010") == 0 && atof(Ksz_ref[PRE_ESTMNT_M]) != 0)
		{
			if (Ksz_passage[0]  == '1')
				MiseAZeroDesPostes();
			
			if ((strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0 &&
		    	 Kbd_ClePerimetre.USGAAP != '1') 			||
		    	 strcmp(Kbd_ClePerimetre.LOB_CF, "31") == 0)
			{
				TraitementLob30ST31Survenance(ptb_InRec_Cur, crible);
			}

			else if ((strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0 &&
		    	      Kbd_ClePerimetre.USGAAP == '1'))
			{
				TraitementLob30LTSurvenance(ptb_InRec_Cur, crible);
			}

			else
			{
				EcritureTableau(ptb_InRec_Cur, crible);
			}
		}
		else  //[009]
		{
			// ligne de reference initialisee avec la derniere ligne lue
			// car non initialisee (pas de ligne 1010 presente)
			while (i < PRE_NBCOL)
			{
				Ksz_ref[i] = strdup(ptb_InRec_Cur[i]);
				++i;
			}
			MiseAZeroDesPostes();
			CalculLiberations();
			NeutraliserLiberations();
			CalculInteretDepot();
			EcritureTableau(ptb_InRec_Cur, crible);
		}

		ReinitSAV(ptb_InRec_Cur);
	}
	RETURN_VAL(OK);
}

/*==============================================================================
objet :	recuperation de la grille	[005]
		mise a jour de celle-ci en fonction des crible A et E
		Ce traitement ci ne s'applique que dans le cadre des contrat
		type 2, 3 et 5.

		On récupères les infos utiles pour le traitement :
        --> LOB               : PER_LOB_CF
        --> Nature du contrat : PER_NAT_CF
        --> Ke_ModeContrat	  : Cet valeur est set pendant n_ActionLignePrev
        						et correspond à PER_ACCADMTYP_CT
==============================================================================*/
int n_ActionLastRuptPrevType2345(char **ptb_InRec, char **ptb_InRec_Cur)
{
	char  crible;
	int i;

	DEBUT_FCT("n_ActionLastRuptPrevType2345");

	if (Ke_ModeContrat == TYPE2345)
	{
		AjustSAVPrev2345(ptb_InRec_Cur);               //[006]
		crible = ptb_InRec_Cur[PRE_ESTCRB_CT][0];

		if (n_IsCompleteAccount(ptb_InRec_Cur) == -1)
		{
			ReinitSAV(ptb_InRec_Cur);
			//memset(&Kbd_ClePrevision, 	0, sizeof(Kbd_ClePrevision));
			RETURN_VAL(OK);
		}

		// Calculs automatiques uniquement si poste 1010 present
		if (Ksz_ref[PRE_ACMTRS_NT] && strcmp(Ksz_ref[PRE_ACMTRS_NT], "1010") == 0 && atof(Ksz_ref[PRE_ESTMNT_M]) != 0)
		{
			if (Ksz_passage[0]  == '1')
				MiseAZeroDesPostes();

			if ((strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0 &&
		    	 Kbd_ClePerimetre.USGAAP != '1') 			||
		    	 strcmp(Kbd_ClePerimetre.LOB_CF, "31") == 0)
			{
				TraitementLob30ST31Autre(ptb_InRec_Cur, crible);
			}

			else if ((strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0 &&
		    	      Kbd_ClePerimetre.USGAAP == '1'))
			{
				TraitementLob30LTAutre(ptb_InRec_Cur, crible);
			}

			else
				EcritureTableau(ptb_InRec_Cur, crible);
		}
		else  //[009]
		{
			// ligne de reference initialisee avec la derniere ligne lue
			// car non initialisee (pas de ligne 1010 presente)
			while (i < PRE_NBCOL)
			{
				Ksz_ref[i] = strdup(ptb_InRec_Cur[i]);
				++i;
			}
			MiseAZeroDesPostes();
			CalculLiberations();
			NeutraliserLiberations();
			CalculInteretDepot();
			EcritureTableau(ptb_InRec_Cur, crible);
		}

		ReinitSAV(ptb_InRec_Cur);
	}
	RETURN_VAL(OK);
}

/*=============================================================================
objet:  	reinitialiser la sauvegarde de l'annees [005]
Parametre:  La ligne courante des previsions
=============================================================================*/
void ReinitSAV(char **ptb_InRec_Cur)
{
	int i;

	DEBUT_FCT("ReinitSAV");
	
	// Conservation de la grille actuelle dans tableau ACY-1
	memcpy(Kbd_ClePrevisionAcyPrec, Kbd_ClePrevision, sizeof(T_ClePrevision) * (Kn_ClePrevision + 1));
	
	// [002] Conservation de la grille actuelle dans tableau UWYPrec
	n_SaveUWYPrec();
	Kn_ClePrevisionAcyPrec = Kn_ClePrevision;
	Kn_ClePrevision = 0;
	InitPrevPrec(ptb_InRec_Cur);
	
	// reinitialisation de la ligne de reference
	for (i = 0; i < PRE_NBCOL; i++)
	{
		Ksz_ref[i] = "";  // [003]
	}
	Ke_ModeContrat = UNUSED;
}

/*=============================================================================
objet:  	Eliminer la sauvegarde de l'annees [005]
Parametre:  La ligne courante des previsions
=============================================================================*/
void AjustSAVPrev2345(char **ptb_InRec_Cur)
{

	DEBUT_FCT("AjustSAVPrev2345");

  	//[002]
	Kn_ACY = atoi(ptb_InRec_Cur[PRE_ACY_NF]);
	Kn_UWY = atoi(ptb_InRec_Cur[PRE_UWY_NF]);
	// oubli des previsions ACY-1 si annees de compte non contigues
	if  (Kn_ClePrevisionAcyPrec &&
	   	(strcmp(bd_PrevPrec.PRE_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) != 0 ||
	   	 strcmp(bd_PrevPrec.PRE_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF]) != 0 ||
	   	 strcmp(bd_PrevPrec.PRE_UWY_NF, ptb_InRec_Cur[PRE_UWY_NF]) != 0 ||
	   	 atoi(bd_PrevPrec.PRE_ACY_NF) + 1 !=  atoi(ptb_InRec_Cur[PRE_ACY_NF]))
	  		)
	{
		Kn_ClePrevisionAcyPrec = 0;
	}
	// [002] si CTR/SEC change ou si UWY ni egaux ni contigues on vide Kbd_ClePrevisionUWYPrec
	if (strcmp(bd_PrevPrec.PRE_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF])      != 0 ||
	   	strcmp(bd_PrevPrec.PRE_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF])      != 0 ||
	   	atoi(bd_PrevPrec.PRE_UWY_NF) - atoi(ptb_InRec_Cur[PRE_UWY_NF])  > 1 )
	{
		Kn_ClePrevisionUWYPrec = 0;
	}
}

/*=============================================================================
objet:  	Eliminer la sauvegarde de l'annees [005]
Parametre:  La ligne courante des previsions
=============================================================================*/
void AjustSAVPrev1(char **ptb_InRec_Cur)
{

	DEBUT_FCT("AjustSAVPrev1");

  	//[002]
	Kn_ACY = atoi(ptb_InRec_Cur[PRE_ACY_NF]);
	Kn_UWY = atoi(ptb_InRec_Cur[PRE_UWY_NF]);
	// oubli des previsions ACY-1 si annees de compte non contigues
	if  (Kn_ClePrevisionAcyPrec &&
	   	(strcmp(bd_PrevPrec.PRE_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF]) != 0 ||
	   	 strcmp(bd_PrevPrec.PRE_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF]) != 0 ||
	   	 atoi(bd_PrevPrec.PRE_UWY_NF) + 1 != atoi(ptb_InRec_Cur[PRE_UWY_NF]) ||
	   	 atoi(bd_PrevPrec.PRE_ACY_NF) + 1 != atoi(ptb_InRec_Cur[PRE_ACY_NF]))
	  		)
	{
		Kn_ClePrevisionAcyPrec = 0;
	}
	// [002] si CTR/SEC change ou si UWY ni egaux ni contigues on vide Kbd_ClePrevisionUWYPrec
	if (strcmp(bd_PrevPrec.PRE_CTR_NF, ptb_InRec_Cur[PRE_CTR_NF])      != 0 ||
	   	strcmp(bd_PrevPrec.PRE_SEC_NF, ptb_InRec_Cur[PRE_SEC_NF])      != 0 ||
	   	atoi(bd_PrevPrec.PRE_UWY_NF) - atoi(ptb_InRec_Cur[PRE_UWY_NF])  > 1 )
	{
		Kn_ClePrevisionUWYPrec = 0;
	}
}

/*=============================================================================
objet:  	Synchronisation du fichier Pilotage pour cette ligne [005]
Parametre:  La ligne courante des previsions
=============================================================================*/
int n_IsCompleteAccount(char **ptb_InRec_Cur)
{
	int 	Kn_SyncPilot;
	DEBUT_FCT("n_IsCompleteAccount");


	Kn_SyncPilot = n_RechPilot5000(ptb_InRec_Cur, PRE_CTR_NF, PRE_SEC_NF, PRE_ACY_NF, &kn_indexPilot);
	if (Kn_SyncPilot >= 0)
	{
		if ( Kbd_PILOT[Kn_SyncPilot].AUTUPD_B && Kbd_PILOT[Kn_SyncPilot].COMACC_B)
			return (-1);
	}
	RETURN_VAL(OK);
}

/*=============================================================================
objet:  Memorise dans un tableau la cle de la ligne courante des previsions et
        le montant qui l'accompagne
Parametre:  La ligne courante des previsions
=============================================================================*/
void MemoPrev(char **ptb_InRec)
{
	int i = 0;
	DEBUT_FCT("MemoPrev");

	strcpy(Kbd_ClePrevision[Kn_ClePrevision].ACMTRS, 	ptb_InRec[PRE_ACMTRS_NT]);
	strcpy(Kbd_ClePrevision[Kn_ClePrevision].DETTRNCOD, ptb_InRec[PRE_DETTRNCOD_CF]);
	Kbd_ClePrevision[Kn_ClePrevision].UWY = atoi(ptb_InRec[PRE_UWY_NF]);
	Kbd_ClePrevision[Kn_ClePrevision].ACY = atoi(ptb_InRec[PRE_ACY_NF]);

	Kbd_ClePrevision[Kn_ClePrevision].GAAP 		= ptb_InRec[PRE_GAAP_NF][0];
	Kbd_ClePrevision[Kn_ClePrevision].ESTAMT_M 	= atof(ptb_InRec[PRE_ESTMNT_M]);

	Kbd_ClePrevision[Kn_ClePrevision].iswrite = 0;
	if (strcmp(Kbd_ClePrevision[Kn_ClePrevision].ACMTRS, "1010") == 0) {
		while (i < PRE_NBCOL)
		{
			Ksz_ref[i] = strdup(ptb_InRec[i]);
			++i;
		}
	}
	++Kn_ClePrevision;
}

/*=============================================================================
objet:  Fonction Calcul des primes non Acquises - etape 2
=============================================================================*/
void CalculPrimeNonAcquise()
{
	DEBUT_FCT("CalculPrimeNonAcquise");

	T_ProtoPoste poste;
	int i;
	double pna = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1010") == 0))
		{
			pna += -Kbd_ClePrevision[i].ESTAMT_M * Kbd_ClePerimetre.TPNA;
		}
	}
	poste = initProtoPoste(n_FindACMTRS("41000"), "41000", pna, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des primes Acquises - etape 3
=============================================================================*/
void CalculPrimeAcquise()
{
	DEBUT_FCT("CalculPrimeAcquise");

	T_ProtoPoste poste;
	int i;
	double total_mnt = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1010") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1013") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1014") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1504") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1503") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1604") == 0) ||  // [008]
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1603") == 0))    // [008]
		{
			total_mnt += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	poste = initProtoPoste("1510", "XXXXX", total_mnt, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des commissions - etape 4
=============================================================================*/
void CalculCommissions()
{
	DEBUT_FCT("CalculCommissions");

	T_ProtoPoste poste;
	int i;
	double Commission = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1010") == 0))
		{
			Commission += -Kbd_ClePrevision[i].ESTAMT_M * (Kbd_ClePerimetre.TCOM + Kbd_ClePerimetre.TSURCOM);
		}
	}

	poste = initProtoPoste(n_FindACMTRS("12000"), "12000", Commission, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des courtages - etape 5
=============================================================================*/
void CalculCourtage()
{
	DEBUT_FCT("CalculCourtage");

	T_ProtoPoste poste;
	int i;
	double courtage = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1010") == 0))
		{
			courtage += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	courtage = (Kbd_ClePerimetre.TCOURTAGE1 + Kbd_ClePerimetre.TCOURTAGE2) * -courtage;

	poste = initProtoPoste(n_FindACMTRS("14000"), "14000", courtage, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des commissions sur primes Non aqcuises const - etape 6
=============================================================================*/
void CalculFARconst()
{
	DEBUT_FCT("CalculFARconst");

	T_ProtoPoste poste;
	int i;
	double montant1 = 0;
	double montant2 = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1503") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1063") == 0))
		{
			montant1 -= Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1164") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1184") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1194") == 0))
		{
			montant2 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant1 = montant1 * (Kbd_ClePerimetre.TCOM + Kbd_ClePerimetre.TSURCOM) - montant2;

	poste = initProtoPoste(n_FindACMTRS("43000"), "43000", montant1, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des provisions Const - etape 7 Lob 30 long term type comptable 1
=============================================================================*/
void CalculProvisionConstSurvenance()
{

	DEBUT_FCT("CalculProvisionConstSurvenance");

	T_ProtoPoste poste;
	int i;
	double prime_acquise = 0;
	double taux_sinistralite = 0;
	double montant_sap = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)) 			// prime acquise
		{
			prime_acquise += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1480") == 0))		// sinistralite
		{
			taux_sinistralite += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1074") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1094") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1084") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1264") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1534") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1634") == 0))
		{
			montant_sap += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant_sap = - prime_acquise * taux_sinistralite / 100 - montant_sap;  // sinistralite en pourcent (ex 40.00) (a la difference des autres taux en 0.4)

	// printf("TracePaul --> CalculProvisionConstSurvenance Affichage Parametre Poste [%s][%s][%c][%f]\n",
	//        "1063",
	//        "40000",
	//        Kbd_ClePrevision[0].GAAP,
	//        montant_sap);

	poste = initProtoPoste(n_FindACMTRS("40000"), "40000", montant_sap, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des provisions Const - etape 11 Lob 30 long term type comptable 2 a 5
=============================================================================*/
void CalculProvisionConstAutre()
{

	DEBUT_FCT("CalculProvisionConstAutre");

	T_ProtoPoste poste;
	int i;
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1509") == 0)			// 		resultat avant PB
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0) || 	// 		prime acquise

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1011") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1243") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1140") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1100") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1143") == 0) ||	//		workflows
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1144") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1220") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1340") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1523") == 0) ||	//

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1524") == 0) ||	//		liberations
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1624") == 0) ||	//		non annulees

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1074") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1094") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1084") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1264") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0) ||	//		liberations annulees
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1534") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1634") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1164") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1184") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1194") == 0))		//
		{
			montant -= Kbd_ClePrevision[i].ESTAMT_M;
		}
	}

	poste = initProtoPoste(n_FindACMTRS("40000"), "40000", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des intérets sur dépot - etape 8 (survenance) etape 10 (autre)
=============================================================================*/
void CalculInteretDepot()
{

	DEBUT_FCT("CalculInteretDepot");

	T_ProtoPoste poste;
	int i;
/***************** avant Modification [016] 
	double montant1 = 0;
	double montant2 = 0;
	double mnt82100 = 0;
	double mnt82200 = 0;
******************************/
/*********************   avant [012]
	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1324") == 0))
		{
			montant1 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1304") == 0))
		{
			montant2 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant1 = montant1 * Kbd_ClePerimetre.TCLMINT_R + montant2 * Kbd_ClePerimetre.TURRINT_R;

	poste = initProtoPoste(n_FindACMTRS("82100"), "82100", montant1, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
*********************************************/
// [012]
/*************************************  [012] *********************************/
/*********************************** Avant [016] ******************************
	double mnt1244 = 0;
	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0))
		{
			montant1 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1504") == 0))
		{
			montant2 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0))
		{
			mnt1244 += Kbd_ClePrevision[i].ESTAMT_M;
		}		
	}
	mnt82100 = ( montant1 + montant2) * Kbd_ClePerimetre.TURRINT_R;

	mnt82200 = 0 ;
	if ( Kbd_ClePerimetre.TCLMINT_R )  {
		if ( Kbd_ClePerimetre.TANNINT_R >= 0 ) {
			mnt82200 = mnt1244 * Kbd_ClePerimetre.TCLMINT_R ;
		} 
		else {
			mnt82200 = mnt1244 * Kbd_ClePerimetre.TANNINT_R ;
		}
	}

	if (Ksz_passage[0]  == '2') {  // [014]
		poste = initProtoPoste(n_FindACMTRS("82100"), "82100", mnt82100, Kbd_ClePrevision[0].GAAP);
		n_UpdatePoste(poste, 1);
		// update pour poste 82200
		poste = initProtoPoste(n_FindACMTRS("82200"), "82200", mnt82200, Kbd_ClePrevision[0].GAAP);
		n_UpdatePoste(poste, 1);
	}
*******************************************************************************/


/************************************************************* 
**                Modofiacation [016] START                 **
**                -------------------------                 **
**************************************************************/
	double poste_81300 = 0;
	double poste_81100 = 0;
	double poste_81500 = 0;
	double poste_81510 = 0;
	double mnt_82100   = 0;
	double mnt_82200   = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{	// postes details 81300 et 81100 ont le mm ACMTRS == 1304
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1304") == 0)
		{
			if (strcmp(Kbd_ClePrevision[i].DETTRNCOD, "81300") == 0)
			{
				poste_81300 += Kbd_ClePrevision[i].ESTAMT_M;
			}
			else if (strcmp(Kbd_ClePrevision[i].DETTRNCOD, "81100") == 0)
			{
				poste_81100 += Kbd_ClePrevision[i].ESTAMT_M;
			}
		}
		// postes details 81500 et 81510 ont le mm ACMTRS == 1324
		else if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1324") == 0)
		{
			if (strcmp(Kbd_ClePrevision[i].DETTRNCOD, "81500") == 0)
			{
				poste_81500 += Kbd_ClePrevision[i].ESTAMT_M;
			}
			else if (strcmp(Kbd_ClePrevision[i].DETTRNCOD, "81510") == 0)
			{
				poste_81510 += Kbd_ClePrevision[i].ESTAMT_M;
			}
		}
	}

	// Calcul des postes 82100 et 82200 selon la spec EST41 v24.1
	mnt_82100 = n_CalculPoste82100 (poste_81300, poste_81100);
	mnt_82200 = n_CalculPoste82200 (poste_81500, poste_81510);

	// Mettre a jour les postes 82100 et 82200
	if (Ksz_passage[0]  == '2') // [016]
	{
		poste = initProtoPoste(n_FindACMTRS("82100"), "82100", mnt_82100, Kbd_ClePrevision[0].GAAP);
		n_UpdatePoste(poste, 1);
		poste = initProtoPoste(n_FindACMTRS("82200"), "82200", mnt_82200, Kbd_ClePrevision[0].GAAP);
		n_UpdatePoste(poste, 1);
	}

/************************************************************* 
**                Modofiacation [016] END                   **
**                -------------------------                 **
**************************************************************/
}

/*=============================================================================
objet:  Fonction Calcul des resultat avant prime benefice - etape 9 type comptable 1 (survenance)
=============================================================================*/
void CalculResultatAvtPBSurvenance()
{

	DEBUT_FCT("CalculResultatAvtPBSurvenance");

	T_ProtoPoste poste;
	int i;
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0) || 		// 		prime acquise

		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1011") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1063") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1140") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1143") == 0) ||	//		workflows
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1144") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1100") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1220") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1243") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1340") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1523") == 0) ||	//

		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1524") == 0) ||	//		liberations
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1624") == 0) ||	//		non annulees

		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1074") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1094") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1084") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1264") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0) ||	//		liberations annulees
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1534") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1634") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1164") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1184") == 0) ||	//
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1194") == 0))		//
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}

	poste = initProtoPoste("1509", "XXXXX", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des resultat avant prime benefice - etape 8 type comptable 2 a 5 (autre)
=============================================================================*/
void CalculResultatAvtPBAutre()
{

	DEBUT_FCT("CalculResultatAvtPBAutre");

	T_ProtoPoste poste;
	int i;
	double montant1 = 0;
	double montant2 = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1500") == 0))
		{
			montant1 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)) 		// prime acquise
		{
			montant2 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	if (Kbd_ClePerimetre.TPB > 1 || Kbd_ClePerimetre.TPB < 1) // eviter la division par 0
		montant1 = (montant1 - (Kbd_ClePerimetre.TFG * montant2 * Kbd_ClePerimetre.TPB)) / (1 - Kbd_ClePerimetre.TPB);
	else // si TPB=1 alors montant=0
		montant1 = 0;

	poste = initProtoPoste("1509", "XXXXX", montant1, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des depots prime Const - etape 12
=============================================================================*/
void CalculDepotPrimeConst()
{

	DEBUT_FCT("CalculDepotPrimeConst");

	T_ProtoPoste poste;
	int i;
/************************* Avant modification [016] ***************************
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1503") == 0) ||
		    (strcmp(Kbd_ClePrevision[i].ACMTRS, "1063") == 0))
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant *= Kbd_ClePerimetre.TURRFUN * Kbd_ClePerimetre.TURRCAS;

	poste = initProtoPoste(n_FindACMTRS("81000"), "81000", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
******************************************************************************/

/************************************************************* 
**                Modofiacation [016] START                 **
**                -------------------------                 **
**************************************************************/
	double estim_1063 = 0;
	double estim_1503 = 0;
	double mnt_81000  = 0;
	double mnt_81200  = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1503") == 0 && strcmp(Kbd_ClePrevision[i].DETTRNCOD, "41000") == 0)
		{
			estim_1503 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1063") == 0 && strcmp(Kbd_ClePrevision[i].DETTRNCOD, "40000") == 0)
		{
			estim_1063 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}

	// UC.01 Life Actuary reserves deposits ending (Poste 81000) spec-v24.1
	mnt_81000 = estim_1063 * Kbd_ClePerimetre.TLIFCAS_R * Kbd_ClePerimetre.TLIFRES_R;
	// UC.03 Premium Reserves deposits ending (Poste 81200) spec-v24.1
	mnt_81200 = estim_1503 * Kbd_ClePerimetre.TURRFUN * Kbd_ClePerimetre.TURRCAS;

	// Mettre a jour les postes 81000 et 81200
	poste = initProtoPoste(n_FindACMTRS("81000"), "81000", mnt_81000, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
	poste = initProtoPoste(n_FindACMTRS("81200"), "81200", mnt_81200, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);

/************************************************************* 
**                Modofiacation [016] END                   **
**                -------------------------                 **
**************************************************************/
}

/*=============================================================================
objet:  Fonction Calcul des depots Sinitres a payer Const - etape 13
=============================================================================*/
void CalculDepotSAPConst()
{

	DEBUT_FCT("CalculDepotSAPConst");

	T_ProtoPoste poste;
	int i;
/********************* Avant Modification [016] *******************************
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1243") == 0))
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant *= Kbd_ClePerimetre.TCLMFUN * Kbd_ClePerimetre.TCLMCAS;
	
	poste = initProtoPoste(n_FindACMTRS("81400"), "81400", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
******************************************************************************/

/************************************************************* 
**                Modofiacation [016] START                 **
**                -------------------------                 **
**************************************************************/
	double estim_1243 = 0;
	double mnt_81400  = 0;
	double mnt_81410  = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1243") == 0) && (strcmp(Kbd_ClePrevision[i].DETTRNCOD, "42000") == 0))
		{
			estim_1243 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	// UC.03 Claims Reserves deposits Ending (Poste 81400) spec-v24.1
	mnt_81400 = estim_1243 * Kbd_ClePerimetre.TCLMFUN * Kbd_ClePerimetre.TCLMCAS;
	// le poste 81410 doit etre egale a 0.0 si le poste 81400 n'est pas null (!= 0.0)
	if (mnt_81400 == 0)
	{	// UC.01 Annuity reserves deposits Ending (Poste 81410) spec-v24.1
		mnt_81410 = estim_1243 * Kbd_ClePerimetre.TANNCAS_R * Kbd_ClePerimetre.TANNFUN_R;
	}
	// Mettre a jour les poste 81400 et 81410
	poste = initProtoPoste(n_FindACMTRS("81400"), "81400", mnt_81400, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
	poste = initProtoPoste(n_FindACMTRS("81410"), "81410", mnt_81410, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);

/************************************************************* 
**                Modofiacation [016] END                   **
**                -------------------------                 **
**************************************************************/
}

/*=============================================================================
objet:  Fonction Calcul Prime benefice - etape 9 (autre) etape 10 (survenance)
=============================================================================*/
void CalculPB()
{

	DEBUT_FCT("CalculPB");

	T_ProtoPoste poste;
	int i;
	double montant1 = 0;
	double montant2 = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1509") == 0))			// resultat avant PB
		{
			montant1 += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)) 	// prime acquise
		{
			montant2 += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant1 = -Kbd_ClePerimetre.TPB * (montant1 - Kbd_ClePerimetre.TFG * montant2);

	if (montant1 > 0) montant1 = 0; //

	poste = initProtoPoste(n_FindACMTRS("15000"), "15000", montant1, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des resultat - etape 11 type comptable 1
=============================================================================*/
void CalculResultatSurvenance()
{

	DEBUT_FCT("CalculResultatSurvenance");

	T_ProtoPoste poste;
	int i;
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1509") == 0 ||			// resultat avant PB
		    strcmp(Kbd_ClePrevision[i].ACMTRS, "1160") == 0)
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}

	}

	poste = initProtoPoste("1500", "XXXXX", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des resultat - etape 7 type comptable 2 a 5
=============================================================================*/
void CalculResultatAutre()
{

	DEBUT_FCT("CalculResultatAutre");

	T_ProtoPoste poste;
	int i;
	double prime_acquise = 0;
	double taux_sinistralite = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)) 			// prime acquise
		{
			prime_acquise += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1480") == 0))		// sinistralite
		{
			taux_sinistralite += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	prime_acquise = prime_acquise * taux_sinistralite / 100; // sinistralite en pourcent (ex 40.00) (a la difference des autres taux en 0.4)

	poste = initProtoPoste("1500", "XXXXX", prime_acquise, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des sinistre a payer - LOB30ST ou 31 - etape 7 type comptable 1 (survenance)
=============================================================================*/
void CalculSAPConstSurvenance()
{

	DEBUT_FCT("CalculSAPConstSurvenance");

	T_ProtoPoste poste;
	int i;
	double prime_acquise = 0;
	double taux_sinistralite = 0;
	double montant_sap = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)) 			// prime acquise
		{
			prime_acquise += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1480") == 0))		// sinistralite
		{
			taux_sinistralite += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1074") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1094") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1084") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1264") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1534") == 0) ||
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1634") == 0))
		{
			montant_sap += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}

	montant_sap = - prime_acquise * taux_sinistralite / 100 - montant_sap;  // sinistralite en pourcent (ex 40.00) (a la difference des autres taux en 0.4)

	poste = initProtoPoste(n_FindACMTRS("42000"), "42000", montant_sap, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des sinistres a payer - LOB30ST ou 31 - etape 11 type comptable 2 a 5 (autre)
=============================================================================*/
void CalculSAPConstAutre()
{

	DEBUT_FCT("CalculSAPConstAutre");

	T_ProtoPoste poste;
	int i;
	double montant = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1509") == 0)			// 		resultat avant PB
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if ((strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0) || 	// 		prime acquise

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1011") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1063") == 0) ||	//     ?, peut-être a supprimer , mais TNR
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1140") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1100") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1143") == 0) ||	//		workflows
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1144") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1220") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1340") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1523") == 0) ||	//

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1524") == 0) ||	//		liberations
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1624") == 0) ||	//		non annulees

		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1064") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1074") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1094") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1084") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1264") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1244") == 0) ||	//		liberations annulees
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1534") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1634") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1164") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1184") == 0) ||	//
		         (strcmp(Kbd_ClePrevision[i].ACMTRS, "1194") == 0))		//
		{
			montant -= Kbd_ClePrevision[i].ESTAMT_M;
		}
	}

	poste = initProtoPoste(n_FindACMTRS("42000"), "42000", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des Sinistres - etape 14 type comptable 1 (survenance)
=============================================================================*/
void CalculSinistresSurvenance()
{

	DEBUT_FCT("CalculSinistresSurvenance");

	T_ProtoPoste poste;
	int i;
	double montant = 0;
	double taux = 0;

	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1480") == 0) 		// Sinistralite
		{
			taux += Kbd_ClePrevision[i].ESTAMT_M;
		}
		else if (strcmp(Kbd_ClePrevision[i].ACMTRS, "1510") == 0)	// prime acquise
		{
			montant += Kbd_ClePrevision[i].ESTAMT_M;
		}
	}
	montant = montant * taux / 100; // sinistralite en pourcent (ex 40.00) (a la difference des autres taux en 0.4)

	poste = initProtoPoste(n_FindACMTRS("20000"), "20000", montant, Kbd_ClePrevision[0].GAAP);
	n_UpdatePoste(poste, 1);
}

/*=============================================================================
objet:  Fonction Calcul des CalculSinistres - etape 14 type comptable 2 a 5 (autre)
=============================================================================*/
void CalculSinistresAutre()
{
	DEBUT_FCT("CalculSinistresAutre");

	/* a remplir */
}

/*=============================================================================
objet:  Fonction Calcul des liberations - etape 1
=============================================================================*/
void CalculLiberations()
{
	DEBUT_FCT("CalculLiberations");

	T_ProtoPoste poste;
	char 	tmp[5] = {0};
	int 	i = 0;
	int 	j = 0;
	int 	ret = 0;
	char 	*POSTE_LIB[] = {"1013",
	                      "1063",
	                      "1073",
	                      "1083",
	                      "1093",
	                      "1143",
	                      "1163",
	                      "1183",
	                      "1193",
	                      "1243",
	                      "1263",
	                      "1303",
	                      "1323",
	                      "1503",
	                      "1523",
	                      "1533",
	                      "1603",
	                      "1623",
	                      "1633",
	                      NULL
	                     };
	int nWrite = 1;
	if (Ksz_passage[0]  == '1')
		nWrite = 0;

  // [002] reecriture de toute la boucle pour recuperer la bonne constitution
	for (j = 0; POSTE_LIB[j] != NULL; ++j)
	{
		// Recherche UWY de la constitution
		if (i_LiberationExeP1(atoi(POSTE_LIB[j]), Kbd_ClePerimetre.ACCTYP - '0'))
		{
			// constitution UWY-1 : recherche dans la structure Kbd_ClePrevisionUWYPrec Kn_ClePrevisionUWYPrec
			for (i = 0; i < Kn_ClePrevisionUWYPrec; ++i)
			{
				// test UWY=UWY-1
				// test ACY=ACY-1
				// test GAAP
				// test ACMTRS
				if ( (Kbd_ClePrevisionUWYPrec[i].UWY      ==    Kn_UWY - 1)                          &&
				     (Kbd_ClePrevisionUWYPrec[i].ACY      ==    Kn_ACY - 1)                          &&
				     (Kbd_ClePrevisionUWYPrec[i].GAAP 	  ==	Ksz_ref[PRE_GAAP_NF][0])  &&
				     (strcmp(Kbd_ClePrevisionUWYPrec[i].ACMTRS, POSTE_LIB[j])         == 0)     )
				{
					if (n_FindTsubTRSAsso(&pbd_SubTrsAsso, 1, 1, Kbd_ClePrevisionUWYPrec[i].DETTRNCOD) == -1)
					{
						sprintf(tmp, "%s", Kbd_ClePrevisionUWYPrec[i].ACMTRS);
						tmp[3] = '4';
						if (n_FindTACCPAR(&pbd_TACCPAR, atoi(Kbd_ClePrevisionUWYPrec[i].ACMTRS) + 1) != ERR)
						{
							poste = initProtoPoste(tmp, pbd_TACCPAR.DETTRNCOD_CF, -Kbd_ClePrevisionUWYPrec[i].ESTAMT_M, Kbd_ClePrevisionUWYPrec[i].GAAP);
							n_UpdatePoste(poste, nWrite);
						}
					} else {
						ret = n_GetACMTRS_TRSLNK(pbd_SubTrsAsso.DETTRNCOD2_CF, Kbd_ClePrevisionUWYPrec[i].ACMTRS[0]);
						sprintf(tmp, "%d", ret);
						if (ret == -1)
						{
							sprintf(tmp, "%s", Kbd_ClePrevisionUWYPrec[i].ACMTRS);
							tmp[3] = '4';
						}
						poste = initProtoPoste(tmp, pbd_SubTrsAsso.DETTRNCOD2_CF, -Kbd_ClePrevisionUWYPrec[i].ESTAMT_M, Kbd_ClePrevisionUWYPrec[i].GAAP);
						n_UpdatePoste(poste, nWrite);
					}
				}
			}
		} else {
			// constitution UWY
			for (i = 0; i < Kn_ClePrevisionAcyPrec; ++i)
			{
				if (strcmp(Kbd_ClePrevisionAcyPrec[i].ACMTRS, POSTE_LIB[j]) == 0)
				{
					if (n_FindTsubTRSAsso(&pbd_SubTrsAsso, 1, 1, Kbd_ClePrevisionAcyPrec[i].DETTRNCOD) == -1)
					{
						sprintf(tmp, "%s", Kbd_ClePrevisionAcyPrec[i].ACMTRS);
						tmp[3] = '4';
						if (n_FindTACCPAR(&pbd_TACCPAR, atoi(Kbd_ClePrevisionAcyPrec[i].ACMTRS) + 1) != ERR)
						{
							poste = initProtoPoste(tmp, pbd_TACCPAR.DETTRNCOD_CF, -Kbd_ClePrevisionAcyPrec[i].ESTAMT_M, Kbd_ClePrevisionAcyPrec[i].GAAP);
							n_UpdatePoste(poste, nWrite);
						}
					} else {
						ret = n_GetACMTRS_TRSLNK(pbd_SubTrsAsso.DETTRNCOD2_CF, Kbd_ClePrevisionAcyPrec[i].ACMTRS[0]);
						sprintf(tmp, "%d", ret);
						if (ret == -1)
						{
							sprintf(tmp, "%s", Kbd_ClePrevisionAcyPrec[i].ACMTRS);
							tmp[3] = '4';
						}
						poste = initProtoPoste(tmp, pbd_SubTrsAsso.DETTRNCOD2_CF, -Kbd_ClePrevisionAcyPrec[i].ESTAMT_M, Kbd_ClePrevisionAcyPrec[i].GAAP);
						n_UpdatePoste(poste, nWrite);
					}
				}
			}
		}

	}
}

/*=============================================================================
objet:  Fonction Neutraliser les liberations - appel si pas de primes
=============================================================================*/
void NeutraliserLiberations()
{
	char dettrncod_cons[6];
	char acmtrs_cons[5];
	T_ProtoPoste poste;
	int i;

	DEBUT_FCT("NeutraliserLiberations");

	for (i = 0; i < Kn_ClePrevision; i++)
	{
		// on traite seulement les postes non nuls
		if (Kbd_ClePrevision[i].ESTAMT_M != 0)
		{
			// if Kbd_ClePrevision[i].DETTRNCOD est liberation ;
			// creer constit
			//   determiner dettrncod
			sprintf(dettrncod_cons, "%d", n_FindTsubTRSAssoCons(1, 1, Kbd_ClePrevision[i].DETTRNCOD));
			if (strcmp(dettrncod_cons,"-1") != 0)
			{
				// determiner acmtrs
				sprintf(acmtrs_cons,"%d", n_GetACMTRS_TRSLNK(dettrncod_cons, Kbd_ClePrevision[i].ACMTRS[0]));
				if (strcmp(acmtrs_cons,"-1") == 0)
				{
					sprintf(acmtrs_cons, "%s", Kbd_ClePrevision[i].ACMTRS);
					acmtrs_cons[3] = '3'; 
				}
				//   creer/maj poste
				poste = initProtoPoste(acmtrs_cons, dettrncod_cons, -Kbd_ClePrevision[i].ESTAMT_M, Kbd_ClePrevision[i].GAAP);
				n_UpdatePoste(poste, 1);
			}
		}
	}
}

/*=============================================================================
objet:  Fonction qui écrit les Calculs dans le fichier de sortie
=============================================================================*/
void EcritureTableau(char **ptb_InRec, char crible)
{
	DEBUT_FCT("EcritureTableau");

	int 	i = 0;
	char 	tmp[25] = {'\0'};
	char    gaap[2] = {Kbd_ClePrevision[i].GAAP, '\0'};
	char  trs_buff[9] = {0};

	for (i = 0; i < Kn_ClePrevision; i++)
	{
		if (Kbd_ClePrevision[i].iswrite == 1)
		{
			sprintf(tmp, "%.3lf", 		Kbd_ClePrevision[i].ESTAMT_M);
			Ksz_ref[PRE_ESTMNT_M] 		= tmp;
			Ksz_ref[PRE_CRE_D] 			= Ksz_CRE_D;
			Ksz_ref[PRE_LSTUPD_D]		= Ksz_CRE_D;
			Ksz_ref[PRE_ACMTRS_NT] 		= Kbd_ClePrevision[i].ACMTRS;
			Ksz_ref[PRE_DETTRNCOD_CF] 	= Kbd_ClePrevision[i].DETTRNCOD;
			sprintf(trs_buff, "%i", n_GetDETTRS(Kbd_ClePrevision[i].DETTRNCOD, Kbd_ClePrevision[i].ACMTRS[0]));
			Ksz_ref[PRE_DETTRS_CF]    = trs_buff;
			Ksz_ref[PRE_ORICOD_LS] 		= ORICOD_LS;
			Ksz_ref[PRE_BATCH_B] 		= "1";
			Ksz_ref[PRE_GAAP_NF] 		= gaap;
			Ksz_ref[PRE_BALSHTMTH_NF] = ksz_blsmth;     //[004]
			strcpy(Ksz_ref[PRE_CREUSR_CF], "dbo");
			strcpy(Ksz_ref[PRE_LSTUPDUSR_CF], "dbo");
			n_WriteCols(Kp_LifestAutoO1Fil, Ksz_ref, SEPARATEUR, 0);
		}
	}
}

/*=============================================================================
objet:  Fonction qui traite les LOB 30 short Term ou LOB 31 type comptable 1 (survenance)
=============================================================================*/
void TraitementLob30ST31Survenance(char **ptb_InRec, char crible)
{
	DEBUT_FCT("TraitementLob30ST31Survenance");

	CalculLiberations();
	if ( Ksz_passage[0]  == '1' )
	{
		CalculPrimeNonAcquise();
		CalculPrimeAcquise();
		CalculCommissions();
		CalculCourtage();
		CalculFARconst();
		CalculSAPConstSurvenance();
	}
	if ( Ksz_passage[0]  == '2' )
	{
		CalculInteretDepot();
		CalculResultatAvtPBSurvenance();
		CalculPB();
		CalculResultatSurvenance();
		CalculDepotPrimeConst();
		CalculDepotSAPConst();
		//CalculSinistresSurvenance(); //[001]
	}
	EcritureTableau(ptb_InRec, crible);
}

/*=============================================================================
objet:  Fonction qui traite les LOB 30 short Term ou LOB 31 type comptable 2 a 5
=============================================================================*/
void TraitementLob30ST31Autre(char **ptb_InRec, char crible)
{
	DEBUT_FCT("TraitementLob30ST31Autre");

	CalculLiberations();
	if ( Ksz_passage[0]  == '1' )
	{
		CalculPrimeNonAcquise();
		CalculPrimeAcquise();
		CalculCommissions();
		CalculCourtage();
		CalculFARconst();
		CalculResultatAutre();
		CalculResultatAvtPBAutre();
		CalculPB();
		CalculInteretDepot();
		CalculSAPConstAutre();
	}
	if ( Ksz_passage[0]  == '2' )
	{
		CalculDepotPrimeConst();
		CalculDepotSAPConst();
		CalculSinistresAutre();
	}
	EcritureTableau(ptb_InRec, crible);
}

/*=============================================================================
objet:  Fonction qui traite les LOB 30 Long Term type comptable 1 (survenance)
=============================================================================*/
void TraitementLob30LTSurvenance(char **ptb_InRec, char crible)
{
	DEBUT_FCT("TraitementLob30LTSurvenance");

	CalculLiberations();
	if ( Ksz_passage[0]  == '1' )
	{
		CalculPrimeNonAcquise();
		CalculPrimeAcquise();
		CalculCommissions();
		CalculCourtage();
		CalculFARconst();
		CalculProvisionConstSurvenance();
	}
	if ( Ksz_passage[0]  == '2' )
	{
		CalculInteretDepot();
		CalculResultatAvtPBSurvenance();
		CalculPB();
		CalculResultatSurvenance();
		CalculDepotPrimeConst();
		CalculDepotSAPConst();
		//CalculSinistresSurvenance(); //[001]
	}
	EcritureTableau(ptb_InRec, crible);
}

/*=============================================================================
objet:  Fonction qui traite les LOB 30 Long Term type comptable 2 a 5
=============================================================================*/
void TraitementLob30LTAutre(char **ptb_InRec, char crible)
{
	DEBUT_FCT("TraitementLob30LTAutre");

	CalculLiberations();
	if ( Ksz_passage[0]  == '1' )
	{
		CalculPrimeNonAcquise();
		CalculPrimeAcquise();
		CalculCommissions();
		CalculCourtage();
		CalculFARconst();
		CalculResultatAutre();
		CalculResultatAvtPBAutre();
		CalculPB();
		CalculInteretDepot();
		CalculProvisionConstAutre();
	}
	if ( Ksz_passage[0]  == '2' )
	{
		CalculDepotPrimeConst();
		CalculDepotSAPConst();
		CalculSinistresAutre();
	}
	EcritureTableau(ptb_InRec, crible);
}

 T_ProtoPoste initProtoPoste(char *acmtrs, char *dettrncod, double montant, char gaap)
 {
 	T_ProtoPoste poste;

	strcpy(poste.ACMTRS, acmtrs);
	strcpy(poste.DETTRNCOD, dettrncod);
	poste.ESTAMT_M = montant;
	poste.GAAP = gaap;

 	RETURN_VAL(poste);
 }

/*==========================================================================
	[007]
	Objet: Recherche du poste dans Kbd_ClePrevision
	Param: acmtrs , dettrncod
	Return: indexe du Poste ou -1 si non trouve 
==========================================================================*/
int findPoste(char *acmtrs, char *dettrncod)
{
	int i;

	// Annulation des postes existant avec meme DETTRNCOD mais ACMTRS different
	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (strcmp(Kbd_ClePrevision[i].ACMTRS, acmtrs) == 0
		    && strcmp(Kbd_ClePrevision[i].DETTRNCOD, dettrncod) == 0)
		{
			return i;
		}
	}
	return -1;	
}

/*==========================================================================
	[007]
	Objet: - nettoyage du montant et annulation des postes existants si DETTRNCOD incorrect
		   - MAJ du poste si il existe 
		   - Ajout du poste si il n'existe pas
==========================================================================*/
int n_UpdatePoste(T_ProtoPoste poste, int nWrite)
{
	int 	indexPoste = -1;
	int 	i = 0;
	char 	TmpACMTRS[5];
	double  TmpESTAMT;

	strcpy(TmpACMTRS, poste.ACMTRS);
	TmpESTAMT = poste.ESTAMT_M;

	if (strcmp(poste.ACMTRS, "0") == 0)
		RETURN_VAL(OK);

	// plafonnage du montant selon limite du champs en base de donnees
	if (poste.ESTAMT_M > 999999999999999.0)
		poste.ESTAMT_M = 999999999999999.0;
	if (poste.ESTAMT_M < -99999999999999.0)
		poste.ESTAMT_M = -99999999999999.0;

	// Annulation des postes existant avec meme DETTRNCOD mais ACMTRS different
	for (i = 0; i < Kn_ClePrevision; ++i)
	{
		if (Kbd_ClePrevision[i].iswrite == 0
		    && strcmp(Kbd_ClePrevision[i].ACMTRS, TmpACMTRS) != 0
		    && strcmp(Kbd_ClePrevision[i].DETTRNCOD, poste.DETTRNCOD) == 0
		    && strcmp(Kbd_ClePrevision[i].DETTRNCOD, "XXXXX") != 0)
		{
			strcpy(poste.ACMTRS, Kbd_ClePrevision[i].ACMTRS);
			poste.ESTAMT_M = 0;
			setPoste(poste, i);
		}
	}
	strcpy(poste.ACMTRS, TmpACMTRS);
	poste.ESTAMT_M = TmpESTAMT;

	if ((indexPoste = findPoste(poste.ACMTRS, poste.DETTRNCOD)) == -1)
	{		
		ajouterPosteClean(poste);
		indexPoste = Kn_ClePrevision - 1;
		if (nWrite == 0)
			Kbd_ClePrevision[indexPoste].iswrite = nWrite;
		RETURN_VAL(OK);
	}
	setPoste(poste, indexPoste);
	if (nWrite == 0)
		Kbd_ClePrevision[indexPoste].iswrite = nWrite;
	RETURN_VAL(OK);
}


/*==========================================================================
     Objet :    Ajout d'un poste dans le tableau Previsions
===========================================================================*/
void ajouterPosteClean(T_ProtoPoste poste)
{
	setPoste(poste, Kn_ClePrevision);
	++Kn_ClePrevision;
}


/*==========================================================================
	[007]
    Objet :    Rempli correctement un poste avec les informations
     		   acmtrs, dettrncod, montant, gaap
===========================================================================*/
void setPoste(T_ProtoPoste poste, int indexPoste)
{
	strcpy(Kbd_ClePrevision[indexPoste].DETTRNCOD, poste.DETTRNCOD);
	strcpy(Kbd_ClePrevision[indexPoste].ACMTRS, poste.ACMTRS);
	Kbd_ClePrevision[indexPoste].GAAP = poste.GAAP;
	Kbd_ClePrevision[indexPoste].ESTAMT_M = poste.ESTAMT_M;
	Kbd_ClePrevision[indexPoste].iswrite = 1;
	if (n_RechSUBTRSESBPROP(&pbd_SubTrsesBrop, poste.DETTRNCOD, Kbd_ClePerimetre.SSD, Kbd_ClePerimetre.ESB) != -1)
	{
		switch (poste.GAAP)
		{
		case '1':
			if (pbd_SubTrsesBrop.GAAP1TRS_CT == 3)
				Kbd_ClePrevision[indexPoste].ESTAMT_M = 0;
			break;

		case '2':
			if (pbd_SubTrsesBrop.GAAP2TRS_CT == 3)
				Kbd_ClePrevision[indexPoste].ESTAMT_M = 0;
			break;

		case '3':
			if (pbd_SubTrsesBrop.GAAP3TRS_CT == 3)
				Kbd_ClePrevision[indexPoste].ESTAMT_M = 0;
			break;

		case '4':
			if (pbd_SubTrsesBrop.GAAP4TRS_CT == 3)
				Kbd_ClePrevision[indexPoste].ESTAMT_M = 0;
			break;

		case '5':
			if (pbd_SubTrsesBrop.GAAP5TRS_CT == 3)
				Kbd_ClePrevision[indexPoste].ESTAMT_M = 0;
			break;
		}
	}
}

/*==========================================================================
     Objet :    Initialisation de la structure TRSASSO
===========================================================================*/
void ChargeClePerim(char **ptb_Perim)
{
	strcpy(Kbd_ClePerimetre.LOB_CF, ptb_Perim[PER_LOB_CF]);
	strcpy(Kbd_ClePerimetre.NAT_CF, ptb_Perim[PER_NAT_CF]);
	strcpy(Kbd_ClePerimetre.SSD,	ptb_Perim[PER_SSD_CF]);
	strcpy(Kbd_ClePerimetre.ESB,	ptb_Perim[PER_ACCESB_CF]);
	if (ptb_Perim[PER_USGAAP_CT] == NULL)
		printf("ERROR -- PERIM pas de USGAAP\n");
	else
		Kbd_ClePerimetre.USGAAP = ptb_Perim[PER_USGAAP_CT][0];
	if (ptb_Perim[PER_ACCADMTYP_CT] == NULL)
		printf("ERROR -- PERIM pas de ACCADMTYP\n");
	else
		Kbd_ClePerimetre.ACCTYP = ptb_Perim[PER_ACCADMTYP_CT][0];
	Kbd_ClePerimetre.TPNA       = atof(ptb_Perim[PER_URRCAL_R]);
	Kbd_ClePerimetre.TCOM       = atof(ptb_Perim[PER_FIXCOM_R]);
	Kbd_ClePerimetre.TSURCOM    = atof(ptb_Perim[PER_OVRCOM_R]);
	Kbd_ClePerimetre.TCOURTAGE1 = atof(ptb_Perim[PER_PRDBRK_R]);
	Kbd_ClePerimetre.TCOURTAGE2 = atof(ptb_Perim[PER_ACCBRK_R]);
	Kbd_ClePerimetre.TPB 		= atof(ptb_Perim[PER_PRFCOM_R]);
	Kbd_ClePerimetre.TFG		= atof(ptb_Perim[PER_CTBGENFEE_R]);
	Kbd_ClePerimetre.TCLMINT_R 	= atof(ptb_Perim[PER_CLMFUNINT_R]);
	Kbd_ClePerimetre.TURRINT_R 	= atof(ptb_Perim[PER_URRFUNINT_R]);
	Kbd_ClePerimetre.TCLMFUN 	= atof(ptb_Perim[PER_CLMFUN_R]);
	Kbd_ClePerimetre.TURRFUN 	= atof(ptb_Perim[PER_URRFUN_R]);
	Kbd_ClePerimetre.TCLMCAS 	= atof(ptb_Perim[PER_CLMFUNCAS_R]);
	Kbd_ClePerimetre.TURRCAS 	= atof(ptb_Perim[PER_URRFUNCAS_R]);
	Kbd_ClePerimetre.TANNINT_R 	= atof(ptb_Perim[PER_ANNFUNINT_R]);   // [012]
	/* Modification [016] START */
	Kbd_ClePerimetre.TCLMVAR_B	= atoi(ptb_Perim[PER_CLMFUNVARINT_B]);// [016]
	Kbd_ClePerimetre.TURRVAR_B	= atoi(ptb_Perim[PER_URRFUNVARINT_B]);// [016]
	Kbd_ClePerimetre.TANNVAR_B	= atoi(ptb_Perim[PER_ANNFUNVARINT_B]);// [016]
	Kbd_ClePerimetre.TLIFVAR_B	= atoi(ptb_Perim[PER_LIFRESVARINT_B]);// [016]
	Kbd_ClePerimetre.TCLMEST_R	= atof(ptb_Perim[PER_CLMFUNESTINT_R]);// [016]
	Kbd_ClePerimetre.TURREST_R	= atof(ptb_Perim[PER_URRFUNESTINT_R]);// [016]
	Kbd_ClePerimetre.TANNCAS_R	= atof(ptb_Perim[PER_ANNFUNCAS_R]);   // [016]
	Kbd_ClePerimetre.TANNEST_R	= atof(ptb_Perim[PER_ANNFUNESTINT_R]);// [016]
	Kbd_ClePerimetre.TLIFCAS_R	= atof(ptb_Perim[PER_LIFRESCAS_R]);   // [016]
	Kbd_ClePerimetre.TLIFINT_R	= atof(ptb_Perim[PER_LIFRESINT_R]);   // [016]
	Kbd_ClePerimetre.TLIFEST_R	= atof(ptb_Perim[PER_LIFRESESTINT_R]);// [016]
	Kbd_ClePerimetre.TANNFUN_R	= atof(ptb_Perim[PER_ANNFUN_R]);      // [016]
	Kbd_ClePerimetre.TLIFRES_R	= atof(ptb_Perim[PER_LIFRES_R]);      // [016]
	/* Modification [016] END */
}

int n_GetACMTRS_TRSLNK(char dettrncod[5], char idx0ACMTRS)
{
	char 	dettrs[9] = {0,
	                   '1',
	                   dettrncod[0],
	                   dettrncod[1],
	                   dettrncod[2],
	                   dettrncod[3],
	                   dettrncod[4],
	                   '0',
	                   '\0'
	                  };

	if (strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0)
	{
		if (idx0ACMTRS == '1')
			dettrs[0] = '3';
		else if (idx0ACMTRS == '2')
			dettrs[0] = '4';
	}
	else if (strcmp(Kbd_ClePerimetre.LOB_CF, "31") == 0)
	{
		if (idx0ACMTRS == '1')
			dettrs[0] = '1';
		else if (idx0ACMTRS == '2')
			dettrs[0] = '2';
	}
	RETURN_VAL(n_RechACMTRS(dettrs));
}

// ----------------------------------------------------------------------------
// objet:  Lit le fichier binaire des postes et les met en memoire
// ----------------------------------------------------------------------------
int n_ChargerTRSLNK(FILE* Kp_TrslnkFil)
{
	int n_EOF = 0;
	T_TRSLNK bd_Lu;

	DEBUT_FCT("n_ChargerTRSLNK");

	Kn_NbLigTrslnk = 0;

	/* Tant que la fin de fichier n'est pas atteinte,... */
	while (n_EOF == 0)
	{
		if (fread(&bd_Lu, sizeof(T_TRSLNK), 1, Kp_TrslnkFil) <= 0)
			n_EOF = 1;
		else
		{
			//[011]
			if ( Kn_NbLigTrslnk + 1 >=  NB_MAX_TRSLNK )//2000
			{
				RETURN_VAL(ERR);
			}
			else if (bd_Lu.PRS_CF == 500)
				// Enregistrement ecrit dans le tableau
				Kbd_TRSLNK[Kn_NbLigTrslnk++] = bd_Lu;
		}
	}

	RETURN_VAL(OK);
}

/*==========================================================================
       Objet :    Recuperer l'ACMTR grace au DETTRNCOD selon LOB
       Nom:       n_FindACMTRS

       Parametres:
                  pointure sur stucture T_ACCPAR
                  Acmtrs

       Retour:    0/-1
===========================================================================*/
char* n_FindACMTRS(char* dettrncod) 
{
	static char acmtrs[5];
	int n_indice = 0;

	DEBUT_FCT("n_FindACMTRS");

	while (1 == 1)
	{
		if ((strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0 &&
		     strncmp("3", Kbd_TRSLNK[n_indice].DETTRS_CF, 1) == 0) || // 3 for Assumed Life
		    (strcmp(Kbd_ClePerimetre.LOB_CF, "31") == 0 &&
		     strncmp("1", Kbd_TRSLNK[n_indice].DETTRS_CF, 1) == 0)) // 1 for Assumed Non Life

		{
			// S'ils sont egaux, retourner l'acmtrs
			if (strncmp(dettrncod, Kbd_TRSLNK[n_indice].DETTRS_CF + 2, 5) == 0)
			{
				snprintf(acmtrs, 5, "%d", Kbd_TRSLNK[n_indice].ACMTRS_NT);
				return acmtrs;
			}
		}
		// Ligne suivante
		n_indice++;

		// Si on est a la fin du tableau, echec
		if (n_indice >= Kn_NbLigTrslnk)
			return "0";
	}

	return acmtrs;
}

/*==========================================================================
       Objet :    Recuperer le dettrs grace au dettrncod
       Nom:       n_GetDETTRS

       Parametres:
                  Dettrncod

       Retour:    0/-1
===========================================================================*/
int n_GetDETTRS(char * dettrncod, char idx0ACMTRS)
{
	DEBUT_FCT("n_GetDETTRS");

	char 	dettrs[9] = {0,
	                   '1',
	                   dettrncod[0],
	                   dettrncod[1],
	                   dettrncod[2],
	                   dettrncod[3],
	                   dettrncod[4],
	                   '0',
	                   '\0'
	                  };

	if (strcmp(Kbd_ClePerimetre.LOB_CF, "30") == 0)
	{
		if (idx0ACMTRS == '1')
			dettrs[0] = '3';
		else if (idx0ACMTRS == '2')
			dettrs[0] = '4';
	}
	else if (strcmp(Kbd_ClePerimetre.LOB_CF, "31") == 0)
	{
		if (idx0ACMTRS == '1')
			dettrs[0] = '1';
		else if (idx0ACMTRS == '2')
			dettrs[0] = '2';
	}

	RETURN_VAL(atoi(dettrs));
}

/*==========================================================================
       Objet :    Recuperer le dettrncod grace a l acmtrs
       Nom:       n_FindTACCPAR

       Parametres:
                  pointure sur stucture T_ACCPAR
                  Acmtrs

       Retour:    0/-1
===========================================================================*/
int n_FindTACCPAR(T_ACCPAR * pbd_lu, short Acmtrs)
{
	DEBUT_FCT("n_FindTACCPAR");
	return n_FindTsubTAACPAR(pbd_lu, Acmtrs);
}

/*==========================================================================
       Objet :    Retire les poste à recalculer du tableau
       Nom:       MiseAZeroDesPostes

       Parametres:
                  

       Retour:    nouveau pointeur
===========================================================================*/
void MiseAZeroDesPostes()
{
	DEBUT_FCT("MiseAZeroDesPostes");
	int i;

	for (i = 0; i < Kn_ClePrevision; i++)
	{
		if (//Kbd_ClePrevision[i].iswrite != 1 &&       //[010]
		    atoi(Kbd_ClePrevision[i].ACMTRS) != 1010 &&
		    atoi(Kbd_ClePrevision[i].ACMTRS) != 1480)
		{
			Kbd_ClePrevision[i].ESTAMT_M = 0;
			Kbd_ClePrevision[i].iswrite = 1;            //[010]
			// if (Ksz_passage[0]  == '1') Kbd_ClePrevision[i].iswrite = 0; //[014]
			if ( Ksz_passage[0]  == '1' && ( strcmp(Kbd_ClePrevision[i].ACMTRS, "1340") == 0 ||
					    strcmp(Kbd_ClePrevision[i].ACMTRS, "1303") == 0  ||
                                            strcmp(Kbd_ClePrevision[i].ACMTRS, "1323") == 0
			))   Kbd_ClePrevision[i].iswrite = 0;       //[14]
		}

	}
}

/*==========================================================================
       Objet :    [002] Ajouter les previsions actuelles dans le tableau UWYPrec
       Nom:       n_SaveUWYPrec

       Parametres: aucun

       Retour:    aucun
===========================================================================*/
void n_SaveUWYPrec()
{
	DEBUT_FCT("n_SaveUWYPrec");
	int i;

	for (i = 0; i < Kn_ClePrevision; i++)
	{
		strcpy(Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].ACMTRS,    Kbd_ClePrevision[i].ACMTRS);
		strcpy(Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].DETTRNCOD, Kbd_ClePrevision[i].DETTRNCOD);
		Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].GAAP 	 = Kbd_ClePrevision[i].GAAP;
		Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].ESTAMT_M = Kbd_ClePrevision[i].ESTAMT_M;
		Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].ACY      = Kn_ACY;
		Kbd_ClePrevisionUWYPrec[Kn_ClePrevisionUWYPrec].UWY      = Kn_UWY;
		Kn_ClePrevisionUWYPrec++;
	}
}

/*==========================================================================
       Objet :    Identifier le type de contrat et retourner le bon mode.	[005]
       Nom:       n_DetectType

       Parametres: ligne venant du fichier IARVPERICASE4

       Retour:    type 1, 4				 1
       			  type 2, 3, 5			 2
       			  defaut				-1
===========================================================================*/
int n_DetectType(char **Pericase_line)
{
	DEBUT_FCT("n_DetectType");
	char type = Pericase_line[PER_ACCADMTYP_CT][0];

	if (type == '1' )
		return TYPE1;
	else if (type == '2' || type == '3' || type == '4' || type == '5')
		return TYPE2345;
	return -1;
}

/************************************************************* 
**                Modofiacation [016] START                 **
**                -------------------------                 **
**************************************************************/

/*************************************************************
** Object     : Calcule du Poste 82100 selon la spec v24.1  **
** Nom        : n_CalculPost82100                           **
** Retour     : la valeur du Poste 82100                    **
** Parametres : Poste detail 81300 , Poste detail 81100     **
**************************************************************/
double n_CalculPoste82100 (double poste_81300, double poste_81100)
{
	DEBUT_FCT("n_CalculPoste82100");
	double mnt82100 = 0;

	// UC.01 UPR fixed ET LAR fixed
	if (strcmp(ptb_Perim[PER_URRFUNINT_R], "") != 0 && strcmp(ptb_Perim[PER_LIFRESINT_R], "") != 0)
	{
		mnt82100 = (poste_81300 * Kbd_ClePerimetre.TURRINT_R) + (poste_81100 * Kbd_ClePerimetre.TLIFINT_R);
	}
	// UC.02 UPR fixed ET LAR estimated
	else if (strcmp(ptb_Perim[PER_URRFUNINT_R], "") != 0 && Kbd_ClePerimetre.TLIFVAR_B == 1)
	{
		mnt82100 = (poste_81300 * Kbd_ClePerimetre.TURRINT_R) + (poste_81100 * Kbd_ClePerimetre.TLIFEST_R);
	}
	// UC.03 UPR Estimated ET LAR fixed
	else if (Kbd_ClePerimetre.TURRVAR_B == 1 && strcmp(ptb_Perim[PER_LIFRESINT_R], "") != 0)
	{
		mnt82100 = (poste_81300 * Kbd_ClePerimetre.TURREST_R) + (poste_81100 * Kbd_ClePerimetre.TLIFINT_R);
	}
	// UC.04 UPR Estimated ET LAR Estimated
	else if (Kbd_ClePerimetre.TURRVAR_B == 1 && Kbd_ClePerimetre.TLIFVAR_B == 1)
	{
		mnt82100 = (poste_81300 * Kbd_ClePerimetre.TURREST_R) + (poste_81100 * Kbd_ClePerimetre.TLIFEST_R);
	}

	return mnt82100;
}

/*************************************************************
** Object     : Calcule du Poste 82200 selon la spec v24.1  **
** Nom        : n_CalculPost82200                           **
** Retour     : la valeur du Poste 82200                    **
** Parametres : poste detail 81500, poste detail 81510      **
**************************************************************/
double n_CalculPoste82200 (double poste_81500, double poste_81510)
{
	DEBUT_FCT("n_CalculPoste82200");
	double mnt82200 = 0;

	// UC.05 OLR fixed interest rate ET (AR fixed interest rate ou AR estimated interest rate)
	if (strcmp(ptb_Perim[PER_CLMFUNINT_R], "") != 0) 
	{
		mnt82200 = poste_81500 * Kbd_ClePerimetre.TCLMINT_R;
	}
	// UC.06 OLR estimated interest rate ET AR fixed interest rate
	else if (strcmp(ptb_Perim[PER_ANNFUNINT_R], "") != 0)
	{
		mnt82200 = poste_81510 * Kbd_ClePerimetre.TANNINT_R;
	}
	// UC.07 OLR Estimated interest rate ET AR estimated interest rate
	else if (Kbd_ClePerimetre.TCLMVAR_B == 1 && Kbd_ClePerimetre.TANNVAR_B == 1)
	{
		if (strcmp(ptb_Perim[PER_CLMFUNESTINT_R], "") != 0)
		{
			mnt82200 = poste_81500 * Kbd_ClePerimetre.TCLMEST_R;
		}
		else
		{
			mnt82200 = poste_81510 * Kbd_ClePerimetre.TANNEST_R;
		}
	}
	
	return mnt82200;
}

/************************************************************* 
**                Modofiacation [016] END                   **
**                -------------------------                 **
**************************************************************/
