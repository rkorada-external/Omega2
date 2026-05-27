/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2302.c
revision                      : $Revision:   1.0  $
date de creation              : 28/08/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Preparation du fichier des placements pour l'inventaire 
        retrocession dommage : synchronisation du perimetre retrocession
        et des placements extraits de la base retrocession

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
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
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLignePLC(char **,char**);
static int n_ConditionSync(char **,char **);
static int n_ActionLignePER(char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Plc;

static T_RUPTURE_VAR   Kbd_RuptPER;       
static T_RUPTURE_SYNC_VAR  Kbd_RuptPLC;  

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

        if ( n_OpenFileAppl ("ESTC2302_O1","wt",&Kp_Plc) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptPER  */
	if ( n_InitPER(&Kbd_RuptPER)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptPLC */
	if ( n_InitPLC(&Kbd_RuptPLC)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptPER) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2302_O1",&Kp_Plc)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2302_I1",&(Kbd_RuptPER.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2302_I2",&(Kbd_RuptPLC.pf_InputFil))==ERR )
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

	if ( n_OpenFileAppl ("ESTC2302_I1","rt",&(pbd_RuptPER->pf_InputFil))==ERR)
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
static int n_InitPLC(T_RUPTURE_SYNC_VAR  *pbd_RuptPLC)
{

	memset( pbd_RuptPLC,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2302_I2","rt",&(pbd_RuptPLC->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptPLC->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptPLC->ConditionEndSync	= n_ConditionSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptPLC->n_ActionLigne   	= n_ActionLignePLC;
	
        pbd_RuptPLC->c_Separ='~';

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
static int n_ActionLignePLC(
	char *tpsz_ReadBufferPER[] ,
	char *tpsz_ReadBufferPLC[]
)
{
   n_WriteCols(Kp_Plc, tpsz_ReadBufferPLC,SEPARATEUR, 0);         
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
	char *tpsz_ReadBufferPER[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferPLC[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferPER[PER_CTR_NF],tpsz_ReadBufferPLC[PLA_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferPER[PER_END_NT],tpsz_ReadBufferPLC[PLA_RETEND_NT]))!=0)
           RETURN_VAL (ret);
        
        if((ret = strcmp(tpsz_ReadBufferPER[PER_SEC_NF],tpsz_ReadBufferPLC[PLA_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UWY_NF],tpsz_ReadBufferPLC[PLA_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        if ((ret = strcmp(tpsz_ReadBufferPER[PER_UW_NT],tpsz_ReadBufferPLC[PLA_RETUW_NT]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLignePER(char *tpsz_ReadBufferPER[])
{
     /* lancement de la synchro */
     if ( n_ProcessingRuptureSyncVar(&Kbd_RuptPLC,tpsz_ReadBufferPER) == ERR)
           return ERR;

        return OK;  
}

