/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Ventilation des complements previsionnels
nom du source                 : ESTC2138.c
revision                      : $Revision: 1.2 $
date de creation              : 22/07/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Ce traitement ventile les complements des traites de rattachements
        sur les comptes non complets dans les differents traites non cribles
        qui les composent.

                PARTIE : Creation des fichiers de rapprochements

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    15/04/1998   M.HA-THUC	Rajout d'une synchro supplementaire avec le
				fichier des comptes stats.
				On n'ecrit plus en sortie dans les fichiers
				de rapprochements si l'annee de compte est
				statistiquee
------------------------------
  27/03/2008    J. Ribot     SPOT 15219  ASE15 : recompilation des programmes C
------------------------------
  19/01/2010    D.GATIBELZA  [003]  ESTVIE19182 Pouvoir Estimer des Intérêts sur Solde technique dans la grille Estimations  Inventaire
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>


/*-------------------------------------------7--*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define TAILLE_TAB_CIBLE        6000

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

typedef struct{
    BOOL        CIBLE;
    char        SSD_CF[3];
    char        ESB_CF[3];
    char        BALSHEY_NF[5];
    char        BALSHRMTH_NF[3];
    char        BALSHRDAY_NF[3];
    char        TRNCOD_CF[9];
    char        DBLTRNCOD_CF[9];
    char        CTR_NF[10];
    char        END_NT[2];
    char        SEC_NF[3];
    char        UWY_NF[5];
    char        UW_NT[2];
    char        OCCYEA_NF[5];
    char        ACY_NF[5];
    char        SCOSTRMTH_NF[3];
    char        SCOENDMTH_NF[3];
    char        CLM_NF[10];
    char        CUR_CF[4];
    char        AMT_M[22];
    char        CED_NF[6];
    char        BRK_NF[6];
    char        PAY_NF[6];
    char        KEY_NF[5];
    char        ESTCUR_CF[4];
    char        ESTAMT_M[22];
    char        NAT_CF[3];
    char        ACMTRS_NT[5];
    char        ESTCTR_NF[10];
    char        ESTSEC_NF[3];
    char        LOB_CF[3];
    char        SCOEGP_M[22];
    char        ESTCRB_CT[2];
    char        LIFTRTTYP_CF[3];
    char        ACCADMTYP_CT[2];
    char        SECSTS_CT[5];
    char        PRD_NF[5];
    char        SEG_NF[11];
    char        COMACC_B[2];
    char        ADJCOD_CT[10];
    char        RETCOD_CT[10];
    char        DETTRS_CF[10];
    char        ADJSIG_B[2];
    char        ESTUWY_NF[5];
    char        LSTENDMTH_NF[3];
    char        PROPER_N[10];
    char        RTOCTY_CF[10];
    char        SIGMOD_CT[10];
    char        BRKSCOEGP_M[22];
    char        SPIMOD_CT[10];
    int	      	n_AnneeStat;
} TMouvement;

TMouvement      Tab_Cible[TAILLE_TAB_CIBLE];
int             Kn_NbCible;

int	Kn_AnneeStat ;		/* annee statistiquee pour un traite donne */


FILE            *Kp_CompFil;            /* pointeur sur les complements */
FILE            *Kp_GTFil;              /* pointeur sur le fichier GT */
FILE            *Kp_Rappro12Fil;        /* pointeur sur les rapprochements (sortie) */
FILE            *Kp_Rappro34Fil;        /* pointeur sur les rapprochements (sortie) */
FILE            *Kp_Rappro5Fil;         /* pointeur sur les rapprochements (sortie) */

T_RUPTURE_VAR           bd_RuptComp;    /* gestion rupture sur le fichier des complements */
T_RUPTURE_SYNC_VAR      bd_RuptGT;      /* gestion rupture sur GT */
T_RUPTURE_SYNC_VAR      bd_RuptCptStat; /* gestion synchro avec le fichier des comptes stats */


