/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application            : ESTIMATIONS
nom du source                   : ESTC2151.c
date de création                : 19/04/2011
auteur                          : D.GATIBELZA
Appelé par le batch             : ESID2041.cmd
------------------------------------------------------------------------------
description : 1: Accès au périmètre : IAV + IRV PERICASE pour retirer les complements
                 sur les terminés comptables.
                 si traite Acc/Retro terminés comptables => pas de complement
              2: Accès pour les contrats de Retro ( postes 2% ou 4% ) pour filtrer
                 les enregistrements qui ne sont pas dans placement
                 si RETCTR/RETSEC/RETRTY ne sont pas dans placement => pas de compléments.
------------------------------------------------------------------------------
historique des modifications :
[001] 01/02/2013 R. Cassis  :spot:24790 Renomage du programme ESTC2131bis en ESTC2151
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"


//#define TRACE_1
//#define TRACE_TC
//#define TRACE_FCT



#define ACCEPT          1
#define RETRO           0
#define EXISTE          1
#define EXISTE_PAS      0
#define TERMINE_CPT     9
#define PAS_TERMINE_CPT 0


T_RUPTURE_VAR               bd_RuptGT;
int n_InitGT                  ( T_RUPTURE_VAR * );
int n_IsRuptureGT1            ( char **, char **);
int n_ActionFirstGT1          ( char ** );
int n_ActionLigneGt           ( char ** );

T_RUPTURE_SYNC_VAR          bd_RuptIAVPERIM;
int n_InitAVPERIMETRE         ( T_RUPTURE_SYNC_VAR *);
int n_ConditionSyncGT_AVPERIM ( char **, char **);
int n_ActionLigneAVPerimetre  ( char **, char **);

T_RUPTURE_SYNC_VAR          bd_RuptIARPERIM;
int n_InitARPERIMETRE         ( T_RUPTURE_SYNC_VAR *);
int n_ConditionSyncGT_ARPERIM ( char **, char **);
int n_ActionLigneARPerimetre  ( char **, char **);

T_RUPTURE_SYNC_VAR          bd_RuptPLC;
int n_InitPLACEMENT           ( T_RUPTURE_SYNC_VAR *);
int n_ConditionSyncGT_PLC     ( char **, char **);
int n_ActionLignePlacement    ( char **, char **);

void DEBUT_FONCTION(char *);

FILE *fp_Fichier_GT_SORTIE;             // pointeur de fichier de sortie GT
FILE *fp_FichierLog_TermineComptable;   // pointeur de fichier log de sortie des lignes pas reconduite parceque Terminés comptables
FILE *fp_FichierLog_RetroPasPlacement;  // pointeur de fichier log de sortie des lignes RETRO pas reconduites parceque pas de placement


int TermineComptable=0;
int Contrat=0;
int Placement=0;



//==============================================================================
// objet :     point d'entree du programme
// retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
//             Sinon, par l'appel systeme exit()
//==============================================================================
int main(int argc  , char *argv[])
{
    // Initialisation des signaux
    InitSig ();

    if ( n_BeginPgm ( argc, argv ) == ERR )                                             ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC2151_O1","wt", &fp_Fichier_GT_SORTIE ) == ERR )               ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC2151_O2","wt", &fp_FichierLog_TermineComptable ) == ERR )     ExitPgm( ERR_XX , "" ) ;
    if ( n_OpenFileAppl ( "ESTC2151_O3","wt", &fp_FichierLog_RetroPasPlacement ) == ERR )    ExitPgm( ERR_XX , "" ) ;

    // Initialisation des variables
    if ( n_InitGT           ( &bd_RuptGT ) )                                            ExitPgm( ERR_XX , "" ) ;
    if ( n_InitAVPERIMETRE  ( &bd_RuptIAVPERIM ) )                                      ExitPgm( ERR_XX , "" ) ;
    if ( n_InitARPERIMETRE  ( &bd_RuptIARPERIM ) )                                      ExitPgm( ERR_XX , "" ) ;
    if ( n_InitPLACEMENT    ( &bd_RuptPLC ) )                                           ExitPgm( ERR_XX , "" ) ;

    // lancement du traitement du fichier des placements
    if ( n_ProcessingRuptureVar( &bd_RuptGT ) == ERR )                                  ExitPgm( ERR_XX , "" ) ;

    if ( n_CloseFileAppl( "ESTC2151_I4", &( bd_RuptPLC.pf_InputFil ) )      == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_I3", &( bd_RuptIARPERIM.pf_InputFil ) ) == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_I2", &( bd_RuptIAVPERIM.pf_InputFil ) ) == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_I1", &( bd_RuptGT.pf_InputFil ) )       == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_O3", &fp_FichierLog_RetroPasPlacement ) == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_O2", &fp_FichierLog_TermineComptable )  == ERR ) ExitPgm( ERR_XX , "" ) ;
    if ( n_CloseFileAppl( "ESTC2151_O1", &fp_Fichier_GT_SORTIE )            == ERR ) ExitPgm( ERR_XX , "" ) ;

    if ( n_EndPgm() == ERR )                                                            ExitPgm( ERR_XX , "" ) ;

  exit( OK );
}


