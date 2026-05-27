/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2334.c  
revision                      : $Revision:   1.0  $
date de creation              : 13/08/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Operateur de placement : GTAr100% * placements ===> GTAr et GTRr

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
	  30/01/03       J. Ribot   ajout colonne retintamt_m sur fichier en sortie
	  26/04/05        M.DJELLOULI   SPOT5084    - MOD02
	                                          Ajout de la Zone SPEENTTYP_CF de TACCSUP
	  24/06/05        M.DJELLOULI   SPOT5085    - MOD03
	                                          Ajout de la Zone SPEENTNAT_CT de TACCSUP
	  25/06/13        Prajakta      Phase1B migration code changes for warning removal
[005] 24/09/2013 R. Cassis   :spot:25427 On remet le include GT_TRN_NT
[006] 14/03/2014 -=Dch=-  	 :spot:25427 Remplacement de d_GetTaux par d_ThisGetTaux pour la version "embarque" plutot que celle de la librairie qui est buggee
[006] 08/04/2014 -=Dch=-     :spot:25427 Corrections techniques ( pointeur p2 dans n_ActionLast2)
[007] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP and suppress warnings
[008] 02/04/2024 JYP/MZM/Florian:spira 110932: RET OVERRIDE exclude some TC when RAICOM_B=0  
[009] 27/08/2025 M.ANI US5850 augmenter Kn_MaxLigFCURCVSNBIS 10000
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include "struct.h"
#include "estserv.h"


/*----------------------------------------*/
static char VERSION_ESTC2334_C[150] = "__version__: ESTC2334.c version [008] 02/04/2024 RET OVERRIDE exclude some TC/RAICOM_B=0" ;


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

#define GT_ENTPERYEA_NF 41
#define GT_ENTPERMTH_NF 42
#define GT_VALPERYEA_NF 43
#define GT_VALPERMTH_NF 44
/**#define GT_TRN_NT 45 **/ /** Commented for Phase1b migration **/
#define GT_TRN_NT2 45    // [005]
#define GT_ACCTYP_NF2 46  // [007]
#define GT_BALSHEY_NF_PLUS 47
#define GT_BALSHRMTH_NF_PLUS 48
#define GT_BALSHRDAY_NF_PLUS 49
#define GT_COMMAC_LL 50
#define GT_SPEENTTYP_CF 51          // MOD02
#define GT_SPEENTNAT_CT 52          // MOD03
#define GT_EVT_NF 53           // [007]
#define GT_REVT_NF 54          // [007]

/*
#define GT_ENTPERYEA_NF 40
#define GT_ENTPERMTH_NF 41
#define GT_VALPERYEA_NF 42
#define GT_VALPERMTH_NF 43
#define GT_TRN_NT 44
#define GT_ACCTYP_NF 45
#define GT_BALSHEY_NF_PLUS 46
#define GT_BALSHRMTH_NF_PLUS 47
#define GT_BALSHRDAY_NF_PLUS 48
#define GT_COMMAC_LL 49
*/
#define MAX_TACC 40000
#define MAX_TPLAC 2000
#define MAX_TGTAR 2000000

typedef struct{
               unsigned char SSD_CF;
               unsigned char ESB_CF;
               char RETCTR_NF[10];
               unsigned char RETEND_NT;
               unsigned char RETSEC_NF;
               short RTY_NF;
               unsigned char RETUW_NT;
               int PLC_NT;
               double OVRCOM_R;
               int RTO_NF;
               int INT_NF;
               int PAY_NF;
               char KEY_CF[2];
               unsigned char ORICUR_B;
               unsigned char SSDRTO_B;
               double RETSIGSHA_R;
               char LOB_CF[3];
               unsigned char RAICOM_B;
               unsigned char RETOVRCOM_B;
               char RETCUR_CF[4];
               double TAUXRETRO_R;
               char PLCTROUVE;      /*  JR 28/04/03 */
              } T_PLAC;

typedef struct{
               unsigned char SSD_CF;
               unsigned char ESB_CF;
               short BALSHEY_NF;
               unsigned char BALSHRMTH_NF;
               unsigned char BALSHRDAY_NF;
               char TRNCOD_CF[9];
               char DBLTRNCOD_CF[9];
               char CTR_NF[10];
               unsigned char END_NT;
               unsigned char SEC_NF;
               short UWY_NF;
               unsigned char UW_NT;
               char OCCYEA_NF[5];
               short ACY_NF;
               unsigned char SCOSTRMTH_NF;
               unsigned char SCOENDMTH_NF;
               char CLM_NF[10];
               char CUR_CF[4];
               double AMT_M;
               int CED_NF;
               int BRK_NF;
               int PAY_NF;
               char KEY_NF[3];
               char RETCTR_NF[10];
               unsigned char RETEND_NT;
               unsigned char RETSEC_NF;
               short RTY_NF;
               unsigned char RETUW_NT;
               char RETOCCYEA_NF[5];
               short RETACY_NF;
               unsigned char RETSCOSTRMTH_NF;
               unsigned char RETSCOENDMTH_NF;
               char RCL_NF[10];
               char RETCUR_CF[4];
               double RETAMT_M;
               short ENTPERYEA_NF;
               short ENTPERMTH_NF;
               short VALPERYEA_NF;
               short VALPERMTH_NF;
               int TRN_NT;
               short ACCTYP_NF;
               short BALSHEY_NF_PLUS;
               unsigned char BALSHRMTH_NF_PLUS;
               unsigned char BALSHRDAY_NF_PLUS;
               char COMMAC_LL[65];
//               int SPEENTTYP_CF;
               char SPEENTTYP_CF[5];
               char SPEENTNAT_CT[2];
               char EVT_NF[11];     // [007]
               char REVT_NF[11];    // [007]
               double TAUXACCEPT_R;
             } T_ACC;

typedef struct{
               T_ACC * pa; /* pointeur sur une ligne T_ACC */
               T_PLAC * pp; /* pointeur sur une ligne T_PLAC */
               double AMT_M;
               double RETAMT_M;
               unsigned char RETCUR_B;
               double OVRCOMAMT_M;
               double RETOVRCOMAMT_M;
               unsigned char RAICOM_B;
              } T_GTAR;



/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_ActionFirst1(char **);
static int n_InitGTA(T_RUPTURE_VAR  *);
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLignePLC(char **v,char **);
static int n_ConditionSync(char **v,char **);
static int n_ActionLigneGTA(char **v);
static int n_ConditionRupture1(char **, char **);
static int n_ConditionRupture2(char **, char **);
static int n_ActionFirst2(char **);
int 	n_ActionLast2(char **);
//static int AfficheTGTAR(T_GTAR TGTAR);

extern int n_ProcessingRuptureVar(T_RUPTURE_VAR *);
extern int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *,char **);

static int EcrireGTRr(FILE * pf, T_GTAR, double d_Ma, char *);
static int EcrireGTAr(FILE * pf, T_GTAR, double d_Ma, double d_Mr, char *);
static int Ecrire2GTAr(FILE * pf, T_GTAR, double d_Ma, double d_Mr, char *);               /* JR 28/04/03 */
static int EcrireGTArp(FILE * pf, T_GTAR, double d_Ma, double d_Mr, double d_Mri, char *); /* JR 10/02/03 */
static int EcrireTGTAR(T_GTAR TGTAR[] ,int i, int a, int p);
static int StockeLignePlac(char ** tpsz_ReadBufferPLC) ;
static int StockeLigneAcc(char ** tpsz_ReadBufferGTA) ;
char   get_exclude_retrocomm_flag(char * trn_cd , int RAICOM_B ) ;

static int b_IsRuptureGTRr(T_GTAR TGTAR[],int i,int j);
static char *sz_GetCurcvsnIndx(
        FILE* pf,         	/* Discripteur du fichier des cours */
        char *sz_acpcur, 	/* Cours d'origine */
        char c_ssd,       	/* filiale */
	      char *sz_retctr,	/* contrat */
        short s_rty,      	/* Exercice */
	      int   n_plc,		  	/* placement */
        char *pc_PlcTrouve        /* JR 28/04/03 */
        );

int n_RechCURCVSNBIS(char *sz_retctr, int n_rty, int n_plc);

/*----------------------*/
/* variables de travail */
/*----------------------*/

T_PLAC   TPLAC[MAX_TPLAC];

T_ACC   TACC[MAX_TACC];

static FILE *Kp_GTAr;
static FILE *Kp_GTArMaj;
static FILE *Kp_GTRr;
static FILE *Kp_GTRrMaj;

//static FILE *Kp_Curcvsn;
static FILE *Kp_CurcvsnIndx;
static FILE *Kp_Curquot;

static T_RUPTURE_VAR   Kbd_RuptGTA;
static T_RUPTURE_SYNC_VAR  Kbd_RuptPLC;

static int Kn_TACC;
static int Kn_TPLAC;
//static int Kn_TGTAR;

static int Kb_TACCDepass;
static int Kb_TPLACDepass;
//static int Kb_TGTARDepass;

static BOOL Kb_ReturnStatus=0; /* statut de retour du programme */