int n_InitComp              (T_RUPTURE_VAR *pbd_Rupt) ;
int n_ActionLigneComp       (char **pbd_InRec_Cur);
int n_IsR1Comp              (char **ptb_InRec, char **ptb_InRec_Cur);
int n_IsR2Comp              (char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptR2Comp (char **ptb_InRec_Cur);

int n_InitGT                ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncGT       ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR1GT                ( char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptR1GT   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_IsR2GT                ( char **ptb_InRec, char **ptb_InRec_Cur);
int n_ActionFirstRuptR2GT   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int n_InitCptStat           ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncCptStat  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLigneCptStat    ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;

int DeterminerCible (int , int);

/*==============================================================================
objet :  point d'entree du programme
retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

    /* Initialisation des signaux */
    InitSig () ;

    if ( n_BeginPgm (argc  ,argv) == ERR )
            ExitPgm ( ERR_XX , "" );

    /* Ouverture des fichiers en sortie */
    if ( n_OpenFileAppl ("ESTC2138_O1","wt",&Kp_Rappro12Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC2138_O2","wt",&Kp_Rappro34Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    if ( n_OpenFileAppl ("ESTC2138_O3","wt",&Kp_Rappro5Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptComp */
    if ( n_InitComp(&bd_RuptComp) )
        ExitPgm ( ERR_XX , "" );

    /* Initialisation de la varible bd_RuptComp */
    if ( n_InitGT(&bd_RuptGT) )
        ExitPgm ( ERR_XX , "" );

	 /* Initialisation de la varible bd_RuptCptStat */
     if ( n_InitCptStat(&bd_RuptCptStat) )
        ExitPgm ( ERR_XX , "" );

    /* Lancement du traitement du fichier */
    if ( n_ProcessingRuptureVar (&bd_RuptComp) == ERR )
        ExitPgm ( ERR_XX , "" );

    /* Fermeture fichier */
    if (n_CloseFileAppl ("ESTC2138_I1",&(bd_RuptComp.pf_InputFil)) == ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2138_I2",&(bd_RuptGT.pf_InputFil)) == ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2138_I3",&(bd_RuptCptStat.pf_InputFil)) == ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2138_O1",&Kp_Rappro12Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2138_O2",&Kp_Rappro34Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    if (n_CloseFileAppl ("ESTC2138_O3",&Kp_Rappro5Fil) == ERR )
        ExitPgm ( ERR_XX , "" );

    if ( n_EndPgm () == ERR )
        ExitPgm ( ERR_XX , "" );

  exit(0) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.
retour : 0
==============================================================================*/
int n_InitComp(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitComp");

    memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

    if ( n_OpenFileAppl ("ESTC2138_I1","rt",&(pbd_Rupt->pf_InputFil)))
        RETURN_VAL (ERR);

    pbd_Rupt->n_NbRupture = 2 ;

    /* Rupture niveau 1 sur Contrat/Section */
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1Comp;

    /* Rupture niveau 2 sur Contrat/Section/Exercice */
    pbd_Rupt->n_ConditionRupture[1] = n_IsR2Comp;
    pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptR2Comp;

    pbd_Rupt->n_ActionLigne = n_ActionLigneComp ;

    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « Liste des affaires » avec
        l’esclave « Mouvement comptable »

retour : OK
==============================================================================*/
int n_InitGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT( "n_InitGT" ) ;

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

    /* ouverture du fichier esclave */
    if ( n_OpenFileAppl( "ESTC2138_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
        return ERR ;

    pbd_Rupt->n_NbRupture = 2 ;

    /********************************************************/
    /* Modifs du 15/04/98 - M.HA-THUC et G.BUISSON 		*/
    /* 1 niveau de rupture supplementaire sur CTR_NF	*/
    /* pour synchro avec le fichier des comptes stats	*/
    /********************************************************/
    /* Rupture niveau 1 sur Contrat traite NC */
    pbd_Rupt->n_ConditionRupture[0] = n_IsR1GT;
    pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptR1GT;

    /* Rupture niveau 2 sur Contrat/Section/Exercice traite NC */
    pbd_Rupt->n_ConditionRupture[1] = n_IsR2GT;
    pbd_Rupt->n_ActionFirst[1] = n_ActionFirstRuptR2GT;

    /* condition de synchro */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncGT ;

    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « GT des traites NC » avec
        l’esclave « fichier des comptes stat »
retour: OK
==============================================================================*/
int n_InitCptStat(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT( "n_InitCptStat" ) ;

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

    /* ouverture du fichier esclave */
    if ( n_OpenFileAppl( "ESTC2138_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
        return ERR ;

    pbd_Rupt->n_NbRupture = 0 ;

    /* condition de synchro */
    pbd_Rupt->ConditionEndSync = n_ConditionSyncCptStat ;

    /* fonction d'action sur la ligne courante */
    pbd_Rupt->n_ActionLigne = n_ActionLigneCptStat ;

    pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1 sur Contrat/Section de rattachement
retour : 0   ---> Pas de rupture
         1   ---> rupture
==============================================================================*/
int n_IsR1Comp(char **ptb_InRec,char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1Comp");

    if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)
        RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 2 sur Contrat/Section/Exercice
        de rattachement
retour : 0   ---> Pas de rupture
         1   ---> rupture
==============================================================================*/
int n_IsR2Comp(char **ptb_InRec,char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR2Comp");

    if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF])!=0)
        RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 1 sur Contrat de traite non crible
retour : 0   ---> Pas de rupture
         1   ---> rupture
==============================================================================*/
int n_IsR1GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR1GT");

    if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
        RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de rupture de niveau 2 sur Contrat/Section/Exercice
        de traite non crible
retour : 0   ---> Pas de rupture
         1   ---> rupture
==============================================================================*/
int n_IsR2GT(char **ptb_InRec,char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_IsR2GT");

    if (strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF])!=0)
        RETURN_VAL(1);
    if (strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF])!=0)
        RETURN_VAL(1);

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :  0     ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
//        ligne du maitre: Liste des affaires, de l'esclave : Mouvement comptable
int n_ConditionSyncGT( char **pbd_InRecOwner , char **pbd_InRecChild  )        
{
  int ret ;

    DEBUT_FCT( "n_ConditionSyncGT" ) ;

    if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[GT_ESTCTR_NF] ) ) != 0 )
        return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_SEC_NF], pbd_InRecChild[GT_ESTSEC_NF] ) ) != 0 )
        return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : Fonction lancee en rupture premiere de niveau 1
