/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job ESCJ0063 : reception retro interne
nom du source                 : ESTC7603.c
revision                      : $Revision:   1.0  $
date de creation              : 14/11/97
auteur                        : CGI (Claire Soulier)
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :

------------------------------------------------------------------------------
historique des modifications :
06/01/2003   O.GIRAUX      MOD01:
                          On avait un pb de doublement de mvts ds le GTEP lorsqu'on relançait la chaîne ds la même journée
                          qu'un précédent passage. Cela venait de la variable Kb_CleTrouvee mal positionnée.


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
#define GTE_CLOPRD 40
#define GTE_DBCLO_D 41
#define GTE_CRE_D 42
#define GTE_ORGSSD_CF 43

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitKEYS(T_RUPTURE_VAR  *);
static int n_InitGTrecu(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneGTrecu(char **,char**);
static int n_ConditionSyncGTrecu(char **,char **);
static int n_ActionLigneKEYS(char **);
static int n_InitGTEperm(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLigneGTEperm(char **,char**);
static int n_ConditionSyncGTEperm(char **,char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_NewGTperm;

static T_RUPTURE_VAR   Kbd_RuptKEYS;
static T_RUPTURE_SYNC_VAR  Kbd_RuptGTEperm;
static T_RUPTURE_SYNC_VAR  Kbd_RuptGTrecu;

BOOL Kb_CleTrouvee;

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

        if ( n_OpenFileAppl ("ESTC7603_O1","wt",&Kp_NewGTperm) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptKEYS  */
	if ( n_InitKEYS(&Kbd_RuptKEYS)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptGTrecu */
	if ( n_InitGTrecu(&Kbd_RuptGTrecu)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptGTEperm */
	if ( n_InitGTEperm(&Kbd_RuptGTEperm)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptKEYS) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7603_O1",&Kp_NewGTperm)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7603_I1",&(Kbd_RuptKEYS.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7603_I2",&(Kbd_RuptGTrecu.pf_InputFil))==ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7603_I3",&(Kbd_RuptGTEperm.pf_InputFil))==ERR )
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
static int n_InitKEYS(T_RUPTURE_VAR  *pbd_RuptKEYS)
{
	memset(pbd_RuptKEYS,0,sizeof(T_RUPTURE_VAR));

	if ( n_OpenFileAppl ("ESTC7603_I1","rt",&(pbd_RuptKEYS->pf_InputFil))==ERR)
		return ERR;

	pbd_RuptKEYS->n_NbRupture =0;
	pbd_RuptKEYS->n_ActionLigne     = n_ActionLigneKEYS;

        pbd_RuptKEYS->c_Separ=SEPARATEUR;

	return OK ;
}


/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTrecu(T_RUPTURE_SYNC_VAR  *pbd_RuptGTrecu)
{

	memset( pbd_RuptGTrecu,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC7603_I2","rt",&(pbd_RuptGTrecu->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptGTrecu->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptGTrecu->ConditionEndSync	= n_ConditionSyncGTrecu;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptGTrecu->n_ActionLigne   	= n_ActionLigneGTrecu;

        pbd_RuptGTrecu->c_Separ=SEPARATEUR;

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
static int n_ActionLigneGTrecu(
	char *tpsz_ReadBufferKEYS[] ,
	char *tpsz_ReadBufferGTrecu[]
)
{
/*      tpsz_ReadBufferGTrecu[GT_RETINTAMT_M]= "0.000"; */
   /* MOD02 J. Ribot 22/01/2003
   /* la ligne courante est reconduite en sortie */
   n_WriteCols(Kp_NewGTperm,tpsz_ReadBufferGTrecu,SEPARATEUR,0);

   Kb_CleTrouvee=TRUE;              //MOD01 OGIRAUX 06/01/03

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
static int n_ConditionSyncGTrecu(
	char *tpsz_ReadBufferKEYS[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferGTrecu[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncGTrecu");

        if((ret = strcmp(tpsz_ReadBufferKEYS[GTE_ORGSSD_CF],tpsz_ReadBufferGTrecu[GTE_ORGSSD_CF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[GT_BALSHEY_NF],tpsz_ReadBufferGTrecu[GT_BALSHEY_NF]))!=0)
           RETURN_VAL (ret);

        /* Modif OG 04/10/02, on a trie le champ en ajoutant EN, on teste ici un champ numerique
           car la valeur du mois peut etre 9 ou 09 */
        if((ret = (atoi(tpsz_ReadBufferKEYS[GT_BALSHRMTH_NF]) - atoi(tpsz_ReadBufferGTrecu[GT_BALSHRMTH_NF])))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[GT_BALSHRDAY_NF],tpsz_ReadBufferGTrecu[GT_BALSHRDAY_NF]))!=0)
           RETURN_VAL (ret);

        /* pour les deux champs suivants la comparaison est faite */
        /* "a l'envers" (fils - pere) car les fichiers en entree  */
        /* sont tries pas ordre decroissant sur ces champs */

        if ((ret = strcmp(tpsz_ReadBufferGTrecu[GTE_DBCLO_D],tpsz_ReadBufferKEYS[GTE_DBCLO_D]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTrecu[GTE_CRE_D],tpsz_ReadBufferKEYS[GTE_CRE_D]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}

/*--------------------------------------------------------------------------*/
/* Fonction de traitement de chaque enregistrement pere                     */
/*--------------------------------------------------------------------------*/
static int  n_ActionLigneKEYS(char *tpsz_ReadBufferKEYS[])
{

     Kb_CleTrouvee=FALSE;

     /* lancement de la 1ere synchro */
     if (n_ProcessingRuptureSyncVar(&Kbd_RuptGTrecu,tpsz_ReadBufferKEYS)==ERR)
           return ERR;

     /* lancement de la 2eme synchro, uniquement si la cle du maitre */
     /* n'a pas ete trouvee dans le premier fils */
     if (Kb_CleTrouvee == FALSE)
     {
     if (n_ProcessingRuptureSyncVar(&Kbd_RuptGTEperm,tpsz_ReadBufferKEYS)==ERR)
           return ERR;
     }

        return OK;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation du maitre avec l'esclave

retour :
	OK ---> traitement correctement effectue
        ERR ---> probleme a l'ouverture du fichier d'entree
==============================================================================*/
static int n_InitGTEperm(T_RUPTURE_SYNC_VAR  *pbd_RuptGTEperm)
{

	memset( pbd_RuptGTEperm,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC7603_I3","rt",&(pbd_RuptGTEperm->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptGTEperm->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptGTEperm->ConditionEndSync	= n_ConditionSyncGTEperm;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptGTEperm->n_ActionLigne   	= n_ActionLigneGTEperm;

        pbd_RuptGTEperm->c_Separ=SEPARATEUR;

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
static int n_ActionLigneGTEperm(
	char *tpsz_ReadBufferKEYS[] ,
	char *tpsz_ReadBufferGTEperm[]
)
{
/*    tpsz_ReadBufferGTEperm[GT_RETINTAMT_M]= "0.000";  */
   /* MOD02 J. Ribot 22/01/2003
   /* la ligne courante est reconduite en sortie */
   n_WriteCols(Kp_NewGTperm,tpsz_ReadBufferGTEperm,SEPARATEUR,0);
   //Kb_CleTrouvee=TRUE;        MOD01 O.GIRAUX 06/01/2003
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
static int n_ConditionSyncGTEperm(
	char *tpsz_ReadBufferKEYS[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferGTEperm[]  /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncGTEperm");

        if((ret = strcmp(tpsz_ReadBufferKEYS[GTE_ORGSSD_CF],tpsz_ReadBufferGTEperm[GTE_ORGSSD_CF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[GT_BALSHEY_NF],tpsz_ReadBufferGTEperm[GT_BALSHEY_NF]))!=0)
           RETURN_VAL (ret);

        /* Modif OG 04/10/02, on a trie le champ en ajoutant EN, on teste ici un champ numerique
           car la valeur du mois peut etre 9 ou 09 */
        if((ret = (atoi(tpsz_ReadBufferKEYS[GT_BALSHRMTH_NF]) - atoi(tpsz_ReadBufferGTEperm[GT_BALSHRMTH_NF])))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[GT_BALSHRDAY_NF],tpsz_ReadBufferGTEperm[GT_BALSHRDAY_NF]))!=0)
           RETURN_VAL (ret);

        /* pour les deux champs suivants la comparaison est faite */
        /* "a l'envers" (fils - pere) car les fichiers en entree  */
        /* sont tries pas ordre decroissant sur ces champs */

        if ((ret = strcmp(tpsz_ReadBufferGTEperm[GTE_DBCLO_D],tpsz_ReadBufferKEYS[GTE_DBCLO_D]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferGTEperm[GTE_CRE_D],tpsz_ReadBufferKEYS[GTE_CRE_D]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}