static int Kn_GTR;
static int Kn_GTE;
static int Kn_AnneeCours;

static double Kd_TauxAccept;

//static long double Kld_Sec=1000000000. ;
long double delta1=0, delta2=0, delta3=0, delta4=0 ;
struct  timespec ts1, ts2;

char Ksz_message[100];

/**************************************************************
** Objet  : chargement FCURCVSNBIS
** Entree : ESTC2334_I5
*/

T_RUPTURE_VAR Kbd_ruptFCURCVSNBIS;
int n_InitFCURCVSNBIS(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneFCURCVSNBIS(char **ptb_InRec_Cur);

/* Pour le chargement dans un tableau
du fichier des plc en dev specifiques */

typedef struct {
short     SSD_CF;
char      RETCTR_NF[9];
short     RTY_NF;
int       PLC_NT;
} T_CURCVSNBIS;

#define Kn_MaxLigFCURCVSNBIS 1000  /* nombre maxi de lignes de bret..tcurcvsn */

#define CURCVSNBIS_SSD_CF     0
#define CURCVSNBIS_RETCTR_NF  1
#define CURCVSNBIS_RTY_NF     2
#define CURCVSNBIS_PLC_NT     3

int  Kn_FCURCVSNBIS=0; /* Nombre de lignes du tableau Ktbd_FEUROCUR */

T_CURCVSNBIS Ktbd_FCURCVSNBIS[Kn_MaxLigFCURCVSNBIS];




/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de problme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );


  printf("Running with %s \n", VERSION_ESTC2334_C );  
  strcpy(Ksz_message,"");
  
  
  /* Chargement des donnees de curcvsnbis */
    /* Initialisation des variables de gestion de ruptures */
        if (n_InitFCURCVSNBIS(&Kbd_ruptFCURCVSNBIS)) ExitPgm(ERR_XX, "");
    /* Lancement du traitement du fichier Maitre */
        if (n_ProcessingRuptureVar(&Kbd_ruptFCURCVSNBIS) == ERR) ExitPgm(ERR_XX, "");
   /* Fermeture des fichiers ouverts */
        if (n_CloseFileAppl("ESTC2334_I5", &(Kbd_ruptFCURCVSNBIS.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");



        if ( n_OpenFileAppl ("ESTC2334_O1","wt",&Kp_GTAr) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2334_O2","wt",&Kp_GTArMaj) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Stockage des parametres du programme */
        Kn_GTR=n_GetIntArgv(1);
        Kn_AnneeCours=n_GetIntArgv(2);
        Kn_GTE=n_GetIntArgv(3);

        /* les fichiers GTR et GTRMaj sont ouverts seulement si */
        /* l'option "generation GTR" est a 'oui' (1) */
        if (Kn_GTR == 1)
        {
           if ( n_OpenFileAppl ("ESTC2334_O3","wt",&Kp_GTRr) == ERR )
                ExitPgm ( ERR_XX , "" );

           if ( n_OpenFileAppl ("ESTC2334_O4","wt",&Kp_GTRrMaj) == ERR )
                ExitPgm ( ERR_XX , "" );
        }

        if ( n_OpenFileAppl ("ESTC2334_I3","rb",&Kp_CurcvsnIndx) == ERR )
                ExitPgm ( ERR_XX , "" );

		  	if ( n_OpenFileAppl ("ESTC2334_I4","rb",&Kp_Curquot) == ERR )
                ExitPgm ( ERR_XX , "" );


	/* Initialisation de la variable Kbd_RuptGTA  */
	if ( n_InitGTA(&Kbd_RuptGTA)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptPLC */
	if ( n_InitPLC(&Kbd_RuptPLC)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptGTA) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2334_O1",&Kp_GTAr)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2334_O2",&Kp_GTArMaj)==ERR )
                ExitPgm ( ERR_XX , "" );

        /* les fichiers GTR et GTRMaj sont presents seulement si */
        /* l'option "generation GTR" est a 'oui' (1) */
        if (Kn_GTR == 1)
        {
           if ( n_CloseFileAppl ("ESTC2334_O3",&Kp_GTRr)==ERR )
                ExitPgm ( ERR_XX , "" );

           if ( n_CloseFileAppl ("ESTC2334_O4",&Kp_GTRrMaj)==ERR )
                ExitPgm ( ERR_XX , "" );
        }

	if ( n_CloseFileAppl ("ESTC2334_I3",&Kp_CurcvsnIndx)==ERR )
                ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2334_I4",&Kp_Curquot)==ERR )
                ExitPgm ( ERR_XX , "" );


        if ( n_CloseFileAppl ("ESTC2334_I1",&(Kbd_RuptGTA.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2334_I2",&(Kbd_RuptPLC.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );



	 fprintf(Gbd_Tech.p_LogFil,
                  "delta1=%10.0Lf \ndelta2=%10.0Lf \ndelta3=%10.0Lf \ndelta4=%10.0Lf\n",
                  delta1, delta2,delta3,delta4);

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(Kb_ReturnStatus) ;

}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
	0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTA(T_RUPTURE_VAR  *pbd_RuptGTA)
{
	DEBUT_FCT ("n_InitGTA") ;

	memset(pbd_RuptGTA,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2334_I1","rt",&(pbd_RuptGTA->pf_InputFil))==ERR)
		RETURN_VAL( ERR );

	pbd_RuptGTA->n_NbRupture =2;
	pbd_RuptGTA->n_ActionLigne     = n_ActionLigneGTA;

	pbd_RuptGTA->n_ConditionRupture[0] = n_ConditionRupture1;
	pbd_RuptGTA->n_ActionFirst[0] = n_ActionFirst1;

	pbd_RuptGTA->n_ConditionRupture[1] = n_ConditionRupture2;
	pbd_RuptGTA->n_ActionFirst[1] = n_ActionFirst2;
	pbd_RuptGTA->n_ActionLast[1] = n_ActionLast2;

        pbd_RuptGTA->c_Separ=SEPARATEUR;

	RETURN_VAL( OK );
}

/*==============================================================================
objet :
Test de rupture sur RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT
        pour le fichier pere (GTAr100%)

retour :
	0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
static int n_ConditionRupture1(char ** tpsz_ReadBufferGTA,
                                 char ** tpsz_ReadBufferGTA_Cur)
{

	DEBUT_FCT ("n_ConditionRupture1") ;

        if(strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF],tpsz_ReadBufferGTA_Cur[GT_RETCTR_NF])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT],tpsz_ReadBufferGTA_Cur[GT_RETEND_NT])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF],tpsz_ReadBufferGTA_Cur[GT_RETSEC_NF])!=0)
           RETURN_VAL(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_RTY_NF],tpsz_ReadBufferGTA_Cur[GT_RTY_NF])!=0)
           RETURN_VAL(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT],tpsz_ReadBufferGTA_Cur[GT_RETUW_NT])!=0)
           RETURN_VAL(1);

      RETURN_VAL(0);
}

/*==============================================================================
objet :
Test de rupture sur RETCTR_NF/RETEND_NT/RETSEC_NF/RTY_NF/RETUW_NT/TRNCOD_CF/CUR_CF
        pour le fichier pere (GTAr100%)

retour :
	0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
static int n_ConditionRupture2(char ** tpsz_ReadBufferGTA,
                                 char ** tpsz_ReadBufferGTA_Cur)
{
	DEBUT_FCT ("n_ConditionRupture2") ;

        if(strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF],tpsz_ReadBufferGTA_Cur[GT_RETCTR_NF])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT],tpsz_ReadBufferGTA_Cur[GT_RETEND_NT])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF],tpsz_ReadBufferGTA_Cur[GT_RETSEC_NF])!=0)
           RETURN_VAL(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_RTY_NF],tpsz_ReadBufferGTA_Cur[GT_RTY_NF])!=0)
           RETURN_VAL(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT],tpsz_ReadBufferGTA_Cur[GT_RETUW_NT])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_TRNCOD_CF],tpsz_ReadBufferGTA_Cur[GT_TRNCOD_CF])!=0)
           RETURN_VAL(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_CUR_CF],tpsz_ReadBufferGTA_Cur[GT_CUR_CF])!=0)
           RETURN_VAL(1);

      RETURN_VAL(0);
}


/*==============================================================================
objet :
	Fonction lancee en rupture premiere sur casex retro
        pour le fichier GTAr100%

retour :
	OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirst1(char ** tpsz_ReadBufferGTA)
{
     /* initialiser TPLAC */
	DEBUT_FCT ("n_ActionFirst1") ;

     Kn_TPLAC=0;
     Kb_TPLACDepass=0;

     /* lancement de la synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptPLC,tpsz_ReadBufferGTA) == ERR)
           RETURN_VAL (ERR );

     RETURN_VAL(OK);
}

/*==============================================================================
objet :
	Fonction lancee en rupture premiere sur casex retro/poste/monnaie
        pour le fichier GTAr100%

retour :
	OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirst2(char ** tpsz_ReadBufferGTA)
{
	DEBUT_FCT ("n_ActionFirst2") ;

     if (Kb_TPLACDepass==0)
     {
        Kn_TACC=0;
        Kb_TACCDepass=0;
	Kd_TauxAccept=d_GetTaux(Kp_Curquot,
				(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]),
                                (short) Kn_AnneeCours,
                                tpsz_ReadBufferGTA[GT_CUR_CF],
				NULL);

     }
    TACC[Kn_TACC].TAUXACCEPT_R=d_GetTaux(Kp_Curquot, TACC[Kn_TACC].SSD_CF,
                                 (short) Kn_AnneeCours,
                                 TACC[Kn_TACC].CUR_CF, NULL);

     RETURN_VAL(OK);
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *pbd_RuptPLC)
{
	DEBUT_FCT ("n_InitPLC") ;

	memset( pbd_RuptPLC,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2334_I2","rt",&(pbd_RuptPLC->pf_InputFil))==ERR)
           RETURN_VAL( ERR );

    pbd_RuptPLC->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptPLC->ConditionEndSync	= n_ConditionSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptPLC->n_ActionLigne   	= n_ActionLignePLC;

    pbd_RuptPLC->c_Separ='~';

	RETURN_VAL(OK) ;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLignePLC(
	char *tpsz_ReadBufferGTA[] ,
	char *tpsz_ReadBufferPLC[]
)
{
   char MsgAno[300];
	DEBUT_FCT ("n_ActionLignePLC") ;

   if (Kb_TPLACDepass == 0)
   {
       if (Kn_TPLAC < MAX_TPLAC)
       {
         StockeLignePlac(tpsz_ReadBufferPLC);
         Kn_TPLAC++;
       }
       else
       {
        sprintf(MsgAno,"The number of records in PLACEMENT file for contract (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity\n",
                      tpsz_ReadBufferPLC[PLA_RETCTR_NF],
                      tpsz_ReadBufferPLC[PLA_RETEND_NT],
                      tpsz_ReadBufferPLC[PLA_RETSEC_NF],
                      tpsz_ReadBufferPLC[PLA_RTY_NF],
                      tpsz_ReadBufferPLC[PLA_RETUW_NT]);

        n_WriteAno(MsgAno);
	Kb_TPLACDepass=1;
	Kb_ReturnStatus=1;
       }
    }

   RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ConditionSync(
	char *tpsz_ReadBufferGTA[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferPLC[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_RETCTR_NF],tpsz_ReadBufferPLC[PLA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_RETEND_NT],tpsz_ReadBufferPLC[PLA_RETEND_NT]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_RETSEC_NF],tpsz_ReadBufferPLC[PLA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RTY_NF],tpsz_ReadBufferPLC[PLA_RTY_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTA[GT_RETUW_NT],tpsz_ReadBufferPLC[PLA_RETUW_NT]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneGTA(char *tpsz_ReadBufferGTA[])
{
    char MsgAno[300];
	DEBUT_FCT ("n_ActionLigneGTA") ;

    if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass ==0) )
    {
/*  if (Kn_TACC > 34999)
      printf ("%d\t",Kn_TACC); */   /*  a utiliser en cas de depassement table pour connaitre  la valeur de depassement */
       if (Kn_TACC < MAX_TACC)
       {
         StockeLigneAcc(tpsz_ReadBufferGTA) ;
         Kn_TACC ++;

     }
     else
     {
        sprintf(MsgAno,"The number of records in GT file for (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s /TRNCOD %s /CUR %s) overflows the program's storage capacity\n",
                      tpsz_ReadBufferGTA[GT_RETCTR_NF],
                      tpsz_ReadBufferGTA[GT_RETEND_NT],
                      tpsz_ReadBufferGTA[GT_RETSEC_NF],
                      tpsz_ReadBufferGTA[GT_RTY_NF],
                      tpsz_ReadBufferGTA[GT_RETUW_NT],
                      tpsz_ReadBufferGTA[GT_TRNCOD_CF],
                      tpsz_ReadBufferGTA[GT_CUR_CF]);

         n_WriteAno(MsgAno);

	 Kb_TACCDepass=1;
	 Kb_ReturnStatus=1;
      }
    }
      RETURN_VAL(OK);
}


/*==============================================================================
objet :
	Fonction lancee en rupture derniere
        pour le fichier GTAa

retour :
	OK --->
        ERR --->
==============================================================================*/
int n_ActionLast2(char ** tpsz_ReadBufferGTA)
{
	int p, a, i, k, i0, imin, imax, n_TGTAR;
 	char c_PlcTrouve=0;        /* JR 28/04/03 */
  char c_Init_PlcTrouve=0;   /* JR 28/04/03 */
	double d_Ma=0., d_MaS=0., d_Mr=0., d_MrS=0., d_MriS=0., d_MaSMaj=0., d_MrSMaj=0., d_MriSMaj=0.;  // [007]
	char sz_retcur[4];
	static T_GTAR   *TGTAR=NULL;
	char MsgAno[400];
	char sz_trncod[9];
  char sv_trncod[9];
	static char *p2;


	if ( TGTAR )  { free ( TGTAR ); TGTAR=NULL;}
	TGTAR = malloc(sizeof(T_GTAR)*Kn_TPLAC*Kn_TACC) ;

	if ( !TGTAR )
	{
		n_WriteAno("Erreur d'alloction memoire pour TGTAR ") ;
	}

	DEBUT_FCT ("n_ActionLast2") ;

	if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass == 0) && (Kn_TPLAC != 0) )
	{
		/*------------------------------*/
		/* 1- Calcul des monnaies retro */
		/*------------------------------*/

		for (p=0; p < Kn_TPLAC; p++)
		{
			if (TPLAC[p].ORICUR_B == 1)
			{
				 /* la devise retrocession est identique a la devise originale */
				strcpy(TPLAC[p].RETCUR_CF,TACC[0].CUR_CF);
        TPLAC[p].PLCTROUVE = c_Init_PlcTrouve;

			}
			else
			{
				clock_gettime(0,&ts1);
				   /* transformation de devise */
/*				p1= sz_GetRetCurBis(TACC[0].CUR_CF,
				                                           TACC[0].SSD_CF,
				                                           TACC[0].RETCTR_NF,
						                         TACC[0].RTY_NF,
						                         TPLAC[p].PLC_NT,
						                         Kp_Curcvsn);


				clock_gettime(0,&ts2);
				delta1 +=ts2.tv_sec*Kld_Sec+ts2.tv_nsec - (ts1.tv_sec*Kld_Sec+ts1.tv_nsec);


				clock_gettime(0,&ts1);

*/				p2=sz_GetCurcvsnIndx(	Kp_CurcvsnIndx,
										TACC[0].CUR_CF,
										TACC[0].SSD_CF,
										TACC[0].RETCTR_NF,
										TACC[0].RTY_NF,
										TPLAC[p].PLC_NT,
                    &c_PlcTrouve);        /* JR 28/04/03 */
				if(p2 !=NULL)
					strcpy(TPLAC[p].RETCUR_CF,p2);
        TPLAC[p].PLCTROUVE = c_PlcTrouve;

        /* Si on n'a pas trouve de placement, la fction retourne -1 */
	     	if ( n_RechCURCVSNBIS(
										TACC[0].RETCTR_NF,
										TACC[0].RTY_NF,
										TPLAC[p].PLC_NT)  == -1)
				      TPLAC[p].PLCTROUVE = 0 ;
				else
							 TPLAC[p].PLCTROUVE = 1 ;


/*				clock_gettime(0,&ts2);
				delta2 +=ts2.tv_sec*Kld_Sec+ts2.tv_nsec - (ts1.tv_sec*Kld_Sec+ts1.tv_nsec);

				printf("%s\t%d\t%s\t%d\t%d\t%s\t%s\n",	TACC[0].CUR_CF,
																	(int)TACC[0].SSD_CF,
																	TACC[0].RETCTR_NF,
																	(int)TACC[0].RTY_NF,
																	(int)TPLAC[p].PLC_NT,
																	p1,
																	p2) ;
*/

/* rq: si la devise retrocession n'a pas ete trouvee, 		*/
	/* la fonction renvoie chaine vide - cette eventualite 		*/
	/* est prise en compte dans la generation du tableau TGTAR  	*/

			}
                   TPLAC[p].TAUXRETRO_R=d_GetTaux(Kp_Curquot, TPLAC[p].SSD_CF,
                           (short) Kn_AnneeCours,
                           TPLAC[p].RETCUR_CF,NULL);

		}


		/*----------------------------------------------*/
		/* 2- Generation du tableau intermediaire TGTAR */
		/*----------------------------------------------*/


		i=-1;
		for (p=0; p < Kn_TPLAC; p++)
		{
			if (strcmp(TPLAC[p].RETCUR_CF,"") != 0)
			{
				for (a=0; a < Kn_TACC; a++)
				{
					i=a * Kn_TPLAC + p;

 					if (i < MAX_TGTAR)
					{
						if (EcrireTGTAR(TGTAR,i,a,p) == ERR)
						{
 							if ( TGTAR )  { free ( TGTAR ); TGTAR=NULL;}
							RETURN_VAL( OK);
						}
	/* la fonction EcrireTGTAR renvoie ERR si le cours */
	/* de change entre CUR et RETCUR n'a pas ete trouve */
	/* dans ce cas on n'ecrit pas en sortie pour la cle */
						/* courante */
					}
					else
					{
						sprintf(MsgAno,"The number of records for \n\tcontract (/CTR %s /END %d /SEC %d /UWY %d /UW %d) \n\tretro contract (/RETCTR %s /RETEND %d /RETSEC %d /RTY %d /RETUW %d) \n\ttransaction code TRNCOD %s \n\tcurrency code CUR %s\noverflows the program's storage capacity\n",
							TACC[a].CTR_NF,
							TACC[a].END_NT,
							TACC[a].SEC_NF,
							TACC[a].UWY_NF,
							TACC[a].UW_NT,
							TACC[a].RETCTR_NF,
							TACC[a].RETEND_NT,
							TACC[a].RETSEC_NF,
							TACC[a].RTY_NF,
							TACC[a].RETUW_NT,
							TACC[a].TRNCOD_CF,
							TACC[a].CUR_CF);
						n_WriteAno(MsgAno);
						Kb_ReturnStatus=1;
						if ( TGTAR )  { free ( TGTAR ); TGTAR=NULL;}
						RETURN_VAL( OK);
					} /* fin "si i < MAX_TGTAR */
				} /* fin boucle sur TACC */
			}
			else
			{
				/* ecrire une ano : devise retro non trouvee */
				sprintf(MsgAno,"No retrocession currency could be found in reference table TCURCVSN for (CUR %s /SSD %d /RETCTR %s /RTY_NF %d /PLC_NT %d)\n",
				TACC[0].CUR_CF,
				TACC[0].SSD_CF,
				TACC[0].RETCTR_NF,
				TACC[0].RTY_NF,
				TPLAC[p].PLC_NT);

				n_WriteAno(MsgAno);
				Kb_ReturnStatus=1;
				if ( TGTAR )  { free ( TGTAR ); TGTAR=NULL;}
				RETURN_VAL( OK);
			} /* fin si TPLAC[p].RETCUR_CF != "" */

		} /* fin boucle sur TPLAC */

		n_TGTAR=i;



		if (n_TGTAR != -1)
		{

			/********** affichage pour verifier (debug) ****************/

		/*	    printf("\n---------------------------------------------\n");
			for (i=0; i < Kn_TACC*Kn_TPLAC ; i++)
				AfficheTGTAR(TGTAR[i]);	     */

				/*----------------------------------------------*/
				/* 3- Cumul 1 : generation des GTAr             */
				/*----------------------------------------------*/
			imin=0;
			imax=Kn_TPLAC - 1;
			for (a=0; a < Kn_TACC; a++)
			{
				i0=imin;
				for (p=0; p < Kn_TPLAC; p++)
				{     /*  printf ("for (p=0; %d < %d; p++)\n",p,Kn_TPLAC); */
					i= a * Kn_TPLAC + p;
					strcpy(sz_trncod,TGTAR[i].pa->TRNCOD_CF);
					if (TGTAR[i].RETCUR_B == 0)
					{
						i0 = i + 1;
						TGTAR[i].RETCUR_B = 1;
						strcpy(sz_retcur,TGTAR[i].pp->RETCUR_CF);
						d_Ma = TGTAR[i].AMT_M;
						d_Mr = TGTAR[i].RETAMT_M;
            strcpy(sv_trncod,TGTAR[i].pa->TRNCOD_CF);

            if ( get_exclude_retrocomm_flag(sv_trncod,TGTAR[i].RAICOM_B)  != 'E'  )
            {
                   if  (TGTAR[i].pp->PLCTROUVE == 0)
                    {
                    EcrireGTAr(Kp_GTAr,TGTAR[i],d_Ma,d_Mr,sv_trncod);        /* jr 28 04 03 sans placement */
                    }
                   else
                    {
                    Ecrire2GTAr(Kp_GTAr,TGTAR[i],d_Ma,d_Mr,sv_trncod);        /* jr 28 04 03 avec placement */
                    }
            }
 						if (TGTAR[i].RAICOM_B == 0 )
						{
							d_MaS = TGTAR[i].OVRCOMAMT_M ;
							d_MrS = TGTAR[i].RETOVRCOMAMT_M;
							d_MriS = TGTAR[i].RETOVRCOMAMT_M;
							d_MaSMaj=0.;
							d_MrSMaj=0.;
							d_MriSMaj=0.;
						}
						else
						{
							d_MaSMaj = TGTAR[i].OVRCOMAMT_M ;
						  d_MrSMaj = TGTAR[i].RETOVRCOMAMT_M;
						  d_MriSMaj = TGTAR[i].RETOVRCOMAMT_M;
							d_MaS=0.;
							d_MrS=0.;
							d_MriS=0.;
						}

/*   ajout JR 10/02/03 */
/*            if (TPLAC[p].SSDRTO_B = 0)  */
            if  (TGTAR[i].pp->SSDRTO_B == 0)
            {
              d_MriS=0.;
							d_MriSMaj=0.;
            }

						if (d_MaS != 0. && d_MrS != 0.)
						{
							/* modification du poste comptable */
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTArp(Kp_GTAr,TGTAR[i],d_MaS,d_MrS,d_MriS,sz_trncod);
						}
						if (d_MaSMaj != 0. && d_MrSMaj != 0.)
						{
							/* modification du poste comptable */
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTArp(Kp_GTArMaj,TGTAR[i],d_MaSMaj,d_MrSMaj,d_MriSMaj,sz_trncod);
/* fin    ajout JR 10/02/03 */
            }

						for (k=i0; k<= imax; k++)
						{
        				//j= a * Kn_TPLAC + k;
							if (strcmp(TGTAR[k].pp->RETCUR_CF,sz_retcur) == 0)
							{
								TGTAR[k].RETCUR_B=1;
								d_Ma =  TGTAR[k].AMT_M;
								d_Mr =  TGTAR[k].RETAMT_M;
                                strcpy(sv_trncod,TGTAR[k].pa->TRNCOD_CF);

                                 if ( get_exclude_retrocomm_flag(sv_trncod,TGTAR[k].RAICOM_B)  != 'E'  )
                                 {
                                   if  (TGTAR[k].pp->PLCTROUVE == 0)
                                   {
                                    EcrireGTAr(Kp_GTAr,TGTAR[k],d_Ma,d_Mr,sv_trncod);        /* jr 28 04 03 sans placement */
                                   }
                                   else
                                   {
                                    Ecrire2GTAr(Kp_GTAr,TGTAR[k],d_Ma,d_Mr,sv_trncod);        /* jr 28 04 03 avec placement */
                                   }
                                 }		
								 
								if (TGTAR[k].RAICOM_B == 0 )
								{
/*  mise en commentaire JR 10/02/03
									d_MaS = d_MaS + TGTAR[k].OVRCOMAMT_M;
									d_MrS = d_MrS + TGTAR[k].RETOVRCOMAMT_M;
								}
								else
								{
									d_MaSMaj = d_MaSMaj + TGTAR[k].OVRCOMAMT_M;
									d_MrSMaj = d_MrSMaj + TGTAR[k].RETOVRCOMAMT_M;
   fin mise en comentaire JR 10/02/03 */

/*   ajout JR 10/02/03 */

					    		d_MaS = TGTAR[k].OVRCOMAMT_M ;
			    				d_MrS = TGTAR[k].RETOVRCOMAMT_M;
							    d_MriS = TGTAR[k].RETOVRCOMAMT_M;
				    			d_MaSMaj=0.;
		    					d_MrSMaj=0.;
						    	d_MriSMaj=0.;
   					  	}
	   			  		else
		  		  		{
	    						d_MaSMaj = TGTAR[k].OVRCOMAMT_M ;
							    d_MrSMaj = TGTAR[k].RETOVRCOMAMT_M;
						      d_MriSMaj = TGTAR[k].RETOVRCOMAMT_M;
    							d_MaS=0.;
	    						d_MrS=0.;
							    d_MriS=0.;

								}

/*      printf ("%d, %d\n",p,Kn_TPLAC);   */
/*            if (TPLAC[p].SSDRTO_B== 0)  */
            if  (TGTAR[k].pp->SSDRTO_B == 0)
            {
              d_MriS=0.;
							d_MriSMaj=0.;
            }

						if (d_MaS != 0. && d_MrS != 0.)
						{
							/* modification du poste comptable */
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTArp(Kp_GTAr,TGTAR[k],d_MaS,d_MrS,d_MriS,sz_trncod);
						}
						if (d_MaSMaj != 0. && d_MrSMaj != 0.)
						{
							/* modification du poste comptable */
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTArp(Kp_GTArMaj,TGTAR[k],d_MaSMaj,d_MrSMaj,d_MriSMaj,sz_trncod);
/* fin    ajout JR 10/02/03 */
               }
							} /* fin "if (strcmp(TGTAR[k].RETCUR_CF,sz_retcur) == 0)" */
						} /* fin "for (k=i0; k<= imax; k++)" */
						/* 21/03/03 EcrireGTAr(Kp_GTAr,TGTAR[i],d_Ma,d_Mr,sz_trncod); */

/* mis en commentaire JR 10/02/03
						if (d_MaS != 0. && d_MrS != 0.)
						{
							** modification du poste comptable
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTAr(Kp_GTAr,TGTAR[i],d_MaS,d_MrS,sz_trncod);
						}
						if (d_MaSMaj != 0. && d_MrSMaj != 0.)
						{
							** modification du poste comptable
							sz_trncod[1]='1';
							sz_trncod[2]='1';
							sz_trncod[3]='2';
							sz_trncod[4]='1';
							sz_trncod[5]='1';
							sz_trncod[6]='0';

							EcrireGTAr(Kp_GTArMaj,TGTAR[i],d_MaSMaj,d_MrSMaj,sz_trncod);
						}
 fin mis en commentaire jr 10/02/03 */
					}  /* fin du "si TGTAR[].RETCUR_B=0" */
				}   /* fin de la boucle sur TPLAC */

				imin=imin+Kn_TPLAC;
				imax=imax+Kn_TPLAC;

   			}  /* fin de la boucle sur TACC */


			/*----------------------------------------------*/
			/* 4- Cumul 2 : generation des GTRr             */
			/*----------------------------------------------*/

			if (Kn_GTR == 1)
			{ /* on ne genere les gtrr que si le parametre option est a "oui" (1) */
				for (p=0; p < Kn_TPLAC; p++)
				{
					d_Mr=0.;
					d_MrS=0.;

					for(a=0; a < Kn_TACC; a++)
					{
						i=a * Kn_TPLAC + p;
						strcpy(sz_trncod,TGTAR[i].pa->TRNCOD_CF);
						d_Mr = d_Mr + TGTAR[i].RETAMT_M;
						d_MrS = d_MrS + TGTAR[i].RETOVRCOMAMT_M;

						if ( (a == Kn_TACC-1) || (b_IsRuptureGTRr(TGTAR,i,i+Kn_TPLAC) == 1) )
						{
						
							if ( get_exclude_retrocomm_flag(sz_trncod,TGTAR[i].RAICOM_B)  != 'E'  )
							{							
							EcrireGTRr(Kp_GTRr, TGTAR[i],d_Mr,sz_trncod);
							}							
							
							if (d_MrS != 0.)
							{
								/* modification du poste comptable */

								sz_trncod[1]='1';
								sz_trncod[2]='1';
								sz_trncod[3]='2';
								sz_trncod[4]='1';
								sz_trncod[5]='1';
								sz_trncod[6]='0';

								EcrireGTRr((TGTAR[p].RAICOM_B == 0? Kp_GTRr: Kp_GTRrMaj),
								TGTAR[i],d_MrS,sz_trncod);
							}
							d_Mr = 0.;
							d_MrS=0.;
						} /* fin du if rupture */
					} /* fin de la boucle sur l'acceptation */
				} /* fin de la boucle sur TPLAC */
			} /* fin du if option=1 */


		} /* fin if n_TGTAR!=0 */
	}  /* fin "if ( (Kb_TPLACDepass == 0) && (Kb_TACCDepass ==0) )" */

	if ( TGTAR )  { free ( TGTAR ); TGTAR=NULL;}
	RETURN_VAL(OK);
}

/*======================================================================
 Fonction qui teste la rupture sur RETOCCYEA_NF/RCL_NF/RETACY_NF/
                                   RETSCOSTRMTH_NF/RETSCOENDMTH_NF
 Retour : 1 si il y a rupture
          0 s'il n'y a pas rupture
=======================================================================*/
static int b_IsRuptureGTRr(T_GTAR TGTAR[],int i,int j)
{
	DEBUT_FCT ("b_IsRuptureGTRr") ;

    if ((atoi(TGTAR[i].pa->RETOCCYEA_NF)-atoi(TGTAR[j].pa->RETOCCYEA_NF)) != 0)
           RETURN_VAL(1);
    if ((atoi(TGTAR[i].pa->RCL_NF)-atoi(TGTAR[j].pa->RCL_NF)) != 0)
           RETURN_VAL(1);
    if ((TGTAR[i].pa->RETACY_NF-TGTAR[j].pa->RETACY_NF) != 0)
           RETURN_VAL(1);
    if ((TGTAR[i].pa->RETSCOSTRMTH_NF-TGTAR[j].pa->RETSCOSTRMTH_NF) != 0)
           RETURN_VAL(1);
    if ((TGTAR[i].pa->RETSCOENDMTH_NF-TGTAR[j].pa->RETSCOENDMTH_NF) != 0)
           RETURN_VAL(1);

       RETURN_VAL(0);
}

/*==================================================================
objet : Stocker une ligne du fichier GTaccepation 100% lu en entree
	dans le tableau TACC.
====================================================================*/

static int StockeLigneAcc(char ** tpsz_ReadBufferGTA)
{
	DEBUT_FCT ("StockeLigneAcc") ;

	TACC[Kn_TACC].SSD_CF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]);
	TACC[Kn_TACC].ESB_CF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_ESB_CF]);
	TACC[Kn_TACC].BALSHEY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_BALSHEY_NF]);
	TACC[Kn_TACC].BALSHRMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRMTH_NF]);
	TACC[Kn_TACC].BALSHRDAY_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRDAY_NF]);
	strcpy(TACC[Kn_TACC].TRNCOD_CF,tpsz_ReadBufferGTA[GT_TRNCOD_CF]);
	strcpy(TACC[Kn_TACC].DBLTRNCOD_CF,tpsz_ReadBufferGTA[GT_DBLTRNCOD_CF]);
	strcpy(TACC[Kn_TACC].CTR_NF,tpsz_ReadBufferGTA[GT_CTR_NF]);
	TACC[Kn_TACC].END_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_END_NT]);
	TACC[Kn_TACC].SEC_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SEC_NF]);
	TACC[Kn_TACC].UWY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_UWY_NF]);
	TACC[Kn_TACC].UW_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_UW_NT]);
	strcpy(TACC[Kn_TACC].OCCYEA_NF,tpsz_ReadBufferGTA[GT_OCCYEA_NF]);
	TACC[Kn_TACC].ACY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ACY_NF]);
	TACC[Kn_TACC].SCOSTRMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOSTRMTH_NF]);
	TACC[Kn_TACC].SCOENDMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOENDMTH_NF]);
	strcpy(TACC[Kn_TACC].CLM_NF,tpsz_ReadBufferGTA[GT_CLM_NF]);
	strcpy(TACC[Kn_TACC].CUR_CF,tpsz_ReadBufferGTA[GT_CUR_CF]);
	TACC[Kn_TACC].AMT_M=atof(tpsz_ReadBufferGTA[GT_AMT_M]);
	TACC[Kn_TACC].CED_NF=atoi(tpsz_ReadBufferGTA[GT_CED_NF]);
	TACC[Kn_TACC].BRK_NF=atoi(tpsz_ReadBufferGTA[GT_BRK_NF]);
	TACC[Kn_TACC].PAY_NF=atoi(tpsz_ReadBufferGTA[GT_PAY_NF]);
	strcpy(TACC[Kn_TACC].KEY_NF,tpsz_ReadBufferGTA[GT_KEY_NF]);
	strcpy(TACC[Kn_TACC].RETCTR_NF,tpsz_ReadBufferGTA[GT_RETCTR_NF]);
	TACC[Kn_TACC].RETEND_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETEND_NT]);
	TACC[Kn_TACC].RETSEC_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSEC_NF]);
	TACC[Kn_TACC].RTY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_RTY_NF]);
	TACC[Kn_TACC].RETUW_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETUW_NT]);
	strcpy(TACC[Kn_TACC].RETOCCYEA_NF,tpsz_ReadBufferGTA[GT_RETOCCYEA_NF]);
	TACC[Kn_TACC].RETACY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_RETACY_NF]);
	TACC[Kn_TACC].RETSCOSTRMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSCOSTRMTH_NF]);
	TACC[Kn_TACC].RETSCOENDMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_RETSCOENDMTH_NF]);
	strcpy(TACC[Kn_TACC].RCL_NF,tpsz_ReadBufferGTA[GT_RCL_NF]);
	strcpy(TACC[Kn_TACC].RETCUR_CF,tpsz_ReadBufferGTA[GT_RETCUR_CF]);
	TACC[Kn_TACC].RETAMT_M=atof(tpsz_ReadBufferGTA[GT_RETAMT_M]);
	
	TACC[Kn_TACC].TAUXACCEPT_R=Kd_TauxAccept;
	
	if (Kn_GTE == 1) /* GT enrichi : 5 champs en plus */
	{
		TACC[Kn_TACC].ENTPERYEA_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ENTPERYEA_NF]);
		TACC[Kn_TACC].ENTPERMTH_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ENTPERMTH_NF]);
		TACC[Kn_TACC].VALPERYEA_NF=(short) atoi(tpsz_ReadBufferGTA[GT_VALPERYEA_NF]);
		TACC[Kn_TACC].VALPERMTH_NF=(short) atoi(tpsz_ReadBufferGTA[GT_VALPERMTH_NF]);
		TACC[Kn_TACC].TRN_NT=atoi(tpsz_ReadBufferGTA[GT_TRN_NT2]);   //[005]
		TACC[Kn_TACC].ACCTYP_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ACCTYP_NF2]);   // [007]
		TACC[Kn_TACC].BALSHEY_NF_PLUS=(short) atoi(tpsz_ReadBufferGTA[GT_BALSHEY_NF_PLUS]);
		TACC[Kn_TACC].BALSHRMTH_NF_PLUS=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRMTH_NF_PLUS]);
		TACC[Kn_TACC].BALSHRDAY_NF_PLUS=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRDAY_NF_PLUS]);
		strcpy(TACC[Kn_TACC].COMMAC_LL,tpsz_ReadBufferGTA[GT_COMMAC_LL]);
		strcpy(TACC[Kn_TACC].SPEENTTYP_CF,tpsz_ReadBufferGTA[GT_SPEENTTYP_CF]);
		strcpy(TACC[Kn_TACC].SPEENTNAT_CT,tpsz_ReadBufferGTA[GT_SPEENTNAT_CT]);
		strcpy(TACC[Kn_TACC].EVT_NF,tpsz_ReadBufferGTA[GT_EVT_NF]);     // [007]
		if ( tpsz_ReadBufferGTA[GT_REVT_NF][0] == 0 || tpsz_ReadBufferGTA[GT_REVT_NF][0] == ' ') 
			strcpy(TACC[Kn_TACC].REVT_NF,tpsz_ReadBufferGTA[GT_EVT_NF]);   // [007]
		else
			strcpy(TACC[Kn_TACC].REVT_NF,tpsz_ReadBufferGTA[GT_REVT_NF]);   // [007]
	}