==============================================================================*/
int n_ActionFirstRuptR1GT    ( char **ptb_InRecOwner, char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionFirstRuptR1GT");

    /* initialisation de l'annee statistiquee */
    Kn_AnneeStat = 0 ;

    /* synchronisation avec le fichier des comptes statistiques */
    n_ProcessingRuptureSyncVar( &bd_RuptCptStat, ptb_InRecChild ) ;

  RETURN_VAL(0);
}


/*==============================================================================
objet :
        Fonction lancee en rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRuptR2GT    ( char **ptb_InRecOwner, char **ptb_InRecChild )
{
  char MsgAno[300];

    DEBUT_FCT("n_ActionFirstRuptR2GT");

    if ( Kn_NbCible >= TAILLE_TAB_CIBLE )
    {
        /* depassement tableau */
        sprintf(MsgAno,"The number of contrats for fictitious contract (/CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program's storage capacity",
            ptb_InRecOwner[GT_CTR_NF],
            ptb_InRecOwner[GT_END_NT],
            ptb_InRecOwner[GT_SEC_NF],
            ptb_InRecOwner[GT_UWY_NF],
            ptb_InRecOwner[GT_UW_NT]);

        n_WriteAno(MsgAno);
        RETURN_VAL(0);
    }

    /* memorisation dans le tableau cible */
    strcpy(Tab_Cible[Kn_NbCible].SSD_CF , ptb_InRecChild[GT_SSD_CF]);
    strcpy(Tab_Cible[Kn_NbCible].ESB_CF , ptb_InRecChild[GT_ESB_CF]);
    strcpy(Tab_Cible[Kn_NbCible].BALSHEY_NF , ptb_InRecChild[GT_BALSHEY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].BALSHRMTH_NF , ptb_InRecChild[GT_BALSHRMTH_NF]);
    strcpy(Tab_Cible[Kn_NbCible].BALSHRDAY_NF , ptb_InRecChild[GT_BALSHRDAY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].TRNCOD_CF , ptb_InRecChild[GT_TRNCOD_CF]);
    strcpy(Tab_Cible[Kn_NbCible].DBLTRNCOD_CF , ptb_InRecChild[GT_DBLTRNCOD_CF]);
    strcpy(Tab_Cible[Kn_NbCible].CTR_NF , ptb_InRecChild[GT_CTR_NF]);
    strcpy(Tab_Cible[Kn_NbCible].END_NT , ptb_InRecChild[GT_END_NT]);
    strcpy(Tab_Cible[Kn_NbCible].SEC_NF , ptb_InRecChild[GT_SEC_NF]);
    strcpy(Tab_Cible[Kn_NbCible].UWY_NF , ptb_InRecChild[GT_UWY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].UW_NT , ptb_InRecChild[GT_UW_NT]);
    strcpy(Tab_Cible[Kn_NbCible].OCCYEA_NF , ptb_InRecChild[GT_OCCYEA_NF]);
    strcpy(Tab_Cible[Kn_NbCible].ACY_NF , ptb_InRecChild[GT_ACY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].SCOSTRMTH_NF,ptb_InRecChild[GT_SCOSTRMTH_NF]);
    strcpy(Tab_Cible[Kn_NbCible].SCOENDMTH_NF,ptb_InRecChild[GT_SCOENDMTH_NF]);
    strcpy(Tab_Cible[Kn_NbCible].CLM_NF , ptb_InRecChild[GT_CLM_NF]);
    strcpy(Tab_Cible[Kn_NbCible].CUR_CF , ptb_InRecChild[GT_CUR_CF]);
    strcpy(Tab_Cible[Kn_NbCible].AMT_M , ptb_InRecChild[GT_AMT_M]);
    strcpy(Tab_Cible[Kn_NbCible].CED_NF , ptb_InRecChild[GT_CED_NF]);
    strcpy(Tab_Cible[Kn_NbCible].BRK_NF , ptb_InRecChild[GT_BRK_NF]);
    strcpy(Tab_Cible[Kn_NbCible].PAY_NF , ptb_InRecChild[GT_PAY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].KEY_NF , ptb_InRecChild[GT_KEY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].ESTCUR_CF , ptb_InRecChild[GT_ESTCUR_CF]);
    strcpy(Tab_Cible[Kn_NbCible].ESTAMT_M , ptb_InRecChild[GT_ESTAMT_M]);
    strcpy(Tab_Cible[Kn_NbCible].NAT_CF , ptb_InRecChild[GT_NAT_CF]);
    strcpy(Tab_Cible[Kn_NbCible].ACMTRS_NT , ptb_InRecChild[GT_ACMTRS_NT]);
    strcpy(Tab_Cible[Kn_NbCible].ESTCTR_NF , ptb_InRecChild[GT_ESTCTR_NF]);
    strcpy(Tab_Cible[Kn_NbCible].ESTSEC_NF , ptb_InRecChild[GT_ESTSEC_NF]);
    strcpy(Tab_Cible[Kn_NbCible].LOB_CF , ptb_InRecChild[GT_LOB_CF]);
    strcpy(Tab_Cible[Kn_NbCible].SCOEGP_M , ptb_InRecChild[GT_SCOEGP_M]);
    strcpy(Tab_Cible[Kn_NbCible].ESTCRB_CT , ptb_InRecChild[GT_ESTCRB_CT]);
    strcpy(Tab_Cible[Kn_NbCible].LIFTRTTYP_CF,ptb_InRecChild[GT_LIFTRTTYP_CF]);
    strcpy(Tab_Cible[Kn_NbCible].ACCADMTYP_CT,ptb_InRecChild[GT_ACCADMTYP_CT]);
    strcpy(Tab_Cible[Kn_NbCible].SECSTS_CT , ptb_InRecChild[GT_SECSTS_CT]);
    strcpy(Tab_Cible[Kn_NbCible].PRD_NF , ptb_InRecChild[GT_PRD_NF]);
    strcpy(Tab_Cible[Kn_NbCible].SEG_NF , ptb_InRecChild[GT_SEG_NF]);
    strcpy(Tab_Cible[Kn_NbCible].COMACC_B , ptb_InRecChild[GT_COMACC_B]);
    strcpy(Tab_Cible[Kn_NbCible].ADJCOD_CT , ptb_InRecChild[GT_ADJCOD_CT]);
    strcpy(Tab_Cible[Kn_NbCible].RETCOD_CT , ptb_InRecChild[GT_RETCOD_CT]);
    strcpy(Tab_Cible[Kn_NbCible].DETTRS_CF , ptb_InRecChild[GT_DETTRS_CF]);
    strcpy(Tab_Cible[Kn_NbCible].ADJSIG_B , ptb_InRecChild[GT_ADJSIG_B]);
    strcpy(Tab_Cible[Kn_NbCible].ESTUWY_NF,ptb_InRecChild[GT_UWY_NF]);
    strcpy(Tab_Cible[Kn_NbCible].LSTENDMTH_NF,ptb_InRecChild[GT_LSTENDMTH_NF]);
    strcpy(Tab_Cible[Kn_NbCible].PROPER_N,ptb_InRecChild[GT_PROPER_N]);
    strcpy(Tab_Cible[Kn_NbCible].SPIMOD_CT , ptb_InRecChild[GT_SPIMOD_CT]);
	Tab_Cible[Kn_NbCible].n_AnneeStat = Kn_AnneeStat;       // Ajout 29/11/98
    strcpy(Tab_Cible[Kn_NbCible].RTOCTY_CF , ptb_InRecChild[GT_RTOCTY_CF]);
    if ( b_IsBlankOrEmpty(ptb_InRecChild[GT_PRD_NF]) == TRUE )
        strcpy(Tab_Cible[Kn_NbCible].BRKSCOEGP_M , "0");
    else
        strcpy(Tab_Cible[Kn_NbCible].BRKSCOEGP_M , ptb_InRecChild[GT_SCOEGP_M]);

    Kn_NbCible++;

  RETURN_VAL(0);
}