//==============================================================================
// objet : Initialisation du maitre « GT »
// retour: OK
//==============================================================================
int n_InitGT( T_RUPTURE_VAR *RuptGT )
{
    DEBUT_FONCTION( "n_InitGT" );

    memset( RuptGT, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier esclave
    if ( n_OpenFileAppl( "ESTC2151_I1", "rt", &( RuptGT->pf_InputFil ) ) == ERR )      return ERR ;

    // nombre de rupture a gerer
    RuptGT->n_NbRupture = 1;
    RuptGT->n_ConditionRupture[0]   = n_IsRuptureGT1;
    RuptGT->n_ActionFirst[0]        = n_ActionFirstGT1;
    RuptGT->n_ActionLigne           = n_ActionLigneGt;
    RuptGT->c_Separ = SEPARATEUR;

  RETURN_VAL( OK );
}



//==============================================================================
//objet :   Condition de ruppture 1 sur le fichier GT
//retour :  0   ---> Pas de rupture
//          1   ---> rupture
//==============================================================================*/
int n_IsRuptureGT1( char **ptPrec_GT, char **pt_GT )
{
    DEBUT_FONCTION( "n_IsRuptureGT1" );

    if ( strcmp(ptPrec_GT[GT_CTR_NF], pt_GT[GT_CTR_NF]) !=0 )       RETURN_VAL(1);
    if ( strcmp(ptPrec_GT[GT_END_NT], pt_GT[GT_END_NT]) !=0 )       RETURN_VAL(1);
    if ( strcmp(ptPrec_GT[GT_SEC_NF], pt_GT[GT_SEC_NF]) !=0 )       RETURN_VAL(1);
    if ( strcmp(ptPrec_GT[GT_UWY_NF], pt_GT[GT_UWY_NF]) !=0 )       RETURN_VAL(1);
    if ( strcmp(ptPrec_GT[GT_UW_NT] , pt_GT[GT_UW_NT])  !=0 )       RETURN_VAL(1);

  RETURN_VAL(0);
}



//==============================================================================
// objet : En rupture première du fichier GT
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
//==============================================================================
int n_ActionFirstGT1( char **pt_GT  )
{
    DEBUT_FONCTION( "n_ActionFirstGT1" );

    TermineComptable=PAS_TERMINE_CPT;
    Contrat=ACCEPT;
    Placement=EXISTE_PAS;

    if(strncmp(pt_GT[GT_TRNCOD_CF], "2", 1 ) == 0 || 
       strncmp(pt_GT[GT_TRNCOD_CF], "4", 1 ) == 0 )
        Contrat = RETRO;

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("Action First 1: CTR[%s] ~END[%s] ~SEC[%s] ~UWY[%s] ~UW[%s]\n",
    pt_GT[GT_CTR_NF],
    pt_GT[GT_END_NT],
    pt_GT[GT_SEC_NF],
    pt_GT[GT_UWY_NF],
    pt_GT[GT_UW_NT]);
#endif
//#--------------
//#  FIN TRACE
//#==============

    //synchronisation avec le fichier PERIMETRE ACCEPTATION
    n_ProcessingRuptureSyncVar (&bd_RuptIAVPERIM, pt_GT);

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("Action First 2: TermineComptable[%d] != %d\n", TermineComptable, TERMINE_CPT );
#endif
//#--------------
//#  FIN TRACE
//#==============

    //synchronisation avec le fichier PERIMETRE RETRO
    n_ProcessingRuptureSyncVar (&bd_RuptIARPERIM, pt_GT);

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("Action First 3: TermineComptable[%d] != %d\n", TermineComptable, TERMINE_CPT );
#endif
//#--------------
//#  FIN TRACE
//#==============

    //synchronisation avec le fichier PLACEMENT
    if (Contrat == RETRO )
        n_ProcessingRuptureSyncVar (&bd_RuptPLC, pt_GT);
    
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("Action First 4: TermineComptable[%d] != %d\n", TermineComptable, TERMINE_CPT );
#endif
//#--------------
//#  FIN TRACE
//#==============
    
  RETURN_VAL ( OK ) ;
}



//==============================================================================
// objet : à Chaque ligne du fichier GT
// retour: OK ---> traitement correctement effectue
//         ERR --> probleme rencontre
//==============================================================================
int n_ActionLigneGt( char **pt_GT )
{
    DEBUT_FONCTION("n_ActionLigneGt");
    
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("test : TermineComptable[%d] != %d\n", TermineComptable, TERMINE_CPT );
#endif
//#--------------
//#  FIN TRACE
//#==============



    if( ( TermineComptable != TERMINE_CPT ) &&
        ( Contrat == ACCEPT || ( Contrat == RETRO && Placement == EXISTE) ) )
    {
        n_WriteCols( fp_Fichier_GT_SORTIE, pt_GT, SEPARATEUR, 0 ) ;
    }

    if( TermineComptable == TERMINE_CPT )
    {
        n_WriteCols( fp_FichierLog_TermineComptable, pt_GT, SEPARATEUR, 0 ) ;
    }

    if( Contrat == RETRO && Placement == EXISTE_PAS )
    {
        n_WriteCols( fp_FichierLog_RetroPasPlacement, pt_GT, SEPARATEUR, 0 ) ;
    }

  RETURN_VAL(OK);
}



//------------------------------------------------------------------------------
//==============================================================================
// objet : Initialisation du fichier Perimetre.
// retour: 0K
//==============================================================================
int n_InitAVPERIMETRE( T_RUPTURE_SYNC_VAR *RuptSyncAVPERIMETRE)
{
    DEBUT_FONCTION( "n_InitAVPERIMETRE" );

    memset( RuptSyncAVPERIMETRE, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier maitre perimetre
    if ( n_OpenFileAppl( "ESTC2151_I2", "rt", &( RuptSyncAVPERIMETRE->pf_InputFil ) ) )     return ERR;

    // nombre de rupture a gerer
    RuptSyncAVPERIMETRE->n_NbRupture = 0;
    RuptSyncAVPERIMETRE->ConditionEndSync = n_ConditionSyncGT_AVPERIM ;
    RuptSyncAVPERIMETRE->n_ActionLigne = n_ActionLigneAVPerimetre;
    RuptSyncAVPERIMETRE->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK );
}



//==============================================================================
// objet : fonction de test de synchronisation
// retour:   0       ---> pt_GT = ptb_AVPERIMETRE ( egalité de rubrique a synchroniser)
//         > 0       ---> pt_GT > ptb_AVPERIMETRE
//         < 0       ---> pt_GT < ptb_AVPERIMETRE
//==============================================================================
int n_ConditionSyncGT_AVPERIM( char **pt_GT, char **ptb_AVPERIMETRE )
{
  int ret ;

    DEBUT_FONCTION( "n_ConditionSyncGT_AVPERIM" ) ;

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
if(strcmp(ptb_AVPERIMETRE[PER_CTR_NF], "04T000028")==0)
{
printf("n_ConditionSyncGT_AVPERIM: CTR[%s/%s] ~END[%s/%s] ~SEC[%s/%s] ~UWY[%s/%s] ~UW[%s/%s]",
    pt_GT[GT_CTR_NF], ptb_AVPERIMETRE[PER_CTR_NF],
    pt_GT[GT_END_NT], ptb_AVPERIMETRE[PER_END_NT],
    pt_GT[GT_SEC_NF], ptb_AVPERIMETRE[PER_SEC_NF],
    pt_GT[GT_UWY_NF], ptb_AVPERIMETRE[PER_UWY_NF],
    pt_GT[GT_UW_NT] , ptb_AVPERIMETRE[PER_UW_NT]);
printf("/\n");
}
#endif
//#--------------
//#  FIN TRACE
//#==============

    if ( ( ret = strcmp(pt_GT[GT_CTR_NF],  ptb_AVPERIMETRE[PER_CTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_END_NT],  ptb_AVPERIMETRE[PER_END_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_SEC_NF],  ptb_AVPERIMETRE[PER_SEC_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UWY_NF],  ptb_AVPERIMETRE[PER_UWY_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UW_NT],   ptb_AVPERIMETRE[PER_UW_NT]  ) ) != 0 ) return ret;

  RETURN_VAL( 0 ) ;
}
   

   
   
/*==============================================================================
objet :  fonction lancee pour chaque ligne du perimetre
retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneAVPerimetre( char **pt_GT, char **ptb_AVPERIMETRE )
{

    DEBUT_FONCTION("n_ActionLigneAVPerimetre");
    
    TermineComptable=atoi(ptb_AVPERIMETRE[PER_SECACCSTS_CT]);


//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
if(strcmp(ptb_AVPERIMETRE[PER_CTR_NF], "04T000028")==0)
{
printf("n_ActionLigneAVPerimetre: CTR[%s/%s] ~END[%s/%s] ~SEC[%s/%s] ~UWY[%s/%s] ~UW[%s/%s]: TERMINE COMPTABLE = %d\n",
    pt_GT[GT_CTR_NF], ptb_AVPERIMETRE[PER_CTR_NF],
    pt_GT[GT_END_NT], ptb_AVPERIMETRE[PER_END_NT],
    pt_GT[GT_SEC_NF], ptb_AVPERIMETRE[PER_SEC_NF],
    pt_GT[GT_UWY_NF], ptb_AVPERIMETRE[PER_UWY_NF],
    pt_GT[GT_UW_NT] , ptb_AVPERIMETRE[PER_UW_NT],
    TermineComptable);
}
#endif
//#--------------
//#  FIN TRACE
//#==============

  RETURN_VAL(OK);
}



//------------------------------------------------------------------------------
//==============================================================================
// objet : Initialisation du fichier Perimetre.
// retour: 0K
//==============================================================================
int n_InitARPERIMETRE( T_RUPTURE_SYNC_VAR *RuptSyncARPERIMETRE)
{
    DEBUT_FONCTION( "n_InitARPERIMETRE" );

    memset( RuptSyncARPERIMETRE, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier maitre perimetre
    if ( n_OpenFileAppl( "ESTC2151_I3", "rt", &( RuptSyncARPERIMETRE->pf_InputFil ) ) )     return ERR;

    // nombre de rupture a gerer
    RuptSyncARPERIMETRE->n_NbRupture = 0;
    RuptSyncARPERIMETRE->ConditionEndSync = n_ConditionSyncGT_ARPERIM ;
    RuptSyncARPERIMETRE->n_ActionLigne = n_ActionLigneARPerimetre;
    RuptSyncARPERIMETRE->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK );
}



//==============================================================================
// objet : fonction de test de synchronisation
// retour:   0       ---> pt_GT = ptb_ARPERIMETRE ( egalité de rubrique a synchroniser)
//         > 0       ---> pt_GT > ptb_ARPERIMETRE
//         < 0       ---> pt_GT < ptb_ARPERIMETRE
//==============================================================================
int n_ConditionSyncGT_ARPERIM( char **pt_GT, char **ptb_ARPERIMETRE )
{
  int ret ;

    DEBUT_FONCTION( "n_ConditionSyncGT_ARPERIM" ) ;

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_1
//printf("CTR:%d/%d  ", GT_CTR_NF, PER_CTR_NF);
//printf("END:%d/%d  ", GT_END_NT, PER_END_NT);
//printf("SEC:%d/%d  ", GT_SEC_NF, PER_SEC_NF);
//printf("UWY:%d/%d  ", GT_UWY_NF, PER_UWY_NF);
//printf("UW :%d/%d\n", GT_UW_NT,  PER_UW_NT);
printf("CTR[%s/%s] ~END[%s/%s] ~SEC[%s/%s] ~UWY[%s/%s] ~UW[%s/%s]",
    pt_GT[GT_CTR_NF], ptb_ARPERIMETRE[PER_CTR_NF],
    pt_GT[GT_END_NT], ptb_ARPERIMETRE[PER_END_NT],
    pt_GT[GT_SEC_NF], ptb_ARPERIMETRE[PER_SEC_NF],
    pt_GT[GT_UWY_NF], ptb_ARPERIMETRE[PER_UWY_NF],
    pt_GT[GT_UW_NT] , ptb_ARPERIMETRE[PER_UW_NT]);
for(int i=0;i<10;i++)
{
printf("[i:%d]%s~%s\n",
    i, pt_GT[i], ptb_ARPERIMETRE[i]);
}
printf("/\n");
#endif
//#--------------
//#  FIN TRACE
//#==============


    if ( ( ret = strcmp(pt_GT[GT_CTR_NF],  ptb_ARPERIMETRE[PER_CTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_END_NT],  ptb_ARPERIMETRE[PER_END_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_SEC_NF],  ptb_ARPERIMETRE[PER_SEC_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UWY_NF],  ptb_ARPERIMETRE[PER_UWY_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UW_NT],   ptb_ARPERIMETRE[PER_UW_NT]  ) ) != 0 ) return ret;

  RETURN_VAL( 0 ) ;
}
   

   
   
/*==============================================================================
objet :  fonction lancee pour chaque ligne du perimetre
retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneARPerimetre( char **pt_GT, char **ptb_ARPERIMETRE )
{

    DEBUT_FONCTION("n_ActionLigneARPerimetre");


    TermineComptable=atoi(ptb_ARPERIMETRE[PER_SECACCSTS_CT]);

//#==============
//#    TRACE
//#--------------
#ifdef TRACE_TC
printf("CTR[%s/%s] ~END[%s/%s] ~SEC[%s/%s] ~UWY[%s/%s] ~UW[%s/%s]: TERMINE COMPTABLE = %d",
    pt_GT[GT_CTR_NF], ptb_ARPERIMETRE[PER_CTR_NF],
    pt_GT[GT_END_NT], ptb_ARPERIMETRE[PER_END_NT],
    pt_GT[GT_SEC_NF], ptb_ARPERIMETRE[PER_SEC_NF],
    pt_GT[GT_UWY_NF], ptb_ARPERIMETRE[PER_UWY_NF],
    pt_GT[GT_UW_NT] , ptb_ARPERIMETRE[PER_UW_NT],
    TermineComptable);
#endif
//#--------------
//#  FIN TRACE
//#==============

  RETURN_VAL(OK);
}



//------------------------------------------------------------------------------
//==============================================================================
// objet : Initialisation du fichier Placement.
// retour: 0K
//==============================================================================
int n_InitPLACEMENT ( T_RUPTURE_SYNC_VAR *RuptSyncPLACEMENT)
{
    DEBUT_FONCTION( "n_InitPLACEMENT" );

    memset( RuptSyncPLACEMENT, 0, sizeof( T_RUPTURE_VAR ) ) ;

    // ouverture du fichier maitre perimetre
    if ( n_OpenFileAppl( "ESTC2151_I4", "rt", &( RuptSyncPLACEMENT->pf_InputFil ) ) )     return ERR;

    // nombre de rupture a gerer
    RuptSyncPLACEMENT->n_NbRupture = 0;
    RuptSyncPLACEMENT->ConditionEndSync = n_ConditionSyncGT_PLC ;
    RuptSyncPLACEMENT->n_ActionLigne = n_ActionLignePlacement;
    RuptSyncPLACEMENT->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK );
}



//==============================================================================
// objet : fonction de test de synchronisation
// retour:   0       ---> pt_GT = pt_PLACEMENT ( egalité de rubrique a synchroniser)
//         > 0       ---> pt_GT > pt_PLACEMENT
//         < 0       ---> pt_GT < pt_PLACEMENT
//==============================================================================
int n_ConditionSyncGT_PLC( char **pt_GT, char **pt_PLACEMENT )
{
  int ret ;

    DEBUT_FONCTION( "n_ConditionSyncGT_PLC" ) ;

    if ( ( ret = strcmp(pt_GT[GT_CTR_NF], pt_PLACEMENT[PLA_RETCTR_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_END_NT], pt_PLACEMENT[PLA_RETEND_NT] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_SEC_NF], pt_PLACEMENT[PLA_RETSEC_NF] ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UWY_NF], pt_PLACEMENT[PLA_RTY_NF]    ) ) != 0 ) return ret;
    if ( ( ret = strcmp(pt_GT[GT_UW_NT] , pt_PLACEMENT[PLA_RETUW_NT]  ) ) != 0 ) return ret;

  RETURN_VAL( 0 );
}
   

   
   
/*==============================================================================
objet :  fonction lancee pour chaque ligne du perimetre
retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePlacement( char **pt_GT, char **ptb_PLACEMENT )
{
    DEBUT_FONCTION("n_ActionLignePlacement");

        Placement = EXISTE;

  RETURN_VAL(OK);
}


//==============================================================================
// objet : Recherche si le poste appartient au code de regroupement
// retour: 1   appartient
//         0   non
//==============================================================================
void DEBUT_FONCTION(char *fonction)
{
    DEBUT_FCT(fonction);
//#==============
//#    TRACE
//#--------------
#ifdef TRACE_FCT
printf("%s\n", fonction);
#endif
//#--------------
//#  FIN TRACE
//#==============
}