RETURN_VAL( OK );
}

/*==================================================================
objet : Stocker une ligne du fichier placements lu en entree
	dans le tableau TPLAC.
====================================================================*/

static int StockeLignePlac(char ** tpsz_ReadBufferPLC)
{
	DEBUT_FCT ("StockeLignePlac") ;
	TPLAC[Kn_TPLAC].SSD_CF=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_SSD_CF]);
	TPLAC[Kn_TPLAC].ESB_CF=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_ESB_CF]);
	strcpy(TPLAC[Kn_TPLAC].RETCTR_NF,tpsz_ReadBufferPLC[PLA_RETCTR_NF]);
	TPLAC[Kn_TPLAC].RETEND_NT=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETEND_NT]);
	TPLAC[Kn_TPLAC].RETSEC_NF=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETSEC_NF]);
	TPLAC[Kn_TPLAC].RTY_NF=(short) atoi(tpsz_ReadBufferPLC[PLA_RTY_NF]);
	TPLAC[Kn_TPLAC].RETUW_NT=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETUW_NT]);
	TPLAC[Kn_TPLAC].PLC_NT=atoi(tpsz_ReadBufferPLC[PLA_PLC_NT]);
	TPLAC[Kn_TPLAC].OVRCOM_R=atof(tpsz_ReadBufferPLC[PLA_OVRCOM_R]);
	TPLAC[Kn_TPLAC].RTO_NF=atoi(tpsz_ReadBufferPLC[PLA_RTO_NF]);
	TPLAC[Kn_TPLAC].INT_NF=atoi(tpsz_ReadBufferPLC[PLA_INT_NF]);
	TPLAC[Kn_TPLAC].PAY_NF=atoi(tpsz_ReadBufferPLC[PLA_PAY_NF]);
	strcpy(TPLAC[Kn_TPLAC].KEY_CF,tpsz_ReadBufferPLC[PLA_KEY_CF]);
	TPLAC[Kn_TPLAC].ORICUR_B=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_ORICUR_B]);
	TPLAC[Kn_TPLAC].SSDRTO_B=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_SSDRTO_B]);
	TPLAC[Kn_TPLAC].RETSIGSHA_R=atof(tpsz_ReadBufferPLC[PLA_RETSIGSHA_R]);
	strcpy(TPLAC[Kn_TPLAC].LOB_CF,tpsz_ReadBufferPLC[PLA_LOB_CF]);
	TPLAC[Kn_TPLAC].RAICOM_B=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RAICOM_B]);
	TPLAC[Kn_TPLAC].RETOVRCOM_B=(unsigned char) atoi(tpsz_ReadBufferPLC[PLA_RETOVRCOM_B]);
	RETURN_VAL(OK);
}


