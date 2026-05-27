/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job xxx : Step xxx
nom du source                 : ESTC2306.c
revision                      : $Revision:   1.1  $
date de creation              : 29/08/97
auteur                        : CGI (Claire Soulier) 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Croisement des fichiers 'part placee cumulee' et versements pour 
        calculer la part retrocedee totale par casex acceptation.
        (generation du fichier image de la table TCONPAR)
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
#define BESTCES_RETCTR_NF 0
#define BESTCES_RTY_NF 1
#define BESTCES_RETSEC_NF 2
#define BESTCES_SSD_CF 3
#define BESTCES_BALSHEPLA_R 4

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitBESTCES(T_RUPTURE_VAR  *);
static int n_InitBRETCES(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneBRETCES(char **,char**);
static int n_ActionFilsSansPereBRETCES(char**);
static int n_ConditionSync(char **,char **);
static int n_ActionLigneBESTCES(char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_Conpar;   

static T_RUPTURE_VAR   Kbd_RuptBESTCES;       
static T_RUPTURE_SYNC_VAR  Kbd_RuptBRETCES;  

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

        if ( n_OpenFileAppl ("ESTC2306_O1","wt",&Kp_Conpar) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptBESTCES  */
	if ( n_InitBESTCES(&Kbd_RuptBESTCES)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptBRETCES */
	if ( n_InitBRETCES(&Kbd_RuptBRETCES)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptBESTCES) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC2306_O1",&Kp_Conpar)==ERR )
                ExitPgm ( ERR_XX , "" );
        
        if ( n_CloseFileAppl ("ESTC2306_I1",&(Kbd_RuptBESTCES.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );
        
        if ( n_CloseFileAppl ("ESTC2306_I2",&(Kbd_RuptBRETCES.pf_InputFil))==ERR )
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
static int n_InitBESTCES(T_RUPTURE_VAR  *pbd_RuptBESTCES)
{
	memset(pbd_RuptBESTCES,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC2306_I1","rt",&(pbd_RuptBESTCES->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptBESTCES->n_NbRupture =0;    
	pbd_RuptBESTCES->n_ActionLigne     = n_ActionLigneBESTCES;

        pbd_RuptBESTCES->c_Separ=SEPARATEUR;

	return OK ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree 
==============================================================================*/
static int n_InitBRETCES(T_RUPTURE_SYNC_VAR  *pbd_RuptBRETCES)
{

	memset( pbd_RuptBRETCES,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC2306_I2","rt",&(pbd_RuptBRETCES->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptBRETCES->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptBRETCES->ConditionEndSync= n_ConditionSync;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptBRETCES->n_ActionLigne 	= n_ActionLigneBRETCES;
	
	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptBRETCES->n_FilsSansPere	= n_ActionFilsSansPereBRETCES;
	
        pbd_RuptBRETCES->c_Separ=SEPARATEUR;

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
static int n_ActionLigneBRETCES(
	char *tpsz_ReadBufferBESTCES[] ,
	char *tpsz_ReadBufferBRETCES[]
)
{
  fprintf(Kp_Conpar,"%s~%s~%s~%s~%s~%s~%s~%s~%.8lf\n",
             tpsz_ReadBufferBRETCES[CES_CTR_NF],
             tpsz_ReadBufferBRETCES[CES_END_NT],
             tpsz_ReadBufferBRETCES[CES_SEC_NF],
             tpsz_ReadBufferBRETCES[CES_UWY_NF],
             tpsz_ReadBufferBRETCES[CES_UW_NT],
             tpsz_ReadBufferBRETCES[CES_SSD_CF],
             tpsz_ReadBufferBRETCES[CES_CUR_CF],
             tpsz_ReadBufferBRETCES[CES_ACCADMTYP_CT],
             atof(tpsz_ReadBufferBRETCES[CES_CESSH_R]) * atof(tpsz_ReadBufferBESTCES[BESTCES_BALSHEPLA_R]));

  return(OK);
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne fils sans pere
        qui synchronise

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
static int n_ActionFilsSansPereBRETCES(
	char *tpsz_ReadBufferBRETCES[]
)
{
  fprintf(Kp_Conpar,"%s~%s~%s~%s~%s~%s~%s~%s~0.0\n",
             tpsz_ReadBufferBRETCES[CES_CTR_NF],
             tpsz_ReadBufferBRETCES[CES_END_NT],
             tpsz_ReadBufferBRETCES[CES_SEC_NF],
             tpsz_ReadBufferBRETCES[CES_UWY_NF],
             tpsz_ReadBufferBRETCES[CES_UW_NT],
             tpsz_ReadBufferBRETCES[CES_SSD_CF],
             tpsz_ReadBufferBRETCES[CES_CUR_CF],
             tpsz_ReadBufferBRETCES[CES_ACCADMTYP_CT]);

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
	char *tpsz_ReadBufferBESTCES[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferBRETCES[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSync");

        if((ret = strcmp(tpsz_ReadBufferBESTCES[BESTCES_RETCTR_NF],tpsz_ReadBufferBRETCES[CES_RETCTR_NF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferBESTCES[BESTCES_RETSEC_NF],tpsz_ReadBufferBRETCES[CES_RETSEC_NF]))!=0)
           RETURN_VAL (ret);
                
        if ((ret = strcmp(tpsz_ReadBufferBESTCES[BESTCES_RTY_NF],tpsz_ReadBufferBRETCES[CES_RTY_NF]))!=0)
           RETURN_VAL (ret);
        
        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneBESTCES(char *tpsz_ReadBufferBESTCES[])
{
   if ( n_ProcessingRuptureSyncVar(&Kbd_RuptBRETCES,tpsz_ReadBufferBESTCES) == ERR )
	   return ERR;

   return OK;
}