/*==============================================================================
objet :
        Fonction lancee a chaque rupture premiere de niveau 2
==============================================================================*/
int n_ActionFirstRuptR2Comp (char **ptb_InRec_Cur)
{
    DEBUT_FCT("n_ActionFirstRuptR2Comp");

    /* si rupture premiere, lancement de la synchro */
    if ( b_IsRupture(&bd_RuptComp, F1) == TRUE )
    {
        /* initialisation indice tableau */
        Kn_NbCible = 0;

        /* synchronisation du fichier mouvement comptable pour chaque ligne */
        n_ProcessingRuptureSyncVar( &bd_RuptGT, ptb_InRec_Cur ) ;
    }

    /* determination des cibles de ventilations */
    if (Kn_NbCible != 0)
        DeterminerCible (atoi(ptb_InRec_Cur[GT_UWY_NF]),atoi(ptb_InRec_Cur[GT_ACY_NF]));

  RETURN_VAL(0);
}


/*==============================================================================
objet : fonction lancee pour chaque ligne du maitre
retour : 0 ----> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneComp(char **ptb_InRec_Cur)
{
  FILE *Kp_Rapprochement;
  int resultat;
  int i;

    DEBUT_FCT("n_ActionLigneComp");

    /* mode de ventilation */
    resultat = atoi(ptb_InRec_Cur[GT_SPIMOD_CT]);

    /* aiguillage selon le mode de ventilation */
    switch ( resultat )
    {
        case 1:
            Kp_Rapprochement = Kp_Rappro12Fil;
            break;
        case 2:
            Kp_Rapprochement = Kp_Rappro12Fil;
            break;
        case 3:
            Kp_Rapprochement = Kp_Rappro34Fil;
            break;
        case 4:
            Kp_Rapprochement = Kp_Rappro34Fil;
            break;
        case 5:
            Kp_Rapprochement = Kp_Rappro5Fil;
            break;
        default:
            return (OK) ;
    }

    /* chaque complement genere une ligne de rapprochement par ligne du tableau Cible */
    for (i=0; i<Kn_NbCible; i++)
    {
        /* selection des cibles */
        if (Tab_Cible[i].CIBLE == FALSE) continue;

        fprintf(Kp_Rapprochement, "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                Tab_Cible[i].SSD_CF,
                Tab_Cible[i].ESB_CF,
                Tab_Cible[i].BALSHEY_NF,
                Tab_Cible[i].BALSHRMTH_NF,
                Tab_Cible[i].BALSHRDAY_NF,
                ptb_InRec_Cur[GT_TRNCOD_CF],
                Tab_Cible[i].DBLTRNCOD_CF,
                Tab_Cible[i].CTR_NF,
                Tab_Cible[i].END_NT,
                Tab_Cible[i].SEC_NF,
                Tab_Cible[i].UWY_NF,
                Tab_Cible[i].UW_NT,
                Tab_Cible[i].OCCYEA_NF,
                ptb_InRec_Cur[GT_ACY_NF],
                Tab_Cible[i].SCOSTRMTH_NF,
                Tab_Cible[i].SCOENDMTH_NF,
                Tab_Cible[i].CLM_NF,
                Tab_Cible[i].CUR_CF,
                ptb_InRec_Cur[GT_AMT_M],
                Tab_Cible[i].CED_NF,
                Tab_Cible[i].BRK_NF,
                Tab_Cible[i].PAY_NF,
                Tab_Cible[i].KEY_NF,
                "",  "",  "", "", "",            /* partie retrocessionnaire */
                "",  "",  "", "", "",
                "",  "",  "", "", "",
                "", "",
                Tab_Cible[i].ESTCUR_CF,
                Tab_Cible[i].ESTAMT_M,
                Tab_Cible[i].NAT_CF,
                ptb_InRec_Cur[GT_ACMTRS_NT],
                Tab_Cible[i].ESTCTR_NF,
                Tab_Cible[i].ESTSEC_NF,
                Tab_Cible[i].LOB_CF,
                Tab_Cible[i].SCOEGP_M,
                Tab_Cible[i].ESTCRB_CT,
                Tab_Cible[i].LIFTRTTYP_CF,
                Tab_Cible[i].ACCADMTYP_CT,
                Tab_Cible[i].SECSTS_CT,
                Tab_Cible[i].PRD_NF,
                Tab_Cible[i].SEG_NF,
                Tab_Cible[i].COMACC_B,
                Tab_Cible[i].ADJCOD_CT,
                Tab_Cible[i].RETCOD_CT,
                Tab_Cible[i].DETTRS_CF,
                Tab_Cible[i].ADJSIG_B,
                ptb_InRec_Cur[GT_UWY_NF],
                Tab_Cible[i].LSTENDMTH_NF,
                Tab_Cible[i].PROPER_N,
                Tab_Cible[i].RTOCTY_CF,
                ptb_InRec_Cur[GT_SPIMOD_CT],
                Tab_Cible[i].BRKSCOEGP_M
                );

    }

  RETURN_VAL (0);
}