/*=============================================================
objet : Stocker une ligne au format GTARr dans le tableau TGTAR
        Les donnees proviennent du tableau des placements
	TPLAC et du tableau du GTacceptation100% TACC
===============================================================*/

static int EcrireTGTAR(T_GTAR TGTAR[] ,int i, int a, int p)
{
    char sz_poste[4];
    double d_taux;
    char MsgAno[200];
	DEBUT_FCT ("EcrireTGTAR") ;

    sprintf(sz_poste,"%.3s",TACC[a].TRNCOD_CF+1);

    TGTAR[i].pa = &TACC[a];
    TGTAR[i].pp = &TPLAC[p];

    TGTAR[i].AMT_M = TACC[a].AMT_M * TPLAC[p].RETSIGSHA_R;
/*    TGTAR[i].PLCTROUVE = c_PlcTrouve;  */

    if ( (TACC[a].TAUXACCEPT_R != -1) && (TPLAC[p].TAUXRETRO_R != -1) )
    {
     d_taux=TACC[a].TAUXACCEPT_R/TPLAC[p].TAUXRETRO_R;
    }
    else d_taux = -1;

/*    d_taux=d_GetTaux(Kp_Curquot, TACC[a].SSD_CF,
                                 (short) Kn_AnneeCours,
				 TACC[a].CUR_CF,
				 TPLAC[p].RETCUR_CF);
*/

/*********/
    if (d_taux == -1)   /* cours de change non trouve */
    {
       /* ecrire une ano : cours de change non trouve */
       sprintf(MsgAno,"Exchange rate from %s to %s for subsidiary %d and year %d not found in reference table TCURQUOT\n",
        TACC[a].RETCUR_CF,
        TPLAC[p].RETCUR_CF,
       TACC[a].SSD_CF,
        Kn_AnneeCours);

       n_WriteAno(MsgAno);
      d_taux = 0 ;
    }
/***********/

    TGTAR[i].RETAMT_M = TGTAR[i].AMT_M * d_taux;

    TGTAR[i].RETCUR_B = 0;

    if ( ((strcmp(sz_poste,"110") == 0) || (strcmp(sz_poste,"111") == 0) ) &&
	 (TPLAC[p].OVRCOM_R != 0.)
       )
    {
         TGTAR[i].OVRCOMAMT_M = TGTAR[i].AMT_M * TPLAC[p].OVRCOM_R * (-1.) ;
         TGTAR[i].RETOVRCOMAMT_M = TGTAR[i].RETAMT_M*TPLAC[p].OVRCOM_R * (-1.) ;
    }
    else
    {
         TGTAR[i].OVRCOMAMT_M = 0. ;
         TGTAR[i].RETOVRCOMAMT_M = 0. ;
    }
    TGTAR[i].RAICOM_B = TPLAC[p].RAICOM_B;

    RETURN_VAL(OK);

}

