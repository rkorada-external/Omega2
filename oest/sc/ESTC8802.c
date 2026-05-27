/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8802.c
révision                      : $Revision: 1.1.1.1 $
date de création              : 17/03/1998
auteur                        : M.HA-THUC
squelette de base             : batch
------------------------------------------------------------------------------
description :   Enrichissement des GTAA et GTAR en entree
------------------------------------------------------------------------------
historique des modifications :
    <jj/mm/aaaa> <auteur>    <description de la modification>
     27/03/2008  J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
[02] 18/03/2011  D.GATIBELZA ESTDOM21408 OneLedger
[03] 24/03/2011  R. Cassis   :spot:21408 Ttecleda passe à 102 colonnes au lieu de 88
[04] 25/06/13    Prajakta    Phase1B migration code changes for warning removal
[05] 05/02/2016  Florent     :spot:29066 suite au GLT à 71 colonnes, 16 nouvelles colonnes dans les 2 tables TTCLEDA et R
[06] 03/05/2016  S.Behague   :spot:30445 Spira 48594 VENTILATION BAD DEBT RETRO PAR RETROCESSIONNAIRE DANS LE GTAR 
     01/06/2016  S.Behague   :spot:30445 Spira 48594 Mise en commentaire des modifications pour utilisation ultérieure (Mep Septembre)
     11/07/2016  S.Behague   :spot:30445 Spira 48594 Activation spot 30445
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
#include "ESTC8802.h"

#define Kn_MaxLigTCLIENT   1000             //[002]

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE *Kp_OutputFilFTECLEDR_O1;                      // pointeur sur le fichier de sortie GTR
FILE *Kp_OutputFilFTECLEDAR_O2;                     // pointeur sur le fichier de sortie GTAR
FILE *Kp_OutputFilFTECLEDR_FORMAT_AR_O3;              //[002]
FILE *Kp_OutputFilFTECLEDAR_REJET_04;          //[002]
FILE *Kp_TCLIENT;                           //[002]

T_TCLIENT Ktbd_TCLIENT[Kn_MaxLigTCLIENT] ;  //[002]

T_RUPTURE_VAR       bd_RuptPer;             // variable de gestion de la rupture sur le perimetre IRDVPERICASE
T_RUPTURE_SYNC_VAR  bd_RuptTotGtr;          // variable de gestion de la synchronisation avec le fichier TOTGTR
T_RUPTURE_SYNC_VAR  bd_RuptTotGtar;         // variable de gestion de la synchronisation avec le fichier TOTGTAR

int n_InitPer                   ( T_RUPTURE_VAR  * );
int n_ActionLignePer            ( char ** );

int n_InitTotGtr                ( T_RUPTURE_SYNC_VAR * );
int n_ActionLigneTotGtr         ( char **, char ** );
int n_ConditionSyncTotGtr       ( char **, char ** );
int n_ActionFilsSansPereTotGtr  ( char ** );

int n_InitTotGtar               ( T_RUPTURE_SYNC_VAR * );
int n_ActionLigneTotGtar        ( char **, char ** );
int n_ConditionSyncTotGtar      ( char **, char ** );
int n_ActionFilsSansPereTotGtar ( char ** );

int n_ProcessingRuptureSyncVar  ( T_RUPTURE_SYNC_VAR *, char ** );

int n_ecrire_formatAR           (char **, char **);     //[002]
int n_ChargerTCLIENT            ( );                    //[002]
int n_recherche_CLISSD_CF       ( char **);             //[002]
int Kn_TCLIENT;                                         //[002] compteur du nombre ligne chargees dans Ktbd_TCLIENT

