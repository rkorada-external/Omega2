/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Estimation - Rapprochement
nom du source                 : ESTC2331.c
revision                      : $Revision: 1.2 $
date de creation              : 15/01/01
auteur                        : AURA (Orhan Arik)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Ce batch est similaire au batch ESTC2322.c, la difference est au
	niveau de la condition de filtre et de l'utilisation de DETTRS.
	PREPARATION DU CALCUL DES ECARTS DUS AUX EFFETS RETROACTIFS
	DU BILAN SUR LES BILANS ANTERIEURS

	--> Synchronisation du fichier des mouvements retro a 100% en attente
        TOUTTRAA avec le perimetre retrocession - Elimination des mouvements
	pour lesquels le perimetre ne participe pas - Elimination des postes
	provisions - Filtre sur les ecritures retroactives -

	--> Synchronisation du fichier des mouvements retro a 100 %
        comptabilises TACCTRAA avec le perimetre retrocession -
	Elimination des mouvements pour lesquels le perimetre ne participe pas -
        Elimination des postes provisions - Filtre sur les ecritures retroactives -

        Les mouvements selectionnes sont ecrits en sortie dans un fichier
        au format GTAr100%.
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    05/02/2003    J. Ribot    ajout champs retintamt_ m en sortie
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[003] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[XXX] 09/10/2014  JBG  :spot:25773  suppress warning: unused variables
 ==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitPER(T_RUPTURE_VAR  *);