/*=============================================================
objet : Ecrire une ligne au format GTAr dans un fichier en sortie
===============================================================*/

static int EcrireGTAr(FILE * pf, T_GTAR TGTAR,
		      double d_Ma, double d_Mr,char * sz_trncod)
{

  DEBUT_FCT ("EcrireGTAr") ;

  /* cas du GT non enrichi */
  if ( (fabs(d_Ma) >= 0.001) || (fabs(d_Mr) >= 0.001) ) {
/*    if  TGTAR[i].PLCTROUVE == 0 {    */
    if (Kn_GTE == 0) {
/* ajout derniere colonne pour retintamt_m */
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~~~~~~%.3lf\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
/*        TGTAR.pp->PLC_NT,      ajout jr 09/04/03 */
        0.000); /* RETINTAMT_M */
    }
    else { /* GT enrichi en entree : 5 champs supplementaires */
/* ajout colonne pour retintamt_m */
//			printf("%c", TGTAR.pa->SPEENTNAT_CT);
//			printf("%c", TGTAR.pa->SPEENTTYP_CF);
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~~~~~~%.3lf~%d~%d~%d~%d~%d~%d~%d~%02d~%02d~%s~%s~%s~%s~%s\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
/*        TGTAR.pp->PLC_NT,      ajout jr 09/04/03 */
	      0.000, /* RETINTAMT_M */
	      TGTAR.pa->ENTPERYEA_NF,
	      TGTAR.pa->ENTPERMTH_NF,
	      TGTAR.pa->VALPERYEA_NF,
	      TGTAR.pa->VALPERMTH_NF,
	      TGTAR.pa->TRN_NT,
	      TGTAR.pa->ACCTYP_NF,
	      TGTAR.pa->BALSHEY_NF_PLUS ,
	      TGTAR.pa->BALSHRMTH_NF_PLUS ,
	      TGTAR.pa->BALSHRDAY_NF_PLUS ,
	      TGTAR.pa->COMMAC_LL,
	      TGTAR.pa->SPEENTTYP_CF,
	      TGTAR.pa->SPEENTNAT_CT,
	      TGTAR.pa->EVT_NF,       // [007]
	      TGTAR.pa->REVT_NF       // [007]
	      );
    }
  }

  RETURN_VAL( OK);

}