/*==============================================================================
objet  : point d'entree du programme
retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
    // Initialisation des signaux
    InitSig () ;

    if ( n_BeginPgm ( argc, argv ) == ERR )             ExitPgm( ERR_XX , "" ) ;

    // ouverture du fichier de sortie GTAA
    if ( n_OpenFileAppl ( "ESTC8802_O1", "wt", &Kp_OutputFilFTECLEDR_O1 ) == ERR )                ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC8802_O2", "wt", &Kp_OutputFilFTECLEDAR_O2 ) == ERR )               ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC8802_O3", "wt", &Kp_OutputFilFTECLEDR_FORMAT_AR_O3 ) == ERR )        ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC8802_O4", "wt", &Kp_OutputFilFTECLEDAR_REJET_04 ) == ERR )    ExitPgm( ERR_XX , "" ) ;


    if ( n_InitPer( &bd_RuptPer ) )                     ExitPgm( ERR_XX , "" ) ;
    if ( n_InitTotGtr( &bd_RuptTotGtr ) )               ExitPgm( ERR_XX , "" ) ;
    if ( n_InitTotGtar( &bd_RuptTotGtar ) )             ExitPgm( ERR_XX , "" ) ;

    // [002] Chargement du tableau TCLIENT
    if ( ( Kn_TCLIENT = n_ChargerTCLIENT() ) == -1 )    ExitPgm( ERR_XX , "" ) ;


    // lancement du traitement du fichier Perimetre IRDVPERICASE
    if ( n_ProcessingRuptureVar( &bd_RuptPer ) == ERR ) ExitPgm( ERR_XX , "" ) ;

    //if ( n_CloseFileAppl( "ESTC8802_I4", &(  ) ) == ERR )  ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC8802_I3", &( bd_RuptTotGtr.pf_InputFil ) ) == ERR )      ExitPgm( ERR_XX , "" ) ;    //[002]
    if ( n_CloseFileAppl( "ESTC8802_I2", &( bd_RuptTotGtar.pf_InputFil ) ) == ERR )     ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC8802_I1", &( bd_RuptPer.pf_InputFil ) ) == ERR )         ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC8802_O4", &Kp_OutputFilFTECLEDAR_REJET_04) == ERR )         ExitPgm( ERR_XX , "" ) ;    //[002]
    if ( n_CloseFileAppl( "ESTC8802_O3", &Kp_OutputFilFTECLEDR_FORMAT_AR_O3 ) == ERR )            ExitPgm( ERR_XX , "" ) ;    //[002]
    if ( n_CloseFileAppl( "ESTC8802_O2", &Kp_OutputFilFTECLEDAR_O2 ) == ERR )                    ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC8802_O1", &Kp_OutputFilFTECLEDR_O1 ) == ERR )                   ExitPgm( ERR_XX , "" ) ;

    if ( n_EndPgm() == ERR )                            ExitPgm( ERR_XX , "" );

    exit(OK) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour: 0K
==============================================================================*/
int n_InitPer(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitPer");

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier maitre Perimetre
    if ( n_OpenFileAppl( "ESTC8802_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
        return ERR ;

    pbd_Rupt->n_NbRupture = 0 ;
    pbd_Rupt->n_ActionLigne = n_ActionLignePer ;            // fonction d'action sur la ligne courante du fichier maitre
    pbd_Rupt->c_Separ = SEPARATEUR ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePer( char **ptb_InRec_Cur )
{
    DEBUT_FCT("n_ActionLignePer");

    // synchronisation avec le GTR
    n_ProcessingRuptureSyncVar( &bd_RuptTotGtr, ptb_InRec_Cur ) ;

    // synchronisation avec le GTAR
    n_ProcessingRuptureSyncVar( &bd_RuptTotGtar, ptb_InRec_Cur ) ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « Perimetre » avec l’esclave « TOTGTR »
retour: OK
==============================================================================*/
int n_InitTotGtr( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitTotGtr");

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

    // ouverture du fichier esclave TOTGTR
    if ( n_OpenFileAppl( "ESTC8802_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
        return ERR ;

    // fonction du test de synchronisation de la ligne du maitre avec l'esclave
    pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGtr ;

    // fonction d'action sur la ligne courante
    pbd_Rupt->n_ActionLigne = n_ActionLigneTotGtr ;
    pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereTotGtr ;       // fonction d'action quand l'esclave n'a pas de maitre
    pbd_Rupt->c_Separ = SEPARATEUR ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour: 0   ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
        > 0 ---> pbd_InRecOwne> > pbd_InRecChild
        < 0 ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
// adresse de la ligne du maitre adresse de la ligne de l'esclave
int n_ConditionSyncTotGtr( char **pbd_InRecOwner, char **pbd_InRecChild )
{
    int ret ;

    DEBUT_FCT("n_ConditionSyncTotGtr");

    if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[TECLEDR_RETCTR_NF] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[TECLEDR_RETEND_NT] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[TECLEDR_RETSEC_NF] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[TECLEDR_RTY_NF] ) ) != 0 )      return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT],  pbd_InRecChild[TECLEDR_RETUW_NT] ) ) != 0 )    return ret ;

    RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
// adresse de la ligne du maitre, de l'esclave
int n_ActionLigneTotGtr( char **ptb_InRecOwner, char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionLigneTotGtr");

    /* rajout des champs supplementaire au GT en sortie */
    ptb_InRecChild[TECLEDR_LOBRET_CF]       = ptb_InRecOwner[PER_LOB_CF] ;
    ptb_InRecChild[TECLEDR_SOBRET_CF]       = ptb_InRecOwner[PER_SOB_CF] ;
    ptb_InRecChild[TECLEDR_TOPRET_CF]       = ptb_InRecOwner[PER_TOP_CF] ;
    ptb_InRecChild[TECLEDR_NATRET_CF]       = ptb_InRecOwner[PER_NAT_CF] ;
    ptb_InRecChild[TECLEDR_GARRET_CF]       = ptb_InRecOwner[PER_GAR_CF] ;
    ptb_InRecChild[TECLEDR_PCPRSKTRYRET_CF] = ptb_InRecOwner[PER_PCPRSKTRY_CF] ;
    ptb_InRecChild[TECLEDR_USRCRTCODRET_CT] = ptb_InRecOwner[PER_USRCRTCOD_CT] ;
    ptb_InRecChild[TECLEDR_USRCRTVALRET_LM] = ptb_InRecOwner[PER_USRCRTVAL_LM] ;
    ptb_InRecChild[TECLEDR_RETCTRCAT_CF]    = ptb_InRecOwner[PER_RETCTRCAT_CF] ;
    ptb_InRecChild[TECLEDR_RETACCTYP_CT]    = ptb_InRecOwner[PER_ACCADMTYP_CT] ;
    ptb_InRecChild[TECLEDR_SSDRTO_B]        = "" ;         // champs non renseigne

    //[002] On écrit aussi dans le fichier FTECLEDR_FORMAT_AR_O3.dat au format TTECLEDA
    if ( strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "81",  2) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "82",  2) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "83",  2) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "841", 3) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "842", 3) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "85",  2) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "110", 3) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "111", 3) == 0   ||
         strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "907", 3) == 0    // [06] spot:30445 Spira 48594 Mise en commentaire des modifications pour utilisation ultérieure (Mep Septembre)
          )
    {
        n_ecrire_formatAR(ptb_InRecOwner, ptb_InRecChild);
    }

    // ecriture dans le GTR en sortie format TTCLEDR !
    n_WriteCols( Kp_OutputFilFTECLEDR_O1, ptb_InRecChild, SEPARATEUR, 0 ) ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee quand le fils n'a pas de pere
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
// adresse de la ligne de l'esclave
int n_ActionFilsSansPereTotGtr( char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionFilsSansPereTotGtr");

    // rajout des champs supplementaire au GT en sortie
    ptb_InRecChild[TECLEDR_LOBRET_CF]       = "" ;
    ptb_InRecChild[TECLEDR_SOBRET_CF]       = "" ;
    ptb_InRecChild[TECLEDR_TOPRET_CF]       = "" ;
    ptb_InRecChild[TECLEDR_NATRET_CF]       = "" ;
    ptb_InRecChild[TECLEDR_GARRET_CF]       = "" ;
    ptb_InRecChild[TECLEDR_PCPRSKTRYRET_CF] = "" ;
    ptb_InRecChild[TECLEDR_USRCRTCODRET_CT] = "" ;
    ptb_InRecChild[TECLEDR_USRCRTVALRET_LM] = "" ;
    ptb_InRecChild[TECLEDR_RETCTRCAT_CF]    = "" ;
    ptb_InRecChild[TECLEDR_RETACCTYP_CT]    = "" ;
    ptb_InRecChild[TECLEDR_SSDRTO_B]        = "" ;

    /* ecriture dans le GTR en sortie au format TTCLEDR !*/
    n_WriteCols( Kp_OutputFilFTECLEDR_O1, ptb_InRecChild, SEPARATEUR, 0 ) ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : Initialisation de la synchronisation du maitre « Perimetre » avec l’esclave « TOTGTAR »
retour: OK
==============================================================================*/
int n_InitTotGtar( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
    DEBUT_FCT("n_InitTotGtar");

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

    // ouverture du fichier esclave TOTGTAR
    if ( n_OpenFileAppl( "ESTC8802_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
        return ERR ;

    // fonction du test de synchronisation de la ligne du maitre avec l'esclave
    pbd_Rupt->ConditionEndSync = n_ConditionSyncTotGtar ;

    // fonction d'action sur la ligne courante
    pbd_Rupt->n_ActionLigne = n_ActionLigneTotGtar ;

    // fonction d'action quand l'esclave n'a pas de maitre
    pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereTotGtar ;

    pbd_Rupt->c_Separ = SEPARATEUR ;

    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour: 0   ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
        > 0 ---> pbd_InRecOwne> > pbd_InRecChild
        < 0 ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
// adresse de la ligne du maitre adresse de la ligne de l'esclave
int n_ConditionSyncTotGtar( char **pbd_InRecOwner, char **pbd_InRecChild )
{
    int ret ;

    DEBUT_FCT("n_ConditionSyncTotGtar");

    if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[TECLEDA_RETCTR_NF] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[TECLEDA_RETEND_NT] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[TECLEDA_RETSEC_NF] ) ) != 0 )   return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[TECLEDA_RTY_NF] ) ) != 0 )      return ret ;
    if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT],  pbd_InRecChild[TECLEDA_RETUW_NT] ) ) != 0 )    return ret ;

    RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
