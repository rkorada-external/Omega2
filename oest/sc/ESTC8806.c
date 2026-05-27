/*==============================================================================
nom de l'application          : OneGL
nom du source                 : ESTC8806.c
date de creation              : 23/03/2011
auteur                        : D.GATIBELZA
specifications                :spot:21408
------------------------------------------------------------------------------
description :   Alimentation des champs du fichier GTAR à partir du fichier perimetre EST_OIADVPERICASE
------------------------------------------------------------------------------
historique des modifications :
    <jj/mm/aaaa> <auteur>    <description de la modification>
[01] 06/04/2014 JBG          :spot:25773 Modify void main declaration to int main
[02] 03/03/2016  Florent     :spot:29066 corrections, on ne fait plus pbd_InRecPERIMETRE avec la structure TECLEDA mais avec celle du périmètre !
==============================================================================*/

//--------------------------------------------------
// inclusion des interfaces des composants importes
//--------------------------------------------------
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "ESTC8802.h"


//----------------------
// variables de travail
//----------------------
FILE    *FichierSortieFTECLEDAR_01;     // pointeur sur le fichier de sortie GTA

T_RUPTURE_VAR       RuptVarPERIMETRE;   // variable de gestion de la rupture sur le perimetre de souscription
T_RUPTURE_SYNC_VAR  RuptVarFTECLEDAR;   // variable de gestion de la synchronisation avec le fichier GTAr

int n_InitPERIMETRE             ( T_RUPTURE_VAR  *);
int n_ActionLignePERIMETRE          ( char **);

int n_InitFTECLEDAR             ( T_RUPTURE_SYNC_VAR * );
int n_ConditionSyncPERIMETRE_FTECLEDAR         ( char **, char ** );
int n_ActionLigneFTECLEDAR           ( char **, char ** );
int n_ActionFTECLEDARsansPERIMETRE    ( char **);

int n_ProcessingRuptureSyncVar  ( T_RUPTURE_SYNC_VAR *, char ** );