/* ajout new fonction JR 28/04/03 */
/*=============================================================
objet : Ecrire une ligne au format GTAr dans un fichier en sortie
===============================================================*/

static int Ecrire2GTAr(FILE * pf, T_GTAR TGTAR,
		      double d_Ma, double d_Mr,char * sz_trncod)
{

  DEBUT_FCT ("Ecrire2GTAr") ;

  /* cas du GT non enrichi */
  if ( (fabs(d_Ma) >= 0.001) || (fabs(d_Mr) >= 0.001) ) {
    if (Kn_GTE == 0) {
/* ajout derniere colonne pour retintamt_m */
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~~~~~%.3lf\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
	      TGTAR.pp->PLC_NT,   /*   ajout jr 28/04/03 */
	      0.000); /* RETINTAMT_M */
    }
    else { /* GT enrichi en entree : 5 champs supplementaires */
/* ajout colonne pour retintamt_m */
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~~~~~%.3lf~%d~%d~%d~%d~%d~%d~%d~%02d~%02d~%s~%s~%s~%s~%s\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
	      TGTAR.pp->PLC_NT,   /*   ajout jr 28/04/03 */
	      0.000, /* RETINTAMT_M */
	      TGTAR.pa->ENTPERYEA_NF,
	      TGTAR.pa->ENTPERMTH_NF,
	      TGTAR.pa->VALPERYEA_NF,
	      TGTAR.pa->VALPERMTH_NF,
	      TGTAR.pa->TRN_NT,
	      TGTAR.pa->ACCTYP_NF,
	      TGTAR.pa->BALSHEY_NF_PLUS ,
	      TGTAR.pa->BALSHRMTH_NF_PLUS ,
	      TGTAR.pa->BALSHRDAY_NF_PLUS ,
	      TGTAR.pa->COMMAC_LL,
	      TGTAR.pa->SPEENTTYP_CF,
	      TGTAR.pa->SPEENTNAT_CT,
	      TGTAR.pa->EVT_NF,       // [007]
	      TGTAR.pa->REVT_NF       // [007]
	      );
    }
  }

  RETURN_VAL( OK);

}