// adresse de la ligne du maitre, ligne de l'esclave
int n_ActionLigneTotGtar( char **ptb_InRecOwner, char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionLigneTotGtar");

    // rajout des champs supplementaire au GT en sortie
    ptb_InRecChild[TECLEDA_LOBRET_CF] = ptb_InRecOwner[PER_LOB_CF] ;
    ptb_InRecChild[TECLEDA_SOBRET_CF] = ptb_InRecOwner[PER_SOB_CF] ;
    ptb_InRecChild[TECLEDA_TOPRET_CF] = ptb_InRecOwner[PER_TOP_CF] ;
    ptb_InRecChild[TECLEDA_NATRET_CF] = ptb_InRecOwner[PER_NAT_CF] ;
    ptb_InRecChild[TECLEDA_GARRET_CF] = ptb_InRecOwner[PER_GAR_CF] ;
    ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = ptb_InRecOwner[PER_PCPRSKTRY_CF] ;
    ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = ptb_InRecOwner[PER_USRCRTCOD_CT] ;
    ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = ptb_InRecOwner[PER_USRCRTVAL_LM] ;
    ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = ptb_InRecOwner[PER_RETCTRCAT_CF] ;
    ptb_InRecChild[TECLEDA_RETACCTYP_CT] = ptb_InRecOwner[PER_ACCADMTYP_CT] ;

    //[002] On écrit aussi dans le fichier FTECLEDR_FORMAT_AR_O3.dat au format TTECLEDA     //[002]
    if ( strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "81",  2) == 0   ||                 //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "82",  2) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "83",  2) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "841", 3) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "842", 3) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "85",  2) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "110", 3) == 0   ||                  //[002]
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "111", 3) == 0   ||
            strncmp(ptb_InRecChild[TECLEDA_TRNCOD_CF] + 2, "907", 3) == 0                       // [06] spot:30445 Spira 48594 Mise en commentaire des modifications pour utilisation ultérieure (Mep Septembre)
       )                  //[002]
    {   //[002]
        // ecriture dans le GTAR REJET                                                      //[002]
        n_WriteCols( Kp_OutputFilFTECLEDAR_REJET_04, ptb_InRecChild, SEPARATEUR, 0 );       //[002]
    }                                                                                       //[002]
    else                                                                                    //[002]
    {
        // si Pas retro interne :
        if (!n_recherche_CLISSD_CF(ptb_InRecChild))
        {
            ptb_InRecChild[TECLEDA_PLC_NT]  = "";    //[003]
            ptb_InRecChild[TECLEDA_RTO_NF]  = "";    //[003]
        }

        // ecriture dans le GTAR en sortie
        n_WriteCols( Kp_OutputFilFTECLEDAR_O2, ptb_InRecChild, SEPARATEUR, 0 ) ;
    }
    RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