/*==============================================================================
objet :
        fonction de test de synchronisation
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalite de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
                 // adresse de la ligne du maitre, de l'esclave */
int n_ConditionSyncCptStat( char **pbd_InRecOwner, char **pbd_InRecChild )
{
  int ret ;

    DEBUT_FCT( "n_ConditionSyncCptStat" ) ;
    if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[CMP_CTR_NF] ) ) != 0 )
        return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne de l'esclave
retour :    0 ----> traitement correctement effectue
            ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneCptStat(char **ptb_InRecOwner, char **pbd_InRecChild)
{
    DEBUT_FCT("n_ActionLigneCptStat");

    /* recherche de l'annee statistiquee */
    if ( atoi( pbd_InRecChild[CMP_ACY_NF] ) > Kn_AnneeStat )
        Kn_AnneeStat = atoi( pbd_InRecChild[CMP_ACY_NF] ) ;

  RETURN_VAL (0);
}


/*==============================================================================
objet : fonction affectant le champ cible en fonction de l'exercice de rattachement,
        de l'exercice du traite non cible et de la resilation

entree : exercice de rattachement, indice du tableau
retour : affecte le champ cible de l'enregistrements donne par l'indice

Modifs du 15/04/98 - M.HA-THUC et G.BUISSON
Une condition supplementaire a ete rajoute pour la mise a jour du champs cible ->
si l'annee de compte n'est pas statistiquee

==============================================================================*/
void AffecterCible (int exercice, int indice, int acy)
{
    if ( ( (exercice == atoi(Tab_Cible[indice].UWY_NF)) || (atoi(Tab_Cible[indice].SECSTS_CT) == 19) )      &&
         acy > Tab_Cible[indice].n_AnneeStat  && atoi(Tab_Cible[indice].ADJCOD_CT) != 9 )
        Tab_Cible[indice].CIBLE = TRUE;
}


