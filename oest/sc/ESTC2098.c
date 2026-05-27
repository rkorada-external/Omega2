/*==============================================================================
nom de l 'application         : Mise au format fichier PLACEMNT2
nom du source                 : ESTC2098.c
revision                      : $Revision: 1.13 $
date de creation              : 23/11/2015
auteur                        : R. BEN EZZINE
references des specifications : Edition SCOR VIE
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Mise au format LIFSTAREP des donnees des fichiers au format Plac


------------------------------------------------------------------------------
historique des modifications :

  <jj/mm/aaaa>   <auteur>    <description de la modification>
[001] 12/02/2018 sbehague    :spira:60627 Prise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro 
[002] 21/09/2018 sbehague    :spira:60627 Prise en compte de l'assumed family du contrat UWY dans la retro auto pour le calcul des estimations retro 
[003] 08/04/2020 BEL         :spira:60627 Remplacer le champ PLA1_OVRBASIS_NT par " " si il est vide. 
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


/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/

FILE    *Kp_OutputFil;                                                  // pointeur sur le fichier de sortie


T_RUPTURE_VAR       bd_RuptPlac;                                       // gestion rupture sur perimetre
T_RUPTURE_SYNC_VAR  bd_RuptPerim;                                          // gestion synchro Plac-perimetre

int n_InitPlac            (T_RUPTURE_VAR *pbd_Rupt) ;
int n_IsR1Plac            (char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionLignePlac     (char **pbd_InRec_Cur);
int n_ActionPlacPereSansFils(char **ptb_InRec) ;


int n_InitPerim         (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;

int n_ActionLignePerim     (char **ptb_InRecOwner,char **pbd_InRecChild) ;
int n_ConditionSyncPerim   (char **ptb_InRecOwner,char **pbd_InRecChild);

char Ksav_ACCADMTYP_CT[2];
char Ksav_CTRNAT_CT[2];
char Ksav_ACCFAM_CT[2];
char Ksav_CLOFAM_CT[2];




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

    if ( n_OpenFileAppl ("ESTC2098_O1","wt",&Kp_OutputFil) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptPlac */
    if ( n_InitPlac(&bd_RuptPlac) )
        ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptPerim */
    if ( n_InitPerim(&bd_RuptPerim) )
        ExitPgm ( ERR_XX , "" );


    /* lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptPlac) == ERR )
        ExitPgm ( ERR_XX , "" );


    if (n_CloseFileAppl ("ESTC2098_O1",&Kp_OutputFil)== ERR)
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl("ESTC2098_I1",&(bd_RuptPlac.pf_InputFil))== ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2098_I2",&(bd_RuptPerim.pf_InputFil))== ERR)
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
int n_InitPlac(T_RUPTURE_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPlac");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2098_I1","rt",&(pbd_Rupt->pf_InputFil)))
        ExitPgm ( ERR_XX , "" );

    pbd_Rupt->n_NbRupture = 1  ;                                     // [16090]
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plac;                   // Rupture sur CTR_NF/SEC_NF/UWY_NF
    pbd_Rupt->n_ActionLigne         = n_ActionLignePlac ;
    pbd_Rupt->c_Separ               = SEPARATEUR ;

  RETURN_VAL(OK);
}


/*==============================================================================
objet : fonction de test de rupture du niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1Plac(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1Perim");


    if (strcmp(ptb_InRec[PLA1_RETCTR_NF],ptb_InRec_Cur[PLA1_RETCTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PLA1_RETSEC_NF],ptb_InRec_Cur[PLA1_RETSEC_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[PLA1_RETSEC_NF],ptb_InRec_Cur[PLA1_RETSEC_NF])!=0)
        RETURN_VAL(1);
    RETURN_VAL (0);
}




/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlac( char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionLignePlac");

    /* synchronisation du fichier Plac pour chaque ligne */
    n_ProcessingRuptureSyncVar (&bd_RuptPerim, ptb_InRec_Cur) ;

  RETURN_VAL(OK);
}

