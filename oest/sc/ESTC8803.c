/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8803.c
révision                      : $Revision: 1.2 $
date de création              : 18/03/1998
auteur                        : M.HA-THUC
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Enrichissement du GTR en entree ( mise a jour du champs SSDRTO_B )

------------------------------------------------------------------------------
historique des modifications :
    <jj/mm/aaaa>   <auteur>    <description de la modification>
     27/03/2008 J. Ribot     SPOT 15219  ASE15 : recompilation des programmes C
[02] 18/03/2011 D.GATIBELZA  ESTDOM21408 OneLedger
[03] 18/01/2013 Roger Cassis :spot:24698 Si rtossb est null, on force 0
[04] 05/02/2016 Florent      :spot:29066 suite au GLT à 71 colonnes, 16 nouvelles colonnes dans les 2 tables TTCLEDA et R
[005] 15/04/2016 Roger Cassis :spot:29066 correction affectation ssdrto
==============================================================================*/

//--------------------------------------------------
// inclusion des interfaces des composants importes
//--------------------------------------------------
#include <util.h>
#include "struct.h"
//---------------------------------------
// inclusion de l'interface du composant
//---------------------------------------
#include "ESTC8802.h"

#define Kn_MaxLigTCLIENT   1000
#define PLACEMT2_RETCTR_NF   0
#define PLACEMT2_RTY_NF      1
#define PLACEMT2_PLC_NT      2
#define PLACEMT2_RTO_NF      3
#define PLACEMT2_SSDRTO_B    4

//----------------------
// variables de travail
//----------------------
FILE *Kp_OutputFilGtr;                          // pointeur sur le fichier de sortie GTR
FILE *fichier_PLACEMENT2;                       //[002]

T_RUPTURE_VAR       bd_RuptGtr;                 // variable de gestion de la rupture sur le fichier FTECLEDR
T_RUPTURE_SYNC_VAR  RuptPlacement2;             // variable de gestion de la synchronisation avec le fichier des placements

int n_InitGtr               ( T_RUPTURE_VAR  * );
int n_IsR1Gtr               ( char **, char ** );
int n_ActionFirstRuptGtr    ( char ** );
int n_ActionLigneGtr        ( char ** );

int n_InitPLACEMENT2                ( T_RUPTURE_SYNC_VAR * );
int n_ActionLignePLACEMENT2         ( char **, char ** );
int n_ConditionSyncGTR_PLACEMENT2   ( char **, char ** );

char Ksz_SsdRto[2];                             // indicateur retrocessionnaire dans le groupe ?
char Ksz_Rto[8];

int n_ProcessingRuptureSyncVar  ( T_RUPTURE_SYNC_VAR *, char ** );

