/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : Ventilation des complements previsionnels
nom du source                 : ESTC2144.c
revision                      : $Revision: 1.2 $
date de creation              : 15/09/1997
auteur                        : P. LOUVEAU
references des specifications : ESIIV01F
squelette de base             : batch
------------------------------------------------------------------------------
description :
        Traitements effectues sur les rapprochements dont le mode de ventilation
        est 3 ou 4.

                              -  ETAPE 1 -

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    29/01/2003  J. Ribot  ajout un champs retro pour reto interne.

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C    
[001] 09/01/2019 SBE  spira:81946: Apolo QE: Trimestrialisation des compléments Distinction poste cash et reserve
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define TAILLE_MAX_TAB          500
#define GT_ACM_NF 74

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE            *Kp_ComprevFil;         /* pointeur sur les complements previsionnels */
FILE            *Kp_MvtFil;             /* pointeur sur le fichier des mouvements */
FILE            *Kp_RappFil;            /* pointeur sur les rapprochements */

T_RUPTURE_VAR           bd_RuptRapp;    /* gestion rupture sur les rapprochements */
T_RUPTURE_SYNC_VAR      bd_RuptMvt;     /* gestion rupture sur les mouvements */


int n_InitRapp(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneRapp(char **pbd_InRec_Cur);
int n_ActionPereSansFils(char **ptb_InRec);

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
        if ( n_OpenFileAppl ("ESTC2144_O1","wt",&Kp_ComprevFil) == ERR )
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
        if (n_CloseFileAppl ("ESTC2144_I1",&(bd_RuptRapp.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2144_I2",&(bd_RuptMvt.pf_InputFil)))
                ExitPgm ( ERR_XX , "" );

        if (n_CloseFileAppl ("ESTC2144_O1",&Kp_ComprevFil))
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

        if ( n_OpenFileAppl ("ESTC2144_I1","rt",&(pbd_Rupt->pf_InputFil)))
                RETURN_VAL (ERR);

        pbd_Rupt->n_NbRupture = 0 ;
        pbd_Rupt->n_ActionLigne = n_ActionLigneRapp ;

        pbd_Rupt->c_Separ = '~' ;

        RETURN_VAL (0);
}


/*==============================================================================
objet :
        Initialisation de la synchronisation du maitre « rapprochements » avec
        l’esclave « Mouvements comptables »

retour :
        OK
==============================================================================*/
int n_InitMvt(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{

        DEBUT_FCT( "n_InitMvt" ) ;

        memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

        /* ouverture du fichier esclave */
        if ( n_OpenFileAppl( "ESTC2144_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
                return ERR ;

        pbd_Rupt->n_NbRupture = 0 ;

        /* condition de synchro */
        pbd_Rupt->ConditionEndSync = n_ConditionSyncMvt ;
        pbd_Rupt->n_PereSansFils   = n_ActionPereSansFils;

        /* fonction d'action sur la ligne courante du fichier Mouvement comptable */
        pbd_Rupt->n_ActionLigne = n_ActionLigneMvt ;

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
        char **pbd_InRecOwner ,         /* adresse de la ligne du maitre Liste des affaires */
        char **pbd_InRecChild  )        /* adresse de la ligne de l'esclave Mouvement comptable */
{
        int ret ;

        DEBUT_FCT( "n_ConditionSyncMvt" ) ;

        if ( ( ret = strcmp( pbd_InRecOwner[GT_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_ACY_NF], pbd_InRecChild[GT_ACY_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_ACM_NF], pbd_InRecChild[GT_ACM_NF] ) ) != 0 )
                return ret ;
        if ( ( ret = strcmp( pbd_InRecOwner[GT_ACMTRS_NT], pbd_InRecChild[GT_ACMTRS_NT] ) ) != 0 )
                return ret ;

        RETURN_VAL( 0 ) ;
}



/*==============================================================================
objet :
        fonction lancee quand le fichier rapprochement participe seul

retour :
        OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionPereSansFils(char **ptb_InRec)
{
        double  AffAliment;

        DEBUT_FCT("n_ActionPereSansFils");


        if ( b_IsBlankOrEmpty(ptb_InRec[GT_PRD_NF]) == FALSE )
                AffAliment = atof(ptb_InRec[GT_BRKSCOEGP_M]);
        else AffAliment = 0;

        /* la liberation est considere comme nulle */
        fprintf(Kp_ComprevFil,  "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~~~~%s\n",
                ptb_InRec[GT_SSD_CF],
                ptb_InRec[GT_ESB_CF],
                ptb_InRec[GT_BALSHEY_NF],
                ptb_InRec[GT_BALSHRMTH_NF],
                ptb_InRec[GT_BALSHRDAY_NF],
                ptb_InRec[GT_TRNCOD_CF],
                ptb_InRec[GT_DBLTRNCOD_CF],
                ptb_InRec[GT_CTR_NF],
                ptb_InRec[GT_END_NT],
                ptb_InRec[GT_SEC_NF],
                ptb_InRec[GT_UWY_NF],
                ptb_InRec[GT_UW_NT],
                ptb_InRec[GT_OCCYEA_NF],
                ptb_InRec[GT_ACY_NF],
                ptb_InRec[GT_SCOSTRMTH_NF],
                ptb_InRec[GT_SCOENDMTH_NF],
                ptb_InRec[GT_CLM_NF],
                ptb_InRec[GT_CUR_CF],
                ptb_InRec[GT_AMT_M],
                ptb_InRec[GT_CED_NF],
                ptb_InRec[GT_BRK_NF],
                ptb_InRec[GT_PAY_NF],
                ptb_InRec[GT_KEY_NF],
                "",  "",  "", "", "",            /* partie retrocessionnaire */
                "",  "",  "", "", "",
                "",  "",  "", "", "",
                "", "", "",                      /* ajout un champs retro pour reto interne JR 29 01 03 */
                ptb_InRec[GT_ESTCUR_CF],
                ptb_InRec[GT_ESTAMT_M],
                ptb_InRec[GT_NAT_CF],
                ptb_InRec[GT_ACMTRS_NT],
                ptb_InRec[GT_ESTCTR_NF],
                ptb_InRec[GT_ESTSEC_NF],
                ptb_InRec[GT_LOB_CF],
                ptb_InRec[GT_SCOEGP_M],
                ptb_InRec[GT_ESTCRB_CT],
                ptb_InRec[GT_LIFTRTTYP_CF],
                ptb_InRec[GT_ACCADMTYP_CT],
                ptb_InRec[GT_SECSTS_CT],
                ptb_InRec[GT_PRD_NF],
                ptb_InRec[GT_SEG_NF],
                ptb_InRec[GT_COMACC_B],
                ptb_InRec[GT_ADJCOD_CT],
                ptb_InRec[GT_ORICOD_CF], 
                ptb_InRec[GT_DETTRS_CF],
                ptb_InRec[GT_ACCRET_B], 
                ptb_InRec[GT_ESTUWY_NF],
                ptb_InRec[GT_LSTENDMTH_NF],
                ptb_InRec[GT_PROPER_N],
                ptb_InRec[GT_RTOCTY_CF],
                ptb_InRec[GT_GAAP_NF],
                AffAliment,
                ptb_InRec[GT_SPIMOD_CT]
              
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
        Fonction lancee a chaque synchro entre rapprochements et mouvements
==============================================================================*/
int n_ActionLigneMvt ( char **ptb_InRecOwner, char **ptb_InRecChild )
{
    double      Aliment, AffAliment;
    double      liberation;

    DEBUT_FCT("n_ActionLigneGT");


    /* aliments pour les complements previsionnels */
    liberation = atof(ptb_InRecChild[GT_AMT_M]);
    Aliment = atof(ptb_InRecOwner[GT_SCOEGP_M]) + liberation;

    if ( b_IsBlankOrEmpty(ptb_InRecChild[GT_PRD_NF]) == FALSE )
        AffAliment = atof(ptb_InRecOwner[GT_BRKSCOEGP_M]) + liberation;
    else AffAliment = 0;

    fprintf(Kp_ComprevFil,  "%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%s~%.3lf~~~~%s\n",
                ptb_InRecOwner[GT_SSD_CF],
                ptb_InRecOwner[GT_ESB_CF],
                ptb_InRecOwner[GT_BALSHEY_NF],
                ptb_InRecOwner[GT_BALSHRMTH_NF],
                ptb_InRecOwner[GT_BALSHRDAY_NF],
                ptb_InRecOwner[GT_TRNCOD_CF],
                ptb_InRecOwner[GT_DBLTRNCOD_CF],
                ptb_InRecOwner[GT_CTR_NF],
                ptb_InRecOwner[GT_END_NT],
                ptb_InRecOwner[GT_SEC_NF],
                ptb_InRecOwner[GT_UWY_NF],
                ptb_InRecOwner[GT_UW_NT],
                ptb_InRecOwner[GT_OCCYEA_NF],
                ptb_InRecOwner[GT_ACY_NF],
                ptb_InRecOwner[GT_SCOSTRMTH_NF],
                ptb_InRecOwner[GT_SCOENDMTH_NF],
                ptb_InRecOwner[GT_CLM_NF],
                ptb_InRecOwner[GT_CUR_CF],
                ptb_InRecOwner[GT_AMT_M],
                ptb_InRecOwner[GT_CED_NF],
                ptb_InRecOwner[GT_BRK_NF],
                ptb_InRecOwner[GT_PAY_NF],
                ptb_InRecOwner[GT_KEY_NF],
                "",  "",  "", "", "",                   /* partie retrocessionnaire */
                "",  "",  "", "", "",
                "",  "",  "", "", "",
                "", "", "",                      /* ajout un champs retro pour reto interne JR 29 01 03 */
                ptb_InRecOwner[GT_ESTCUR_CF],
                ptb_InRecOwner[GT_ESTAMT_M],
                ptb_InRecOwner[GT_NAT_CF],
                ptb_InRecOwner[GT_ACMTRS_NT],
                ptb_InRecOwner[GT_ESTCTR_NF],
                ptb_InRecOwner[GT_ESTSEC_NF],
                ptb_InRecOwner[GT_LOB_CF],
                Aliment,
                ptb_InRecOwner[GT_ESTCRB_CT],
                ptb_InRecOwner[GT_LIFTRTTYP_CF],
                ptb_InRecOwner[GT_ACCADMTYP_CT],
                ptb_InRecOwner[GT_SECSTS_CT],
                ptb_InRecOwner[GT_PRD_NF],
                ptb_InRecOwner[GT_SEG_NF],
                ptb_InRecOwner[GT_COMACC_B],
                ptb_InRecOwner[GT_ADJCOD_CT],
                ptb_InRecOwner[GT_ORICOD_CF], 
                ptb_InRecOwner[GT_DETTRS_CF],
                ptb_InRecOwner[GT_ACCRET_B], 
                ptb_InRecOwner[GT_ESTUWY_NF],
                ptb_InRecOwner[GT_LSTENDMTH_NF],
                ptb_InRecOwner[GT_PROPER_N],
                ptb_InRecOwner[GT_RTOCTY_CF],
                ptb_InRecOwner[GT_GAAP_NF],
                AffAliment,
                ptb_InRecOwner[GT_SPIMOD_CT]                
                );

    RETURN_VAL (0);
}



