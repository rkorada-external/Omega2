/*==============================================================================
nom de l 'application         : Syncro des CC avec FPLACMNT2
nom du source                 : ESTC2099.c
revision                      : $Revision: 1.13 $
date de creation              : 13/04/2016
auteur                        : S. ASKRI
references des specifications : Edition SCOR VIE
squelette de base             : batch
------------------------------------------------------------------------------
description :
   synchronisation du fichier PLAC avec le Estimation


------------------------------------------------------------------------------
historique des modifications :

  <jj/mm/aaaa>   <auteur>    <description de la modification>

==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include <estserv.h>


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
/* structure du fichier commum avec estimation */
#include <struct.h>

#define PLA1_ACCADMTYP_CT 33
/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

FILE    *Kp_OutputFil;
FILE    *Kp_OutputSAV;


T_RUPTURE_VAR       bd_RuptPrev;                                       // gestion rupture sur perimetre
T_RUPTURE_SYNC_VAR  bd_RuptPlac;                                          // gestion synchro Plac-perimetre

int n_InitPrev            (T_RUPTURE_VAR *pbd_Rupt) ;
int n_IsR1Prev            (char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLignePrev     (char **pbd_InRec_Cur);
int n_ActionPereSansFils(char **ptb_InRec) ;


int n_InitPlac            (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_ActionLignePlac     (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPlac   (char **ptb_InRecOwner,char **pbd_InRecChild);


char Ksav_CESSH_R[16];

/*==============================================================================
objet : point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()

==============================================================================*/
int main(int argc ,char *argv[])
{

  /* Initialisation des signaux */
  InitSig ();

    if ( n_BeginPgm (argc  ,argv) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* ouverture des fichiers */

    if ( n_OpenFileAppl ("ESTC2095_O1","wt",&Kp_OutputFil) == ERR )             ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC2095_O2","wt",&Kp_OutputSAV) == ERR )             ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptPrev */
    if ( n_InitPrev(&bd_RuptPrev) )                                             ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptPlac */
    if ( n_InitPlac(&bd_RuptPlac) )                                             ExitPgm ( ERR_XX , "" );

    /* lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptPrev) == ERR )                         ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2095_O1",&Kp_OutputFil)== ERR)                    ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2095_O2",&Kp_OutputSAV)== ERR)                    ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl("ESTC2095_I1",&(bd_RuptPrev.pf_InputFil))== ERR )       ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2095_I2",&(bd_RuptPlac.pf_InputFil))== ERR)       ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )                                                   ExitPgm ( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        OK
==============================================================================*/
int n_InitPrev(T_RUPTURE_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPrev");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2095_I1","rt",&(pbd_Rupt->pf_InputFil)))
        ExitPgm ( ERR_XX , "" );

    pbd_Rupt->n_NbRupture = 1  ;                                     // [16090]
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Prev;                   // Rupture sur CTR_NF/SEC_NF/UWY_NF
    pbd_Rupt->n_ActionLigne         = n_ActionLignePrev ;
    pbd_Rupt->c_Separ               = SEPARATEUR ;

  RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Prev(char **ptb_InRec,char **ptb_InRec_Cur)
{
       DEBUT_FCT("n_IsR1Prev");

    if (strcmp(ptb_InRec[PRE_CTR_NF],ptb_InRec_Cur[PRE_CTR_NF])!=0)           RETURN_VAL(1);

    RETURN_VAL (0);
}




/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrev( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePrev");

    /* synchronisation du fichier Plac pour chaque ligne */
    n_ProcessingRuptureSyncVar (&bd_RuptPlac, ptb_InRec_Cur) ;

  RETURN_VAL(OK);
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Plac
retour :    OK
==============================================================================*/
int n_InitPlac(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPlac");

    memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier esclave */
    n_OpenFileAppl ("ESTC2095_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0  ;

    /* fonction du test de la ligne du maitre avec l'esclave */
    pbd_Rupt->ConditionEndSync      = n_ConditionSyncPlac ;

    /* fonction d'action sur la ligne courante du fichier esclave */
    pbd_Rupt->n_ActionLigne         = n_ActionLignePlac ;

    /* Pere sans fils */
    pbd_Rupt->n_PereSansFils        = n_ActionPereSansFils;

    pbd_Rupt->c_Separ       = SEPARATEUR ;

  RETURN_VAL(OK);
}

/*==============================================================================
objet : fonction de test de rupture du niveau 1
retour :    0       ---> pbd_InRecOwner = pbd_InRecChild
                        ( egalite de rubriques a synchroniser)
            > 0     ---> pbd_InRecOwne> > pbd_InRecChild
            < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPlac(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild )/* adresse de la ligne de l'esclave */
{
  int ret;

    DEBUT_FCT("n_ConditionSyncPlac");

    if ( (ret = strcmp(pbd_InRecOwner[PRE_CTR_NF],pbd_InRecChild[PLA1_CTR_NF])) != 0 )
        RETURN_VAL(ret);

  RETURN_VAL(0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne du Plac synchronisee avec le perimetre
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlac(char **ptb_InRecOwner ,                      // adresse de la ligne du maitre
                    char **ptb_InRecChild)                      // adresse de la ligne de l'esclave
{

    DEBUT_FCT("n_ActionLignePlac");


    /* extraire les CTR Retro*/
    n_WriteCols(Kp_OutputFil, ptb_InRecOwner, SEPARATEUR, 0);

  RETURN_VAL(OK);
}


/*==============================================================================
objet :
        fonction lancee quand le fichier prevision participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{
	DEBUT_FCT("n_ActionPrevPereSansFils");

//printf("here %s", ptb_InRec[PRE_CTR_NF]);
   /* CTR CC*/
   n_WriteCols(Kp_OutputSAV, ptb_InRec, SEPARATEUR, 0);

	RETURN_VAL (OK);
}
