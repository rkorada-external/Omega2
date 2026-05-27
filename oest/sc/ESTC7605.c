/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Job ESCJ0064 : reception retro interne
nom du source                 : ESTC7605.c
revision                      : $Revision:   1.0  $
date de creation              : 23/06/2004
auteur                        : J.Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :

------------------------------------------------------------------------------
historique des modifications :
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
#define PRE_UWGRP_CF  36 /* ajout 12/01/98 */
#define PRE_CNATYP_CT  37 /* ajout 04/06/03 */
#define PREV_CLOPRD 38
#define PREV_DBCLO_D 39
#define PREV_CRE_D 40
#define PREV_ORGSSD_CF 41

/*--------------------------*/
/*    Protoypes             */
/*--------------------------*/
static int n_InitKEYS(T_RUPTURE_VAR  *);
static int n_InitPRErecu(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLignePRErecu(char **,char**);
static int n_ConditionSyncPRErecu(char **,char **);
static int n_ActionLigneKEYS(char **);
static int n_InitPREVperm(T_RUPTURE_SYNC_VAR  *);
static int n_ActionLignePREVperm(char **,char**);
static int n_ConditionSyncPREVperm(char **,char **);

/*----------------------*/
/* variables de travail */
/*----------------------*/

static FILE *Kp_NewPREperm;

static T_RUPTURE_VAR   Kbd_RuptKEYS;
static T_RUPTURE_SYNC_VAR  Kbd_RuptPREVperm;
static T_RUPTURE_SYNC_VAR  Kbd_RuptPRErecu;

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

        if ( n_OpenFileAppl ("ESTC7605_O1","wt",&Kp_NewPREperm) == ERR )
                ExitPgm ( ERR_XX , "" );

	/* Initialisation de la variable Kbd_RuptKEYS  */
	if ( n_InitKEYS(&Kbd_RuptKEYS)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptPRErecu */
	if ( n_InitPRErecu(&Kbd_RuptPRErecu)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* Initialisation de la varible Kbd_RuptPREVperm */
	if ( n_InitPREVperm(&Kbd_RuptPREVperm)==ERR )
		ExitPgm ( ERR_XX , "" );

	/* lancement du traitement du fichier maitre */
	if ( n_ProcessingRuptureVar(&Kbd_RuptKEYS) == ERR )
		ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7605_O1",&Kp_NewPREperm)==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7605_I1",&(Kbd_RuptKEYS.pf_InputFil))==ERR )
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7605_I2",&(Kbd_RuptPRErecu.pf_InputFil))==ERR)
                ExitPgm ( ERR_XX , "" );

        if ( n_CloseFileAppl ("ESTC7605_I3",&(Kbd_RuptPREVperm.pf_InputFil))==ERR )
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

	if ( n_OpenFileAppl ("ESTC7605_I1","rt",&(pbd_RuptKEYS->pf_InputFil))==ERR)
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
static int n_InitPRErecu(T_RUPTURE_SYNC_VAR  *pbd_RuptGTrecu)
{

	memset( pbd_RuptGTrecu,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC7605_I2","rt",&(pbd_RuptGTrecu->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptGTrecu->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptGTrecu->ConditionEndSync	= n_ConditionSyncPRErecu;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptGTrecu->n_ActionLigne   	= n_ActionLignePRErecu;

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
static int n_ActionLignePRErecu(
	char *tpsz_ReadBufferKEYS[] ,
	char *tpsz_ReadBufferPRErecu[]
)
{

//    printf("Ecrit PRErecu \n");

   /* la ligne courante est reconduite en sortie */
   n_WriteCols(Kp_NewPREperm,tpsz_ReadBufferPRErecu,SEPARATEUR,0);

   Kb_CleTrouvee=TRUE;

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
static int n_ConditionSyncPRErecu(
	char *tpsz_ReadBufferKEYS[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferPRErecu[]     /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncPRErecu");

//            printf("n_ConditionSyncPRErecu \n");


        if((ret = strcmp(tpsz_ReadBufferKEYS[PREV_ORGSSD_CF],tpsz_ReadBufferPRErecu[PREV_ORGSSD_CF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[PRE_BALSHEY_NF],tpsz_ReadBufferPRErecu[PRE_BALSHEY_NF]))!=0)
           RETURN_VAL (ret);

        /* Modif OG 04/10/02, on a trie le champ en ajoutant EN, on teste ici un champ numerique
           car la valeur du mois peut etre 9 ou 09 */
        if((ret = (atoi(tpsz_ReadBufferKEYS[PRE_BALSHTMTH_NF]) - atoi(tpsz_ReadBufferPRErecu[PRE_BALSHTMTH_NF])))!=0)
           RETURN_VAL (ret);

//        if((ret = strcmp(tpsz_ReadBufferKEYS[PRE_BALSHRDAY_NF],tpsz_ReadBufferPRErecu[PRE_BALSHRDAY_NF]))!=0)
//           RETURN_VAL (ret);

        /* pour les deux champs suivants la comparaison est faite */
        /* "a l'envers" (fils - pere) car les fichiers en entree  */
        /* sont tries pas ordre decroissant sur ces champs */

        if ((ret = strcmp(tpsz_ReadBufferPRErecu[PREV_DBCLO_D],tpsz_ReadBufferKEYS[PREV_DBCLO_D]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferPRErecu[PREV_CRE_D],tpsz_ReadBufferKEYS[PREV_CRE_D]))!=0)
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
     if (n_ProcessingRuptureSyncVar(&Kbd_RuptPRErecu,tpsz_ReadBufferKEYS)==ERR)
           return ERR;

     /* lancement de la 2eme synchro, uniquement si la cle du maitre */
     /* n'a pas ete trouvee dans le premier fils */
     if (Kb_CleTrouvee == FALSE)
     {
     if (n_ProcessingRuptureSyncVar(&Kbd_RuptPREVperm,tpsz_ReadBufferKEYS)==ERR)
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
static int n_InitPREVperm(T_RUPTURE_SYNC_VAR  *pbd_RuptPREVperm)
{

	memset( pbd_RuptPREVperm,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

	/* ouverture du fichier esclave */
	if(n_OpenFileAppl ("ESTC7605_I3","rt",&(pbd_RuptPREVperm->pf_InputFil))==ERR)
           return ERR;

      	pbd_RuptPREVperm->n_NbRupture =0;

	/* fonction du test de la ligne du maitre avec l'esclave */
	pbd_RuptPREVperm->ConditionEndSync	= n_ConditionSyncPREVperm;

	/* fonction d'action sur la ligne courante du fichier esclave */
	pbd_RuptPREVperm->n_ActionLigne   	= n_ActionLignePREVperm;

        pbd_RuptPREVperm->c_Separ=SEPARATEUR;

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
static int n_ActionLignePREVperm(
	char *tpsz_ReadBufferKEYS[] ,
	char *tpsz_ReadBufferPREVperm[]
)
{

//   printf("Ecrit PREVperm \n");

   /* la ligne courante est reconduite en sortie */
   n_WriteCols(Kp_NewPREperm,tpsz_ReadBufferPREVperm,SEPARATEUR,0);
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
static int n_ConditionSyncPREVperm(
	char *tpsz_ReadBufferKEYS[] ,   /* adresse de la ligne du maitre */
	char *tpsz_ReadBufferPREVperm[]  /* adresse de la ligne de l'esclave */
	)
{

	int ret ;
        DEBUT_FCT("n_ConditionSyncPREVperm");


//           printf("n_ConditionSyncPREVperm \n");

        if((ret = strcmp(tpsz_ReadBufferKEYS[PREV_ORGSSD_CF],tpsz_ReadBufferPREVperm[PREV_ORGSSD_CF]))!=0)
           RETURN_VAL (ret);

        if((ret = strcmp(tpsz_ReadBufferKEYS[PRE_BALSHEY_NF],tpsz_ReadBufferPREVperm[PRE_BALSHEY_NF]))!=0)
           RETURN_VAL (ret);

        /* Modif OG 04/10/02, on a trie le champ en ajoutant EN, on teste ici un champ numerique
           car la valeur du mois peut etre 9 ou 09 */
        if((ret = (atoi(tpsz_ReadBufferKEYS[PRE_BALSHTMTH_NF]) - atoi(tpsz_ReadBufferPREVperm[PRE_BALSHTMTH_NF])))!=0)
           RETURN_VAL (ret);

//        if((ret = strcmp(tpsz_ReadBufferKEYS[PRE_BALSHRDAY_NF],tpsz_ReadBufferPREVperm[PRE_BALSHRDAY_NF]))!=0)
//           RETURN_VAL (ret);

        /* pour les deux champs suivants la comparaison est faite */
        /* "a l'envers" (fils - pere) car les fichiers en entree  */
        /* sont tries pas ordre decroissant sur ces champs */

        if ((ret = strcmp(tpsz_ReadBufferPREVperm[PREV_DBCLO_D],tpsz_ReadBufferKEYS[PREV_DBCLO_D]))!=0)
           RETURN_VAL (ret);

        if ((ret = strcmp(tpsz_ReadBufferPREVperm[PREV_CRE_D],tpsz_ReadBufferKEYS[PREV_CRE_D]))!=0)
           RETURN_VAL (ret);

        RETURN_VAL(0);
}