/*==============================================================================
objet : point d'entree du programme
retour :    En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
            Sinon, par l'appel systeme exit()
==============================================================================*/
int main( int argc, char *argv[] )
{
  // Initialisation des signaux
  InitSig();

  if ( n_BeginPgm ( argc, argv ) == ERR )                                         ExitPgm( ERR_XX , "" );

  if ( n_OpenFileAppl ( "ESTC8803_O1", "wt", &Kp_OutputFilGtr ) == ERR )            ExitPgm( ERR_XX , "" ) ;
  if ( n_InitGtr( &bd_RuptGtr ) )                                                 ExitPgm( ERR_XX , "" ) ;

  if ( n_InitPLACEMENT2( &RuptPlacement2 ) )                                      ExitPgm( ERR_XX , "" ) ;

  // lancement du traitement du fichier GTR
  if ( n_ProcessingRuptureVar( &bd_RuptGtr ) == ERR )                             ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8803_I1", &(bd_RuptGtr.pf_InputFil ) ) == ERR )      ExitPgm( ERR_XX , "" ) ;
  if ( n_CloseFileAppl( "ESTC8803_I2", &(RuptPlacement2.pf_InputFil ) ) == ERR )  ExitPgm( ERR_XX , "" ) ;
  if ( n_CloseFileAppl( "ESTC8803_O1", &Kp_OutputFilGtr ) == ERR )                ExitPgm( ERR_XX , "" ) ;

  if ( n_EndPgm() == ERR )                                                        ExitPgm( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet : fonction d'initialisation de la variable de gestion de rupture du fichier maitre.
retour: 0K
==============================================================================*/
int n_InitGtr(T_RUPTURE_VAR  *pbd_Rupt)
{
   DEBUT_FCT("n_InitGtr");

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  // ouverture du fichier maitre GTR
  if ( n_OpenFileAppl( "ESTC8803_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Gtr;                // fonction du test de rupture de niveau 1
  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRuptGtr;     // fonction lancee en rupture premiere de niveau 1
  pbd_Rupt->n_ActionLigne         = n_ActionLigneGtr;         // fonction d'action sur la ligne courante du fichier maitre
  pbd_Rupt->c_Separ               = SEPARATEUR;

  RETURN_VAL( OK );
}


/*==============================================================================
objet  : fonction de test de rupture de niveau 1
retour :    0       ---> pas de rupture
            sinon   ---> rupture
==============================================================================*/
/* adresse de la ligne en avance, adresse de la ligne courante */
int n_IsR1Gtr( char **pbd_InRec, char **ptGTR_Cur )
{
  int ret;

   DEBUT_FCT("n_IsR1Gtr");

  if ( ( ret = strcmp( pbd_InRec[TECLEDR_RETCTR_NF],  ptGTR_Cur[TECLEDR_RETCTR_NF] ) ) != 0 ) RETURN_VAL (ret);
  if ( ( ret = atoi(pbd_InRec[TECLEDR_RTY_NF]) - atoi(ptGTR_Cur[TECLEDR_RTY_NF]) )     != 0 ) RETURN_VAL (ret);
  if ( ( ret = atoi(pbd_InRec[TECLEDR_PLC_NT]) - atoi(ptGTR_Cur[TECLEDR_PLC_NT]) )     != 0 ) RETURN_VAL (ret);

  RETURN_VAL( 0 );
}


//==============================================================================
//objet :     fonction lancee en rupture premiere de niveau 1
//retour :  OK ---> traitement correctement effectue
//            ERR --> probleme rencontre
//==============================================================================
/* adresse de la ligne courante */
int n_ActionFirstRuptGtr( char **ptGTR )
{
   DEBUT_FCT("n_ActionFirstRuptGtr");

  // initialisation de SSDRTO_B avant la synchro
  strcpy(Ksz_SsdRto, "0");
  strcpy(Ksz_Rto, "0");

  // synchronisation avec le fichier des placements
  n_ProcessingRuptureSyncVar( &RuptPlacement2, ptGTR );

  RETURN_VAL ( OK );
}


//==============================================================================
// objet : fonction lancee pour chaque ligne
// retour :    OK ---> traitement correctement effectue
//             ERR --> probleme rencontre
//==============================================================================
int n_ActionLigneGtr( char **ptGTR )
{
   DEBUT_FCT("n_ActionLigneGtr");

  // mise a jour des champs RTO_NF et SSDRTO_B dans le GTR en entree
  if (strcmp(Ksz_Rto, "0") != 0 )
  {
    ptGTR[TECLEDR_RTO_NF]   = Ksz_Rto;
    ptGTR[TECLEDR_SSDRTO_B] = Ksz_SsdRto;
  }
  if (strcmp(ptGTR[TECLEDR_SSDRTO_B], "0") != 0 && strcmp(ptGTR[TECLEDR_SSDRTO_B], "1") != 0) ptGTR[TECLEDR_SSDRTO_B] = "0"; //[005]
//printf("TECLEDR_TRN_NT 3 = %s - TECLEDR_SSDRTO_B = %s\n",ptGTR[TECLEDR_TRN_NT],ptGTR[TECLEDR_SSDRTO_B]);

  // ecriture en sortie du GTR au format de TTECLEDR
  n_WriteCols( Kp_OutputFilGtr, ptGTR, SEPARATEUR, 0 ) ;

  RETURN_VAL( OK );
}

//==============================================================================
// objet  : Initialisation de la synchronisation du maitre « GTR »
//                                          avec l’esclave « Placements »
// retour : OK
//==============================================================================
int n_InitPLACEMENT2( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitPLACEMENT2") ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  // ouverture du fichier esclave des placements
  if ( n_OpenFileAppl( "ESTC8803_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  // fonction du test de synchronisation de la ligne du maitre avec l'esclave
  pbd_Rupt->ConditionEndSync  = n_ConditionSyncGTR_PLACEMENT2;
  pbd_Rupt->n_ActionLigne     = n_ActionLignePLACEMENT2;          // fonction d'action sur la ligne courante
  pbd_Rupt->c_Separ           = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}


//==============================================================================
// objet  : fonction de test de synchronisation
// retour :    0    ---> ptGTR = ptPLACEMENT2 ( egalité de rubrique a synchroniser)
//           > 0    ---> ptGTR > ptPLACEMENT2
//           < 0    ---> ptGTR < ptPLACEMENT2
//==============================================================================
int n_ConditionSyncGTR_PLACEMENT2( char **ptGTR, char **ptPLACEMENT2 )
{
  int ret;

  DEBUT_FCT("n_ConditionSyncGTR_PLACEMENT2") ;

  if ( ( ret = strcmp( ptGTR[TECLEDR_RETCTR_NF],  ptPLACEMENT2[PLACEMT2_RETCTR_NF] ) ) != 0 )  return ret;
  if ( ( ret = ( atoi(ptGTR[TECLEDR_RTY_NF]) - atoi(ptPLACEMENT2[PLACEMT2_RTY_NF]) ) ) != 0 )  return ret;
  if ( ( ret = ( atoi(ptGTR[TECLEDR_PLC_NT]) - atoi(ptPLACEMENT2[PLACEMT2_PLC_NT]) ) ) != 0 )  return ret;

  RETURN_VAL( 0 ) ;
}


//==============================================================================
// objet  : fonction lancee pour chaque ligne
// retour : OK ---> traitement correctement effectue
//          ERR --> probleme rencontre
//==============================================================================
int n_ActionLignePLACEMENT2( char **ptGTR, char **ptPLACEMENT2 )
{
  DEBUT_FCT("n_ActionLignePLACEMENT2") ;

  // recherche de l'indicateur retrocessionnaire dans le groupe ?
  strcpy( Ksz_SsdRto, ptPLACEMENT2[PLACEMT2_SSDRTO_B] ) ;
  strcpy( Ksz_Rto,    ptPLACEMENT2[PLACEMT2_RTO_NF] ) ;


  RETURN_VAL( OK );
}