/* fin ajout new fontion 28 /04 /03 */

/* ajout new fonction jr 10/02/03 */
/*=============================================================
objet : Ecrire une ligne au format GTAr dans un fichier en sortie
===============================================================*/

static int EcrireGTArp(FILE * pf, T_GTAR TGTAR,
		      double d_Ma, double d_Mr, double d_Mri, char * sz_trncod)
{

  DEBUT_FCT ("EcrireGTArp") ;

  /* cas du GT non enrichi */
  if ( (fabs(d_Ma) >= 0.001) || (fabs(d_Mr) >= 0.001) ) {
    if (Kn_GTE == 0) {
/* ajout derniere colonne pour retintamt_m */
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~~~~~%.3lf\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
	      TGTAR.pp->PLC_NT,     /* ajout jr 10/02/03 */
        d_Mri);  /*  "0.000"  RETINTAMT_M */
    }
    else { /* GT enrichi en entree : 5 champs supplementaires */
/* ajout colonne pour retintamt_m */
      fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~~~~~%.3lf~%d~%d~%d~%d~%d~%d~%d~%02d~%02d~%s~%s~%s~%s~%s\n",
	      TGTAR.pa->SSD_CF,
	      TGTAR.pp->ESB_CF,
	      TGTAR.pa->BALSHEY_NF ,
	      TGTAR.pa->BALSHRMTH_NF ,
	      TGTAR.pa->BALSHRDAY_NF ,
	      sz_trncod,
	      TGTAR.pa->DBLTRNCOD_CF,
	      TGTAR.pa->CTR_NF,
	      TGTAR.pa->END_NT ,
	      TGTAR.pa->SEC_NF ,
	      TGTAR.pa->UWY_NF ,
	      TGTAR.pa->UW_NT ,
	      TGTAR.pa->OCCYEA_NF ,
	      TGTAR.pa->ACY_NF ,
	      TGTAR.pa->SCOSTRMTH_NF ,
	      TGTAR.pa->SCOENDMTH_NF ,
	      TGTAR.pa->CLM_NF ,
	      TGTAR.pa->CUR_CF,
	      d_Ma,
	      TGTAR.pa->CED_NF ,
	      TGTAR.pa->BRK_NF ,
	      TGTAR.pa->PAY_NF ,
	      TGTAR.pa->KEY_NF ,
	      TGTAR.pa->RETCTR_NF,
	      TGTAR.pa->RETEND_NT ,
	      TGTAR.pa->RETSEC_NF ,
	      TGTAR.pa->RTY_NF ,
	      TGTAR.pa->RETUW_NT ,
	      TGTAR.pa->RETOCCYEA_NF ,
	      TGTAR.pa->RETACY_NF ,
	      TGTAR.pa->RETSCOSTRMTH_NF ,
	      TGTAR.pa->RETSCOENDMTH_NF ,
	      TGTAR.pa->RCL_NF ,
	      TGTAR.pp->RETCUR_CF,
	      d_Mr,
	      TGTAR.pp->PLC_NT,    /* ajout JR 10/02/03 */
	      d_Mri,         /*   "0.000"  RETINTAMT_M */
	      TGTAR.pa->ENTPERYEA_NF,
	      TGTAR.pa->ENTPERMTH_NF,
	      TGTAR.pa->VALPERYEA_NF,
	      TGTAR.pa->VALPERMTH_NF,
	      TGTAR.pa->TRN_NT,
	      TGTAR.pa->ACCTYP_NF,
	      TGTAR.pa->BALSHEY_NF_PLUS ,
	      TGTAR.pa->BALSHRMTH_NF_PLUS ,
	      TGTAR.pa->BALSHRDAY_NF_PLUS ,
	      TGTAR.pa->COMMAC_LL,
	      TGTAR.pa->SPEENTTYP_CF,
	      TGTAR.pa->SPEENTNAT_CT,
	      TGTAR.pa->EVT_NF,       // [007]
	      TGTAR.pa->REVT_NF       // [007]
	      );
    }
  }

  RETURN_VAL( OK);

}

/*  fin ajout new fonction jr 10/02/03  */
/*=============================================================
objet : Ecrire une ligne au format GTRr dans un fichier en sortie
===============================================================*/

static int EcrireGTRr(FILE * pf, T_GTAR TGTAR,
		      double d_Mr, char * sz_trncod)
{

  DEBUT_FCT ("EcrireGTRr") ;

  if ( fabs(d_Mr) >= 0.001 ) {
/* ajout derniere colonne pour retintamt_m */
    fprintf(pf,"%d~%d~%d~%d~%d~%s~%s~~~~~~~~~~~~~~~~~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%d~%s~%.3lf\n",
	    TGTAR.pa->SSD_CF,
	    TGTAR.pp->ESB_CF,
	    TGTAR.pa->BALSHEY_NF ,
	    TGTAR.pa->BALSHRMTH_NF ,
	    TGTAR.pa->BALSHRDAY_NF ,
	    sz_trncod,
	    TGTAR.pa->DBLTRNCOD_CF,
	    TGTAR.pa->RETCTR_NF,
	    TGTAR.pa->RETEND_NT ,
	    TGTAR.pa->RETSEC_NF ,
	    TGTAR.pa->RTY_NF ,
	    TGTAR.pa->RETUW_NT ,
	    TGTAR.pa->RETOCCYEA_NF ,
	    TGTAR.pa->RETACY_NF ,
	    TGTAR.pa->RETSCOSTRMTH_NF ,
	    TGTAR.pa->RETSCOENDMTH_NF ,
	    TGTAR.pa->RCL_NF ,
	    TGTAR.pp->RETCUR_CF,
	    d_Mr,
	    TGTAR.pp->PLC_NT,
	    TGTAR.pp->RTO_NF,
	    TGTAR.pp->INT_NF,
	    TGTAR.pp->PAY_NF,
	    TGTAR.pp->KEY_CF,
      0.000); /* RETINTAMT_M */
  }

  RETURN_VAL (OK);

}

