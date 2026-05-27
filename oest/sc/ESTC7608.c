/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Syncro Perimetre Vie et Estimation
nom du source                 : ESTC7608.c
revision                      : $Revision:   1.1  $
date de creation              : 20/02/2008
auteur                        : J. Ribot
references des specifications :
squelette de base             : batch
------------------------------------------------------------------------------
description :

SPOT 14307

ajout info renouvellement du traite dans VLIFEST195 pour traitement
ESTC2136.c trimestrialisation

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

[002] 25/11/2013 -=Dch=-  	   :spot:25773  - Omega 2B modification de colonnes pour LIFEST	 
  
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/*
 * complété dans struct.h
	define PRE_UWGRP_CF  36 // ajout 12/01/98 
	define PRE_CNATYP_CT  37 // ajout 04/06/03 
	define PRE_RENOUV_B  38 // ajout 20/02/08 
*/
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFil,  /* pointeur sur le fichier de sortie */
	      *Kp_OutPREB1;       /* fichier Bilan -1 en sortie */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptPRE; /* gestion synchro GT-perimetre */

int n_InitPRE (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePRE(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPRE(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_IsR1Perim(char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLastRuptPerim(char **ptb_InRec_Cur);
int     Kb_rupt1;       /* 1 si rupture de niveau 1, 0 sinon */

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionFilsSansPerePRE(char **ptb_InRecChild);

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
 
        if ( n_OpenFileAppl ("ESTC7608_O1","wt",&Kp_OutputFil) == ERR )
                  ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPRE */
        if ( n_InitPRE(&bd_RuptPRE) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC7608_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );


        if (n_CloseFileAppl("ESTC7608_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC7608_I2",&(bd_RuptPRE.pf_InputFil))== ERR)
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
int n_InitPerim(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPerim");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC7608_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Perim;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

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
int n_IsR1Perim(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1Perim");

        Kb_rupt1=0;

        if (strcmp(ptb_InRec[PER_CTR_NF],ptb_InRec_Cur[PER_CTR_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_SEC_NF],ptb_InRec_Cur[PER_SEC_NF])!=0)
                RETURN_VAL(1);
        if (strcmp(ptb_InRec[PER_UWY_NF],ptb_InRec_Cur[PER_UWY_NF])!=0)
                RETURN_VAL(1);
        RETURN_VAL (0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPerim(char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLastRuptPerim");
    RETURN_VAL (0);
}
/*==============================================================================
objet :
        fonction lancee pour chaque ligne du maitre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionLignePerim");
        n_ProcessingRuptureSyncVar (&bd_RuptPRE, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitPRE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPRE");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC7608_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPRE ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLignePRE ;

 	/* fonction d'action quand le maitre n'a pas de fils PRE */
         pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPerePRE;

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
int n_ConditionSyncPRE(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncPRE");

        if ( (ret = strcmp(pbd_InRecOwner[PER_CTR_NF],pbd_InRecChild[PRE_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_SEC_NF],pbd_InRecChild[PRE_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[PRE_UWY_NF])) != 0 )
                RETURN_VAL(ret);

        RETURN_VAL(0);
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne du GT synchronisee avec le perimetre

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePRE(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{


        DEBUT_FCT("n_ActionLignePRE");
       ptb_InRecChild[PRE_RENOUV_B] = "1" ;
	     n_WriteCols(Kp_OutputFil , ptb_InRecChild, '~' , 0);	
       RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/

int n_ActionFilsSansPerePRE(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
)
{

      DEBUT_FCT("n_ActionFilsSansPerePRE");
 		ptb_InRecChild[PRE_RENOUV_B] = "0";
		n_WriteCols(Kp_OutputFil, ptb_InRecChild, '~' , 0);

		RETURN_VAL(OK);
}



