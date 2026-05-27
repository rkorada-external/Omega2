/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Introduction des postes cumuls et conversion
                                en devise principale
nom du source                 : ESTC2042.c
revision                      : $Revision:   1.1  $
date de creation              : 04/06/1997
auteur                        : C. Chavatte
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
/*==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFil;  /* pointeur sur le fichier de sortie */

T_RUPTURE_VAR bd_RuptPerim; /* gestion rupture sur perimetre */
T_RUPTURE_SYNC_VAR bd_RuptGT; /* gestion synchro GT-perimetre */

int n_InitGT (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLigneGT(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncGT(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitPerim(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLignePerim(char **pbd_InRec_Cur);
int n_ActionFilsSansPereGT(char **ptb_InRecOwner );


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

        if ( n_OpenFileAppl ("ESTC2042_O1","wt",&Kp_OutputFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptPerim */
        if ( n_InitPerim(&bd_RuptPerim) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptGT */
        if ( n_InitGT(&bd_RuptGT) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptPerim) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2042_O1",&Kp_OutputFil)== ERR)
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC2042_I1",&(bd_RuptPerim.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2042_I2",&(bd_RuptGT.pf_InputFil))== ERR)
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

        if ( n_OpenFileAppl ("ESTC2042_I1","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        pbd_Rupt->n_ActionLigne = n_ActionLignePerim ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL(OK);
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

        /* synchronisation du fichier GT pour chaque ligne */
        n_ProcessingRuptureSyncVar (&bd_RuptGT, ptb_InRec_Cur) ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre avec l'esclave GT

retour :
        OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitGT");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2042_I2","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncGT ;

        /* fonction d'action sur la ligne courante du fichier esclave */
        pbd_Rupt->n_ActionLigne         = n_ActionLigneGT ;

      	/* fonction d'action quand le maitre n'a pas de fils GT */
        pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGT;


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
int n_ConditionSyncGT(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret;

        DEBUT_FCT("n_ConditionSyncGT");

        if ( (ret = strcmp(pbd_InRecOwner[PER_ESTCTR_NF],pbd_InRecChild[GT_CTR_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_ESTSEC_NF],pbd_InRecChild[GT_SEC_NF])) != 0 )
                RETURN_VAL(ret);
        if ( (ret = strcmp(pbd_InRecOwner[PER_UWY_NF],pbd_InRecChild[GT_UWY_NF])) != 0 )
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
int n_ActionLigneGT(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{

        DEBUT_FCT("n_ActionLigneGT");


	{
        n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);
	}
        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le pere n'a pas de fils GT
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre

==============================================================================*/
int n_ActionFilsSansPereGT(
        char **ptb_InRecChild   /* adresse de la ligne du maitre */
        )
{

      DEBUT_FCT("n_ActionFilsSansPereGT");

        ptb_InRecChild[GT_COMACC_B]     = "1";

		n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

        RETURN_VAL(OK);
}