static int n_InitTOUTTRAA(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTOUTTRAA(char **,char**);
static int n_ConditionSyncTOUTTRAA(char **,char **);
static int n_ActionLignePER(char **);
static int n_InitTACCTRAA(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneTACCTRAA(char **,char**);
static int n_ConditionSyncTACCTRAA(char **,char **);


int n_RechTrn(char *sz_trn);

int n_ChargerDETTRS();
/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Dettrs;
static FILE *Kp_GT_100;

static T_RUPTURE_VAR   Kbd_RuptPER;
static T_RUPTURE_SYNC_VAR  Kbd_RuptTACCTRAA;
static T_RUPTURE_SYNC_VAR  Kbd_RuptTOUTTRAA;

static char sz_clodat[9];

/** #define Kn_MaxLigDETTRS 10000 **/
#define NB_DETTRS_MAX 30000   /* Le nombre max de postes est fixe a 10000 [003] triplé */

T_DETTRS Ktbd_DETTRS[NB_DETTRS_MAX];

int             Kn_NbLigDettrs=0 ;      /* nombre de lignes du tableau Ktbd_Dettrs */


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

        if ( n_OpenFileAppl ("ESTC2331_O1","wt",&Kp_GT_100) == ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_OpenFileAppl ("ESTC2331_I4","rb",&Kp_Dettrs) == ERR )
                ExitPgm ( ERR_XX , "" );

        sprintf(sz_clodat,"%s",psz_GetCharArgv(1));

	/* Initialisation de la variable Kbd_RuptPER  */
	if ( n_InitPER(&Kbd_RuptPER)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptTOUTTRAA */
	if ( n_InitTOUTTRAA(&Kbd_RuptTOUTTRAA)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptTACCTRAA */
	if ( n_InitTACCTRAA(&Kbd_RuptTACCTRAA)==ERR )
		ExitPgm ( ERR_XX , "" );

        if( (Kn_NbLigDettrs = n_ChargerDETTRS( ))==-1)
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2331_O1",&Kp_GT_100)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2331_I1",&(Kbd_RuptPER.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2331_I2",&(Kbd_RuptTOUTTRAA.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2331_I3",&(Kbd_RuptTACCTRAA.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2331_I4",&Kp_Dettrs)==ERR )
                ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}


/*==============================================================================
objet :
    fonction d'initialisation de la variable de gestion de rupture du fichier
    maitre.

retour :
	0K ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitPER(T_RUPTURE_VAR  *pbd_RuptPER)
{
	memset(pbd_RuptPER,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2331_I1","rt",&(pbd_RuptPER->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptPER->n_NbRupture =0;
	pbd_RuptPER->n_ActionLigne     = n_ActionLignePER;

        pbd_RuptPER->c_Separ=SEPARATEUR;

	return OK ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitTOUTTRAA(T_RUPTURE_SYNC_VAR  *pbd_RuptTOUTTRAA)
{

	memset( pbd_RuptTOUTTRAA,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2331_I2","rt",&(pbd_RuptTOUTTRAA->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptTOUTTRAA->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptTOUTTRAA->ConditionEndSync	= n_ConditionSyncTOUTTRAA;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptTOUTTRAA->n_ActionLigne   	= n_ActionLigneTOUTTRAA;

        pbd_RuptTOUTTRAA->c_Separ=SEPARATEUR;

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
static int n_ActionLigneTOUTTRAA(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferTOUTTRAA[]
)
{
    char MsgAno[200];



int n_indtrn;
  /* ... */


  n_indtrn=n_RechTrn(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF]);

  if (n_indtrn < 0)
  {
     sprintf(MsgAno,"The transaction code %s could not be found in table TDETTRS",tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF]);
     n_WriteAno(MsgAno);
     RETURN_VAL( OK ) ;
  }


    if (strcmp(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETACT_CT],"P") == 0)
    /* filtre sur ecritures retroactives */
    {
	if
	(
		Ktbd_DETTRS[n_indtrn].TRSTYP_CT==1
	)
          {
                   if (atof(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CED_M]) != 0. )
                   {
                    /* ecriture en sortie d'un enregistrement au format du GT */

                    fprintf(Kp_GT_100,"%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s\n",
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SSD_CF],
                      tpsz_ReadBufferPER[PER_ACCESB_CF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_BLCSHT_D],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_BLCSHT_D]+4,
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_BLCSHT_D]+6,
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_TRNCOD_CF],
                      "",
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CTR_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_END_NT],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SEC_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_UWY_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_UW_NT],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_OCCYEA_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACCYER_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SCOSTRMTH_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_SCOENDMTH_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CLM_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACPCUR_CF],
                      -1 * atof(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CED_M]),
                      "", /* CED_NF */
                      "", /* BRK_NF */
                      "", /* PAY_NF */
                      "", /* KEY_NF */
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETCTR_NF],
                      "0", /* RETEND_NT */
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETSEC_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RTY_NF],
                      "1",  /* RETUW_NT */
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_OCCYEA_NF],
                      sz_clodat,    /* annee libelle d'inventaire */
                      sz_clodat+4,  /* mois libelle d'inventaire */
                      sz_clodat+4,  /* mois libelle d'inventaire */
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CLM_NF],
                      tpsz_ReadBufferTOUTTRAA[TOUTTRAA_ACPCUR_CF],
                      -1 * atof(tpsz_ReadBufferTOUTTRAA[TOUTTRAA_CED_M]),
                      "",  /* PLC_NT */
                      "",  /* RTO_NF */
                      "",  /* INT_NF */
                      "",  /* RETPAY_NF */
                      "",  /* RETKEY_NF */
                      ""); /* RETINTAMT_M */
                   }  /* fin du if montant non nul */
          } /*fin du if Ktbd_DETTRS[n_indtrn].TRSTYP_CT==1*/
     } /* fin du if RETACT_CF=P */

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
static int n_ConditionSyncTOUTTRAA(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferTOUTTRAA[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncTOUTTRAA");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferTOUTTRAA[TOUTTRAA_RTY_NF]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
     /* lancement de la 1ere synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTOUTTRAA,tpsz_ReadBufferPER) == ERR)
           return ERR;

     /* lancement de la 2eme synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptTACCTRAA,tpsz_ReadBufferPER) == ERR)
           return ERR;

        return OK;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitTACCTRAA(T_RUPTURE_SYNC_VAR  *pbd_RuptTACCTRAA)
{

	memset( pbd_RuptTACCTRAA,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2331_I3","rt",&(pbd_RuptTACCTRAA->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptTACCTRAA->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptTACCTRAA->ConditionEndSync	= n_ConditionSyncTACCTRAA;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptTACCTRAA->n_ActionLigne   	= n_ActionLigneTACCTRAA;

        pbd_RuptTACCTRAA->c_Separ=SEPARATEUR;

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
static int n_ActionLigneTACCTRAA(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferTACCTRAA[]
)
{
    char MsgAno[200];


int n_indtrn;
  /* ... */


  n_indtrn=n_RechTrn(tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF]);

  if (n_indtrn < 0)
  {
     sprintf(MsgAno,"The transaction code %s could not be found in table TDETTRS",tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF]);
     n_WriteAno(MsgAno);
     RETURN_VAL( OK ) ;
  }


    if (strcmp(tpsz_ReadBufferTACCTRAA[TACCTRAA_RETACT_CT],"P") == 0)
    /* filtre sur ecritures retroactives */
    {
	if
	(
		Ktbd_DETTRS[n_indtrn].TRSTYP_CT==1
	)
          {
                   if (atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CED_M]) != 0. )
                   {
                    /* ecriture en sortie d'un enregistrement au format du GT */

                     fprintf(Kp_GT_100,"%s~%s~%4.4s~%2.2s~%2.2s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%-.3lf~%s~%s~%s~%s~%s~%s\n",
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SSD_CF],
                      tpsz_ReadBufferPER[PER_ACCESB_CF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D]+4,
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_BLCSHT_D]+6,
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_TRNCOD_CF],
                      "",
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_CTR_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_END_NT],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SEC_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_UWY_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_UW_NT],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_OCCYEA_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_ACCYER_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SCOSTRMTH_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SCOENDMTH_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_CLM_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_ACPCUR_CF],
                      -1 * atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CED_M]),
                      "", /* CED_NF */
                      "", /* BRK_NF */
                      "", /* PAY_NF */
                      "", /* KEY_NF */
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_RETCTR_NF],
                      "0", /* RETEND_NT */
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_RETSEC_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_RTY_NF],
                      "1",  /* RETUW_NT */
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_OCCYEA_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_RETACCYER_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SCOSTRMTH_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_SCOENDMTH_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_CLM_NF],
                      tpsz_ReadBufferTACCTRAA[TACCTRAA_ACPCUR_CF],
                      -1 * atof(tpsz_ReadBufferTACCTRAA[TACCTRAA_CED_M]),
                      "",  /* PLC_NT */
                      "",  /* RTO_NF */
                      "",  /* INT_NF */
                      "",  /* RETPAY_NF */
                      "",  /* RETKEY_NF */
                      ""); /* RETINTAMT_M */
                   } /* fin du if montant non nul */
          } /*fin du if Ktbd_DETTRS[n_indtrn].TRSTYP_CT==1 */
     } /* fin du if RETACT_CF=P */


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
static int n_ConditionSyncTACCTRAA(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferTACCTRAA[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferTACCTRAA[TACCTRAA_RTY_NF]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}

/*==============================================================================
objet:
 Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/

int n_ChargerDETTRS()
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerDETTRS");

  while (fread(&Ktbd_DETTRS[i], sizeof(T_DETTRS), 1, Kp_Dettrs) == 1)
    {
        i += 1 ;
        if ( i == NB_DETTRS_MAX ){
		n_WriteAno("max DETTRS atteint \n");
		/*printf( " max DETTRS atteint " );*/ return (-1 )  ;
	}
    }

  RETURN_VAL(i);
}

/*==============================================================================
objet :
        fonction de recherche du trncod
retour :
        0               ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
        int i;

        DEBUT_FCT("n_RechTrn");


        for ( i = 0; i <  Kn_NbLigDettrs ; i++ )
        {
                if ( strcmp( sz_trn, Ktbd_DETTRS[i].DETTRS_CF ) == 0) RETURN_VAL(i); ;
        }

        RETURN_VAL(-1);
}

