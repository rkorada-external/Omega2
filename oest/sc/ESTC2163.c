/*==============================================================================
nom de l'application          : Creation des complements FWH
nom du source                 : ESTC2163.c
revision                      : $Revision: 1 $
date de creation              : 22/01/2025
auteur                        : S.Behague
references des specificati_ons :
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Creation du fichier des Liberations.


------------------------------------------------------------------------------
[001] 22/01/2025 sbehague: SPIRA 111434 - [OMEGA Life] FWH - Accrual adjustment
[002] 14/02/2025 sbehague: SPIRA 112750 - FWH complement - Multi devise and ASIA issue
[003] 12/05/2025 sbehague: SPIRA 113027 - FWH accrual complement issue
[004] 19/01/2025 sbehague: US7172 - L&H- FWH accruals complement- Accounting extraction issue
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
#define PROJ_CUR_CF     18
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
#define ISAMTFLAG       86
/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE				*Kp_FWHFile;		       // pointeur sur les FWH en entree
FILE				*Kp_PericaseFile;      // pointeur sur le Pericase en entree
FILE				*Kp_OutFWHFile;		     // pointeur sur les FWH Accrual en sortie

T_RUPTURE_VAR		    bd_RuptPericase;	 // gestion rupture sur Pericase
T_RUPTURE_SYNC_VAR	bd_RuptFWH;		     // gestion rupture sur FWH


char sz_clodat[9];
char sz_clodatyea[5];
char sz_clodatmth[3];
char sz_clodatday[3];
char sz_Norme[5];


// Function Pericase (Pere)
int n_InitPericase(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLignePericase(char **pbd_InRec_Cur);
int n_IsRPericase(char **ptb_InRec, char **ptb_InRec_Cur);

// Function FWH (Fils)
int n_InitFWH(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncFWH (char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ActionLigneFWH(char **ptb_InRecOwner, char **ptb_InRecChild);


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
	if (n_OpenFileAppl("ESTC2163_O1", "wt", &Kp_OutFWHFile) == ERR)
		ExitPgm(ERR_XX, "");

	strcpy(sz_clodat, psz_GetCharArgv(1));
  strcpy(sz_Norme, psz_GetCharArgv(2));
  
  sscanf( sz_clodat, "%4s%2s%2s", sz_clodatyea, sz_clodatmth, sz_clodatday ) ;

	// Init Pericase struct
	if (n_InitPericase(&bd_RuptPericase))
		ExitPgm (ERR_XX, "");

	// Init FWH struct
	if (n_InitFWH(&bd_RuptFWH))
		ExitPgm(ERR_XX, "");
		
	// Start of file processing
	if (n_ProcessingRuptureVar(&bd_RuptPericase) == ERR)
		ExitPgm(ERR_XX, "");

	// Close file
	if (n_CloseFileAppl("ESTC2163_I1", &(bd_RuptFWH.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");
	if (n_CloseFileAppl("ESTC2163_I2", &(bd_RuptPericase.pf_InputFil)) == ERR)
		ExitPgm(ERR_XX, "");

	if (n_CloseFileAppl("ESTC2163_O1", &Kp_OutFWHFile) == ERR)
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
int n_InitPericase(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitPericase");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC2163_I2", "rt", &(pbd_Rupt->pf_InputFil)) == ERR)
		RETURN_VAL(ERR);
		
	pbd_Rupt->n_NbRupture = 1;
	pbd_Rupt->n_ConditionRupture[0] = n_IsRPericase;
	pbd_Rupt->n_ActionLigne = n_ActionLignePericase;
	pbd_Rupt->c_Separ = '~';
	RETURN_VAL(0);
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK
==============================================================================*/
int n_InitFWH(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitFWH");
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR)) ;
	// ouverture du fichier esclave
	n_OpenFileAppl("ESTC2163_I1", "rt", &(pbd_Rupt->pf_InputFil));
	pbd_Rupt->n_NbRupture = 0;
	pbd_Rupt->ConditionEndSync = n_ConditionSyncFWH;
	pbd_Rupt->n_ActionLigne = n_ActionLigneFWH;
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
int n_ConditionSyncFWH (char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
                        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */ )
{
  int ret=0;

	DEBUT_FCT("n_ConditionSyncFWH");

 if ((ret = strcmp(pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF])) != 0)
		RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF])) != 0)
		RETURN_VAL(ret);
	if ((ret = strcmp(pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF])) != 0)
		RETURN_VAL(ret);

	RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture niveau 1 sur
        Contrat/Section/Exercice/Annee de compte
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsRPericase(char **ptb_InRec, char **ptb_InRec_Cur)
{
	
	DEBUT_FCT("n_IsPericase");
  if (strcmp(ptb_InRec[PER_CTR_NF], ptb_InRec_Cur[PER_CTR_NF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[PER_SEC_NF], ptb_InRec_Cur[PER_SEC_NF]) != 0)
	  RETURN_VAL(1);
	if (strcmp(ptb_InRec[PER_UWY_NF], ptb_InRec_Cur[PER_UWY_NF]) != 0)
	  RETURN_VAL(1);

	RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePericase(char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLignePericase");

  n_ProcessingRuptureSyncVar (&bd_RuptFWH, ptb_InRec_Cur);
  
  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne des FWH synchronisee
        avec les Projections
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFWH(
  char **ptb_InRecOwner ,         /* adresse de la ligne du maitre */
  char **ptb_InRecChild)          /* adresse de la ligne de l'esclave */
{
	double d_FWHAMT=0;
  char   sz_fwhamt[22];
  char   sz_oricod[7]="I17FWH";
  char   sz_trncod[9]="XXXXXXXX";
  char   sz_Mthb[3]="9";
  char   sz_Mthe[3]="9";
  char   sz_Trt[2]="A";
  char   sz_Ret[2]="R";
  
  // Ne pas calculer de FWH accrual si contrat non IFRS17
  if ( atoi(ptb_InRecOwner[PER_ASSFINANCE_CT]) == 2 )
  {
    RETURN_VAL (OK);
  }
  // Contrats Asie
  if ( atoi(ptb_InRecChild[ASIAFLAG]) == 1 )
  {
    d_FWHAMT=0-atof(ptb_InRecChild[AMT_FWH]);
    
  }

  // Contrats mastérisés
  if ( atoi(ptb_InRecChild[MSTRFLAG]) == 1 )
  {
    d_FWHAMT=0-atof(ptb_InRecChild[AMT_GT])-atof(ptb_InRecChild[AMT_FWH]);
    
  }

  if ( atoi(ptb_InRecChild[ASIAFLAG]) == 0 && atoi(ptb_InRecChild[MSTRFLAG]) == 0 )
  {
    d_FWHAMT=0-(atof(ptb_InRecChild[AMT_PROJ])+atof(ptb_InRecChild[AMT_GT])+atof(ptb_InRecChild[AMT_FWH]));
    
  }
  // On ecrit un FWH accrual en sortie si le contrat n'est pas US et si la projection n'est pas egale a zero
  // Ou si traite master
  // Ou si traite asie
  if ( (( atoi(ptb_InRecChild[USFLAG]) != 1) && ( atof(ptb_InRecChild[ISAMTFLAG]) == 1 )) || atoi(ptb_InRecChild[MSTRFLAG]) == 1 || atoi(ptb_InRecChild[ASIAFLAG]) == 1 )
  {
  	// Renseignement des champs venant du Pericase
  	ptb_InRecChild[GT_LOB_CF]=ptb_InRecOwner[PER_LOB_CF];
  	ptb_InRecChild[GT_CED_NF]=ptb_InRecOwner[PER_CED_NF];
  	ptb_InRecChild[GT_NAT_CF]=ptb_InRecOwner[PER_NAT_CF];
  	ptb_InRecChild[GT_ACCADMTYP_CT]=ptb_InRecOwner[PER_ACCADMTYP_CT];
  	ptb_InRecChild[GT_UWGRP_CF]=ptb_InRecOwner[PER_UWGRP_CF];
  	ptb_InRecChild[GT_ESTCRB_CT]=ptb_InRecOwner[PER_ESTCRB_CT];
  	ptb_InRecChild[GT_ESB_CF]=ptb_InRecOwner[PER_ACCESB_CF];
  	ptb_InRecChild[GT_SSD_CF]=ptb_InRecOwner[PER_SSD_CF];
    ptb_InRecChild[GT_END_NT]=ptb_InRecOwner[PER_END_NT];
    ptb_InRecChild[GT_UW_NT]=ptb_InRecOwner[PER_UW_NT];
    
    if ( strcmp(ptb_InRecOwner[PER_CTRTYP_CT], "TRT") == 0 )  ptb_InRecChild[GT_ACCRET_B]=sz_Trt;
    if ( strcmp(ptb_InRecOwner[PER_CTRTYP_CT], "RET") == 0 )  ptb_InRecChild[GT_ACCRET_B]=sz_Ret;
    
  	
  	// Renseignements des champs de sortie
  	if ( atof(ptb_InRecChild[AMT_PROJ]) == 0 )
  	{
  		if ( atof(ptb_InRecChild[AMT_FWH]) == 0 )
  		{
  		  ptb_InRecChild[GT_UWY_NF]=ptb_InRecChild[UWY_GT];
  		}
  	}
  	else
  	{
  	  ptb_InRecChild[GT_UWY_NF]=ptb_InRecChild[UWY_PROJ];
  	}
  	ptb_InRecChild[GT_ACY_NF]=sz_clodatyea;

    sprintf(sz_fwhamt, "%f", d_FWHAMT);
  	ptb_InRecChild[GT_ESTAMT_M]=sz_fwhamt;
  	ptb_InRecChild[GT_AMT_M]=sz_fwhamt;
  	
  	//Renitialisation du mois
  	ptb_InRecChild[GT_SCOSTRMTH_NF]=sz_Mthb;
  	ptb_InRecChild[GT_SCOENDMTH_NF]=sz_Mthe;
  	
  	if ( atoi(sz_clodatmth) >=1 && atoi(sz_clodatmth) <=3 )
  	{
	  	strcpy(ptb_InRecChild[GT_SCOSTRMTH_NF],"1");
  		strcpy(ptb_InRecChild[GT_SCOENDMTH_NF],"3");
  	}
  	if ( atoi(sz_clodatmth) >=4 && atoi(sz_clodatmth) <=6 )
  	{
	  	strcpy(ptb_InRecChild[GT_SCOSTRMTH_NF],"4");
  		strcpy(ptb_InRecChild[GT_SCOENDMTH_NF],"6");
  	}
	  if ( atoi(sz_clodatmth) >=7 && atoi(sz_clodatmth) <=9 )
	  {
  		strcpy(ptb_InRecChild[GT_SCOSTRMTH_NF],"7");
	  	strcpy(ptb_InRecChild[GT_SCOENDMTH_NF],"9");
  	}
  	if ( atoi(sz_clodatmth) >=10 && atoi(sz_clodatmth) <=12 )
  	{
	  	strcpy(ptb_InRecChild[GT_SCOSTRMTH_NF],"10");
  		strcpy(ptb_InRecChild[GT_SCOENDMTH_NF],"12");
  	}
  
  	if ( atoi(ptb_InRecChild[GT_LOB_CF]) == 30 && strcmp(ptb_InRecChild[GT_ACCRET_B], "A") == 0 ) sz_trncod[0]='3';
  	if ( atoi(ptb_InRecChild[GT_LOB_CF]) == 30 && strcmp(ptb_InRecChild[GT_ACCRET_B], "R") == 0 ) sz_trncod[0]='4';
  	if ( atoi(ptb_InRecChild[GT_LOB_CF]) == 31 && strcmp(ptb_InRecChild[GT_ACCRET_B], "A") == 0 ) sz_trncod[0]='1';	
  	if ( atoi(ptb_InRecChild[GT_LOB_CF]) == 31 && strcmp(ptb_InRecChild[GT_ACCRET_B], "R") == 0 ) sz_trncod[0]='2';
  
  	sz_trncod[1]='2';
  	sz_trncod[2]=ptb_InRecChild[GT_TRNCOD5_CF][0];
  	sz_trncod[3]=ptb_InRecChild[GT_TRNCOD5_CF][1];
  	sz_trncod[4]=ptb_InRecChild[GT_TRNCOD5_CF][2];
  	sz_trncod[5]=ptb_InRecChild[GT_TRNCOD5_CF][3];
  	sz_trncod[6]=ptb_InRecChild[GT_TRNCOD5_CF][4];
  	
  	if ( strcmp(sz_Norme,"I17G") == 0) sz_trncod[7]='I';
  	if ( strcmp(sz_Norme,"I17P") == 0) sz_trncod[7]='K';
  	if ( strcmp(sz_Norme,"I17L") == 0) sz_trncod[7]='M';


    ptb_InRecChild[GT_BALSHEY_NF]=sz_clodatyea;
   	ptb_InRecChild[GT_BALSHRMTH_NF]=sz_clodatmth;
    ptb_InRecChild[GT_BALSHRDAY_NF]=sz_clodatday;

    
  	ptb_InRecChild[GT_TRNCOD_CF]=sz_trncod;

  	ptb_InRecChild[GT_ORICOD_CF]=sz_oricod;
  
  	n_WriteCols(Kp_OutFWHFile, ptb_InRecChild, '~', 0);
  }

  RETURN_VAL (OK);
}
