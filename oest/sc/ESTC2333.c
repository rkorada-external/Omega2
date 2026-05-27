/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2333.c
revision                      : $Revision:   1.3  $
date de creation              : 13/08/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Operateur de versement : GTAa * versements ===> GTAr100%

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	  30/01/03       J. Ribot   ajout colonne retintamt_m sur fichier en sortie
	  26/04/05        M.DJELLOULI   SPOT5084    - MOD02
	                                          Ajout de la Zone SPEENTTYP_CF de TACCSUPAE auto generation auto : AEs have been generated with the wrong ACY on retro side
	  24/06/05        M.DJELLOULI   SPOT5085    - MOD03
	                                          Ajout de la Zone SPEENTNAT_CT de TACCSUP
          25/06/12        Prajakta      Phase1B migration code changes for warning removal
[005] 24/09/2013 R. Cassis :spot:25427 On remet le include GT_TRN_NT
[006] 20/02/2015 R. cassis :spot:28328 - Add 2 columns EVT_NF and REVT_NF to TACCSUP
[007] 05/10/2015 -=Dch=-   :spot:29162 - Ajout du fichier périmètre dans l'appel de ESTC2303 (pour ajout CTR_CF et CTRNAT_CF) 
[008] 23/10/2017 R. cassis :spot:61508 - For Local ES Balance sheet date must be retained
[009] 02/08/2022 S.Behague :spira:94695 - AE auto generation auto : AEs have been generated with the wrong ACY on retro side
[010] 23/01/2024 S.Behague :spira:110548 - Wrong Retro ACY during the retro auto AE generation
[011] 15/02/2024 S.Behague/JYP/Mariem :spira:110548 - update scor period for retro
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/* position des champs dans le cas d'un GT enrichi en entree */
#define GT_ENTPERYEA_NF 41
#define GT_ENTPERMTH_NF 42
#define GT_VALPERYEA_NF 43
#define GT_VALPERMTH_NF 44
/*#define GT_TRN_NT 45 */ /** Commented for Phase1b migration **/
#define GT_TRN_NT2 45    // [005]
#define GT_ACCTYP_NF2 46   // [006]
#define GT_COMMAC_LL 47
#define GT_SPEENTTYP_CF 48
#define GT_SPEENTNAT_CT2 49
#define GT_EVT_NF2 50        // [006]
#define GT_REVT_NF2 51       // [006]

/* nombre max de versements pour une section donnee d'un contrat acceptation */
#define MAX_TCES 1000

/*  nombre max d'ecritures dans le GTAa pour un meme casex acceptation */
#define MAX_TGTA 10000

#define FLD_CONTRAT 0
#define FLD_NATURE 1



typedef struct{
               char CTR_NF[10];
               unsigned char END_NT;
               unsigned char SEC_NF;
               short UWY_NF;
               unsigned char UW_NT;
               char RETCTR_NF[10];
               unsigned char RETEND_NT;
               unsigned char RETSEC_NF;
               short RTY_NF;
               unsigned char RETUW_NT;
               int CESACCSTA_N;
               int CESACCEND_N;
               double CESSH_R;
               unsigned char SSD_CF;
               unsigned char ESB_CF;
               char RETCTRCAT_CF[3];
               unsigned char ACCADMTYP_CT;
               unsigned char RETACCADM_B;
               unsigned char CLECUTPER_B;
               int CLECUTPER_NB;
			   char ACCFAM_CT[6];
              } T_CES;

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
               char OCCYEA_NF[10];
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
               short ENTPERYEA_NF;
               short ENTPERMTH_NF;
               short VALPERYEA_NF;
               short VALPERMTH_NF;
               int TRN_NT;
               short ACCTYP_NF;
               char COMMAC_LL[65];
//               int SPEENTTYP_CF;                   // MOD02
               char SPEENTTYP_CF[5];              // MOD02
               unsigned char SPEENTNAT_CT;              // MOD03
               char EVT_NF[11];              // [006]
               char REVT_NF[11];             // [006]
              } T_GTA;

//               short SPEENTTYP_CF;              // MOD02
//               short SPEENTNAT_CT;              // MOD03

typedef struct { 
				char Contract [ 10 ];
				char Nature [2] ;
}	T_PERIMETRE;


