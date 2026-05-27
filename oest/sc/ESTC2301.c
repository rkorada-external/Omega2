/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2301.c
revision                      : $Revision:   1.1  $
date de creation              : 13/08/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Preparation du fichier des versements a utiliser pour l'inventaire
        retrocession dommages : synchronisation entre le perimetre acceptation
        et les versements extrais de la base retrocession.

------------------------------------------------------------------------------
historique des modifications :
[001] 22/05/2012 Roger Cassis :spot:23802	Ajout d'une sortie pour fichier contrat avec segments et egpcur affectés
[002] 30/08/2012 Roger Cassis :spot:24041 Solvency 2
[003] 25/09/2012 -=Dch=-      : spot:24041 Solvency 2
[004] 05/10/2015 -=Dch=- 	    :spot:29162
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

/* le nombre maximum d'avenants pour un contrat acceptation */
#define MAX_END 1000

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitPER(T_RUPTURE_VAR  *);
static int n_InitCES(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneCES(char **,char**);
static int n_ConditionSync(char **,char **);
static int n_ActionLignePER(char **);
int n_ConditionRupturePER(char **, char **);
static int n_ActionLastPER(char ** );  
static int n_ActionFirstPER(char ** );  
static int  n_ActionPereSansFils(char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Ces;   
static FILE *Kp_Seg;   // [001]

static T_RUPTURE_VAR   Kbd_RuptPER;       
static T_RUPTURE_SYNC_VAR  Kbd_RuptCES;  

int Kn_cmpt;
int Ktn_END[MAX_END];

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

	if ( n_OpenFileAppl ("ESTC2301_O1","wt",&Kp_Ces) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_OpenFileAppl ("ESTC2301_O2","wt",&Kp_Seg) == ERR )   // [001]
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptPER  */
	if ( n_InitPER(&Kbd_RuptPER)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptCES */
	if ( n_InitCES(&Kbd_RuptCES)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
		ExitPgm ( ERR_XX , "" );

	if ( n_CloseFileAppl ("ESTC2301_O1",&Kp_Ces)==ERR )
		ExitPgm ( ERR_XX , "" );
	
	if ( n_CloseFileAppl ("ESTC2301_O2",&Kp_Seg)==ERR )   // [001]
		ExitPgm ( ERR_XX , "" );
	
	if ( n_CloseFileAppl ("ESTC2301_I1",&(Kbd_RuptPER.pf_InputFil))==ERR )
		ExitPgm ( ERR_XX , "" );
	
	if ( n_CloseFileAppl ("ESTC2301_I2",&(Kbd_RuptCES.pf_InputFil))==ERR )
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

	if ( n_OpenFileAppl ("ESTC2301_I1","rt",&(pbd_RuptPER->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptPER->n_NbRupture =1;    
	pbd_RuptPER->n_ActionLigne = n_ActionLignePER;
	pbd_RuptPER->n_ConditionRupture[0] = n_ConditionRupturePER;
	pbd_RuptPER->n_ActionLast[0] = n_ActionLastPER;
	pbd_RuptPER->n_ActionFirst[0] = n_ActionFirstPER;

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
static int n_InitCES(T_RUPTURE_SYNC_VAR  *pbd_RuptCES)
{
	memset( pbd_RuptCES,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2301_I2","rt",&(pbd_RuptCES->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptCES->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptCES->ConditionEndSync	= n_ConditionSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptCES->n_ActionLigne = n_ActionLigneCES;

	pbd_RuptCES->n_PereSansFils = n_ActionPereSansFils;
	
	pbd_RuptCES->c_Separ='~';

	return OK ;
}
/*==============================================================================
objet :
        Test de rupture sur CTR_NF/END_NT/SEC_NF/UWY_NF/UW_NT
        pour le fichier pere 

retour :
        0 ---> pas de rupture
        1 ---> rupture
==============================================================================*/
int n_ConditionRupturePER(char ** tpsz_ReadBufferPER,
                          char ** tpsz_ReadBufferPER_Cur)
{
	if(strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferPER_Cur[PER_CTR_NF])!=0)
		return(1);
	
	if(strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferPER_Cur[PER_SEC_NF])!=0)
		return(1);
	
	if (strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferPER_Cur[PER_UWY_NF])!=0)
		return(1);
	
	if (strcmp(tpsz_ReadBufferPER[PER_UW_NT],tpsz_ReadBufferPER_Cur[PER_UW_NT])!=0)
		return(1);

	return(0);
}

/*==============================================================================
objet :
        Fonction lancee en rupture derniere sur l'acceptation
        pour le fichier perimetre

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionLastPER(char ** tpsz_ReadBufferPER)
{    
	/* lancement de la synchro */
	if ( n_ProcessingRuptureSyncVar(&Kbd_RuptCES,tpsz_ReadBufferPER) == ERR)
		return ERR;

	RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Fonction lancee en rupture premiere sur l'acceptation
        pour le fichier perimetre

retour :
        OK --->
        ERR --->
==============================================================================*/
static int n_ActionFirstPER(char ** tpsz_ReadBufferPER)
{    
	Kn_cmpt=0;
	return OK;
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
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferCES[]
)
{
	int      i;
	CS_FLOAT n_Scoegp;       // [002]
	char     sz_Scoegp[20];  // [002]

// [002]	
	n_Scoegp = atof(tpsz_ReadBufferPER[PER_SCOEGP_M]) * atof(tpsz_ReadBufferCES[CES_CESSH_R]);
	sprintf(sz_Scoegp,"%.3f",n_Scoegp);

	for (i=0; i< Kn_cmpt; i++)
	{
		fprintf(Kp_Ces,"%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
		        tpsz_ReadBufferCES[CES_CTR_NF],
		        Ktn_END[i],
		        tpsz_ReadBufferCES[CES_SEC_NF],
		        tpsz_ReadBufferCES[CES_UWY_NF],
		        tpsz_ReadBufferCES[CES_UW_NT],
		        tpsz_ReadBufferCES[CES_RETCTR_NF],
		        tpsz_ReadBufferCES[CES_RETEND_NT],
		        tpsz_ReadBufferCES[CES_RETSEC_NF],
		        tpsz_ReadBufferCES[CES_RTY_NF],
		        tpsz_ReadBufferCES[CES_RETUW_NT],
		        tpsz_ReadBufferCES[CES_CESACCSTA_N],
		        tpsz_ReadBufferCES[CES_CESACCEND_N],
		        tpsz_ReadBufferCES[CES_CESSH_R],
		        tpsz_ReadBufferCES[CES_SSD_CF],
		        tpsz_ReadBufferCES[CES_ESB_CF],
		        tpsz_ReadBufferCES[CES_RETCTRCAT_CF],
		        tpsz_ReadBufferCES[CES_ACCADMTYP_CT],
		        tpsz_ReadBufferCES[CES_RETACCADM_B],
		        tpsz_ReadBufferCES[CES_CLECUTPER_B],
		        tpsz_ReadBufferCES[CES_CLECUTPER_NB],
		        tpsz_ReadBufferCES[CES_LOB_CF],
		        tpsz_ReadBufferPER[PER_EGPCUR_CF],
		        tpsz_ReadBufferCES[CES_RETPCPCUR_CF],
				tpsz_ReadBufferCES[CES_CONRETCTR_B],
				tpsz_ReadBufferCES[CES_ACCFAM_CT]);

// [003]
		fprintf(Kp_Seg,"%s~%s~%s~%d~%s~%s~%s~%s~%s~%s~%s~%s~%s~%d~%s~%s~%s~%s~%d~%s~%s~%d~%d~%d~%d~%d~%d~%s~%d~%d~%d~%d~%d~%d~%d~%d~%d~%d\n",
		       tpsz_ReadBufferPER[PER_SSD_CF],
		       tpsz_ReadBufferPER[PER_ACCESB_CF],
		       tpsz_ReadBufferCES[CES_CTR_NF],
		       Ktn_END[i],
		       tpsz_ReadBufferCES[CES_SEC_NF],
		       tpsz_ReadBufferCES[CES_UWY_NF],
		       tpsz_ReadBufferCES[CES_UW_NT],
		       tpsz_ReadBufferPER[PER_PCPCUR_CF],
		       tpsz_ReadBufferPER[PER_CED_NF],
		       tpsz_ReadBufferPER[PER_PRD_NF],
		       tpsz_ReadBufferPER[PER_GENPRMPAY_NF],
		       tpsz_ReadBufferPER[PER_GANPAYORD_NT],
		       tpsz_ReadBufferCES[CES_RETCTR_NF],
		       Ktn_END[i],
		       tpsz_ReadBufferCES[CES_RETSEC_NF],
		       tpsz_ReadBufferCES[CES_RTY_NF],
		       tpsz_ReadBufferCES[CES_RETUW_NT],
		       tpsz_ReadBufferPER[PER_EGPCUR_CF],
		       0,                                       //PLC_NT,
		       "",                                      //RTO_NF,
		       tpsz_ReadBufferPER[PER_SEG_NF],
		       0,                                       //ULR_MC,     
		       0,                                       //ULR_MC,     
		       0,                                       //WPREMIUM_MC,
		       0,                                       //WCHARGES_MC,
		       0,                                       //WCLAIM_MC,  
		       0,                                       //UPR_MC,     
		       sz_Scoegp,                               //SCOEGP_MC, 
		       0,                                       //FPREMIUM_MC,
		       0,                                       //UCR_MC,
		       0,                                       //PRCO_MC,
		       0,                                       //PRCI_MC,
		       0,                                       //NORME_CF,
		       0,                                       //PRMDSC_MC,
		       0,                                       //CLMDSC_MC,
		       0,                                       //BDTRAT_MC,
		       0,                                       //PRMRESD_MC,
		       0                                        //PRMRESB_MC  
		       );

	}
	return(OK);
}

/*==============================================================================
objet :
	fonction de test de synchronisation

retour :
	0   ---> pbd_InRecOwner = pbd_InRecChild 
	> 0 ---> pbd_InRecOwner > pbd_InRecChild 
	< 0 ---> pbd_InRecOwner < pbd_InRecChild 
==============================================================================*/
static int n_ConditionSync(
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferCES[]     /* adresse de la ligne de l'esclave */
	)
{
	int ret ;
	DEBUT_FCT("n_ConditionSync");

	if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferCES[CES_CTR_NF]))!=0)
		RETURN_VAL (ret);
	
	if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferCES[CES_SEC_NF]))!=0)
		RETURN_VAL (ret);
	        
	if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferCES[CES_UWY_NF]))!=0)
		RETURN_VAL (ret);
	
	if ((ret = strcmp(tpsz_ReadBufferPER[PER_UW_NT],tpsz_ReadBufferCES[CES_UW_NT]))!=0)
		RETURN_VAL (ret);
	
	RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement du perimetre             */
