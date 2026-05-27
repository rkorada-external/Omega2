/*==============================================================================
nom de l'application          : Creation des complements FWH
nom du source                 : ESTC2171.c
revision                      : $Revision: 1 $
date de creation              : 20/02/2025
auteur                        : S.Behague
references des specificati_ons :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Creation du fichier des Liberations.


------------------------------------------------------------------------------
[001] 23/02/2025 sbehague: SPIRA 112750 - FWH complement - Multi devise and ASIA issue
[==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define GT_TRNCOD5_CF   76
#define GT_LICLRC       77
#define AMT_GT          78
#define AMT_FWH         79
#define AMT_PROJ        80
#define UWY_GT          81
#define UWY_PROJ        82
#define ASIAFLAG        83
#define MSTRFLAG        84
#define USFLAG          85
/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE				*Kp_FWHFile;		       // pointeur sur les FWH en entree
FILE				*Kp_ProjectionFile;		 // pointeur sur les Projection en entree
FILE				*Kp_OutFWHFile;		     // pointeur sur les FWH Accrual en sortie


T_RUPTURE_VAR		    bd_RuptFWH;		 // gestion rupture sur FWH
T_RUPTURE_SYNC_VAR	bd_RuptGT;	   // gestion rupture sur Projection


// Function FWH (Pere)
int n_InitFWH(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFWH(char **pbd_InRec_Cur);

// Function GT (Fils)
int n_InitGT(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncGT (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneGT(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);


// Variales globales


/*==============================================================================
objet :     point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc , char *argv[])
{
	// Init signal
	InitSig();

	if (n_BeginPgm(argc, argv) == ERR)
	  ExitPgm ( ERR_XX , "" );

	// Open output file
	if (n_OpenFileAppl("ESTC2171_O1", "wt", &Kp_OutFWHFile) == ERR)
		ExitPgm(ERR_XX, "");

	// Init FWH struct
	if (n_InitFWH(&bd_RuptFWH))
		ExitPgm (ERR_XX, "");

	// Init GT struct
	if (n_InitGT(&bd_RuptGT))
		ExitPgm(ERR_XX, "");

	// Start of file processing
	if (n_ProcessingRuptureVar(&bd_RuptFWH) == ERR)
		ExitPgm(ERR_XX, "");

	// Close file
	if (n_CloseFileAppl("ESTC2171_I1", &(bd_RuptFWH.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl ("ESTC2171_I2", &(bd_RuptGT.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2171_O1", &Kp_OutFWHFile) == ERR)
		ExitPgm(ERR_XX, "");


	if (n_EndPgm() == ERR)
	  ExitPgm(ERR_XX, "");
	exit(0);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour :    0
==============================================================================*/
int n_InitFWH(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitFWH");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2171_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);
		
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->n_ActionLigne = n_ActionLigneFWH;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitGT");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR)) ;
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2171_I2", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncGT;
	pbd_Rupt->n_ActionLigne = n_ActionLigneGT;
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFils;
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPere;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(OK);
}


/*==============================================================================
objet :
	fonction de test de synchro
retour :
	0		---> pbd_InRecOwner = pbd_InRecChild (egalite de rubriques a synchroniser)
	> 0		---> pbd_InRecOwne> > pbd_InRecChild
	< 0		---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGT (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret=0;

	DEBUT_FCT("n_ConditionSyncMvt");

 if ((ret = strcmp(pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0)
		RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[GT_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[GT_CUR_CF], pbd_InRecChild[GT_CUR_CF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[GT_TRNCOD5_CF], pbd_InRecChild[GT_TRNCOD5_CF])) != 0)
		RETURN_VAL(ret);

	RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFWH(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLigneFWH");

  n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur);

  RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des FWH synchronisee
        avec les Projections
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGT(
  char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
  char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	double d_ProjAMT = 0;
  int    i_uwy = 1901;
  char sz_amt[22];
  char sz_uwy[5];
  
#define AMT_GT          78
#define AMT_FWH         79
#define AMT_PROJ        80
#define UWY_GT          81
#define UWY_PROJ        82
  // Ecriture infos fichier compta
  ptb_InRecOwner[AMT_GT]=ptb_InRecChild[GT_AMT_M];
  ptb_InRecOwner[UWY_GT]=ptb_InRecChild[GT_UWY_NF];
  
  // Ecriture infos fichier FWH
  ptb_InRecOwner[AMT_FWH]=ptb_InRecOwner[GT_AMT_M];
  
  // Ecriture infos fichier Proj
  sprintf(sz_amt,"%.3lf",d_ProjAMT);
  sprintf(sz_uwy,"%d",i_uwy);
  
  ptb_InRecOwner[AMT_PROJ]=sz_amt;
  ptb_InRecOwner[UWY_PROJ]=sz_uwy;
  
  n_WriteCols(Kp_OutFWHFile, ptb_InRecOwner, '~', 0);
  
  RETURN_VAL (OK);
}

/*==============================================================================
objet :
        fonction lancee quand le fichier FWH participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{
	// FWH I4I sans GT
	
  double d_ProjAMT = 0;
  int    i_uwy = 1901;
  char sz_amt[22];
  char sz_uwy[5];
  
  sprintf(sz_amt,"%.3lf",d_ProjAMT);
  sprintf(sz_uwy,"%d",i_uwy);
  
  // Ecriture infos fichier compta
  ptb_InRec[AMT_GT]=sz_amt;
  ptb_InRec[UWY_GT]=sz_uwy;
  
  // Ecriture infos fichier FWH
  ptb_InRec[AMT_FWH]=ptb_InRec[GT_AMT_M];
  
  // Ecriture infos fichier Proj
  ptb_InRec[AMT_PROJ]=sz_amt;
  ptb_InRec[UWY_PROJ]=sz_uwy;
  
  
  n_WriteCols(Kp_OutFWHFile, ptb_InRec, '~', 0);

  RETURN_VAL (OK);

}


/*==============================================================================
objet :
        fonction lancee quand le fichier GT participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{ 
	// GT Sans FWH I4I
  double d_ProjAMT = 0;
  int    i_uwy = 1901;
  char sz_amt[22];
  char sz_uwy[5];
  
  sprintf(sz_amt,"%.3lf",d_ProjAMT);
  sprintf(sz_uwy,"%d",i_uwy);
  
  ptb_InRec[AMT_GT]=ptb_InRec[GT_AMT_M];
  ptb_InRec[UWY_GT]=ptb_InRec[GT_UWY_NF];
  ptb_InRec[AMT_FWH]=sz_amt;
  
  // Ecriture infos fichier Proj
  ptb_InRec[AMT_PROJ]=sz_amt;
  ptb_InRec[UWY_PROJ]=sz_uwy;
  
  n_WriteCols(Kp_OutFWHFile, ptb_InRec, '~', 0);
  
  RETURN_VAL (OK);
}