/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitGTA(T_RUPTURE_VAR  *);
static int n_InitCES(T_RUPTURE_SYNC_VAR  *);
static int n_InitPerimetre(T_RUPTURE_SYNC_VAR  *);
static int n_ContratNatureSync(char **,char**);
static int n_ActionLigneCES(char **,char**);
static int n_ActionLignePerimetre(char **,char**);
static int n_ConditionSync(char **,char **);
static int n_ActionLigneGTA(char **);
static int n_ConditionRuptureGTA(char **, char **);
static int n_ActionFirstGTA(char **);
static int n_ActionLastGTA(char ** );
static void EcrireGTAr100(T_CES LigneVersement, T_GTA LigneGTAa, char * sz_PosteRetro);
static void StockeLigneAcc(char ** tpsz_ReadBufferGTA);
static void StockeLigneVers(char ** tpsz_ReadBufferCES);

extern int n_ProcessingRuptureVar(T_RUPTURE_VAR *);
extern int n_ProcessingRuptureSyncVar(T_RUPTURE_SYNC_VAR *,char**);

char *trim(char *s);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static T_CES   TCES[MAX_TCES]; /* pour stocker lignes du fichier versements */
static T_PERIMETRE CTR;
static T_GTA   TGTA[MAX_TGTA]; /* pour stocker lignes du fichier GTAa */

static FILE *Kp_Gtar100;   /* fichier de sortie */
static FILE *Kp_Dettrs, *Kp_Rettrf;

static T_RUPTURE_VAR   Kbd_RuptGTA;
static T_RUPTURE_SYNC_VAR  Kbd_RuptCES;

static T_RUPTURE_SYNC_VAR  Kbd_Perimetre;

static int Kn_GTA;  /* taille effective du tableau T_GTA */
static int Kn_CES;  /* taille effective du tableau T_CES */

static BOOL Kb_CESDepass; /* pour controler le depassement de la */
static BOOL Kb_GTADepass; /* capacite maximale des tableaux T_CES et T_GTA */

static BOOL Kb_ReturnStatus=0; /* statut de retour du programme */

static char Ksz_clodat[9];  /* 1er parametre du pgm : libelle d'inventaire */
static int Kn_GTE;        /* 2eme parametre du pgm : option GT enrichi */
static char sz_TypeTrait;  /* Type de traitement : Local(L) ou Autres (A)  */