// adresse de la ligne de l'esclave
int n_ActionFilsSansPereTotGtar( char **ptb_InRecChild )
{
    DEBUT_FCT("n_ActionFilsSansPereTotGtar");

    // rajout des champs supplementaire au GT en sortie
    ptb_InRecChild[TECLEDA_LOBRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_SOBRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_TOPRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_NATRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_GARRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_PCPRSKTRYRET_CF] = "" ;
    ptb_InRecChild[TECLEDA_USRCRTCODRET_CT] = "" ;
    ptb_InRecChild[TECLEDA_USRCRTVALRET_LM] = "" ;
    ptb_InRecChild[TECLEDA_RETCTRCAT_CF] = "" ;
    ptb_InRecChild[TECLEDA_RETACCTYP_CT] = "" ;

    // ecriture dans le GTAR en sortie
    n_WriteCols( Kp_OutputFilFTECLEDAR_O2, ptb_InRecChild, SEPARATEUR, 0 ) ;

    RETURN_VAL( OK ) ;
}


//[002]
/*==============================================================================
objet : Ecriture fichier au format AR
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ecrire_formatAR(char **ptb_InRecOwner, char **ptb_InRecChild)
{
    char *formatAR[TECLEDA_NB_COL];
    int i, ncli;
    char *sz_blanc = "";

    DEBUT_FCT("n_ecrire_formatAR");

    for ( i = 0; i < TECLEDA_NB_COL; i++)
    {
        formatAR[i] = sz_blanc ;
    }

    formatAR[TECLEDA_NB_COL] = NULL;


    formatAR[TECLEDA_SSD_CF]           = ptb_InRecChild[TECLEDR_SSD_CF];
    formatAR[TECLEDA_ESB_CF]           = ptb_InRecChild[TECLEDR_ESB_CF];
    formatAR[TECLEDA_BALSHEY_NF]       = ptb_InRecChild[TECLEDR_BALSHEY_NF];
    formatAR[TECLEDA_BALSHRMTH_NF]     = ptb_InRecChild[TECLEDR_BALSHRMTH_NF];
    formatAR[TECLEDA_BALSHRDAY_NF]     = ptb_InRecChild[TECLEDR_BALSHRDAY_NF];
    formatAR[TECLEDA_TRNCOD_CF]        = ptb_InRecChild[TECLEDR_TRNCOD_CF];
    formatAR[TECLEDA_DBLTRNCOD_CF]     = ptb_InRecChild[TECLEDR_DBLTRNCOD_CF];

    formatAR[TECLEDA_RETCTR_NF]        = ptb_InRecChild[TECLEDR_RETCTR_NF];
    formatAR[TECLEDA_RETEND_NT]        = ptb_InRecChild[TECLEDR_RETEND_NT];
    formatAR[TECLEDA_RETSEC_NF]        = ptb_InRecChild[TECLEDR_RETSEC_NF];
    formatAR[TECLEDA_RTY_NF]           = ptb_InRecChild[TECLEDR_RTY_NF];
    formatAR[TECLEDA_RETUW_NT]         = ptb_InRecChild[TECLEDR_RETUW_NT];
    formatAR[TECLEDA_RETOCCYEA_NF]     = ptb_InRecChild[TECLEDR_RETOCCYEA_NF];
    formatAR[TECLEDA_RETACY_NF]        = ptb_InRecChild[TECLEDR_RETACY_NF];
    formatAR[TECLEDA_RETSCOSTRMTH_NF]  = ptb_InRecChild[TECLEDR_RETSCOSTRMTH_NF];
    formatAR[TECLEDA_RETSCOENDMTH_NF]  = ptb_InRecChild[TECLEDR_RETSCOENDMTH_NF];
    formatAR[TECLEDA_RCL_NF]           = ptb_InRecChild[TECLEDR_RCL_NF];
    formatAR[TECLEDA_RETCUR_CF]        = ptb_InRecChild[TECLEDR_RETCUR_CF];
    formatAR[TECLEDA_RETAMT_M]         = ptb_InRecChild[TECLEDR_RETAMT_M];

    formatAR[TECLEDA_INT_NF]           = ptb_InRecChild[TECLEDR_INT_NF];
    formatAR[TECLEDA_RETPAY_NF]        = ptb_InRecChild[TECLEDR_RETPAY_NF];
    formatAR[TECLEDA_RETKEY_CF]        = ptb_InRecChild[TECLEDR_RETKEY_CF];
    formatAR[TECLEDA_CRE_D]            = ptb_InRecChild[TECLEDR_CRE_D];
    formatAR[TECLEDA_CREUSR_CF]        = ptb_InRecChild[TECLEDR_CREUSR_CF];
    formatAR[TECLEDA_LSTUPD_D]         = ptb_InRecChild[TECLEDR_LSTUPD_D];
    formatAR[TECLEDA_LSTUPDUSR_CF]     = ptb_InRecChild[TECLEDR_LSTUPDUSR_CF];

    formatAR[TECLEDA_LOBRET_CF]        = ptb_InRecChild[TECLEDR_LOBRET_CF];

    formatAR[TECLEDA_SOBRET_CF]        = ptb_InRecChild[TECLEDR_SOBRET_CF];
    formatAR[TECLEDA_TOPRET_CF]        = ptb_InRecChild[TECLEDR_TOPRET_CF];
    formatAR[TECLEDA_NATRET_CF]        = ptb_InRecChild[TECLEDR_NATRET_CF];
    formatAR[TECLEDA_GARRET_CF]        = ptb_InRecChild[TECLEDR_GARRET_CF];
    formatAR[TECLEDA_PCPRSKTRYRET_CF]  = ptb_InRecChild[TECLEDR_PCPRSKTRYRET_CF];
    formatAR[TECLEDA_USRCRTCODRET_CT]  = ptb_InRecChild[TECLEDR_USRCRTCODRET_CT];
    formatAR[TECLEDA_USRCRTVALRET_LM]  = ptb_InRecChild[TECLEDR_USRCRTVALRET_LM];
    formatAR[TECLEDA_RETCTRCAT_CF]     = ptb_InRecChild[TECLEDR_RETCTRCAT_CF];
    formatAR[TECLEDA_RETACCTYP_CT]     = ptb_InRecChild[TECLEDR_RETACCTYP_CT];

    formatAR[TECLEDA_TRN_NT]           = ptb_InRecChild[TECLEDR_TRN_NT];         // [05]
    formatAR[TECLEDA_ORICOD_LS]        = ptb_InRecChild[TECLEDR_ORICOD_LS];      // [05]
    formatAR[TECLEDA_RETROAUTO_B]      = ptb_InRecChild[TECLEDR_RETROAUTO_B];    // [05]
    formatAR[TECLEDA_SPEENTNAT_CF]     = ptb_InRecChild[TECLEDR_SPEENTNAT_CF];   // [05]
    formatAR[TECLEDA_EVT_CF]           = ptb_InRecChild[TECLEDR_EVT_CF];         // [05]
    formatAR[TECLEDA_REVT_CF]          = ptb_InRecChild[TECLEDR_REVT_CF];        // [05]
    formatAR[TECLEDA_RETARDRETINT_B]   = ptb_InRecChild[TECLEDR_RETARDRETINT_B]; // [05]
    formatAR[TECLEDA_NEWCOLS1_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS1_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS2_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS2_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS3_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS3_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS4_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS4_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS5_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS5_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS6_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS6_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS7_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS7_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS8_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS8_CF];    // [05]
    formatAR[TECLEDA_NEWCOLS9_CF]      = ptb_InRecChild[TECLEDR_NEWCOLS9_CF];    // [05]

    // recherche du CLISSD_CF dans la table FCLIENT ( si retro interne )
    if ((ncli = n_recherche_CLISSD_CF(ptb_InRecChild)))
    {
        formatAR[TECLEDA_RETINTAMT_M]      = ptb_InRecChild[TECLEDR_RETAMT_M];  //[003]
        formatAR[TECLEDA_PLC_NT]           = ptb_InRecChild[TECLEDR_PLC_NT];    //[003]
        formatAR[TECLEDA_RTO_NF]           = ptb_InRecChild[TECLEDR_RTO_NF];    //[003]
    }

    // pour les primes diff    (110/111, et les SAC 841/842), on garde la ventilation par retrocessionnaire (plc et rto)
    if ( strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "841", 3) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "842", 3) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "110", 3) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "111", 3) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "907", 3) == 0       // [06] spot:30445 Spira 48594 Mise en commentaire des modifications pour utilisation ultérieure (Mep Septembre)
       )
    {
        formatAR[TECLEDA_PLC_NT]           = ptb_InRecChild[TECLEDR_PLC_NT];    //[003]
        formatAR[TECLEDA_RTO_NF]           = ptb_InRecChild[TECLEDR_RTO_NF];    //[003]
    }

    // Regarder si rétrocessionnaire interne pour ces postes
    if ( strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "81", 2) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "82", 2) == 0    ||
            strncmp(ptb_InRecChild[TECLEDR_TRNCOD_CF] + 2, "83", 2) == 0    )
    {
        // recherche du CLISSD_CF dans la table FCLIENT
        if (!ncli)
        {
            formatAR[TECLEDA_CTR_NF]       = "";    // [003]
            formatAR[TECLEDA_END_NT]       = "";    // [003]
            formatAR[TECLEDA_SEC_NF]       = "";    // [003]
            formatAR[TECLEDA_UWY_NF]       = "";    // [003]
            formatAR[TECLEDA_UW_NT]        = "";    // [003]
            formatAR[TECLEDA_OCCYEA_NF]    = "";    // [003]
            formatAR[TECLEDA_ACY_NF]       = "";    // [003]
            formatAR[TECLEDA_SCOSTRMTH_NF] = "";    // [003]
            formatAR[TECLEDA_SCOENDMTH_NF] = "";    // [003]
            formatAR[TECLEDA_CLM_NF]       = "";    // [003]
            formatAR[TECLEDA_CUR_CF]       = "";    // [003]
            formatAR[TECLEDA_AMT_M]        = "";    // [003]
            formatAR[TECLEDA_CED_NF]       = "";    // [003]
            formatAR[TECLEDA_BRK_NF]       = "";    // [003]
            formatAR[TECLEDA_PAY_NF]       = "";    // [003]
            formatAR[TECLEDA_KEY_NF]       = "";    // [003]
            formatAR[TECLEDA_PLC_NT]       = "";
            formatAR[TECLEDA_RTO_NF]       = "";
        }
    }

    n_WriteCols( Kp_OutputFilFTECLEDR_FORMAT_AR_O3, formatAR, SEPARATEUR, 0 ) ;

    RETURN_VAL( OK ) ;
}

//[002]
//==============================================
// objet :     Chargement du tableau TCLIENT
// retour :    Taille du tableau
//==============================================
int n_ChargerTCLIENT()
{
    int i = 0;
    char sz_message[300];

    DEBUT_FCT("n_ChargerTCLIENT");

    memset(&Ktbd_TCLIENT, 0, sizeof(T_TCLIENT) );

    // ouverture du fichier
    if ( n_OpenFileAppl( "ESTC8802_I4", "rb", &Kp_TCLIENT ) )
        return ERR ;

    while (fread(&Ktbd_TCLIENT[i], sizeof(T_TCLIENT), 1, Kp_TCLIENT) == 1)
    {
        if (i > Kn_MaxLigTCLIENT)
        {
            sprintf(sz_message, "Depassement de capacite du tableau Ktbd_TCLIENT[%d]", Kn_MaxLigTCLIENT);
            n_WriteAno(sz_message);
            RETURN_VAL(-1);
        }
        i += 1 ;
    }

    if ( i == 0 )
    {
        n_WriteAno("Aucune ligne Chargee dans le tableau TCLIENT");
    }

    RETURN_VAL(i);
}


//[002]
//==============================================
// objet :     recherche du CLISSD_CF dans le tableau TCLIENT
// retour :    CLISSD_CF
//==============================================
int n_recherche_CLISSD_CF( char **ptb_InRec_Cur )
{
    int   n_CurPos,
          clissd = 0,
          nc = 0;

    DEBUT_FCT("n_recherche_CLISSD_CF");

    nc = atoi(ptb_InRec_Cur[TECLEDR_RTO_NF]);
    for ( n_CurPos = 0; n_CurPos < Kn_TCLIENT; n_CurPos++ )
    {
        if (Ktbd_TCLIENT[n_CurPos].CLI_NF == nc)
        {
            clissd = Ktbd_TCLIENT[n_CurPos].CLISSD_NF;
            break;
        }
    }
    return (clissd);
}
