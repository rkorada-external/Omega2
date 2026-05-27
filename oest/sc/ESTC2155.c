/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Actualisation du parametrage
nom du source                 : ESTC2155.c
revision                      : $Revision:   1.1  $
date de creation              : 25/047/2003
auteur                        : J. Ribot
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :


------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    04/10/2003     j. Ribot  ajout test ACY pour alimentation adjcod
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  *Kp_PrevFil;            /* pointeurs sur les fichiers en sortie */

T_RUPTURE_VAR bd_RuptAccpar;    /* gestion rupture sur ACCPAR */
T_RUPTURE_SYNC_VAR  bd_RuptPrev; /* gestion synchro accpar-previsions */

char	Ksz_Balshey[5] ;	/* annee bilan passee en argument */

int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt);
int n_ActionLignePrev(char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPrev(char **ptb_InRecOwner,char **pbd_InRecChild);

int n_InitAccpar(T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneAccpar(char **pbd_InRec_Cur);
int n_IsR1ACCPAR(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRuptAccpar ( char **ptb_InRec_Cur);

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

	/* Recuperation des arguments */
	//Kn_Balshey = n_GetIntArgv( 1 ) ;
	strcpy(Ksz_Balshey, psz_GetCharArgv(1));


        /* ouverture des fichiers en sortie */

        if ( n_OpenFileAppl ("ESTC2155_O1","wt",&Kp_PrevFil) == ERR )
                ExitPgm ( ERR_XX , "" );


        /* Initialisation de la varible bd_RuptPrev */
        if ( n_InitPrev(&bd_RuptPrev) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptAccpar */
        if ( n_InitAccpar (&bd_RuptAccpar) )
                ExitPgm ( ERR_XX , "" );

        /* lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptAccpar) == ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2155_O1",&Kp_PrevFil))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl("ESTC2155_I2",&(bd_RuptPrev.pf_InputFil))== ERR )
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2155_I1",&(bd_RuptAccpar.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(OK) ;

}

/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier des previsions.

retour :
        OK
==============================================================================*/
int n_InitPrev(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitPrev");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

        if ( n_OpenFileAppl ("ESTC2155_I2","rt",&(pbd_Rupt->pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        pbd_Rupt->n_NbRupture = 0  ;

        /* fonction du test de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync      = n_ConditionSyncPrev;

        pbd_Rupt->n_ActionLigne = n_ActionLignePrev ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction lancee pour chaque ligne des previsions

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev(
        char **ptb_InRecOwner ,/* adresse de la ligne du maitre */
        char **ptb_InRecChild  /* adresse de la ligne de l'esclave */
)
{
        DEBUT_FCT("n_ActionLignePrev");

 		  if ( atoi( ptb_InRecChild[PRE_ACY_NF] ) > atoi( Ksz_Balshey) )
         {
               ptb_InRecChild[PRE_ADJCOD_CT] = "0";
         }
	    	  else
         {
               ptb_InRecChild[PRE_ADJCOD_CT] = ptb_InRecOwner[ACC_ADJCOD_CT];
         }
        ptb_InRecChild[PRE_RETCOD_CT] = ptb_InRecOwner[ACC_RETCOD_CT];
        ptb_InRecChild[PRE_DETTRS_CF] = ptb_InRecOwner[ACC_DETTRS_CF];
        // ptb_InRecChild[PRE_ADJSIG_B]  = ptb_InRecOwner[ACC_ADJSIG_B]; On enlève suite à modification du nom du champ
        ptb_InRecChild[PRE_SPIMOD_CT] = ptb_InRecOwner[ACC_SPIMOD_CT];

       if (atoi(ptb_InRecChild[PRE_DETTRS_CF]) > 0)
    {
      ptb_InRecChild[PRE_DETTRS_CF][0]= '2';

      if (atoi(ptb_InRecChild[PRE_LOB_CF]) == 30)
            {
              ptb_InRecChild[PRE_DETTRS_CF][0]= '4';
            }
    }

        n_WriteCols(Kp_PrevFil,ptb_InRecChild,'~',0);

        RETURN_VAL(OK);
}


/*==============================================================================
objet :
        Initialisation du maitre

retour :
        OK
==============================================================================*/
int n_InitAccpar(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitAccpar");

        memset( pbd_Rupt,0,sizeof(T_RUPTURE_VAR) ) ;

        /* ouverture du fichier esclave */
        n_OpenFileAppl ("ESTC2155_I1","rt",&(pbd_Rupt->pf_InputFil));

        pbd_Rupt->n_NbRupture = 1  ;
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1ACCPAR;
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptAccpar;

        pbd_Rupt->n_ActionLigne         = n_ActionLigneAccpar ;

        pbd_Rupt->c_Separ               = '~' ;

        RETURN_VAL(OK);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1

retour :
        0   ---> Pas de rupture
        1   ---> rupture
==============================================================================*/
int n_IsR1ACCPAR(char **ptb_InRec,char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_IsR1ACCPAR");

        if (strcmp(ptb_InRec[ACC_ACMTRS_NT],ptb_InRec_Cur[ACC_ACMTRS_NT])!=0)
                        RETURN_VAL(1);

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere
==============================================================================*/
int n_ActionFirstRuptAccpar ( char **ptb_InRec_Cur)
{
        DEBUT_FCT("n_ActionFirstRuptAccpar");

        /* synchronisation du fichier des previsions */
        n_ProcessingRuptureSyncVar (&bd_RuptPrev, ptb_InRec_Cur) ;

        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction de test de rupture du niveau 1
retour :
        0       ---> Pas de rupture
        < 0     ---> On n'est pas arrive au bloc synchrone
        > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_ConditionSyncPrev(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild  /* adresse de la ligne de l'esclave */
        )
{
        int ret ;

        DEBUT_FCT("n_ConditionSyncPrev");

        if( (ret = strcmp(pbd_InRecOwner[ACC_ACMTRS_NT],pbd_InRecChild[PRE_ACMTRS_NT])) != 0 ) RETURN_VAL(ret);

        RETURN_VAL(0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne des postes regroupes
retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAccpar( char **ptb_InRec_Cur )

{
        DEBUT_FCT("n_ActionLigneAccpar");

        RETURN_VAL(OK);
}

