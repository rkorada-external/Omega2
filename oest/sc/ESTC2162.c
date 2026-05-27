/*==============================================================================
nom de l'application          : Creation des complements FWH
nom du source                 : ESTC2162.c
revision                      : $Revision: 1 $
date de creation              : 03/01/2025
auteur                        : S.Behague
references des specificati_ons :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Creation du fichier des Liberations.


------------------------------------------------------------------------------
[001] 03/01/2025 sbehague: SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
[002] 14/02/2025 sbehague: SPIRA 112750 - FWH complement - Multi devise and ASIA issue
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
#define PROJ_CTR_NF     11
#define PROJ_SEC_NF     12
#define PROJ_UWY_NF     13
#define PROJ_CUR_CF     18
#define PROJ_LICLRC     24
#define PROJ_TRNCOD5_CF 25
#define PROJ_AMT_M      19
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
T_RUPTURE_SYNC_VAR	bd_RuptProj;	 // gestion rupture sur Projection


// Function FWH (Pere)
int n_InitFWH(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFWH(char **pbd_InRec_Cur);
int n_IsRFWH(char **ptb_InRec, char **ptb_InRec_Cur);
int n_IsR2FWH(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstFWH(char **ptb_InRec_Cur);

// Function Projection (Fils)
int n_InitProj(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncProj (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneProj(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere(char **ptb_InRec);

// Function Global
void sav_LigneFWH(char ** pbd_LigneFWH);
void sav_LigneFWHSync(char ** pbd_LigneFWH);
void sav_LigneProj(char ** pbd_LigneProj);
void EcritureFWH(char ** pbd_Ligne);
void EcritureFWHBis(char ** pbd_Ligne);

// Variales globales
int     FlagAMT = 0;
char 		psz_SavLigneFWH[USFLAG+1][25];
char 		psz_SavLigneFWHSync[USFLAG+1][25];
char 		psz_SavLigneProj[PROJ_TRNCOD5_CF][25];
int     FlagSav = 0;
int     FlagFsP = 0;

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
	if (n_OpenFileAppl("ESTC2162_O1", "wt", &Kp_OutFWHFile) == ERR)
		ExitPgm(ERR_XX, "");

	// Init FWH struct
	if (n_InitFWH(&bd_RuptFWH))
		ExitPgm (ERR_XX, "");

	// Init Proj struct
	if (n_InitProj(&bd_RuptProj))
		ExitPgm(ERR_XX, "");

	// Start of file processing
	if (n_ProcessingRuptureVar(&bd_RuptFWH) == ERR)
		ExitPgm(ERR_XX, "");

	// Close file
	if (n_CloseFileAppl("ESTC2162_I1", &(bd_RuptFWH.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl ("ESTC2162_I2", &(bd_RuptProj.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2162_O1", &Kp_OutFWHFile) == ERR)
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
	if (n_OpenFileAppl("ESTC2162_I1", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);
		
	pbd_Rupt->n_NbRupture = 2;
	pbd_Rupt->n_ConditionRupture[1] = n_IsRFWH;
	pbd_Rupt->n_ConditionRupture[0] = n_IsR2FWH;
	pbd_Rupt->n_ActionLigne = n_ActionLigneFWH;
	pbd_Rupt->n_ActionFirst[0] = n_ActionFirstFWH;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK
==============================================================================*/
int n_InitProj(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitProj");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR)) ;
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2162_I2", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncProj;
	pbd_Rupt->n_ActionLigne = n_ActionLigneProj;
	pbd_Rupt->n_PereSansFils = n_ActionPereSansFils;
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPere;
	pbd_Rupt->c_Separ = '~' ;
	RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Cur/TRNCOD5
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsRFWH(char **ptb_InRec, char **ptb_InRec_Cur)
{
	
	DEBUT_FCT("n_IsRFWH");
  if (strcmp(ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[GT_SEC_NF], ptb_InRec_Cur[GT_SEC_NF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[GT_CUR_CF], ptb_InRec_Cur[GT_CUR_CF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[GT_TRNCOD5_CF], ptb_InRec_Cur[GT_TRNCOD5_CF]) != 0)
	  RETURN_VAL(1);

	RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Cur/TRNCOD5
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR2FWH(char **ptb_InRec, char **ptb_InRec_Cur)
{
	
	DEBUT_FCT("n_IsRFWH");
  if (strcmp(ptb_InRec[GT_CTR_NF], ptb_InRec_Cur[GT_CTR_NF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[GT_SEC_NF], ptb_InRec_Cur[GT_SEC_NF]) != 0)
	  RETURN_VAL(1);

	RETURN_VAL (0);
}


/*==============================================================================
  objet :     Fonction lancee a chaque 1ere rupture contrat/sec
  ==============================================================================*/
int n_ActionFirstFWH(char **ptb_InRec_Cur)
{
	
	if ( FlagFsP == 1 && strcmp(psz_SavLigneProj[PROJ_CTR_NF], ptb_InRec_Cur[GT_CTR_NF]) != 0 )
	{ 
    EcritureFWH(ptb_InRec_Cur);
     
    FlagFsP=0;
	}
  //else
  //{
  //	FlagSav=1;
	//  sav_LigneFWH(ptb_InRec_Cur);
	//}
	
	RETURN_VAL (0);
}


/*==============================================================================
objet :
	fonction de test de synchro
retour :
	0		---> pbd_InRecOwner = pbd_InRecChild (egalite de rubriques a synchroniser)
	> 0		---> pbd_InRecOwne> > pbd_InRecChild
	< 0		---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncProj (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret=0;

	DEBUT_FCT("n_ConditionSyncMvt");

 if ((ret = strcmp(pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[PROJ_CTR_NF])) != 0)
		RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[GT_SEC_NF], pbd_InRecChild[PROJ_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[GT_CUR_CF], pbd_InRecChild[PROJ_CUR_CF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[GT_TRNCOD5_CF], pbd_InRecChild[PROJ_TRNCOD5_CF])) != 0)
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

  n_ProcessingRuptureSyncVar (&bd_RuptProj, ptb_InRec_Cur);

  RETURN_VAL (0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne des FWH synchronisee
        avec les Projections
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneProj(
  char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
  char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	sav_LigneFWHSync(ptb_InRecOwner);
	FlagSav=2;
	
	if ( FlagFsP == 1 )
	{ 
    EcritureFWH(ptb_InRecOwner);
     
    FlagFsP=0;
	}
	
  ptb_InRecOwner[AMT_PROJ]=ptb_InRecChild[PROJ_AMT_M];
  ptb_InRecOwner[UWY_PROJ]=ptb_InRecChild[PROJ_UWY_NF];
    
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
  double d_ProjAMT = 0;
  char sz_amt[22];

	if ( FlagFsP == 1 )
	{ 
    EcritureFWH(ptb_InRec);
     
    FlagFsP=0;
	}

  sprintf(sz_amt,"%.3lf",d_ProjAMT);
  ptb_InRec[AMT_PROJ]=sz_amt;
  
  n_WriteCols(Kp_OutFWHFile, ptb_InRec, '~', 0);

  RETURN_VAL (OK);

}


/*==============================================================================
objet :
        fonction lancee quand le fichier Proj participe seul
        Ne prend en compte que les devise differentes pour un meme CTR/SEC
        Si un contrat n'existe pas dans le fichier FWH I4I, le cas n'est pas géré

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere(char **ptb_InRec)
{ 
  FlagFsP=1;
  sav_LigneProj(ptb_InRec);
      
  RETURN_VAL (OK);
}

/*=============================================================================
objet:  Sauvegarde la ligne FWH/GT pour dupliquer si devise différentes
============================================================================*/
void sav_LigneFWH(char ** pbd_LigneFWH)
{
    int i;

    for (i=0;i < USFLAG+1; i++)
    {
         strcpy(psz_SavLigneFWH[i],pbd_LigneFWH[i]);
    }
}


/*=============================================================================
objet:  Sauvegarde la ligne FWH/GT pour dupliquer si devise différentes
============================================================================*/
void sav_LigneFWHSync(char ** pbd_LigneFWH)
{
    int i;

    for (i=0;i < USFLAG+1; i++)
    {
         strcpy(psz_SavLigneFWHSync[i],pbd_LigneFWH[i]);
    }
}

/*=============================================================================
objet:  Sauvegarde la ligne Proj si Proj sans FWH/Compta
============================================================================*/
void sav_LigneProj(char ** pbd_LigneProj)
{
    int i;

    for (i=0;i < PROJ_TRNCOD5_CF+1; i++)
    {
         strcpy(psz_SavLigneProj[i],pbd_LigneProj[i]);
    }
}


/*=============================================================================
objet:  Sauvegarde la ligne Proj si Proj sans FWH/Compta Mais contrat/sec synchronisé
============================================================================*/
void EcritureFWH(char ** pbd_Ligne)
{
	
    fprintf(Kp_OutFWHFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~%s~~%s~~~~~%s~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
            pbd_Ligne[GT_SSD_CF],
            pbd_Ligne[GT_ESB_CF],
            pbd_Ligne[GT_BALSHEY_NF],
            pbd_Ligne[GT_BALSHRMTH_NF],
            pbd_Ligne[GT_BALSHRDAY_NF],
            pbd_Ligne[GT_TRNCOD_CF],
            psz_SavLigneProj[PROJ_CTR_NF],
            pbd_Ligne[GT_END_NT],
            psz_SavLigneProj[PROJ_SEC_NF],
            pbd_Ligne[GT_UWY_NF],
            pbd_Ligne[GT_UW_NT],
            pbd_Ligne[GT_OCCYEA_NF],
            pbd_Ligne[GT_UWY_NF],
            pbd_Ligne[GT_SCOSTRMTH_NF],
            pbd_Ligne[GT_SCOENDMTH_NF],
            psz_SavLigneProj[PROJ_CUR_CF],
            "0.000",
            pbd_Ligne[GT_CED_NF],
            pbd_Ligne[GT_BRK_NF],
            pbd_Ligne[GT_PAY_NF],
            pbd_Ligne[GT_KEY_NF],
            psz_SavLigneProj[PROJ_CUR_CF],
            "0.000",
            pbd_Ligne[GT_NAT_CF],
            pbd_Ligne[GT_ESTCTR_NF],
            pbd_Ligne[GT_ESTSEC_NF],
            pbd_Ligne[GT_LOB_CF],
            pbd_Ligne[GT_SCOEGP_M],
            pbd_Ligne[GT_ESTCRB_CT],
            pbd_Ligne[GT_LIFTRTTYP_CF],
            pbd_Ligne[GT_ACCADMTYP_CT],
            pbd_Ligne[GT_SECSTS_CT],
            pbd_Ligne[GT_PRD_NF],
            pbd_Ligne[GT_SEG_NF],
            pbd_Ligne[GT_COMACC_B],
            pbd_Ligne[GT_ADJCOD_CT],
            pbd_Ligne[GT_ORICOD_CF],
            pbd_Ligne[GT_DETTRS_CF],
            pbd_Ligne[GT_ACCRET_B],
            pbd_Ligne[GT_LSTENDMTH_NF],
            pbd_Ligne[GT_PROPER_N],
            pbd_Ligne[GT_GAAP_NF],
            pbd_Ligne[GT_SPIMOD_CT],
            psz_SavLigneProj[PROJ_TRNCOD5_CF],
            psz_SavLigneProj[PROJ_LICLRC],
            "0.000", //[AMT_GT],
            "0.000", //[AMT_FWH],
            psz_SavLigneProj[PROJ_AMT_M],
            pbd_Ligne[UWY_GT],
            psz_SavLigneProj[PROJ_UWY_NF],
            pbd_Ligne[ASIAFLAG],
            pbd_Ligne[MSTRFLAG],
            pbd_Ligne[USFLAG]); 

}


/*=============================================================================
objet:  Sauvegarde la ligne Proj si Proj sans FWH/Compta 
============================================================================*/
void EcritureFWHBis(char ** pbd_Ligne)
{
	
    fprintf(Kp_OutFWHFile, "%s~%s~%4.4s~%2.2s~%2.2s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~%s~%s~%s~%s~%s~~~~~~~~~~~~~~~~~~~%s~%s~%s~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~%s~%s~~%s~~~~~%s~~~~~~~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
            pbd_Ligne[GT_SSD_CF],
            pbd_Ligne[GT_ESB_CF],
            pbd_Ligne[GT_BALSHEY_NF],
            pbd_Ligne[GT_BALSHRMTH_NF],
            pbd_Ligne[GT_BALSHRDAY_NF],
            pbd_Ligne[GT_TRNCOD_CF],
            psz_SavLigneProj[PROJ_CTR_NF],
            pbd_Ligne[GT_END_NT],
            psz_SavLigneProj[PROJ_SEC_NF],
            psz_SavLigneProj[PROJ_UWY_NF],
            pbd_Ligne[GT_UW_NT],
            pbd_Ligne[GT_OCCYEA_NF],
            pbd_Ligne[GT_UWY_NF],
            pbd_Ligne[GT_SCOSTRMTH_NF],
            pbd_Ligne[GT_SCOENDMTH_NF],
            psz_SavLigneProj[PROJ_CUR_CF],
            "0.000",
            pbd_Ligne[GT_CED_NF],
            pbd_Ligne[GT_BRK_NF],
            pbd_Ligne[GT_PAY_NF],
            pbd_Ligne[GT_KEY_NF],
            psz_SavLigneProj[PROJ_CUR_CF],
            "0.000",
            pbd_Ligne[GT_NAT_CF],
            pbd_Ligne[GT_ESTCTR_NF],
            pbd_Ligne[GT_ESTSEC_NF],
            pbd_Ligne[GT_LOB_CF],
            pbd_Ligne[GT_SCOEGP_M],
            pbd_Ligne[GT_ESTCRB_CT],
            pbd_Ligne[GT_LIFTRTTYP_CF],
            pbd_Ligne[GT_ACCADMTYP_CT],
            pbd_Ligne[GT_SECSTS_CT],
            pbd_Ligne[GT_PRD_NF],
            pbd_Ligne[GT_SEG_NF],
            pbd_Ligne[GT_COMACC_B],
            pbd_Ligne[GT_ADJCOD_CT],
            pbd_Ligne[GT_ORICOD_CF],
            pbd_Ligne[GT_DETTRS_CF],
            pbd_Ligne[GT_ACCRET_B],
            pbd_Ligne[GT_LSTENDMTH_NF],
            pbd_Ligne[GT_PROPER_N],
            pbd_Ligne[GT_GAAP_NF],
            pbd_Ligne[GT_SPIMOD_CT],
            psz_SavLigneProj[PROJ_TRNCOD5_CF],
            psz_SavLigneProj[PROJ_LICLRC],
            "0.000", //[AMT_GT],
            "0.000", //[AMT_FWH],
            psz_SavLigneProj[PROJ_AMT_M],
            pbd_Ligne[UWY_GT],
            psz_SavLigneProj[PROJ_UWY_NF],
            pbd_Ligne[ASIAFLAG],
            pbd_Ligne[MSTRFLAG],
            pbd_Ligne[USFLAG]); 

}