/*==============================================================================
objet : point d'entree du programme
retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
    // Initialisation des signaux
    InitSig ();

    if ( n_BeginPgm ( argc, argv ) == ERR )             ExitPgm( ERR_XX , "" );

    // ouverture des fichiers
    if ( n_OpenFileAppl ( "ESTC8806_O1","wt",&FichierSortieFTECLEDAR_01 ) == ERR )      ExitPgm( ERR_XX , "" );

    // Initialisation
    if ( n_InitPERIMETRE( &RuptVarPERIMETRE ) )         ExitPgm( ERR_XX , "" );
  if ( n_InitFTECLEDAR( &RuptVarFTECLEDAR ) )         ExitPgm( ERR_XX , "" );

    // lancement du traitement du fichier Perimetre de souscription IADPERICASE.dat
    if ( n_ProcessingRuptureVar( &RuptVarPERIMETRE ) == ERR )                           ExitPgm( ERR_XX , "" );


    // fermeture des fichiers
  if ( n_CloseFileAppl( "ESTC8806_I1", &( RuptVarPERIMETRE.pf_InputFil ) ) == ERR )   ExitPgm( ERR_XX , "" );
  if ( n_CloseFileAppl( "ESTC8806_I2", &( RuptVarFTECLEDAR.pf_InputFil ) ) == ERR )   ExitPgm( ERR_XX , "" );
  if ( n_CloseFileAppl( "ESTC8806_O1", &FichierSortieFTECLEDAR_01 ) == ERR )          ExitPgm( ERR_XX , "" );

    if ( n_EndPgm() == ERR )                            ExitPgm( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour: 0K
==============================================================================*/
int n_InitPERIMETRE(T_RUPTURE_VAR  *pbd_Rupt)
{
    DEBUT_FCT( "n_InitPERIMETRE" ) ;

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier maitre Perimetre de souscription
    if ( n_OpenFileAppl( "ESTC8806_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
        return ERR ;

    pbd_Rupt->n_NbRupture   = 0 ;
  pbd_Rupt->n_ActionLigne = n_ActionLignePERIMETRE;           // à chaque ligne du fichier maitre
  pbd_Rupt->c_Separ       = SEPARATEUR;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : à chaque ligne du fichier maitre
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePERIMETRE( char **ptb_InRec_Cur )
{
    DEBUT_FCT( "n_ActionLignePERIMETRE" );

    // synchronisation avec le fichier GTAr
    n_ProcessingRuptureSyncVar( &RuptVarFTECLEDAR, ptb_InRec_Cur );

  RETURN_VAL( OK );
}


/*==============================================================================
objet : Initialisation de la synchro du maitre « Perimetre de souscription »
                                     avec l’esclave « GTAr »
retour: OK
==============================================================================*/
int n_InitFTECLEDAR( T_RUPTURE_SYNC_VAR  *pbd_Rupt )
{
    DEBUT_FCT( "n_InitFTECLEDAR" );

    memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

    // ouverture du fichier esclave
    if ( n_OpenFileAppl( "ESTC8806_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
        return ERR ;

    pbd_Rupt->n_NbRupture       = 0 ;                                   // nombre de rupture a gerer
    pbd_Rupt->ConditionEndSync  = n_ConditionSyncPERIMETRE_FTECLEDAR;   // Conditions de synchronisation
  pbd_Rupt->n_FilsSansPere    = n_ActionFTECLEDARsansPERIMETRE;       // fonction d'action quand l'esclave n'a pas de maitre
  pbd_Rupt->n_ActionLigne     = n_ActionLigneFTECLEDAR;               // fonction d'action sur la ligne courante
  pbd_Rupt->c_Separ           = SEPARATEUR;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction de test de synchronisation
retour :   0    ---> pbd_InRecPERIMETRE = pbd_InRecFTECLEDAR ( egalité de rubrique a synchroniser)
         > 0    ---> pbd_InRecOwne> > pbd_InRecFTECLEDAR
         < 0    ---> pbd_InRecOwne> < pbd_InRecFTECLEDAR
==============================================================================*/
int n_ConditionSyncPERIMETRE_FTECLEDAR( char **pbd_InRecPERIMETRE,  char **pbd_InRecFTECLEDAR )
{
  int ret ;

    DEBUT_FCT( "n_ConditionSyncGta" ) ;


    if ( ( ret = strcmp( pbd_InRecPERIMETRE[PER_CTR_NF], pbd_InRecFTECLEDAR[GT_CTR_NF] ) ) != 0 )       return ret;
    if ( ( ret = strcmp( pbd_InRecPERIMETRE[PER_END_NT], pbd_InRecFTECLEDAR[GT_END_NT] ) ) != 0 )       return ret;
    if ( ( ret = strcmp( pbd_InRecPERIMETRE[PER_SEC_NF], pbd_InRecFTECLEDAR[GT_SEC_NF] ) ) != 0 )       return ret;
    if ( ( ret = strcmp( pbd_InRecPERIMETRE[PER_UWY_NF], pbd_InRecFTECLEDAR[GT_UWY_NF]    ) ) != 0 )    return ret;
    if ( ( ret = strcmp( pbd_InRecPERIMETRE[PER_UW_NT],  pbd_InRecFTECLEDAR[GT_UW_NT]  ) ) != 0 )       return ret;

printf("SYNCH: %s / %s\n", pbd_InRecPERIMETRE[PER_CTR_NF], pbd_InRecFTECLEDAR[GT_RETCTR_NF]);
  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet : fonction lancee pour chaque ligne
retour: OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFTECLEDAR( char **pbd_InRecPERIMETRE, char **pbd_InRecFTECLEDAR )
{
    DEBUT_FCT( "n_ActionLigneFTECLEDAR" ) ;

printf("n_ActionLigneFTECLEDAR: \n");

    pbd_InRecFTECLEDAR[TECLEDA_LOBACC_CF]        = pbd_InRecPERIMETRE[TECLEDA_LOBACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_SOBACC_CF]        = pbd_InRecPERIMETRE[TECLEDA_SOBACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_TOPACC_CF]        = pbd_InRecPERIMETRE[TECLEDA_TOPACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_NATACC_CF]        = pbd_InRecPERIMETRE[TECLEDA_NATACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_GARACC_CF]        = pbd_InRecPERIMETRE[TECLEDA_GARACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_PCPRSKTRYACC_CF]  = pbd_InRecPERIMETRE[TECLEDA_PCPRSKTRYACC_CF];
    pbd_InRecFTECLEDAR[TECLEDA_USRCRTCODACC_CT]  = pbd_InRecPERIMETRE[TECLEDA_USRCRTCODACC_CT];
    pbd_InRecFTECLEDAR[TECLEDA_USRCRTVALACC_LM]  = pbd_InRecPERIMETRE[TECLEDA_USRCRTVALACC_LM];
    pbd_InRecFTECLEDAR[TECLEDA_CTRNAT_CT]        = pbd_InRecPERIMETRE[TECLEDA_CTRNAT_CT];
    pbd_InRecFTECLEDAR[TECLEDA_WRKCAT_CT]        = pbd_InRecPERIMETRE[TECLEDA_WRKCAT_CT];
    pbd_InRecFTECLEDAR[TECLEDA_PRDCOD_CT]        = pbd_InRecPERIMETRE[TECLEDA_PRDCOD_CT];
    pbd_InRecFTECLEDAR[TECLEDA_ANLCTY_CF]        = pbd_InRecPERIMETRE[TECLEDA_ANLCTY_CF];
    pbd_InRecFTECLEDAR[TECLEDA_ACCADMTYP_CT]     = pbd_InRecPERIMETRE[TECLEDA_ACCADMTYP_CT];
    pbd_InRecFTECLEDAR[TECLEDA_COMACC_B]         = pbd_InRecPERIMETRE[TECLEDA_COMACC_B];
    pbd_InRecFTECLEDAR[TECLEDA_CPLACCUPD_D]      = pbd_InRecPERIMETRE[TECLEDA_CPLACCUPD_D];
    pbd_InRecFTECLEDAR[TECLEDA_CTRRET_B]         = pbd_InRecPERIMETRE[TECLEDA_CTRRET_B];
    pbd_InRecFTECLEDAR[TECLEDA_UWGRP_CF]         = pbd_InRecPERIMETRE[TECLEDA_UWGRP_CF];
    pbd_InRecFTECLEDAR[TECLEDA_VRS_NF]           = pbd_InRecPERIMETRE[TECLEDA_VRS_NF];
    pbd_InRecFTECLEDAR[TECLEDA_SEG_NF]           = pbd_InRecPERIMETRE[TECLEDA_SEG_NF];
    pbd_InRecFTECLEDAR[TECLEDA_UWORG_CF]         = pbd_InRecPERIMETRE[TECLEDA_UWORG_CF];
    pbd_InRecFTECLEDAR[TECLEDA_ESTCRB_CT]        = pbd_InRecPERIMETRE[TECLEDA_ESTCRB_CT];
    pbd_InRecFTECLEDAR[TECLEDA_ESTCTR_NF]        = pbd_InRecPERIMETRE[TECLEDA_ESTCTR_NF];
    pbd_InRecFTECLEDAR[TECLEDA_ESBACC_NF]        = pbd_InRecPERIMETRE[TECLEDA_ESBACC_NF];
    pbd_InRecFTECLEDAR[TECLEDA_ORGCED_NF]        = pbd_InRecPERIMETRE[TECLEDA_ORGCED_NF];
    pbd_InRecFTECLEDAR[TECLEDA_CEDHORDNBR_NT]    = pbd_InRecPERIMETRE[TECLEDA_CEDHORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_CEDSORDNBR_NT]    = pbd_InRecPERIMETRE[TECLEDA_CEDSORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_ORGCEDHORDNBR_NT] = pbd_InRecPERIMETRE[TECLEDA_ORGCEDHORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_ORGCEDSORDNBR_NT] = pbd_InRecPERIMETRE[TECLEDA_ORGCEDSORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_BRKHORDNBR_NT]    = pbd_InRecPERIMETRE[TECLEDA_BRKHORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_BRKSORDNBR_NT]    = pbd_InRecPERIMETRE[TECLEDA_BRKSORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_FACADMTYP_CT]     = pbd_InRecPERIMETRE[TECLEDA_FACADMTYP_CT];
    pbd_InRecFTECLEDAR[TECLEDA_CLIIND_NF]        = pbd_InRecPERIMETRE[TECLEDA_CLIIND_NF];
    pbd_InRecFTECLEDAR[TECLEDA_HORDNBR_NT]       = pbd_InRecPERIMETRE[TECLEDA_HORDNBR_NT];
    pbd_InRecFTECLEDAR[TECLEDA_RETINTAMT_M]      = pbd_InRecPERIMETRE[TECLEDA_RETINTAMT_M];
    pbd_InRecFTECLEDAR[TECLEDA_BUKRS_CF]         = pbd_InRecPERIMETRE[TECLEDA_BUKRS_CF];
    pbd_InRecFTECLEDAR[TECLEDA_LDGRP_CF]         = pbd_InRecPERIMETRE[TECLEDA_LDGRP_CF];
    pbd_InRecFTECLEDAR[TECLEDA_HKONT_CF]         = pbd_InRecPERIMETRE[TECLEDA_HKONT_CF];
    pbd_InRecFTECLEDAR[TECLEDA_DBLHKONT_CF]      = pbd_InRecPERIMETRE[TECLEDA_DBLHKONT_CF];
    pbd_InRecFTECLEDAR[TECLEDA_GJAHR_NF]         = pbd_InRecPERIMETRE[TECLEDA_GJAHR_NF];
    pbd_InRecFTECLEDAR[TECLEDA_MONAT_NF]         = pbd_InRecPERIMETRE[TECLEDA_MONAT_NF];
    pbd_InRecFTECLEDAR[TECLEDA_VBUND_CF]         = pbd_InRecPERIMETRE[TECLEDA_VBUND_CF];
    pbd_InRecFTECLEDAR[TECLEDA_ZZCED_NF]         = pbd_InRecPERIMETRE[TECLEDA_ZZCED_NF];
    pbd_InRecFTECLEDAR[TECLEDA_SEGMENT_CF]       = pbd_InRecPERIMETRE[TECLEDA_SEGMENT_CF];
    pbd_InRecFTECLEDAR[TECLEDA_BEWAR_CF]         = pbd_InRecPERIMETRE[TECLEDA_BEWAR_CF];
    pbd_InRecFTECLEDAR[TECLEDA_ZZGAAPDIF_CF]     = pbd_InRecPERIMETRE[TECLEDA_ZZGAAPDIF_CF];
    pbd_InRecFTECLEDAR[TECLEDA_BLART_CF]         = pbd_InRecPERIMETRE[TECLEDA_BLART_CF];
    pbd_InRecFTECLEDAR[TECLEDA_ZZRECONKEY_CF]    = pbd_InRecPERIMETRE[TECLEDA_ZZRECONKEY_CF];

    // ecriture en sortie du fichier GTA
    n_WriteCols( FichierSortieFTECLEDAR_01, pbd_InRecFTECLEDAR, SEPARATEUR, 0 ) ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet : fonction lancee quand le fils n'a pas de maitre
retour:	OK ---> traitement correctement effectue
        ERR --> probleme rencontre
==============================================================================*/
int n_ActionFTECLEDARsansPERIMETRE( char **pbd_InRecFTECLEDAR )
{
    DEBUT_FCT( "n_ActionFTECLEDARsansPERIMETRE" ) ;


//printf("n_ActionFTECLEDARsansPERIMETRE: \n");

    // ecriture en sortie du fichier GTA
    n_WriteCols( FichierSortieFTECLEDAR_01, pbd_InRecFTECLEDAR, SEPARATEUR, 0 ) ;

  RETURN_VAL( OK ) ;
}