/*==============================================================================
objet :
   point d'entre du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

	/* Initialisation des signaux */
	InitSig () ;

	if ( n_BeginPgm (argc  ,argv) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2333_I3","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2333_I4","rb",&Kp_Rettrf) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2333_O1","wt",&Kp_Gtar100) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* stockage des parametres du programme */
         sprintf(Ksz_clodat,"%s",psz_GetCharArgv(1));
         Kn_GTE=n_GetIntArgv(2);
         sz_TypeTrait = *(psz_GetCharArgv(3));  //[008]
	
	printf("Date Bilan : Ksz_clodat: %s\n",Ksz_clodat);
	printf("Type traitement : sz_TypeTrait: %c\n",sz_TypeTrait);

	printf("1: n_InitGTA\n");
	/* Initialisation de la variable Kbd_RuptGTA  */
	if ( n_InitGTA(&Kbd_RuptGTA)==ERR )
		ExitPgm ( ERR_XX , "" );

	printf("2: n_InitCES\n");
	/* Initialisation de la varible Kbd_RuptCES */
	if ( n_InitCES(&Kbd_RuptCES)==ERR )
		ExitPgm ( ERR_XX , "" );

	printf("3: n_InitPerimetre\n");
	/* Initialisation de la varible Kbd_Perimetre */
	if ( n_InitPerimetre(&Kbd_Perimetre)==ERR )
		ExitPgm ( ERR_XX , "" );

	
	printf("4:n_ProcessingRuptureVar \n");

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptGTA) == ERR )
		ExitPgm ( ERR_XX , "" );

	printf("1: n_InitGTA\n");
        if ( n_CloseFileAppl ("ESTC2333_I3",&Kp_Dettrs)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2333_I4",&Kp_Rettrf)==ERR )
                ExitPgm ( ERR_XX , "" );

		if ( n_CloseFileAppl("ESTC2333_I5", &(Kbd_Perimetre.pf_InputFil))==ERR)
				ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2333_O1",&Kp_Gtar100)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2333_I1",&(Kbd_RuptGTA.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2333_I2",&(Kbd_RuptCES.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

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
	memset(pbd_RuptGTA,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2333_I1","rt",&(pbd_RuptGTA->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptGTA->n_NbRupture =1;
	pbd_RuptGTA->n_ActionLigne     = n_ActionLigneGTA;

	pbd_RuptGTA->n_ConditionRupture[0] = n_ConditionRuptureGTA;
	pbd_RuptGTA->n_ActionFirst[0] = n_ActionFirstGTA;
	pbd_RuptGTA->n_ActionLast[0] = n_ActionLastGTA;

        pbd_RuptGTA->c_Separ='~';

	return OK ;
}

/*==============================================================================
objet :
	Test de rupture sur CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT
        pour le fichier pere (GTAa)

retour :
	0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
static int n_ConditionRuptureGTA(char ** tpsz_ReadBufferGTA,
                                 char ** tpsz_ReadBufferGTA_Cur)
{

        if(strcmp(tpsz_ReadBufferGTA[GT_CTR_NF],tpsz_ReadBufferGTA_Cur[GT_CTR_NF])!=0)
           return(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_END_NT],tpsz_ReadBufferGTA_Cur[GT_END_NT])!=0)
           return(1);

        if(strcmp(tpsz_ReadBufferGTA[GT_SEC_NF],tpsz_ReadBufferGTA_Cur[GT_SEC_NF])!=0)
           return(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_UWY_NF],tpsz_ReadBufferGTA_Cur[GT_UWY_NF])!=0)
           return(1);

        if (strcmp(tpsz_ReadBufferGTA[GT_UW_NT],tpsz_ReadBufferGTA_Cur[GT_UW_NT])!=0)
           return(1);

      return(0);
}

/*==============================================================================
objet :
	Fonction lancee en rupture premiere sur l'acceptation
        pour le fichier GTAa

retour :
	OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirstGTA(char ** tpsz_ReadBufferGTA)
{
     /* initialisation de TCES et TGTA */

     Kn_GTA=0;
     Kn_CES=0;
	 memset(TGTA, 0 , sizeof(TGTA));
	 memset(TCES, 0 , sizeof(TCES));
     Kb_GTADepass=0;
     Kb_CESDepass=0;

     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptCES,tpsz_ReadBufferGTA) == ERR)
           return ERR;

     return(OK);
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitCES(T_RUPTURE_SYNC_VAR  *pbd_RuptCES)
{

	memset( pbd_RuptCES,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2333_I2","rt",&(pbd_RuptCES->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptCES->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptCES->ConditionEndSync	= n_ConditionSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptCES->n_ActionLigne   	= n_ActionLigneCES;

        pbd_RuptCES->c_Separ='~';

	return OK ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPerimetre(T_RUPTURE_SYNC_VAR  *pbd_Perimetre)
{

	memset( pbd_Perimetre,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2333_I5","rt",&(pbd_Perimetre->pf_InputFil))==ERR)
           return ERR;

     pbd_Perimetre->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_Perimetre->ConditionEndSync	= n_ContratNatureSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_Perimetre->n_ActionLigne= n_ActionLignePerimetre;

    pbd_Perimetre->c_Separ='~';

	return OK ;
}



/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLigneCES(
	char *tpsz_ReadBufferGTA[] ,
	char *tpsz_ReadBufferCES[]
)
{
    char MsgAno[300];

    /* stockage de la ligne courante dans TCES */
 if (Kb_CESDepass == 0)
 {
    if (Kn_CES < MAX_TCES)
    {
       StockeLigneVers(tpsz_ReadBufferCES);
       Kn_CES++;
    }
    else
    {
     sprintf(MsgAno,"The number of records in CESSION file for contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program's storage capacity",
                      tpsz_ReadBufferCES[CES_CTR_NF],
                      tpsz_ReadBufferCES[CES_END_NT],
                      tpsz_ReadBufferCES[CES_SEC_NF],
                      tpsz_ReadBufferCES[CES_UWY_NF],
                      tpsz_ReadBufferCES[CES_UW_NT]);

     n_WriteAno(MsgAno);
     Kb_CESDepass=1;
     Kb_ReturnStatus=1;
    }
  }

  return(OK);
}



/*==============================================================================
objet :
	fonction lancee pour chaque ligne du fichier fils
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionLignePerimetre (
	char *tpsz_ReadBufferGTA[] ,
	char *tpsz_ReadBufferPerimeter[]
)
{
		
		
		memset(CTR.Contract,0,sizeof (CTR.Contract));
		// récupération de la nature du contrat en cours 

	if (strcmp(tpsz_ReadBufferGTA[GT_CTR_NF] , tpsz_ReadBufferPerimeter[FLD_CONTRAT])==0)
	{
		strcpy(CTR.Contract,tpsz_ReadBufferPerimeter[FLD_CONTRAT]);
		strcpy(CTR.Nature , tpsz_ReadBufferPerimeter[FLD_NATURE]);
	}

  return(OK);
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
	char *tpsz_ReadBufferCES[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_CTR_NF],tpsz_ReadBufferCES[CES_CTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_END_NT],tpsz_ReadBufferCES[CES_END_NT]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferGTA[GT_SEC_NF],tpsz_ReadBufferCES[CES_SEC_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UWY_NF],tpsz_ReadBufferCES[CES_UWY_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTA[GT_UW_NT],tpsz_ReadBufferCES[CES_UW_NT]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0       ---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
static int n_ContratNatureSync(
	char *tpsz_ReadBufferGTA[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferPeri[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret=0 ;
    DEBUT_FCT("n_ContratNatureSync");

    ret = strcmp(tpsz_ReadBufferGTA[GT_CTR_NF],tpsz_ReadBufferPeri[FLD_CONTRAT]);
    RETURN_VAL(ret);
}






/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneGTA(char *tpsz_ReadBufferGTA[])
{
    char MsgAno[300];

    /* stocker la ligne courante dans TGTA */
   if ( (Kb_CESDepass == 0) && (Kb_GTADepass == 0) )
   {
    if (Kn_GTA < MAX_TGTA)
    {
       StockeLigneAcc(tpsz_ReadBufferGTA);
       Kn_GTA ++;
	   n_ProcessingRuptureSyncVar(&Kbd_Perimetre, tpsz_ReadBufferGTA);
    }
    else
    {
     sprintf(MsgAno,"The number of records in GTA file for contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program storage capacity",
                      tpsz_ReadBufferGTA[GT_CTR_NF],
                      tpsz_ReadBufferGTA[GT_END_NT],
                      tpsz_ReadBufferGTA[GT_SEC_NF],
                      tpsz_ReadBufferGTA[GT_UWY_NF],
                      tpsz_ReadBufferGTA[GT_UW_NT]);

     n_WriteAno(MsgAno);
      Kb_GTADepass=1;
      Kb_ReturnStatus=1;
    }
  }
      return OK;
}

/*==============================================================================
objet :
	Fonction lancee en rupture derniere sur l'acceptation
        pour le fichier GTAa

retour :
	OK --->
        ERR --->
==============================================================================*/
static int n_ActionLastGTA(char ** tpsz_ReadBufferGTA)
{
     int i, j, n_acy;
     char sz_trncod[9], sz_rettrncod[9];
     char MsgAno[300];

     /* traitement des tableaux TGTA et TCES */
   if ( (Kb_CESDepass == 0) && (Kb_GTADepass == 0) && (Kn_CES != 0) )
   {

     for (i=0; i < Kn_CES; i++)  /* boucle sur les versements */
     {
	 strcpy(sz_trncod,"");
	 n_acy=0;

         for (j=0; j < Kn_GTA; j++)  /* boucle sur le GT acceptation */
         {
	     /* le versement n'est pris en compte que si l'annee de */
	     /* compte est incluse dans les bornes des annees    */
	     /* d'application du versement */

             if ( ( TCES[i].CESACCSTA_N <= TGTA[j].ACY_NF ) &&
                  ( TGTA[j].ACY_NF <= TCES[i].CESACCEND_N )
                )
              {
		  /* pour optimiser, le nouveau poste comptable n'est pas */
		  /* calcule a chaque iteration sur le GT acceptation   */
		  /* mais seulement quand le poste comptable et/ou l'annee */
		  /* de compte changent (ce sont les deux seuls parametres */
		  /* de la fonction de tranformation de poste qui proviennent */
		  /* du GTA) */

                  if (  (strcmp(TGTA[j].TRNCOD_CF,sz_trncod) != 0) ||
                        (TGTA[j].ACY_NF!=n_acy)
                     )
                   {
                      strcpy(sz_trncod,TGTA[j].TRNCOD_CF);
                      n_acy=TGTA[j].ACY_NF;
/*
                     strcpy(sz_rettrncod,sz_GetRetPoste(sz_trncod,
                                                     (int)TCES[i].ACCADMTYP_CT,
                                                     (int)TCES[i].RETACCADM_B,
                                                     (int)TCES[i].CLECUTPER_B,
                                                     (int)TCES[i].CLECUTPER_NB,
						     n_acy,
						     (int) TGTA[j].UWY_NF,
						     Kp_Dettrs,
						     Kp_Rettrf)); 
*/
						strcpy(sz_rettrncod, GetRetroPoste(trim(sz_trncod),
															trim(CTR.Nature),
                                                     		(int)TCES[i].ACCADMTYP_CT,
                                                     		trim(TCES[i].ACCFAM_CT),
															Kp_Dettrs,
															Kp_Rettrf));
															
                   }
                   if (strcmp(sz_rettrncod,"") == 0) /* non trouve */
		   {
                        sprintf(MsgAno,
				"Either the transaction code DETTRS_CF=%s was not found in reference table TDETTRS or the key (/DETTRS_CF=%s /ACCADMTYP_CT=%d /RETACCADM_B=%d) was not found in reference table TRETTRF",
                      sz_trncod,
                      sz_trncod,
                      (int)TCES[i].ACCADMTYP_CT,
                      (int)TCES[i].RETACCADM_B);

                      n_WriteAno(MsgAno);
/***** 30 01 98: modif provisoire : le plantage du programme est suspendu *****/
/*** (par la mise en commentaire de l'instruction Kb_ReturnStatus=1) *****/
/***** si on ne trouve pas le poste dans dettrs ou rettrf (pour faire ****/
/*** passer le rapprochement - pb avec le poste 17440000) ***/
/*** A retablir une fois le probleme avec le poste 17440000 resolu ****/
/** dans TRETTRF ****/
/*                       Kb_ReturnStatus=1; */
		   }
		   else if (strcmp(sz_trncod, sz_rettrncod) != 0)
		   {
                   /* ecriture d'une ligne en sortie */
                   EcrireGTAr100(TCES[i],TGTA[j],sz_rettrncod);
		   }
              }
         }
     }
  }
     return(OK);
}

static void EcrireGTAr100(T_CES TCES, T_GTA TGTA, char * sz_rettrncod)
{
  char sz_Brk_nf [10] = "" ;
  double montant;

  if (TGTA.BRK_NF != 0) {
     sprintf (sz_Brk_nf, "%d", TGTA.BRK_NF);
     }
	 	// pour éviter de faire 2 fois le calcul , on place le résultat dans "montant"
	 	montant = TGTA.AMT_M * (-1.) * TCES.CESSH_R;

		/* cas du GT non enrichi en entree" */
		if (Kn_GTE == 0)
		{
			/* ajout derniere colonne pour retintamt_m */
			fprintf(Kp_Gtar100,"%d~%d~%4.4s~%2.2s~%2.2s~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%s~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf\n",
			TGTA.SSD_CF,
			TGTA.ESB_CF,
			Ksz_clodat,
			Ksz_clodat+4,
			Ksz_clodat+6,
			sz_rettrncod,
			"",
			TGTA.CTR_NF,
			TGTA.END_NT,
			TGTA.SEC_NF,
			TGTA.UWY_NF,
			TGTA.UW_NT,
			TGTA.OCCYEA_NF,
			TGTA.ACY_NF,
			TGTA.SCOSTRMTH_NF,
			TGTA.SCOENDMTH_NF,
			TGTA.CLM_NF,
			TGTA.CUR_CF,
			montant ,   //TGTA.AMT_M * (-1.) * TCES.CESSH_R,
			TGTA.CED_NF,
			sz_Brk_nf,
			TGTA.PAY_NF,
			TGTA.KEY_NF,
			TCES.RETCTR_NF,
			TCES.RETEND_NT,
			TCES.RETSEC_NF,
			TCES.RTY_NF,
			TCES.RETUW_NT,
			TGTA.OCCYEA_NF,
			TGTA.ACY_NF,
			TGTA.SCOSTRMTH_NF,
			TGTA.SCOENDMTH_NF,
			TGTA.CLM_NF,
			TGTA.CUR_CF,
			TGTA.AMT_M * (-1.) * TCES.CESSH_R,
			"",
			"",
			"",
			"",
			"",
			0.000); /* RETINTAMT_M */
		}
		else
		{
			/* cas du GT enrichi : 5 champs supplementaires */
			/* + 1 champ : acctyp_nf */
			/* + 3 champs supplementaires : on reconduit en sortie */
			/* la date bilan du GT en entree */
			/* ajout colonne pour retintamt_m */
         //[008]
         if (sz_TypeTrait != 'L')
         {
				fprintf(Kp_Gtar100,"%d~%d~%4.4s~%2.2s~%2.2s~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%s~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf~%d~%d~%d~%d~%d~%d~%d~%02d~%02d~%s~%s~%d~%s~%s\n",
				TGTA.SSD_CF,
				TGTA.ESB_CF,
				Ksz_clodat,
				Ksz_clodat+4,
				Ksz_clodat+6,
				sz_rettrncod,
				"",
				TGTA.CTR_NF,
				TGTA.END_NT,
				TGTA.SEC_NF,
				TGTA.UWY_NF,
				TGTA.UW_NT,
				TGTA.OCCYEA_NF,
				TGTA.ACY_NF,
				TGTA.SCOSTRMTH_NF,
				TGTA.SCOENDMTH_NF,
				TGTA.CLM_NF,
				TGTA.CUR_CF,
				montant , //			TGTA.AMT_M * (-1.) * TCES.CESSH_R,
				TGTA.CED_NF,
				sz_Brk_nf,
				TGTA.PAY_NF,
				TGTA.KEY_NF,
				TCES.RETCTR_NF,
				TCES.RETEND_NT,
				TCES.RETSEC_NF,
				TCES.RTY_NF,
				TCES.RETUW_NT,
				TGTA.OCCYEA_NF,
				TGTA.ACY_NF,
				TGTA.SCOSTRMTH_NF,
				TGTA.SCOENDMTH_NF,
				TGTA.CLM_NF,
				TGTA.CUR_CF,
				TGTA.AMT_M * (-1.) * TCES.CESSH_R,
				"",
				"",
				"",
				"",
				"",
				0.000,  /* RETINTAMT_M */
				TGTA.ENTPERYEA_NF,
				TGTA.ENTPERMTH_NF,
				TGTA.VALPERYEA_NF,
				TGTA.VALPERMTH_NF,
				TGTA.TRN_NT,
				TGTA.ACCTYP_NF,
				TGTA.BALSHEY_NF,
				TGTA.BALSHRMTH_NF,
				TGTA.BALSHRDAY_NF,
				TGTA.COMMAC_LL,
				TGTA.SPEENTTYP_CF,
				TGTA.SPEENTNAT_CT,
				TGTA.EVT_NF,        // [006]
				TGTA.REVT_NF        // [006]
				);
			}
			else
			{
				//[008]
				fprintf(Kp_Gtar100,"%d~%d~%d~%d~%d~%s~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%d~%s~%d~%s~%s~%d~%d~%d~%d~%s~%d~%d~%d~%s~%s~%.3lf~%s~%s~%s~%s~%s~%.3lf~%d~%d~%d~%d~%d~%d~%d~%02d~%02d~%s~%s~%d~%s~%s\n",
				TGTA.SSD_CF,
				TGTA.ESB_CF,
				TGTA.BALSHEY_NF,
				TGTA.BALSHRMTH_NF,
				TGTA.BALSHRDAY_NF,
				sz_rettrncod,
				"",
				TGTA.CTR_NF,
				TGTA.END_NT,
				TGTA.SEC_NF,
				TGTA.UWY_NF,
				TGTA.UW_NT,
				TGTA.OCCYEA_NF,
				TGTA.ACY_NF,
				TGTA.SCOSTRMTH_NF,
				TGTA.SCOENDMTH_NF,
				TGTA.CLM_NF,
				TGTA.CUR_CF,
				montant , //			TGTA.AMT_M * (-1.) * TCES.CESSH_R,
				TGTA.CED_NF,
				sz_Brk_nf,
				TGTA.PAY_NF,
				TGTA.KEY_NF,
				TCES.RETCTR_NF,
				TCES.RETEND_NT,
				TCES.RETSEC_NF,
				TCES.RTY_NF,
				TCES.RETUW_NT,
				TGTA.OCCYEA_NF,
				TGTA.ACY_NF,
				TGTA.SCOSTRMTH_NF,
				TGTA.SCOENDMTH_NF,
				TGTA.CLM_NF,
				TGTA.CUR_CF,
				TGTA.AMT_M * (-1.) * TCES.CESSH_R,
				"",
				"",
				"",
				"",
				"",
				0.000,  /* RETINTAMT_M */
				TGTA.ENTPERYEA_NF,
				TGTA.ENTPERMTH_NF,
				TGTA.VALPERYEA_NF,
				TGTA.VALPERMTH_NF,
				TGTA.TRN_NT,
				TGTA.ACCTYP_NF,
				TGTA.BALSHEY_NF,
				TGTA.BALSHRMTH_NF,
				TGTA.BALSHRDAY_NF,
				TGTA.COMMAC_LL,
				TGTA.SPEENTTYP_CF,
				TGTA.SPEENTNAT_CT,
				TGTA.EVT_NF,        // [006]
				TGTA.REVT_NF        // [006]
				);
			}	
		}
}

static void StockeLigneVers(char ** tpsz_ReadBufferCES)
{
	strcpy(TCES[Kn_CES].CTR_NF,tpsz_ReadBufferCES[CES_CTR_NF]);
	TCES[Kn_CES].END_NT=(unsigned char) atoi(tpsz_ReadBufferCES[CES_END_NT]);
	TCES[Kn_CES].SEC_NF=(unsigned char) atoi(tpsz_ReadBufferCES[CES_SEC_NF]);
	TCES[Kn_CES].UWY_NF=(short) atoi(tpsz_ReadBufferCES[CES_UWY_NF]);
	TCES[Kn_CES].UW_NT=(unsigned char) atoi(tpsz_ReadBufferCES[CES_UW_NT]);
	strcpy(TCES[Kn_CES].RETCTR_NF,tpsz_ReadBufferCES[CES_RETCTR_NF]);
	TCES[Kn_CES].RETEND_NT=(unsigned char) atoi(tpsz_ReadBufferCES[CES_RETEND_NT]);
	TCES[Kn_CES].RETSEC_NF=(unsigned char) atoi(tpsz_ReadBufferCES[CES_RETSEC_NF]);
	TCES[Kn_CES].RTY_NF=(short) atoi(tpsz_ReadBufferCES[CES_RTY_NF]);
	TCES[Kn_CES].RETUW_NT=(unsigned char) atoi(tpsz_ReadBufferCES[CES_RETUW_NT]);
	TCES[Kn_CES].CESACCSTA_N=atoi(tpsz_ReadBufferCES[CES_CESACCSTA_N]);
	TCES[Kn_CES].CESACCEND_N=atoi(tpsz_ReadBufferCES[CES_CESACCEND_N]);
	TCES[Kn_CES].CESSH_R=atof(tpsz_ReadBufferCES[CES_CESSH_R]);
	TCES[Kn_CES].SSD_CF=(unsigned char) atoi(tpsz_ReadBufferCES[CES_SSD_CF]);
	TCES[Kn_CES].ESB_CF=(unsigned char) atoi(tpsz_ReadBufferCES[CES_ESB_CF]);
	strcpy(TCES[Kn_CES].RETCTRCAT_CF,tpsz_ReadBufferCES[CES_RETCTRCAT_CF]);
	TCES[Kn_CES].ACCADMTYP_CT=(unsigned char) atoi(tpsz_ReadBufferCES[CES_ACCADMTYP_CT]);
	TCES[Kn_CES].RETACCADM_B=(unsigned char) atoi(tpsz_ReadBufferCES[CES_RETACCADM_B]);
	TCES[Kn_CES].CLECUTPER_B=(unsigned char) atoi(tpsz_ReadBufferCES[CES_CLECUTPER_B]);
	TCES[Kn_CES].CLECUTPER_NB=(unsigned char) atoi(tpsz_ReadBufferCES[CES_CLECUTPER_NB]);
	strcpy(TCES[Kn_CES].ACCFAM_CT,tpsz_ReadBufferCES[CES_ACCFAM_CT]);
}

static void StockeLigneAcc(char ** tpsz_ReadBufferGTA)
{
	TGTA[Kn_GTA].SSD_CF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SSD_CF]);
	TGTA[Kn_GTA].ESB_CF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_ESB_CF]);
	TGTA[Kn_GTA].BALSHEY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_BALSHEY_NF]);
	TGTA[Kn_GTA].BALSHRMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRMTH_NF]);
	TGTA[Kn_GTA].BALSHRDAY_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_BALSHRDAY_NF]);
	strcpy(TGTA[Kn_GTA].TRNCOD_CF,tpsz_ReadBufferGTA[GT_TRNCOD_CF]);
	strcpy(TGTA[Kn_GTA].DBLTRNCOD_CF,tpsz_ReadBufferGTA[GT_DBLTRNCOD_CF]);
	strcpy(TGTA[Kn_GTA].CTR_NF,tpsz_ReadBufferGTA[GT_CTR_NF]);
	TGTA[Kn_GTA].END_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_END_NT]);
	TGTA[Kn_GTA].SEC_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SEC_NF]);
	TGTA[Kn_GTA].UWY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_UWY_NF]);
	TGTA[Kn_GTA].UW_NT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_UW_NT]);
	strcpy(TGTA[Kn_GTA].OCCYEA_NF,tpsz_ReadBufferGTA[GT_OCCYEA_NF]);
	TGTA[Kn_GTA].ACY_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ACY_NF]);
	TGTA[Kn_GTA].SCOSTRMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOSTRMTH_NF]);
	TGTA[Kn_GTA].SCOENDMTH_NF=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SCOENDMTH_NF]);
	strcpy(TGTA[Kn_GTA].CLM_NF,tpsz_ReadBufferGTA[GT_CLM_NF]);
	strcpy(TGTA[Kn_GTA].CUR_CF,tpsz_ReadBufferGTA[GT_CUR_CF]);
	TGTA[Kn_GTA].AMT_M=atof(tpsz_ReadBufferGTA[GT_AMT_M]);
	TGTA[Kn_GTA].CED_NF=atoi(tpsz_ReadBufferGTA[GT_CED_NF]);
	TGTA[Kn_GTA].BRK_NF=atoi(tpsz_ReadBufferGTA[GT_BRK_NF]);
	TGTA[Kn_GTA].PAY_NF=atoi(tpsz_ReadBufferGTA[GT_PAY_NF]);
	strcpy(TGTA[Kn_GTA].KEY_NF,tpsz_ReadBufferGTA[GT_KEY_NF]);

	if (Kn_GTE == 1)  /* si GT enrichi en entree */
	                  /*alors 5 champs supplementaires a stocker*/
	{
		TGTA[Kn_GTA].ENTPERYEA_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ENTPERYEA_NF]);
		TGTA[Kn_GTA].ENTPERMTH_NF=(short) atoi(tpsz_ReadBufferGTA[GT_ENTPERMTH_NF]);
		TGTA[Kn_GTA].VALPERYEA_NF=(short) atoi(tpsz_ReadBufferGTA[GT_VALPERYEA_NF]);
		TGTA[Kn_GTA].VALPERMTH_NF=(short) atoi(tpsz_ReadBufferGTA[GT_VALPERMTH_NF]);
		TGTA[Kn_GTA].TRN_NT=atoi(tpsz_ReadBufferGTA[GT_TRN_NT2]);  //[005]
		TGTA[Kn_GTA].ACCTYP_NF= (short) atoi(tpsz_ReadBufferGTA[GT_ACCTYP_NF2]);  // [006]
		strcpy(TGTA[Kn_GTA].COMMAC_LL ,tpsz_ReadBufferGTA[GT_COMMAC_LL]);
		strcpy(TGTA[Kn_GTA].SPEENTTYP_CF,tpsz_ReadBufferGTA[GT_SPEENTTYP_CF]);
//    TGTA[Kn_GTA].SPEENTTYP_CF=atoi(tpsz_ReadBufferGTA[GT_SPEENTTYP_CF]);
		TGTA[Kn_GTA].SPEENTNAT_CT=(unsigned char) atoi(tpsz_ReadBufferGTA[GT_SPEENTNAT_CT2]);
		strcpy(TGTA[Kn_GTA].EVT_NF,tpsz_ReadBufferGTA[GT_EVT_NF2]);      // [006]
		strcpy(TGTA[Kn_GTA].REVT_NF,tpsz_ReadBufferGTA[GT_REVT_NF2]);    // [006]
	}
}


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


