/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION Transfert de Portefeuille
nom du source                 : ESTM7020.c
révision                      : $Revision: 1.2 $
date de creation              : 11/01/2010
auteur                        : Roger Cassis
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRAITEMENT DES TRANSFERTS DE CONTRATS  - :spot:18415 - Reconduction des données de type TFLISTAREP
   du fichier permanent P_STAD1520_LIFSTAREP_PLAN.dat.
   Il faut juste prendre les lignes qui sont sur des contrats transférés,
   changer le numéro de contrat et la filiale (qui doit être en 2eme position),
   et remetre les lignes le fichier (mais sur le bon site).

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[001] 19/08/2015 Roger Cassis :spot:29223 Evol du modele de la table TLIFSTAREP
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/* prise reprise de STAC15.h             */
/*---------------------------------------*/
#include <ESTM7020.h>

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/* structure du fichier commum avec estimation */
#include <struct.h>

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_OutputFil;  /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR bd_RuptTRFctr;		/* gestion rupture sur traites Trfcrossref */
T_RUPTURE_SYNC_VAR bd_RuptLSR;	/* gestion synchro LSR-traites Trfcrossref */

int n_InitLSR (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneLSR(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncLSR(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_IsTRFctr(char **ptb_InRec, char **ptb_InRec_Cur);
int Kb_rupt1;       /* 1 si rupture de niveau 1, 0 sinon */

int n_InitTRFctr(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneTRFctr(char **pbd_InRec_Cur);
int n_ActionFilsSansPereLSR(char **ptb_InRecOwner );

char sz_destCtr[10];
char sz_destSsd[3];

int i_flagFin;

/*==============================================================================
objet :
   point d'entree du programme

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

	/* ouverture des fichiers */

	if ( n_OpenFileAppl ("ESTM7020_O1","wt",&Kp_OutputFil) == ERR )
		ExitPgm ( ERR_XX , "" );

	i_flagFin = 0;

	/* Initialisation de la varible bd_RuptTRFctr */
	if ( n_InitTRFctr(&bd_RuptTRFctr) )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible bd_RuptLSR */
	if ( n_InitLSR(&bd_RuptLSR) )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier */
	if ( n_ProcessingRuptureVar (&bd_RuptTRFctr) == ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTM7020_O1",&Kp_OutputFil)== ERR)
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl("ESTM7020_I1",&(bd_RuptTRFctr.pf_InputFil))== ERR )
		ExitPgm ( ERR_XX , "" );

	if (n_CloseFileAppl ("ESTM7020_I2",&(bd_RuptLSR.pf_InputFil))== ERR)
		ExitPgm ( ERR_XX , "" );

	if ( n_EndPgm () == ERR )
		ExitPgm ( ERR_XX , "" );

	exit(OK) ;

}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitTRFctr(T_RUPTURE_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitTRFctr");

	memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTM7020_I1","rt",&(pbd_Rupt->pf_InputFil)))
		ExitPgm ( ERR_XX , "" );

	pbd_Rupt->n_NbRupture = 1  ;

	pbd_Rupt->n_ConditionRupture[0] = n_IsTRFctr;

	pbd_Rupt->n_ActionLigne = n_ActionLigneTRFctr ;

	pbd_Rupt->c_Separ = SEPARATEUR ;

	RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsTRFctr(char **ptb_InRec,char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_IsTRFctr");

	Kb_rupt1=0;

	strcpy(sz_destCtr, ptb_InRec_Cur[TRF_DESTCTR_NF]);
	strcpy(sz_destSsd, ptb_InRec_Cur[TRF_DESTSSD_CF]);

	if (strcmp(ptb_InRec[TRF_CTR_NF],ptb_InRec_Cur[LSR_CTR_NF])!=0)
	{
		i_flagFin = 1;
		RETURN_VAL(1);
	}

	RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneTRFctr( char **ptb_InRec_Cur)
{
	DEBUT_FCT("n_ActionLigneTRFctr");

	/* synchronisation du fichier LSR pour chaque ligne */
	n_ProcessingRuptureSyncVar (&bd_RuptLSR, ptb_InRec_Cur) ;

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave LSR

retour :
        OK
==============================================================================*/
int n_InitLSR(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	DEBUT_FCT("n_InitLSR");

	memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	n_OpenFileAppl ("ESTM7020_I2","rt",&(pbd_Rupt->pf_InputFil));

	pbd_Rupt->n_NbRupture = 0  ;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_Rupt->ConditionEndSync      = n_ConditionSyncLSR ;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_Rupt->n_ActionLigne         = n_ActionLigneLSR ;

	/* fonction d'action quand le maitre n'a pas de fils LSR */
	/*      pbd_Rupt->n_PereSansFils = n_ActionPereSansFilsLSR;  jr 11 09 2003  */

	/* fonction d'action quand le fils n'a pas de pere LSR */
	pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereLSR;

	pbd_Rupt->c_Separ               = SEPARATEUR ;

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncLSR(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
	int ret;

	DEBUT_FCT("n_ConditionSyncLSR");

	if (i_flagFin == 1)
	{
		strcpy(sz_destCtr, pbd_InRecOwner[TRF_DESTCTR_NF]);
		strcpy(sz_destSsd, pbd_InRecOwner[TRF_DESTSSD_CF]);
	}

	if ( (ret = strcmp(pbd_InRecOwner[TRF_CTR_NF],pbd_InRecChild[LSR_CTR_NF])) != 0 )
		RETURN_VAL(ret);

	RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du LSR synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneLSR(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
	char   *ptb_Lsr [LSR_NBCOL+1];
	char   *sz_blanc="";
	int    i;

	DEBUT_FCT("n_ActionLigneLSR");
	/* initialisation des donnees a ecrire */

	for ( i=0; i<LSR_NBCOL; i++)
	{
		ptb_Lsr[i] = sz_blanc ;
	}
	ptb_Lsr[LSR_NBCOL] = NULL;

//[001]
/* remplissage des donnees depuis le fichier d'entree */
	ptb_Lsr[LSR_CLODAT_D]=ptb_InRecChild[LSR_CLODAT_D];
	ptb_Lsr[LSR_SSD_CF]=sz_destSsd;
	ptb_Lsr[LSR_CTR_NF]=sz_destCtr;
	ptb_Lsr[LSR_END_NT]=ptb_InRecChild[LSR_END_NT];
	ptb_Lsr[LSR_SEC_NF]=ptb_InRecChild[LSR_SEC_NF];
	ptb_Lsr[LSR_UWY_NF]=ptb_InRecChild[LSR_UWY_NF];
	ptb_Lsr[LSR_UW_NT]=ptb_InRecChild[LSR_UW_NT];
	ptb_Lsr[LSR_PLC_NT]=ptb_InRecChild[LSR_PLC_NT];
	ptb_Lsr[LSR_ACCRET_CF]=ptb_InRecChild[LSR_ACCRET_CF];
	ptb_Lsr[LSR_ACY_NF]=ptb_InRecChild[LSR_ACY_NF];
	ptb_Lsr[LSR_ACMTRS_NT]=ptb_InRecChild[LSR_ACMTRS_NT];
	ptb_Lsr[LSR_DETTRNCOD_CF]=ptb_InRecChild[LSR_DETTRNCOD_CF];
	ptb_Lsr[LSR_ESTMTH_NF]=ptb_InRecChild[LSR_ESTMTH_NF];
	ptb_Lsr[LSR_PCPCUR_CF]=ptb_InRecChild[LSR_PCPCUR_CF];
	ptb_Lsr[LSR_CBNMNT_M]=ptb_InRecChild[LSR_CBNMNT_M];
	ptb_Lsr[LSR_CBPMNT_M]=ptb_InRecChild[LSR_CBPMNT_M];
	ptb_Lsr[LSR_PC1MNT_M]=ptb_InRecChild[LSR_PC1MNT_M];
	ptb_Lsr[LSR_PCMNT_M]=ptb_InRecChild[LSR_PCMNT_M];
	ptb_Lsr[LSR_PC3MNT_M]=ptb_InRecChild[LSR_PC3MNT_M];
	ptb_Lsr[LSR_PC4MNT_M]=ptb_InRecChild[LSR_PC4MNT_M];
	ptb_Lsr[LSR_PC5MNT_M]=ptb_InRecChild[LSR_PC5MNT_M];
	ptb_Lsr[LSR_PA1MNT_M]=ptb_InRecChild[LSR_PA1MNT_M];
	ptb_Lsr[LSR_PAMNT_M]=ptb_InRecChild[LSR_PAMNT_M];
	ptb_Lsr[LSR_PA3MNT_M]=ptb_InRecChild[LSR_PA3MNT_M];
	ptb_Lsr[LSR_PA4MNT_M]=ptb_InRecChild[LSR_PA4MNT_M];
	ptb_Lsr[LSR_PA5MNT_M]=ptb_InRecChild[LSR_PA5MNT_M];
	ptb_Lsr[LSR_PR1MNT_M]=ptb_InRecChild[LSR_PR1MNT_M];
	ptb_Lsr[LSR_PRMNT_M]=ptb_InRecChild[LSR_PRMNT_M];
	ptb_Lsr[LSR_PR3MNT_M]=ptb_InRecChild[LSR_PR3MNT_M];
	ptb_Lsr[LSR_PR4MNT_M]=ptb_InRecChild[LSR_PR4MNT_M];
	ptb_Lsr[LSR_PR5MNT_M]=ptb_InRecChild[LSR_PR5MNT_M];
	ptb_Lsr[LSR_CED_NF]=ptb_InRecChild[LSR_CED_NF];
	ptb_Lsr[LSR_SECSTS_CT]=ptb_InRecChild[LSR_SECSTS_CT];
	ptb_Lsr[LSR_SECACCSTS_CT]=ptb_InRecChild[LSR_SECACCSTS_CT];
	ptb_Lsr[LSR_ACCADMTYP_CT]=ptb_InRecChild[LSR_ACCADMTYP_CT];
	ptb_Lsr[LSR_ESTCRB_CT]=ptb_InRecChild[LSR_ESTCRB_CT];
	ptb_Lsr[LSR_ESTCTR_NF]=ptb_InRecChild[LSR_ESTCTR_NF];
	ptb_Lsr[LSR_ESTSEC_NF]=ptb_InRecChild[LSR_ESTSEC_NF];
	ptb_Lsr[LSR_COMACC_B]=ptb_InRecChild[LSR_COMACC_B];
	ptb_Lsr[LSR_AUTUPD_B]=ptb_InRecChild[LSR_AUTUPD_B];
	ptb_Lsr[LSR_YNEWCTR_B]=ptb_InRecChild[LSR_YNEWCTR_B];
	ptb_Lsr[LSR_TNEWCTR_B]=ptb_InRecChild[LSR_TNEWCTR_B];
	ptb_Lsr[LSR_CLMCUTOFF_B]=ptb_InRecChild[LSR_CLMCUTOFF_B];
	ptb_Lsr[LSR_PRMCUTOFF_B]=ptb_InRecChild[LSR_PRMCUTOFF_B];
	ptb_Lsr[LSR_CLMRUNOFF_B]=ptb_InRecChild[LSR_CLMRUNOFF_B];
	ptb_Lsr[LSR_PRMRUNOFF_B]=ptb_InRecChild[LSR_PRMRUNOFF_B];
	ptb_Lsr[LSR_LSTUPD_D]=ptb_InRecChild[LSR_LSTUPD_D];
	ptb_Lsr[LSR_CTRINC_D]=ptb_InRecChild[LSR_CTRINC_D];
	ptb_Lsr[LSR_TRNCOD]=ptb_InRecChild[LSR_TRNCOD];
	ptb_Lsr[LSR_ORICTR_NF]=ptb_InRecChild[LSR_ORICTR_NF];
	ptb_Lsr[LSR_ORISEC_NF]=ptb_InRecChild[LSR_ORISEC_NF];
	ptb_Lsr[LSR_ORIUWY_NF]=ptb_InRecChild[LSR_ORIUWY_NF];
	ptb_Lsr[LSR_PAMNTNB_M]=ptb_InRecChild[LSR_PAMNTNB_M];
	ptb_Lsr[LSR_PRMNTNB_M]=ptb_InRecChild[LSR_PRMNTNB_M];
	ptb_Lsr[LSR_SSDRTO_B]=ptb_InRecChild[LSR_SSDRTO_B];
	ptb_Lsr[LSR_PROPAG_B]=ptb_InRecChild[LSR_PROPAG_B];
	ptb_Lsr[LSR_EXEPLAN_CF]=ptb_InRecChild[LSR_EXEPLAN_CF];
	ptb_Lsr[LSR_VSRPLAN_CF]=ptb_InRecChild[LSR_VSRPLAN_CF];
	ptb_Lsr[LSR_ECRPLANPO1_MC]=ptb_InRecChild[LSR_ECRPLANPO1_MC];
	ptb_Lsr[LSR_ECRPLANPO2_MC]=ptb_InRecChild[LSR_ECRPLANPO2_MC];
	ptb_Lsr[LSR_ECRPLANPO3_MC]=ptb_InRecChild[LSR_ECRPLANPO3_MC];
	ptb_Lsr[LSR_ECRPLANPO4_MC]=ptb_InRecChild[LSR_ECRPLANPO4_MC];
	ptb_Lsr[LSR_ECRPLANPO5_MC]=ptb_InRecChild[LSR_ECRPLANPO5_MC];

	/* reconduction de chaque ligne en entree vers la sortie */
	n_WriteCols(Kp_OutputFil, ptb_Lsr , '~',0) ;

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils LSR
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPereLSR(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
)
{
	RETURN_VAL(OK);
}

