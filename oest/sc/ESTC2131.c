/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC2131.c
révision                      : $Revision: 1.2 $
date de création              : 15/10/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   MISE AU FORMAT GT DES COMPLEMENTS

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
           ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"


/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/


/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define NB_PLC_MAX      100     /* nombre de placements maxi par affaire */

typedef struct {
        char    PLC_NT[11] ;            /* code placement */
        double  RETSIGSHA_R ;           /* part cedee */
        char    RTO_NF[11] ;            /* tiers retrocessionnaire */
        char    INT_NF[11] ;            /* courtier retrocessionnaire */
        char    RETPAY_NF[11] ;         /* payeur retrocessionnaire */
        char    RETKEY_CF[2] ;          /* clef TP retrocessionnaire */
} T_PLAC ;


/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE                    *Kp_OutputFilGt ;       /* pointeur sur le fichier de sortie GT */

T_RUPTURE_VAR           bd_RuptPlc ;    /* variable de gestion de la rupture sur le fichier des placements */

T_RUPTURE_SYNC_VAR      bd_RuptGt ;     /* variable de gestion de la synchronisation avec le GT */


double  Kd_RetSigShaCum ;               /* part placee cumulee par une affaire retro */

T_PLAC  Ktbd_TabPlac[NB_PLC_MAX] ;      /* tableau des placements pour une affaire retro */
short   Kn_TabPlac_Nbp ;                /* nombre de postes du tableau Ktbd_TabPlac */


int n_InitPlc                   ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_IsR1Plc                   ( char **pbd_InRec, char **pbd_InRec_Cur ) ;
int n_ActionFirstRuptPlc        ( char **pbd_InRec_Cur ) ;
int n_ActionLignePlc            ( char **pbd_InRec_Cur ) ;
int n_ActionLastRuptPlc         ( char **pbd_InRec_Cur ) ;

int n_InitGt                    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGt             ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGt           ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_ProcessingRuptureSyncVar (
                        T_RUPTURE_SYNC_VAR  *pbd_Rupt,
                        char **ptb_InRecOwner );