/*--------------------------------------------------------------------------*/
static int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
/* stocker le numero d'avenant courant */
Ktn_END[Kn_cmpt++]=atoi(tpsz_ReadBufferPER[PER_END_NT]);
return OK;  
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement du perimetre             */
/* qui n'a pas de lien avec le fichier des versements                       */
/* (ajout le 14 01 98) 														*/
/*--------------------------------------------------------------------------*/
static int  n_ActionPereSansFils(char *tpsz_ReadBufferPER[])
{
	/* dans ce cas on ecrit quand-meme une ligne dans le fichier en sortie */
	/* en mettant a blanc les valeurs des champs retrocession              */

	/* ces lignes servent en fait a garder les affaires acceptation,       */
	/* meme celles n'ayant aucun lien en retro, en vue de l'alimentation   */
	/* de la table TCONPAR (cf ESTC2306.c )                                */

	fprintf(Kp_Ces,"%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~~~~\n",
	        tpsz_ReadBufferPER[PER_CTR_NF],
	        tpsz_ReadBufferPER[PER_END_NT],
	        tpsz_ReadBufferPER[PER_SEC_NF],
	        tpsz_ReadBufferPER[PER_UWY_NF],
	        tpsz_ReadBufferPER[PER_UW_NT],
	        "",
	        "",
	        "",
	        "",
	        "",
	        "",
	        "",
	        "0.",   /* CESSH_R */
	        tpsz_ReadBufferPER[PER_SSD_CF],
	        tpsz_ReadBufferPER[PER_ACCESB_CF],
	        "",
	        tpsz_ReadBufferPER[PER_ACCADMTYP_CT],
	        "",
	        "",
	        "",
	        tpsz_ReadBufferPER[PER_LOB_CF],
	        tpsz_ReadBufferPER[PER_EGPCUR_CF]);
// [001]
/* [002] 
	fprintf(Kp_Seg,"%s~%d~%s~%s~%s~%s~%s\n",
	        tpsz_ReadBufferPER[CES_RETCTR_NF],
	        tpsz_ReadBufferPER[PER_END_NT],
	        tpsz_ReadBufferPER[CES_RETSEC_NF],
	        tpsz_ReadBufferPER[CES_RTY_NF],
	        tpsz_ReadBufferPER[CES_RETUW_NT],
	        tpsz_ReadBufferPER[PER_SEG_NF],
	        tpsz_ReadBufferPER[PER_EGPCUR_CF]);
*/
	return(OK);
}