/*==============================================================================
objet : Initialisation de la synchronisation du maitre avec l'esclave Plac
retour :    OK
==============================================================================*/
int n_InitPerim(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

    DEBUT_FCT("n_InitPerim");

    memset( pbd_Rupt, 0, sizeof(T_RUPTURE_SYNC_VAR) ) ;

    /* ouverture du fichier esclave */
    n_OpenFileAppl ("ESTC2098_I2","rt",&(pbd_Rupt->pf_InputFil));

    pbd_Rupt->n_NbRupture = 0  ;

    /* fonction du test de la ligne du maitre avec l'esclave */
    pbd_Rupt->ConditionEndSync      = n_ConditionSyncPerim ;

    /* fonction d'action sur la ligne courante du fichier esclave */
    pbd_Rupt->n_ActionLigne         = n_ActionLignePerim ;

    /* Pere sans fils */
    pbd_Rupt->n_PereSansFils        = n_ActionPlacPereSansFils;

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
int n_ConditionSyncPerim(
        char **pbd_InRecOwner ,/* adresse de la ligne du maitre */
        char **pbd_InRecChild )/* adresse de la ligne de l'esclave */
{
  int ret;

    DEBUT_FCT("n_ConditionSyncPerim");

    if ( (ret = strcmp(pbd_InRecOwner[PLA1_RETCTR_NF],pbd_InRecChild[PER_CTR_NF])) != 0 )
        RETURN_VAL(ret);
    if ( (ret = strcmp(pbd_InRecOwner[PLA1_RETSEC_NF],pbd_InRecChild[PER_SEC_NF])) != 0 )
        RETURN_VAL(ret);
    if ( (ret = strcmp(pbd_InRecOwner[PLA1_RTY_NF],pbd_InRecChild[PER_UWY_NF])) != 0 )
        RETURN_VAL(ret);

  RETURN_VAL(0);
}

/*==============================================================================
objet : fonction lancee pour chaque ligne du Plac synchronisee avec le perimetre
retour :    OK ---> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerim(char **ptb_InRecOwner ,                      // adresse de la ligne du maitre
                    char **ptb_InRecChild)                      // adresse de la ligne de l'esclave
{

    DEBUT_FCT("n_ActionLignePerim");
    /* Mettre les valeur en variable globale pour les ecrire en pere sans fils dans les valeur placement*/

    strcpy(Ksav_ACCADMTYP_CT , ptb_InRecChild[PER_ACCADMTYP_CT]);
    strcpy(Ksav_CTRNAT_CT    , ptb_InRecChild[PER_CTRNAT_CT]);
    strcpy(Ksav_ACCFAM_CT    , ptb_InRecChild[PER_ACCFAM_CT]);
    strcpy(Ksav_CLOFAM_CT    , ptb_InRecChild[PER_CLOFAM_CT]);
    

    ptb_InRecOwner[PLA1_ACCTYP_CT] = ptb_InRecChild[PER_ACCADMTYP_CT];
    ptb_InRecOwner[PLA1_CTRNAT_CT] = ptb_InRecChild[PER_CTRNAT_CT];
    ptb_InRecOwner[PLA1_ACCFAM_CT] = ptb_InRecChild[PER_ACCFAM_CT];
    ptb_InRecOwner[PLA1_CLOFAM_CT] = ptb_InRecChild[PER_CLOFAM_CT];

    // [003]
    if (strcmp(ptb_InRecOwner[PLA1_OVRBASIS_NT], "") == 0)
        ptb_InRecOwner[PLA1_OVRBASIS_NT] = " ";

    ptb_InRecOwner[PLA1_NBCOL]=0;

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
int n_ActionPlacPereSansFils(char **ptb_InRec)
{
	DEBUT_FCT("n_ActionPlacPereSansFils");


    ptb_InRec[PLA1_ACCTYP_CT] = Ksav_ACCADMTYP_CT;
    ptb_InRec[PLA1_CTRNAT_CT] = Ksav_CTRNAT_CT;
    ptb_InRec[PLA1_ACCFAM_CT] = Ksav_ACCFAM_CT;
    ptb_InRec[PLA1_CLOFAM_CT] = Ksav_CLOFAM_CT;

    // [003]
    if (strcmp(ptb_InRec[PLA1_OVRBASIS_NT], "") == 0)
        ptb_InRec[PLA1_OVRBASIS_NT] = " ";

    ptb_InRec[PLA1_NBCOL]=0;
    n_WriteCols(Kp_OutputFil, ptb_InRec, SEPARATEUR, 0);


	RETURN_VAL (OK);
}