/*==============================================================================
objet : fonction determinant les cibles par contrat/section de rattachement
entree : exercice de rattachement
retour : affecte les champs cible des enregistrements du tableau Detail.

==============================================================================*/
int DeterminerCible (int exercice, int acy)
{
  char contrat[10];
  int section = -1;
  int i;

    DEBUT_FCT("DeterminerCible");

    strcpy(contrat, "");
    /* mise a faux du flag de tous les contrats non cribles */
    for (i=0; i<Kn_NbCible; i++)
        Tab_Cible[i].CIBLE = FALSE;

    /* recherche du dernier exercice */
    for (i=(Kn_NbCible-1); i>=0; i--)
    {
        if (atoi(Tab_Cible[i].UWY_NF) <= exercice )
        {
            AffecterCible (exercice, i,acy);
            strcpy(contrat, Tab_Cible[i].CTR_NF);
            section = atoi(Tab_Cible[i].SEC_NF);
        }
    }

  RETURN_VAL (0);
}


// Ne sert pas
//[003]/*==============================================================================
//[003]objet :
//[003]        fonction de calcul du mode de ventilation
//[003]
//[003]entree : poste comptable
//[003]retour : mode de ventilation
//[003]==============================================================================*/
//[003]int CalculModeVentilation (int poste_comptable)
//[003]{
//[003]    DEBUT_FCT("CalculModeVentilation");
//[003]
//[003]    switch (poste_comptable) {
//[003]        case 1140: RETURN_VAL (1);                              /* charges */
//[003]        case 1160: RETURN_VAL (1);
//[003]        case 1010: RETURN_VAL (1);                              /* primes */
//[003]        case 1022: RETURN_VAL (1);                              /* entree portefeuille */
//[003]        case 1232: RETURN_VAL (1);
//[003]        case 1200: RETURN_VAL (1);                              /* sinistres */
//[003]        case 1210: RETURN_VAL (1);
//[003]        case 1220: RETURN_VAL (1);
//[003]        case 1100: RETURN_VAL (2);                              /* courtage */
//[003]        case 1021: RETURN_VAL (3);                              /* retrait de portefeuille */
//[003]        case 1231: RETURN_VAL (3);
//[003]        case 1123: RETURN_VAL (4);                              /* FAR courtage */
//[003]        case 1124: RETURN_VAL (4);
//[003]        case 1340: RETURN_VAL (5);                              /* Interet sur depot */
//[003]        case 1350: RETURN_VAL (5);                              //[003] Int. Payé/Solde technique
//[003]        case 1360: RETURN_VAL (5);                              //[003] Int. Reçu/Solde technique
//[003]        default: if ( (poste_comptable % 10) == 3) RETURN_VAL (3);       /* constitutions */
//[003]                  break;
//[003]    }
//[003]    RETURN_VAL (-1);
//[003]}

