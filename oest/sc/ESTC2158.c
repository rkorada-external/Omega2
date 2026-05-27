/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Rapprochement entre fichiers SRGTE
nom du source                 : ESTC2158.c
revision                      : $Revision: 1.2 $
date de creation              : 11/10/2004
auteur                        : J. Ribot
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Rapprochement entre le fichier SRGTE et le fichier SRGTE issue RETRO INTERNE.

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C

==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <ESTC2158.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define TAILLE_MAX_TAB          500

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE            *Kp_ComprevFil;         /* pointeur sur le SRGTE sortie */
FILE            *Kp_MvtFil;             /* pointeur sur le fichier SRGTE issue RETRO INTERNE */
FILE            *Kp_RappFil;            /* pointeur sur le fichier SRGTE */

T_RUPTURE_VAR           bd_RuptRapp;    /* gestion rupture sur le fichier SRGTE */
T_RUPTURE_SYNC_VAR      bd_RuptMvt;     /* gestion rupture sur le fichier SRGTE issue RETRO INTERNE  */


int n_InitRapp(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRapp(char **pbd_InRec_Cur);
int n_ActionPereSansFils(char **ptb_InRec);
int n_ActionFilsSansPere (char **ptb_InRec_Cur);

int n_InitMvt           ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ConditionSyncMvt  ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ActionLigneMvt    ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;



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

        /* Ouverture des fichiers en sortie */
        if ( n_OpenFileAppl ("ESTC2158_O1","wt",&Kp_ComprevFil) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptRapp */
        if ( n_InitRapp(&bd_RuptRapp) )
                ExitPgm ( ERR_XX , "" );

        /* Initialisation de la varible bd_RuptMvt */
        if ( n_InitMvt(&bd_RuptMvt) )
                ExitPgm ( ERR_XX , "" );

        /* Lancement du traitement du fichier */
        if ( n_ProcessingRuptureVar (&bd_RuptRapp) == ERR )
                ExitPgm ( ERR_XX , "" );

        /* Fermeture fichier */
        if (n_CloseFileAppl ("ESTC2158_I1",&(bd_RuptRapp.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2158_I2",&(bd_RuptMvt.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2158_O1",&Kp_ComprevFil))
                ExitPgm ( ERR_XX , "" );

        if ( n_EndPgm () == ERR )
                ExitPgm ( ERR_XX , "" );

        exit(0) ;
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du
        fichier maitre.

retour :
        0
==============================================================================*/
int n_InitRapp(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT("n_InitRapp");

        memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

        if ( n_OpenFileAppl ("ESTC2158_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 0 ;
        pbd_Rupt->n_ActionLigne = n_ActionLigneRapp ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre « SRGTE » avec
        l’esclave « SRGTE RETRO INTERNE »

retour :
        OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

        DEBUT_FCT( "n_InitMvt" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESTC2158_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR ;

        pbd_Rupt->n_NbRupture = 0 ;

        /* condition de synchro */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;
        pbd_Rupt->n_PereSansFils   = n_ActionPereSansFils;

        /* fonction d'action sur la ligne courante du fichier SRGTE issue RETRO INTERNE */
        pbd_Rupt->n_ActionLigne = n_ActionLigneMvt ;

        pbd_Rupt->n_FilsSansPere        = n_ActionFilsSansPere;


        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction de test de synchronisation
retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild
        > 0     ---> pbd_InRecOwner > pbd_InRecChild
        < 0     ---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncMvt(
        char **pbd_InRecOwner ,         /* adresse de la ligne du maitre  */
        char **pbd_InRecChild  )        /* adresse de la ligne de l'esclave  */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncMvt" ) ;
/*
printf("n_ConditionSyncMvt GT258_CTR_NF [%s] GT258_CTR_NF [%s]\n",
                                  pbd_InRecOwner[GT2158_CTR_NF], pbd_InRecChild[GT2158_CTR_NF]);
printf("n_ConditionSyncMvt GT2158_SEC_NF [%s] GT2158_SEC_NF [%s]\n",
                                  pbd_InRecOwner[GT2158_SEC_NF], pbd_InRecChild[GT2158_SEC_NF]);
printf("n_ConditionSyncMvt GT2158_UWY_NF [%s] GT2158_UWY_NF [%s]\n",
                                  pbd_InRecOwner[GT2158_UWY_NF], pbd_InRecChild[GT2158_UWY_NF]);
printf("n_ConditionSyncMvt GT2158_ACY_NF [%s] GT2158_ACY_NF [%s]\n",
                                  pbd_InRecOwner[GT2158_ACY_NF], pbd_InRecChild[GT2158_ACY_NF]);
printf("n_ConditionSyncMvt GT2158_ACMTRS_NT [%s] GT2158_ACMTRS_NT [%s], %d\n",
                                  pbd_InRecOwner[GT2158_ACMTRS_NT], pbd_InRecChild[GT2158_ACMTRS_NT], GT2158_ACMTRS_NT);
*/
        if ( ( ret = strcmp( pbd_InRecOwner[GT2158_CTR_NF], pbd_InRecChild[GT2158_CTR_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT2158_SEC_NF], pbd_InRecChild[GT2158_SEC_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT2158_UWY_NF], pbd_InRecChild[GT2158_UWY_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT2158_ACY_NF], pbd_InRecChild[GT2158_ACY_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT2158_ACMTRS_NT], pbd_InRecChild[GT2158_ACMTRS_NT] ) ) != 0 )
                return ret ;

        RETURN_VAL( 0 ) ;
}



/*==============================================================================
objet :
        fonction lancee quand le fichier SRGTE  participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{

        DEBUT_FCT("n_ActionPereSansFils");
// printf("n_ActionPereSansFils..[%s]\n", ptb_InRec[GT2158_CTR_NF]);

        //                        1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65
        fprintf(Kp_ComprevFil,  "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                ptb_InRec[GT2158_SSD_CF],
                ptb_InRec[GT2158_ESB_CF],
                ptb_InRec[GT2158_BALSHEY_NF],
                ptb_InRec[GT2158_BALSHRMTH_NF],
                ptb_InRec[GT2158_BALSHRDAY_NF],
                ptb_InRec[GT2158_TRNCOD_CF],
                ptb_InRec[GT2158_DBLTRNCOD_CF],
                ptb_InRec[GT2158_CTR_NF],
                ptb_InRec[GT2158_END_NT],
                ptb_InRec[GT2158_SEC_NF],
                ptb_InRec[GT2158_UWY_NF],
                ptb_InRec[GT2158_UW_NT],
                ptb_InRec[GT2158_OCCYEA_NF],
                ptb_InRec[GT2158_ACY_NF],
                ptb_InRec[GT2158_SCOSTRMTH_NF],
                ptb_InRec[GT2158_SCOENDMTH_NF],
                ptb_InRec[GT2158_CLM_NF],
                ptb_InRec[GT2158_CUR_CF],
                ptb_InRec[GT2158_AMT_M],
                ptb_InRec[GT2158_CED_NF],
                ptb_InRec[GT2158_BRK_NF],
                ptb_InRec[GT2158_PAY_NF],
                ptb_InRec[GT2158_KEY_NF],
                ptb_InRec[GT2158_RETCTR_NF],
                ptb_InRec[GT2158_RETEND_NT],
                ptb_InRec[GT2158_RETSEC_NF],
                ptb_InRec[GT2158_RTY_NF],
                ptb_InRec[GT2158_RETUW_NT],
                ptb_InRec[GT2158_RETOCCYEA_NF],
                ptb_InRec[GT2158_RETACY_NF],
                ptb_InRec[GT2158_RETSCOSTRMTH_NF],
                ptb_InRec[GT2158_RETSCOENDMTH_NF],
                ptb_InRec[GT2158_RCL_NF],
                ptb_InRec[GT2158_RETCUR_CF],
                ptb_InRec[GT2158_RETAMT_M],
                ptb_InRec[GT2158_PLC_NT],
                ptb_InRec[GT2158_RTO_NF],
                ptb_InRec[GT2158_INT_NF],
                ptb_InRec[GT2158_RETPAY_NF],
                ptb_InRec[GT2158_RETKEY_CF],
//                ptb_InRec[GT2158_RETINTAMT_M],
                ptb_InRec[GT2158_ESTCUR_CF],
                ptb_InRec[GT2158_ESTAMT_M],
                ptb_InRec[GT2158_NAT_CF],
                ptb_InRec[GT2158_ACMTRS_NT],
                ptb_InRec[GT2158_ESTCTR_NF],
                ptb_InRec[GT2158_ESTSEC_NF],
                ptb_InRec[GT2158_LOB_CF],
                ptb_InRec[GT2158_SCOEGP_M],
                ptb_InRec[GT2158_ESTCRB_CT],
                ptb_InRec[GT2158_LIFTRTTYP_CF],
                ptb_InRec[GT2158_ACCADMTYP_CT],
                ptb_InRec[GT2158_SECSTS_CT],
                ptb_InRec[GT2158_PRD_NF],
                ptb_InRec[GT2158_SEG_NF],
                ptb_InRec[GT2158_COMACC_B],
                ptb_InRec[GT2158_ADJCOD_CT],
                ptb_InRec[GT2158_RETCOD_CT],
                ptb_InRec[GT2158_DETTRS_CF],
                ptb_InRec[GT2158_ADJSIG_B],
                ptb_InRec[GT2158_ESTUWY_NF],
                ptb_InRec[GT2158_LSTENDMTH_NF],
                ptb_InRec[GT2158_PROPER_N],
                ptb_InRec[GT2158_RTOCTY_CF],
                ptb_InRec[GT2158_SPIMOD_CT],
                ptb_InRec[GT2158_BRKSCOEGP_M],
                ptb_InRec[GT2158_UWGRP_CF]
                );
        RETURN_VAL(0);
}



/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :
        0 ----> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneRapp(char **ptb_InRec_Cur)
{

        DEBUT_FCT("n_ActionLigneRapp");

        /* lancement synchro */
        n_ProcessingRuptureSyncVar( &bd_RuptMvt, ptb_InRec_Cur ) ;

        RETURN_VAL (0);
}



/*==============================================================================
objet :
      Fonction lancee a chaque synchro entre SRGTE et SRGTE ISSUE RETRO INTERNE
==============================================================================*/
int n_ActionLigneMvt ( char **ptb_InRecOwner, char **ptb_InRecChild )
{

    DEBUT_FCT("n_ActionLigneGT");

// printf("n_ActionLigneGT..[%s]\n", ptb_InRecChild[GT2158_CTR_NF]);
    /*  */


        fprintf(Kp_ComprevFil,  "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                ptb_InRecChild[GT2158_SSD_CF],
                ptb_InRecChild[GT2158_ESB_CF],
                ptb_InRecChild[GT2158_BALSHEY_NF],
                ptb_InRecChild[GT2158_BALSHRMTH_NF],
                ptb_InRecChild[GT2158_BALSHRDAY_NF],
                ptb_InRecChild[GT2158_TRNCOD_CF],
                ptb_InRecChild[GT2158_DBLTRNCOD_CF],
                ptb_InRecChild[GT2158_CTR_NF],
                ptb_InRecChild[GT2158_END_NT],
                ptb_InRecChild[GT2158_SEC_NF],
                ptb_InRecChild[GT2158_UWY_NF],
                ptb_InRecChild[GT2158_UW_NT],
                ptb_InRecChild[GT2158_OCCYEA_NF],
                ptb_InRecChild[GT2158_ACY_NF],
                ptb_InRecChild[GT2158_SCOSTRMTH_NF],
                ptb_InRecChild[GT2158_SCOENDMTH_NF],
                ptb_InRecChild[GT2158_CLM_NF],
                ptb_InRecChild[GT2158_CUR_CF],
                ptb_InRecChild[GT2158_AMT_M],
                ptb_InRecChild[GT2158_CED_NF],
                ptb_InRecChild[GT2158_BRK_NF],
                ptb_InRecChild[GT2158_PAY_NF],
                ptb_InRecChild[GT2158_KEY_NF],
                ptb_InRecChild[GT2158_RETCTR_NF],
                ptb_InRecChild[GT2158_RETEND_NT],
                ptb_InRecChild[GT2158_RETSEC_NF],
                ptb_InRecChild[GT2158_RTY_NF],
                ptb_InRecChild[GT2158_RETUW_NT],
                ptb_InRecChild[GT2158_RETOCCYEA_NF],
                ptb_InRecChild[GT2158_RETACY_NF],
                ptb_InRecChild[GT2158_RETSCOSTRMTH_NF],
                ptb_InRecChild[GT2158_RETSCOENDMTH_NF],
                ptb_InRecChild[GT2158_RCL_NF],
                ptb_InRecChild[GT2158_RETCUR_CF],
                ptb_InRecChild[GT2158_RETAMT_M],
                ptb_InRecChild[GT2158_PLC_NT],
                ptb_InRecChild[GT2158_RTO_NF],
                ptb_InRecChild[GT2158_INT_NF],
                ptb_InRecChild[GT2158_RETPAY_NF],
                ptb_InRecChild[GT2158_RETKEY_CF],
//                ptb_InRecChild[GT2158_RETINTAMT_M],
                ptb_InRecChild[GT2158_ESTCUR_CF],
                ptb_InRecChild[GT2158_ESTAMT_M],
                ptb_InRecChild[GT2158_NAT_CF],
                ptb_InRecChild[GT2158_ACMTRS_NT],
                ptb_InRecChild[GT2158_ESTCTR_NF],
                ptb_InRecChild[GT2158_ESTSEC_NF],
                ptb_InRecChild[GT2158_LOB_CF],
                ptb_InRecChild[GT2158_SCOEGP_M],
                ptb_InRecChild[GT2158_ESTCRB_CT],
                ptb_InRecChild[GT2158_LIFTRTTYP_CF],
                ptb_InRecChild[GT2158_ACCADMTYP_CT],
                ptb_InRecChild[GT2158_SECSTS_CT],
                ptb_InRecChild[GT2158_PRD_NF],
                ptb_InRecChild[GT2158_SEG_NF],
                ptb_InRecChild[GT2158_COMACC_B],
                ptb_InRecChild[GT2158_ADJCOD_CT],
                ptb_InRecChild[GT2158_RETCOD_CT],
                ptb_InRecChild[GT2158_DETTRS_CF],
                ptb_InRecChild[GT2158_ADJSIG_B],
                ptb_InRecChild[GT2158_ESTUWY_NF],
                ptb_InRecChild[GT2158_LSTENDMTH_NF],
                ptb_InRecChild[GT2158_PROPER_N],
                ptb_InRecChild[GT2158_RTOCTY_CF],
                ptb_InRecChild[GT2158_SPIMOD_CT],
                ptb_InRecChild[GT2158_BRKSCOEGP_M],
                ptb_InRecChild[GT2158_UWGRP_CF]
                );
        RETURN_VAL(0);
}

/*==============================================================================
objet :
        fonction lancee pour chaque prevision ne participant
        pas a aucun placement

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPere (char **ptb_InRec_Cur)
{

    DEBUT_FCT("n_ActionFilsSansPere");

        fprintf(Kp_ComprevFil,  "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s\n",
                ptb_InRec_Cur[GT2158_SSD_CF],
                ptb_InRec_Cur[GT2158_ESB_CF],
                ptb_InRec_Cur[GT2158_BALSHEY_NF],
                ptb_InRec_Cur[GT2158_BALSHRMTH_NF],
                ptb_InRec_Cur[GT2158_BALSHRDAY_NF],
                ptb_InRec_Cur[GT2158_TRNCOD_CF],
                ptb_InRec_Cur[GT2158_DBLTRNCOD_CF],
                ptb_InRec_Cur[GT2158_CTR_NF],
                ptb_InRec_Cur[GT2158_END_NT],
                ptb_InRec_Cur[GT2158_SEC_NF],
                ptb_InRec_Cur[GT2158_UWY_NF],
                ptb_InRec_Cur[GT2158_UW_NT],
                ptb_InRec_Cur[GT2158_OCCYEA_NF],
                ptb_InRec_Cur[GT2158_ACY_NF],
                ptb_InRec_Cur[GT2158_SCOSTRMTH_NF],
                ptb_InRec_Cur[GT2158_SCOENDMTH_NF],
                ptb_InRec_Cur[GT2158_CLM_NF],
                ptb_InRec_Cur[GT2158_CUR_CF],
                ptb_InRec_Cur[GT2158_AMT_M],
                ptb_InRec_Cur[GT2158_CED_NF],
                ptb_InRec_Cur[GT2158_BRK_NF],
                ptb_InRec_Cur[GT2158_PAY_NF],
                ptb_InRec_Cur[GT2158_KEY_NF],
                ptb_InRec_Cur[GT2158_RETCTR_NF],
                ptb_InRec_Cur[GT2158_RETEND_NT],
                ptb_InRec_Cur[GT2158_RETSEC_NF],
                ptb_InRec_Cur[GT2158_RTY_NF],
                ptb_InRec_Cur[GT2158_RETUW_NT],
                ptb_InRec_Cur[GT2158_RETOCCYEA_NF],
                ptb_InRec_Cur[GT2158_RETACY_NF],
                ptb_InRec_Cur[GT2158_RETSCOSTRMTH_NF],
                ptb_InRec_Cur[GT2158_RETSCOENDMTH_NF],
                ptb_InRec_Cur[GT2158_RCL_NF],
                ptb_InRec_Cur[GT2158_RETCUR_CF],
                ptb_InRec_Cur[GT2158_RETAMT_M],
                ptb_InRec_Cur[GT2158_PLC_NT],
                ptb_InRec_Cur[GT2158_RTO_NF],
                ptb_InRec_Cur[GT2158_INT_NF],
                ptb_InRec_Cur[GT2158_RETPAY_NF],
                ptb_InRec_Cur[GT2158_RETKEY_CF],
//                ptb_InRec_Cur[GT2158_RETINTAMT_M],
                ptb_InRec_Cur[GT2158_ESTCUR_CF],
                ptb_InRec_Cur[GT2158_ESTAMT_M],
                ptb_InRec_Cur[GT2158_NAT_CF],
                ptb_InRec_Cur[GT2158_ACMTRS_NT],
                ptb_InRec_Cur[GT2158_ESTCTR_NF],
                ptb_InRec_Cur[GT2158_ESTSEC_NF],
                ptb_InRec_Cur[GT2158_LOB_CF],
                ptb_InRec_Cur[GT2158_SCOEGP_M],
                ptb_InRec_Cur[GT2158_ESTCRB_CT],
                ptb_InRec_Cur[GT2158_LIFTRTTYP_CF],
                ptb_InRec_Cur[GT2158_ACCADMTYP_CT],
                ptb_InRec_Cur[GT2158_SECSTS_CT],
                ptb_InRec_Cur[GT2158_PRD_NF],
                ptb_InRec_Cur[GT2158_SEG_NF],
                ptb_InRec_Cur[GT2158_COMACC_B],
                ptb_InRec_Cur[GT2158_ADJCOD_CT],
                ptb_InRec_Cur[GT2158_RETCOD_CT],
                ptb_InRec_Cur[GT2158_DETTRS_CF],
                ptb_InRec_Cur[GT2158_ADJSIG_B],
                ptb_InRec_Cur[GT2158_ESTUWY_NF],
                ptb_InRec_Cur[GT2158_LSTENDMTH_NF],
                ptb_InRec_Cur[GT2158_PROPER_N],
                ptb_InRec_Cur[GT2158_RTOCTY_CF],
                ptb_InRec_Cur[GT2158_SPIMOD_CT],
                ptb_InRec_Cur[GT2158_BRKSCOEGP_M],
                ptb_InRec_Cur[GT2158_UWGRP_CF]
                );
        RETURN_VAL(0);
}