/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
        /* Initialisation des signaux */
        InitSig () ;

        if ( n_BeginPgm ( argc, argv ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        /* ouverture du fichier en sortie GT */
        if ( n_OpenFileAppl ( "ESTC2131_O1","wt",&Kp_OutputFilGt ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        /* Initialisation de la variable bd_RuptPlc */
        if ( n_InitPlc( &bd_RuptPlc ) )
                ExitPgm( ERR_XX , "" ) ;

        /* Initialisation de la variable bd_RuptGt */
        if ( n_InitGt( &bd_RuptGt ) )
                ExitPgm( ERR_XX , "" ) ;

        /* lancement du traitement du fichier des placements */
        if ( n_ProcessingRuptureVar( &bd_RuptPlc ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        if ( n_CloseFileAppl( "ESTC2131_I1", &( bd_RuptPlc.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        if ( n_CloseFileAppl( "ESTC2131_I2", &( bd_RuptGt.pf_InputFil ) ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        if ( n_CloseFileAppl( "ESTC2131_O1", &Kp_OutputFilGt ) == ERR )
                ExitPgm( ERR_XX , "" ) ;

        if ( n_EndPgm() == ERR )
                ExitPgm( ERR_XX , "" );

        exit( OK ) ;
}


/*==============================================================================
objet :
        fonction d'initialisation de la variable de gestion de rupture du fichier
        maitre.

retour :
        0K
==============================================================================*/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
        DEBUT_FCT( "n_InitPlc" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

        /* ouverture du fichier maitre des placements */
        if ( n_OpenFileAppl( "ESTC2131_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
                return ERR ;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 1 ;

        /* fonction du test de rupture de niveau 1 */
        pbd_Rupt->n_ConditionRupture[0] = n_IsR1Plc ;

        /* fonction lancee en rupture premiere */
        pbd_Rupt->n_ActionFirst[0] = n_ActionFirstRuptPlc ;

        /* fonction d'action sur la ligne courante du fichier maitre */
        pbd_Rupt->n_ActionLigne = n_ActionLignePlc ;

        /* Fonction lancee en rupture derniere */
        pbd_Rupt->n_ActionLast[0] = n_ActionLastRuptPlc ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction de test de rupture de niveau 1

retour :
        0       ---> pas de rupture
        sinon           ---> rupture
==============================================================================*/
int n_IsR1Plc(
        char **ptb_InRec ,  /* adresse de la ligne en avance */
        char **ptb_InRec_Cur  ) /* adresse de la ligne courante */
{
        int ret ;

        DEBUT_FCT( "n_IsR1Plc" ) ;

        if ( ( ret = strcmp( ptb_InRec[PLA_RETCTR_NF], ptb_InRec_Cur[PLA_RETCTR_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( ptb_InRec[PLA_RETEND_NT], ptb_InRec_Cur[PLA_RETEND_NT] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( ptb_InRec[PLA_RETSEC_NF], ptb_InRec_Cur[PLA_RETSEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( ptb_InRec[PLA_RTY_NF], ptb_InRec_Cur[PLA_RTY_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( ptb_InRec[PLA_RETUW_NT], ptb_InRec_Cur[PLA_RETUW_NT] ) ) != 0 ) return ret ;

        RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
        fonction lancee en rupture premiere

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionFirstRuptPlc( char **pbd_InRec_Cur  )
{
        DEBUT_FCT( "n_ActionFirstRuptPlc" ) ;

        /* initialisation du cumuls des parts placees */
        Kd_RetSigShaCum = 0 ;

        /* initialisation du compteur de postes du tableau Ktbd_TabPlac */
        Kn_TabPlac_Nbp = 0 ;

        /* initialisation du tableau des placements */
        memset( Ktbd_TabPlac, 0, NB_PLC_MAX * sizeof( T_PLAC ) ) ;

        RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlc( char **ptb_InRec_Cur )
{
        char MsgAno[300];

        DEBUT_FCT( "n_ActionLignePlc" ) ;

        if (Kn_TabPlac_Nbp >= NB_PLC_MAX) {
                sprintf(MsgAno,"The number of placements by retro contracts (/RETCTR %s /RETEND %s /RETSEC %s /RTY %s /RETUW %s) overflows the program's storage capacity",
                        ptb_InRec_Cur[PLA_RETCTR_NF],
                        ptb_InRec_Cur[PLA_RETEND_NT],
                        ptb_InRec_Cur[PLA_RETSEC_NF],
                        ptb_InRec_Cur[PLA_RTY_NF],
                        ptb_InRec_Cur[PLA_RETUW_NT]);

                n_WriteAno(MsgAno);
                RETURN_VAL( OK ) ;
        }

        /* memorisation du code placement, part placee, tiers, courtier, payeur, clef TP */
        strcpy( Ktbd_TabPlac[Kn_TabPlac_Nbp].PLC_NT, ptb_InRec_Cur[PLA_PLC_NT] ) ;
        Ktbd_TabPlac[Kn_TabPlac_Nbp].RETSIGSHA_R = atof( ptb_InRec_Cur[PLA_RETSIGSHA_R] ) ;
        strcpy( Ktbd_TabPlac[Kn_TabPlac_Nbp].RTO_NF, ptb_InRec_Cur[PLA_RTO_NF] ) ;
        strcpy( Ktbd_TabPlac[Kn_TabPlac_Nbp].INT_NF, ptb_InRec_Cur[PLA_INT_NF] ) ;
        strcpy( Ktbd_TabPlac[Kn_TabPlac_Nbp].RETPAY_NF, ptb_InRec_Cur[PLA_PAY_NF] ) ;
        strcpy( Ktbd_TabPlac[Kn_TabPlac_Nbp].RETKEY_CF, ptb_InRec_Cur[PLA_KEY_CF] ) ;

        /* cumul de la part placee */
        Kd_RetSigShaCum += Ktbd_TabPlac[Kn_TabPlac_Nbp].RETSIGSHA_R ;

        /* incrementation du compteur du tableau Ktbd_TabPlac */
        Kn_TabPlac_Nbp += 1 ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction lancee en rupture derniere

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLastRuptPlc( char **ptb_InRec_Cur  )
{
        DEBUT_FCT( "n_ActionLastRuptPlc" ) ;

        /* lancement de la synchronisation avec le GT */
        n_ProcessingRuptureSyncVar( &bd_RuptGt, ptb_InRec_Cur ) ;

        RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre « des placements »
        avec l’esclave « GT »

retour :
        OK
==============================================================================*/
int n_InitGt( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
        DEBUT_FCT( "n_InitGt" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESTC2131_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR ;

        /* nombre de rupture a gerer */
        pbd_Rupt->n_NbRupture = 0 ;

        /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncGt ;

        /* fonction d'action sur la ligne courante */
        pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;

        pbd_Rupt->c_Separ = SEPARATEUR ;

        RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
        fonction de test de synchronisation

retour :
        0       ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
        > 0     ---> pbd_InRecOwne> > pbd_InRecChild
        < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGt(
        char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
        char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncGt" ) ;

        if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETCTR_NF], pbd_InRecChild[GT_RETCTR_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETEND_NT], pbd_InRecChild[GT_RETEND_NT] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETSEC_NF], pbd_InRecChild[GT_RETSEC_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PLA_RTY_NF], pbd_InRecChild[GT_RTY_NF] ) ) != 0 ) return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[PLA_RETUW_NT], pbd_InRecChild[GT_RETUW_NT] ) ) != 0 ) return ret ;

        RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
        fonction lancee pour chaque ligne

retour :        OK ---> traitement correctement effectue
                ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt(
        char **ptb_InRecOwner , /* adresse de la ligne du maitre */
        char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
        char    sz_Amt[22] ;    /* zone de travail: montant acceptation */
        double  d_Amt ;         /* variable de travail: montant acceptation */
        double  d_Amt_i ;       /* variable de travail: montant acceptation */
        char    sz_RetAmt[22] ; /* zone de travail: montant retro */
        double  d_RetAmt ;      /* variable de travail: montant retrocession */
        double  d_RetAmt_i ;    /* variable de travail: montant acceptation */

        int i ;

        DEBUT_FCT( "n_ActionLigneGt" ) ;

        if (Kd_RetSigShaCum != 0) {
                /* preparation du calcul */
                d_Amt_i = atof( ptb_InRecChild[GT_AMT_M] ) / Kd_RetSigShaCum ;
                d_RetAmt_i = atof( ptb_InRecChild[GT_RETAMT_M] ) / Kd_RetSigShaCum ;
        }
        else d_Amt_i = d_RetAmt_i = 0;

        /* boucle sur chaque placement de l'affaire */
        for ( i = 0; i < Kn_TabPlac_Nbp; i++ )
        {
                /* calcul des montants acceptation et retrocession */
                d_Amt = d_Amt_i * Ktbd_TabPlac[i].RETSIGSHA_R ;
                d_RetAmt = d_RetAmt_i * Ktbd_TabPlac[i].RETSIGSHA_R ;

                /* formatage des montants */
                sprintf( sz_Amt, "%-.3f", d_Amt ) ;
                sprintf( sz_RetAmt, "%-.3f", d_RetAmt ) ;

                /* ecriture en sortie dans le GT */
                ptb_InRecChild[GT_AMT_M] = sz_Amt ;
                ptb_InRecChild[GT_RETAMT_M] = sz_RetAmt ;
                ptb_InRecChild[GT_PLC_NT] = Ktbd_TabPlac[i].PLC_NT ;
                ptb_InRecChild[GT_RTO_NF] = Ktbd_TabPlac[i].RTO_NF ;
                ptb_InRecChild[GT_INT_NF] = Ktbd_TabPlac[i].INT_NF ;
                ptb_InRecChild[GT_RETPAY_NF] = Ktbd_TabPlac[i].RETPAY_NF ;
                ptb_InRecChild[GT_RETKEY_CF] = Ktbd_TabPlac[i].RETKEY_CF ;

                n_WriteCols( Kp_OutputFilGt, ptb_InRecChild, SEPARATEUR, 0 ) ;
        }

        RETURN_VAL( OK ) ;
}