/*=============================================================
objet : Ecrire le tableau TGTAR pour verification (debug a enlever plus tard)
===============================================================*/
/*
static int AfficheTGTAR(T_GTAR TGTAR)
{
	DEBUT_FCT ("AfficheTGTAR") ;

   printf("%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%d~%d~%d~%s~%d\n",
    TGTAR.pa->SSD_CF,
    TGTAR.pp->ESB_CF,
    TGTAR.pa->BALSHEY_NF ,
    TGTAR.pa->BALSHRMTH_NF ,
    TGTAR.pa->BALSHRDAY_NF ,
    TGTAR.pa->TRNCOD_CF,
    TGTAR.pa->DBLTRNCOD_CF,
    TGTAR.pa->CTR_NF,
    TGTAR.pa->END_NT,
    TGTAR.pa->SEC_NF,
    TGTAR.pa->UWY_NF,
    TGTAR.pa->UW_NT,
    TGTAR.pa->OCCYEA_NF,
    TGTAR.pa->ACY_NF,
    TGTAR.pa->SCOSTRMTH_NF,
    TGTAR.pa->SCOENDMTH_NF,
    TGTAR.pa->CLM_NF,
    TGTAR.pa->CUR_CF,
    TGTAR.AMT_M,
    TGTAR.pa->CED_NF,
    TGTAR.pa->BRK_NF,
    TGTAR.pa->PAY_NF,
    TGTAR.pa->KEY_NF,
    TGTAR.pa->RETCTR_NF,
    TGTAR.pa->RETEND_NT ,
    TGTAR.pa->RETSEC_NF ,
    TGTAR.pa->RTY_NF ,
    TGTAR.pa->RETUW_NT ,
    TGTAR.pa->RETOCCYEA_NF ,
    TGTAR.pa->RETACY_NF ,
    TGTAR.pa->RETSCOSTRMTH_NF ,
    TGTAR.pa->RETSCOENDMTH_NF ,
    TGTAR.pa->RCL_NF ,
    TGTAR.pp->RETCUR_CF,
    TGTAR.RETAMT_M,
    TGTAR.pp->PLC_NT,
    TGTAR.pp->RTO_NF,
    TGTAR.pp->INT_NF,
    TGTAR.pp->PAY_NF,
    TGTAR.pp->KEY_CF,
    TGTAR.RAICOM_B);

   RETURN_VAL( OK);

}

*/


/*============================================================================
objet :
   Lancement du traitement destine a ramener des lignes de la base.

retour :
 CS_SUCCEED
 CS_FAIL
==============================================================================*/
static char *sz_GetCurcvsnIndx(
 FILE* pf,/* Discripteur du fichier des cours */
        char *sz_acpcur,        /* Cours d'origine */
        char c_ssd,             /* filiale */
                char *sz_retctr,        /* contrat */
        short s_rty,            /* Exercice */
                int   n_plc,                     /* placement */
        char *pc_PlcTrouve         /* JR 28/04/03 */
        )
{
  static char          b_First = TRUE ;
  static T_INDXCURQUOT *pKbd_Adr;
  static T_CURCVSN *pKbd_curcvsn;
  T_INDXCURQUOT  bd_AdrTampon ;
  static int Kn_MaxCoursDevise ;
  static int k = 0 ;

  static char sz_Vide[4] = "   " ;
  int i, j ;
  int   n_position=-1;
  char  b_SsdTrouve = 0;
  static int  n_DebutData = MAX_DEVISE*sizeof(T_INDXCURQUOT)	;


  DEBUT_FCT ("sz_GetCurcvsnIndx");

  *pc_PlcTrouve = 0;        /* JR 28/04/03 */
  if(b_First)
  {
    b_First = FALSE;
    if(fseek(pf,0,SEEK_SET)==-1L)
    {   RETURN_VAL (NULL) ;}
    else
{
    while (fread (&bd_AdrTampon, sizeof(T_INDXCURQUOT), 1, pf) > 0 && bd_AdrTampon.n_Nbr != 0 )
    {
    k++;
    Kn_MaxCoursDevise = max ( bd_AdrTampon.n_Nbr, Kn_MaxCoursDevise );
    }


/* allocation de la memoire pour les deux structures */

   pKbd_curcvsn = malloc (sizeof(T_CURCVSN) * Kn_MaxCoursDevise);

   pKbd_Adr = malloc (sizeof(T_INDXCURQUOT) * k);

/* remplissage de la structure des adresses */

   fseek(pf, 0, SEEK_SET);

   fread(pKbd_Adr,  sizeof(T_INDXCURQUOT) , k, pf);

}
}
  //sz_acccur_cf = sz_Vide ;

  for(i=0;i<k; i++)
  {
        if(strcmp(pKbd_Adr[i].sz_cur,sz_acpcur)==0)
        {
                if(fseek( pf,
                        pKbd_Adr[i].l_Pos*sizeof(T_CURCVSN)+n_DebutData,
                        SEEK_SET)==-1L)
                {
                        RETURN_VAL(NULL);
                }
                else
                {
                        if( fread(pKbd_curcvsn,sizeof(T_CURCVSN),pKbd_Adr[i].n_Nbr,pf)> 0 )
                        {
                                for(j=0;j<pKbd_Adr[i].n_Nbr ; j++ )
                                {
                                        if (c_ssd == pKbd_curcvsn[j].SSD_CF)
                                        {
                                            b_SsdTrouve=1;
                                            if ( (strcmp(pKbd_curcvsn[j].RETCTR_NF,"         ")==0) && pKbd_curcvsn[j].RTY_NF == 0)
					    {
                                                n_position = j;
						continue ;
					    }
                                            if ( (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) == 0) &&
                                                 (s_rty == pKbd_curcvsn[j].RTY_NF)      )
                                            {
                                                //b_RetctrRtyTrouve=1;
                                                if (pKbd_curcvsn[j].PLC_NT == 0)
                                                {
                                                   n_position = j;
                                                   //b_PlcNulTrouve=1;
                                                }
                                                if (n_plc == pKbd_curcvsn[j].PLC_NT)
                                                {
                                                    //b_PlcTrouve=1;
                                                    *pc_PlcTrouve = 1;   /* JR 28/04/03 */
                                                    n_position = j;
                                                    break;
                                                }
                                            }
                                            if  (strcmp(sz_retctr, pKbd_curcvsn[j].RETCTR_NF) < 0)  break;
                                        }

                                }


                                if ((n_position < 0) || (b_SsdTrouve == 0) )
                                        {RETURN_VAL(sz_Vide);}
                                else
                                   { RETURN_VAL (pKbd_curcvsn[n_position].ACCCUR_CF);}


                        }
                        else { RETURN_VAL(sz_Vide) ; }
                }
        }
  }

  RETURN_VAL(sz_Vide);
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre==FCUR)
 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFCURCVSNBIS(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2334_I5","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneFCURCVSNBIS;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneFCURCVSNBIS(char **ptb_InRec_Cur)
{

  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].SSD_CF = atoi(ptb_InRec_Cur[CURCVSNBIS_SSD_CF]);
  strcpy(Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].RETCTR_NF,ptb_InRec_Cur[CURCVSNBIS_RETCTR_NF]);
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].RTY_NF = atoi(ptb_InRec_Cur[CURCVSNBIS_RTY_NF]);
  Ktbd_FCURCVSNBIS[Kn_FCURCVSNBIS].PLC_NT = atoi(ptb_InRec_Cur[CURCVSNBIS_PLC_NT]);

  Kn_FCURCVSNBIS +=1;

  if (Kn_FCURCVSNBIS > Kn_MaxLigFCURCVSNBIS )
  {
      n_WriteAno(" Depassement capacite du tableau CURCVSNBIS ");
      return ERR;
  }

return OK ;
}


/*==============================================================================
objet :
        fonction de recherche de la devise
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechCURCVSNBIS(char *sz_retctr,
     								 int n_rty,
											int n_plc)
{
        int i;

        DEBUT_FCT("n_RechCur");


        for ( i = 0; i <  Kn_FCURCVSNBIS ; i++ )
        {
                if (
											strcmp( sz_retctr, Ktbd_FCURCVSNBIS[i].RETCTR_NF) == 0
											&&
											n_rty == Ktbd_FCURCVSNBIS[i].RTY_NF
											&&
											n_plc == Ktbd_FCURCVSNBIS[i].PLC_NT
									)
                 	RETURN_VAL(i);
        }

        RETURN_VAL(-1);   /* Si non trouve */
}



/*==============================================================================
objet : specific exclusion rule : retro overrider - retro commission , TC exclude

retour :
  OK ---> E for excluded , N for not excluded 
==============================================================================*/
char   get_exclude_retrocomm_flag(char * trn_cd , int RAICOM_B ) 
{
	
            if ( RAICOM_B == 0 
                && ( 
                      ( strncmp(&trn_cd[2],"12",2) == 0 
					    && strncmp(&trn_cd[2],"12110",5) != 0 && strncmp(&trn_cd[2],"12120",5) != 0 
					    && strncmp(&trn_cd[2],"12128",5) != 0 && strncmp(&trn_cd[2],"12161",5) != 0 && strncmp(&trn_cd[2],"12121",5) != 0 
					  ) 
                    || strncmp(&trn_cd[2],"13",2) == 0 
                    || strncmp(&trn_cd[2],"14",2) == 0 
                    || strncmp(&trn_cd[2],"15",2) == 0 
                    || strncmp(&trn_cd[2],"31",2) == 0 
                    || strncmp(&trn_cd[2],"43",2) == 0 						
                   )  
               )
            { 
               return 'E';
            }
            else
               return 'N';							
}	


