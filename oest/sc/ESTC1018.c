/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTC1018.c
revision                      : $Revision: 1.2 $
date de creation              : 05/08/1997
auteur                        : M.HA-THUC
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   VENTILATION DES CHARGES AU DETAIL DES PC/AC DANS LE GT

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa><auteur>    <description de la modification>
     27/03/2008 J. Ribot    SPOT 15219 ASE15 : recompilation des programmes C
[02] 05/03/2014 R. Cassis  :spot:25427 Modification transfert du suffixe poste pour adaptation Linux
[03] 06/04/2014 JBG        :spot:25773 Modify void main declaration to int main
[04] 03/02/2015 F.MARAGNES :spot:28140 appel calculExerciceSeuil et ajout d'un test sur la sinistrabilite
[05] 18/11/2015 Florent    :spot:29643 utilise le calculExerciceSeuil pour les taxes sur primes
[06] 01/02/2016 -=Dch=-    :spot:30167 Modificiation des calculs de compléments de charges sur EPP et RPP
[07] 05/12/2016   PGA       SPIRA 50815-47759-47946 Correct des IPP et OPP
[08] 02/08/2017 R. cassis  :spira:61387 - Désactivation de la FAR estimée (surcom) si l'option estcomtyp_ct est en mode manuel (valeur = 3)
[09] 23/05/2018 M.Naji	!  :spira 61503  ventilation de la taxe de base EPP et RPP
[10] 13/12/2018   Spira:73841; Ecart INT/IN2 sur les postes 11312102 et 11312106
[11] 22/05/2019 MZM        :spira:61503: senario 3 ne fonctionne pas correctement sur la partie  taxe ; Modif de PERICOND  
[12] 01/10/2019 MiS        :spira:77463: Split Minimum and rest of variable commission
[13] 02/10/2019 MiS        :spira:77462: split DAC Commission into DAC Fixed Commission and DAC Variable Commission
[14] 28/02/2020 MiS        :REQ.P.09.6 : DAC IFRS17
[15] 18/05/2020 RC         :spira:86652 - Suppression d'une boucle car elle a été doublée ce qui fait diminuer le montant par 2 dans fonction n_VentilationComplement
[16] 01/07/2020 MiS        :spira:87621 : Ajout initialisation de variables 
[17] 14/04/2021 MiS        :spira:86214 : Ecriture de Recieved Minimum Variable Commission Charge
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
#include "ESTC1018.h"

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/

#define TRACE_PERICOND

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE    *Kp_OutputFilGtLoa ; /* pointeur sur le fichier de sortie GT des charges estimees */

T_RUPTURE_VAR       bd_RuptPerUw ; /* variable de gestion de la rupture sur le perimetre */
T_RUPTURE_SYNC_VAR  bd_RuptGtPre ; /* variable de gestion de la synchronisation avec le fichier GT des complements de primes */
T_RUPTURE_SYNC_VAR  bd_RuptGtBcRec ; /* variable de gestion de la synchronisation avec le fichier GT des reconstitution et burning cost */
T_RUPTURE_SYNC_VAR  bd_RuptGtPna ; /* variable de gestion de la synchronisation avec le fichier GT des PNA */
T_RUPTURE_SYNC_VAR  bd_RuptPrmLoa ; /* variable de gestion de la synchronisation avec fichier des montants de primes et charges */
T_RUPTURE_SYNC_VAR  bd_RuptGtEpp ; /* variable de gestion de la synchronisation avec fichier GT des EPP */
T_RUPTURE_SYNC_VAR  bd_RuptGtRpp ; /* variable de gestion de la synchronisation avec le fichier GT des RPP */
T_RUPTURE_SYNC_VAR  bd_RuptPeriCondition ; /* variable de gestion de la synchro des condition EPP et RPP */

char  Ksz_CloDat[10] ;      /* parametre de la chaîne: libelle d'inventaire */
char  Annee_bilan[5] ;
char  Mois_bilan[3] ;
char  Jour_bilan[3] ;

double  Ktd_Comp[COMP_NBPOSTE] ;  /* tableau des complements de charges, taxes et courtage */

T_PCACM Ktbd_GtPBR[NB_GT_MAX] ; /* tableau des Pc/Ac et montants du GT des Primes et du GT des Burning cost et Reconstitution par affaire */
T_PCACM2 Ktbd_GtEpp[NB_GT_MAX] ;  /* tableau des Pc/Ac et montants du GT des EPP par affaire */
T_PCACM2 Ktbd_GtRpp[NB_GT_MAX] ;  /* tableau des Pc/Ac et montants du GT des RPP par affaire */
T_PCACM2 Ktbd_GtPpna[NB_GT_MAX] ; /* tableau des Pc/Ac et montants du GT des PNA par affaire */
T_PERICOND periCond ; // Tableau des condition EPP et RPP

int Kn_GtPBR_Nbp ;    /* nombre de poste du tableau Ktbd_GtPeBcRec */
int Kn_GtEpp_Nbp ;    /* nombre de poste du tableau Ktbd_GtEpp */
int Kn_GtRpp_Nbp ;    /* nombre de poste du tableau Ktbd_GtRpp */
int Kn_GtPpna_Nbp ;   /* nombre de poste du tableau Ktbd_GtPpna */

// [12]
double Kd_MinVarCE ;
double Kd_ResVarCE ;
short b_Acmtrs[3] ; // Bool pour tester si Fixed, Minimum ou rest of Variable Commission

//[13]
double Kd_DACfix ;
double Kd_DACvar ;
//[14]
double Kd_DACIFRS17;
//[17]
double Kd_RecievedMinVarCom;

int n_InitPerUw     ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLignePerUw    ( char **pbd_InRec_Cur ) ;

int n_InitGtPre     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPre    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPre  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtBcRec   ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtBcRec  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtBcRec  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtPna     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPna    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPna  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitPrmLoa    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLignePrmLoa   ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncPrmLoa ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtEpp     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtEpp    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtEpp  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtRpp     ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtRpp    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtRpp  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_InitGtPeriCondition ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneGtPeriCond    ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncGtPeriCond  ( char **pbd_InRecOwner, char **pbd_InRecChild ) ;

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char **ptb_InRecOwner );

int n_VentilationComplement( T_PCACM *ptbd_Gt_I, int NbPostes, T_PCACM *ptbd_Gt_O, double Comp ) ;
int n_VentilationComplement2( T_PCACM2 *ptbd_Gt_I, int NbPostes, T_PCACM2 *ptbd_Gt_O, double Comp ) ;
int n_InitVariables( void ) ;


int  n_initCalculExerciceSeuil(char *nomFic);

int n_CalculExerciceSeuil(short  , short esb_cf, char *lob_cf, short nat_cf );

BOOL Kb_ReturnStatus = 0; /* statut de retour du programme (=0 si OK, 1 sinon) */

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

  /* recuperation du libelle d'inventaire passe en argument */
  strcpy( Ksz_CloDat, psz_GetCharArgv( 1 ) ) ;

  /* Eclatement de la date AAAAMMJJ en 3 chaines de caractere */
  sscanf( Ksz_CloDat, "%4s%2s%2s", Annee_bilan, Mois_bilan, Jour_bilan ) ;

  /* ouverture du fichier de sortie GT des charges estimees */
  if ( n_OpenFileAppl ( "ESTC1018_O1", "wt", &Kp_OutputFilGtLoa ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPerUw*/
  if ( n_InitPerUw( &bd_RuptPerUw) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtPre */
  if ( n_InitGtPre( &bd_RuptGtPre ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtBcRec */
  if ( n_InitGtBcRec( &bd_RuptGtBcRec ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtPna */
  if ( n_InitGtPna( &bd_RuptGtPna ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptPrmLoa */
  if ( n_InitPrmLoa( &bd_RuptPrmLoa ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtEpp */
  if ( n_InitGtEpp( &bd_RuptGtEpp ) )
    ExitPgm( ERR_XX , "") ;
  /* Initialisation de la variable bd_RuptGtRpp */
  if ( n_InitGtRpp( &bd_RuptGtRpp ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGtBcRec */
  if (n_InitGtPeriCondition ( &bd_RuptPeriCondition ) )
    ExitPgm( ERR_XX , "" ) ;

//Spot 28140 Initialisation fonction n_CalculExerciceSeuil
  if (n_initCalculExerciceSeuil("ESTC1018_I8"))
    ExitPgm( ERR_XX , "" ) ;

  /* lancement du traitement du fichier de travail */
  if ( n_ProcessingRuptureVar( &bd_RuptPerUw) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I1", &( bd_RuptPerUw.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I2", &( bd_RuptGtPre.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I3", &( bd_RuptGtBcRec.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I4", &( bd_RuptGtPna.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I5", &( bd_RuptPrmLoa.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I6", &( bd_RuptGtEpp.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I7", &( bd_RuptGtRpp.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_I9", &( bd_RuptPeriCondition.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC1018_O1", &Kp_OutputFilGtLoa ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(Kb_ReturnStatus) ;
}

/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du fichier
  maitre.

retour :
  0K
==============================================================================*/
int n_InitPerUw(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPerUw" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre Perimetre de souscription */
  if ( n_OpenFileAppl( "ESTC1018_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePerUw ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePerUw( char **pbd_InRec_Cur )
{
  char  *Gt[NB_COL_GT + 1] ; /* tableau de pointeurs a l'image du GT */
  T_PCACM tbd_Gt_O[NB_GT_MAX] ; /* tableau pour ecriture en sortie */
  T_PCACM2 tbd_Gt2_O[NB_GT_MAX] ; /* tableau pour ecriture en sortie */
  char  sz_Acy[5] ;   /* zone de travail */
  char  sz_ScoStrMth[3] ; /* zone de travail */
  char  sz_ScoEndMth[3] ; /* zone de travail */
  char  sz_Amt[30] ;    /* zone de travail */
  char  sz_Trncod[9] ;  /* zone de travail */
  char  sz_Vide[2] = "" ;
  int   i;
  int   i_calc_seuil;
  int   combas_cf = atoi(pbd_InRec_Cur[PER_COMBAS_CF]); // prime avec ou sans portefeuille

  DEBUT_FCT( "n_ActionLignePerUw" ) ;

  /*******************************************/
  /* initialisation des variables de travail */
  /*******************************************/
  n_InitVariables( ) ;

  /****************************************************************/
  /* synchronisation avec le fichier GT des complements de primes */
  /****************************************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptGtPre, pbd_InRec_Cur ) ;

  /*************************************************************************************/
  /* synchronisation avec le fichier GT des montants de reconstitution et burning cost */
  /*************************************************************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptGtBcRec, pbd_InRec_Cur ) ;

  /**********************************************/
  /* synchronisation avec le fichier GT des PNA */
  /**********************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptGtPna, pbd_InRec_Cur ) ;

  /*********************************************************************/
  /* synchronisation avec le fichier des montants de primes et charges */
  /*********************************************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptPrmLoa, pbd_InRec_Cur ) ;

  /**********************************************/
  /* synchronisation avec le fichier GT des EPP */
  /**********************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptGtEpp, pbd_InRec_Cur ) ;

  /**********************************************/
  /* synchronisation avec le fichier GT des RPP */
  /**********************************************/
  n_ProcessingRuptureSyncVar( &bd_RuptGtRpp, pbd_InRec_Cur ) ;

  /**********************************************************/
  /* synchronisation avec le fichier des conditions de Com */
  /********************************************************/

  n_ProcessingRuptureSyncVar( &bd_RuptPeriCondition, pbd_InRec_Cur ) ;


  /******************************************************************/
  /* positionnement du tableau de pointeur avant ecriture en sortie */
  /******************************************************************/
  Gt[GT_SSD_CF] = pbd_InRec_Cur[PER_SSD_CF] ;
  Gt[GT_ESB_CF] = pbd_InRec_Cur[PER_ACCESB_CF] ;
  Gt[GT_BALSHEY_NF] = Annee_bilan ;
  Gt[GT_BALSHRMTH_NF] = Mois_bilan ;
  Gt[GT_BALSHRDAY_NF] = Jour_bilan ;
  Gt[GT_DBLTRNCOD_CF] = sz_Vide ;
  Gt[GT_CTR_NF] = pbd_InRec_Cur[PER_CTR_NF] ;
  Gt[GT_END_NT] = pbd_InRec_Cur[PER_END_NT] ;
  Gt[GT_SEC_NF] = pbd_InRec_Cur[PER_SEC_NF] ;
  Gt[GT_UWY_NF] = pbd_InRec_Cur[PER_UWY_NF] ;
  Gt[GT_UW_NT] = pbd_InRec_Cur[PER_UW_NT] ;
  Gt[GT_OCCYEA_NF] = pbd_InRec_Cur[PER_UWY_NF] ;
  Gt[GT_ACY_NF] = sz_Acy ;
  Gt[GT_SCOSTRMTH_NF] = sz_ScoStrMth ;
  Gt[GT_SCOENDMTH_NF] = sz_ScoEndMth ;
  Gt[GT_CLM_NF] = sz_Vide ;
  Gt[GT_CUR_CF] = pbd_InRec_Cur[PER_EGPCUR_CF] ;
  Gt[GT_AMT_M] = sz_Amt ;
  Gt[GT_CED_NF] = pbd_InRec_Cur[PER_CED_NF] ;
  Gt[GT_BRK_NF] = pbd_InRec_Cur[PER_PRD_NF] ;
  Gt[GT_PAY_NF] = pbd_InRec_Cur[PER_GENPRMPAY_NF] ;
  Gt[GT_KEY_NF] = pbd_InRec_Cur[PER_GANPAYORD_NT] ;
  Gt[GT_RETCTR_NF] = sz_Vide ;
  Gt[GT_RETEND_NT] = sz_Vide ;
  Gt[GT_RETSEC_NF] = sz_Vide ;
  Gt[GT_RTY_NF] = sz_Vide ;
  Gt[GT_RETUW_NT] = sz_Vide ;
  Gt[GT_RETOCCYEA_NF] = sz_Vide ;
  Gt[GT_RETACY_NF] = sz_Vide ;
  Gt[GT_RETSCOSTRMTH_NF] = sz_Vide ;
  Gt[GT_RETSCOENDMTH_NF] = sz_Vide ;
  Gt[GT_RCL_NF] = sz_Vide ;
  Gt[GT_RETCUR_CF] = sz_Vide ;
  Gt[GT_RETAMT_M] = sz_Vide ;
  Gt[GT_PLC_NT] = sz_Vide ;
  Gt[GT_RTO_NF] = sz_Vide ;
  Gt[GT_INT_NF] = sz_Vide ;
  Gt[GT_RETPAY_NF] = sz_Vide ;
  Gt[GT_RETKEY_CF] = sz_Vide ;
  Gt[GT_RETINTAMT_M] = sz_Vide ;   /* JR  13/05/2003 */
  Gt[GT_RETINTAMT_M + 1] = NULL ;

  memset( sz_Trncod, 0, sizeof( sz_Trncod ) ) ;

  /*************************************/
  /* complement de charges sur primes  */
  /*************************************/

  if ( *pbd_InRec_Cur[PER_CTRNAT_CT] != 'F' )
  {
    i_calc_seuil = ( atoi(pbd_InRec_Cur[PER_UWY_NF]) >=
                     n_CalculExerciceSeuil( atoi( pbd_InRec_Cur[PER_SSD_CF] ),
                                            atoi(pbd_InRec_Cur[PER_ACCESB_CF]),
                                            pbd_InRec_Cur[PER_LOB_CF],
                                            atoi(pbd_InRec_Cur[PER_NAT_CF]) ) );
  }
  else
  {
    i_calc_seuil = 1;
  }

  if (atoi( pbd_InRec_Cur[PER_COMTYP_CT] ) != 2)
  { 
    Gt[GT_TRNCOD_CF] = "11120002";

    // on calcule le seuil uniquement pour TRT

    if ( i_calc_seuil 
    	  || Kn_GtPBR_Nbp != 0
        || Ktd_Comp[Charge_PRM] == 0
        || atoi(pbd_InRec_Cur[PER_UWY_NF]) <= 1994)
    {

      n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, Ktd_Comp[Charge_PRM] ) ;
      for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
        if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
        {
          sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
          sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
          sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
          sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
          n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
        }
	
    }
  }


/**************************************************/
/* Ecriture Minimum, Rest Of Variable Commissions */
/**************************************************/

  if ((i_calc_seuil || *pbd_InRec_Cur[PER_SEGSA_B] == '1' ) && atoi( pbd_InRec_Cur[PER_COMTYP_CT] ) == 2 ) // Commissions Variable
  {
    if(b_Acmtrs[1] == 1 )
    {
      Gt[GT_TRNCOD_CF] = "11120212";
    }

    if(Kd_MinVarCE != 0
       && Kn_GtPBR_Nbp == 0
       && atoi(pbd_InRec_Cur[PER_UWY_NF]) > 1994
      )
    {
      sprintf(sz_Amt, "%-.3lf", Kd_MinVarCE );
      strcpy(sz_Acy,  Annee_bilan );
      strcpy(sz_ScoStrMth, Mois_bilan );
      strcpy(sz_ScoEndMth, Mois_bilan );
      n_WriteCols ( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 );  
    }
    else
    {
      n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, Kd_MinVarCE ) ;
      for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
        if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
        {
          sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
          sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
          sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
          sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
          n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
        }
    }

    if(b_Acmtrs[2] == 1 )
    {
      Gt[GT_TRNCOD_CF] = "11120302";
    }

    if (Kd_ResVarCE != 0
        && Kn_GtPBR_Nbp == 0
        && atoi(pbd_InRec_Cur[PER_UWY_NF]) > 1994
       )
    {
      sprintf(sz_Amt, "%-.3lf", Kd_ResVarCE );
      strcpy(sz_Acy,  Annee_bilan );
      strcpy(sz_ScoStrMth, Mois_bilan );
      strcpy(sz_ScoEndMth, Mois_bilan );
      n_WriteCols ( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 );
    }
    else
    {
      n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, Kd_ResVarCE ) ;
      for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
        if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
        {
          sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
          sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
          sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
          sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
          n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
        }
    } 
  }

  // on calcule le seuil uniquement pour TRT, donc pour FAC i_calc_seuil est toujours vrai
  if ( i_calc_seuil )
  {
    /**********************************/
    /* complement de taxes sur primes */
    /**********************************/
    n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, Ktd_Comp[Taxe_PRM] ) ;

    Gt[GT_TRNCOD_CF] = "11122002" ;

    for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
      if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
      {
        sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
        sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
        sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
        sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
        n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
      }
  }

  /**********************************************/
  /* complement de courtage sur primes hors REC */
  /**********************************************/
  n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, (Ktd_Comp[Courtage_PRM] - Ktd_Comp[Courtage_REC]) ) ;

  Gt[GT_TRNCOD_CF] = "11140002" ;

  for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
    if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  /**********************************/
  /* complement de courtage sur REC */
  /**********************************/
  n_VentilationComplement( Ktbd_GtPBR, Kn_GtPBR_Nbp, tbd_Gt_O, Ktd_Comp[Courtage_REC] ) ;

  Gt[GT_TRNCOD_CF] = "11140102" ;

  for ( i = 0; i < Kn_GtPBR_Nbp; i++ )
    if (  fabs(tbd_Gt_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt_O[i].AMT_M ) ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  /**********************************/
  /* complement de charges sur EPP  */
  /**********************************/

  Gt[GT_TRNCOD_CF] = "11310002" ;

  // Controle des conditions EPP (1,3,5)
  //
  // Prime avec Portefeuille

  n_VentilationComplement2( Ktbd_GtEpp, Kn_GtEpp_Nbp, tbd_Gt2_O, Ktd_Comp[Charge_EPP] ) ;
  if ((combas_cf == 0) || ((combas_cf == 1) && (periCond.Condition_EPP <= 3)))
  {
    for ( i = 0; i < Kn_GtEpp_Nbp; i++ )
      if ( fabs(tbd_Gt2_O[i].AMT_M) > 1 )
      {
        sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
        sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
        sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
        sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
        strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
        sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
        Gt[GT_TRNCOD_CF] = sz_Trncod ;
        n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
      }
  }
  // Prime sans portefeuille
  // [07]
  if ((combas_cf == 2) && ( periCond.Condition_EPP == 5))
  {
    sprintf( sz_Acy, "%s", Annee_bilan ) ;
    sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
    sprintf( sz_ScoEndMth, "%s", Mois_bilan ) ;
    sprintf( sz_Amt, "%-.3f", (periCond.Comm_EPP * -1.0) ) ;
    n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
  }
  // [07]



  /*******************************/
  /* complement de taxes sur EPP */
  /*******************************/
  n_VentilationComplement2( Ktbd_GtEpp, Kn_GtEpp_Nbp, tbd_Gt2_O, Ktd_Comp[Taxe_EPP] ) ;

  Gt[GT_TRNCOD_CF] = "11312002" ;

// [09]
  // Prime avec Portefeuille
  if (fabs(Ktd_Comp[Taxe_EPP]) >= 1  && (periCond.Condition_Tax_EPP <= 7) && (combas_cf == 1 || combas_cf ==0) ) //  [10] if (fabs(Ktd_Comp[Taxe_EPP]) <= 1  && (periCond.Condition_Tax_EPP <= 7) )
	  for ( i = 0; i < Kn_GtEpp_Nbp; i++ )
		if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
		{
		  sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
		  sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
		  sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
		  sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
		  strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
		  sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
		  Gt[GT_TRNCOD_CF] = sz_Trncod ;
		  n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
		}

  // Prime sans portefeuille
  if (fabs(Ktd_Comp[Taxe_EPP]) >= 1  && (periCond.Condition_Tax_EPP == 9)  && (combas_cf == 2)) // [10] if (fabs(Ktd_Comp[Taxe_EPP]) > 1  && (periCond.Condition_Tax_EPP == 9) )
  {
    sprintf( sz_Acy, "%s", Annee_bilan ) ;
    sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
    sprintf( sz_ScoEndMth, "%s", Mois_bilan ) ;
    sprintf( sz_Amt, "%-.3f", (periCond.Tax_EPP * -1.0) ) ;
    n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
  }
		
		
  /**********************************/
  /* complement de courtage sur EPP */
  /**********************************/
  n_VentilationComplement2( Ktbd_GtEpp, Kn_GtEpp_Nbp, tbd_Gt2_O, Ktd_Comp[Courtage_EPP] ) ;

  Gt[GT_TRNCOD_CF] = "11313002" ;

  for ( i = 0; i < Kn_GtEpp_Nbp; i++ )
    if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  /**********************************/
  /* complement de charges sur RPP  */
  /**********************************/
// Controle des conditions RPP (2,4,6)
  //
  // Prime avec Portefeuille
  //

  Gt[GT_TRNCOD_CF] = "11310102" ;

  n_VentilationComplement2( Ktbd_GtRpp, Kn_GtRpp_Nbp, tbd_Gt2_O, Ktd_Comp[Charge_RPP] ) ;
  if ((combas_cf == 0) || ((combas_cf == 1) && (periCond.Condition_RPP <= 4)))
  {
    for ( i = 0; i < Kn_GtRpp_Nbp; i++ )
      if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
      {
        sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
        sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
        sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
        sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
        strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
        sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
        Gt[GT_TRNCOD_CF] = sz_Trncod ;
        n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
      }
  }
  // Prime sans portefeuille
  // [07]
  if ((combas_cf == 2) && ( periCond.Condition_RPP == 6))
  {
    sprintf( sz_Acy, "%s", Annee_bilan ) ;
    sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
    sprintf( sz_ScoEndMth, "%s", Mois_bilan ) ;
    sprintf( sz_Amt, "%-.3f", (periCond.Comm_RPP * -1.0) ) ;
    n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
  }
  // [07]

  /*******************************/
  /* complement de taxes sur RPP */
  /*******************************/
  n_VentilationComplement2( Ktbd_GtRpp, Kn_GtRpp_Nbp, tbd_Gt2_O, Ktd_Comp[Taxe_RPP] ) ;
  
  Gt[GT_TRNCOD_CF] = "11312102" ;  //[10]

  // [09]
  // Taxe avec Portefeuille
  // Prime avec Portefeuille
  
  //[11]
#ifdef TRACE_PERICOND    
  if ( strcmp(pbd_InRec_Cur[PER_CTR_NF], "02U036968") == 0)
  	printf(" AVANT Taxes WP CTR_NF, SECT, UWY, Ktd_Comp[Taxe_RPP], periCond.Condition_Tax_RPP : %s ; %s ; %s ; %f ;  %d \n", pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_SEC_NF], pbd_InRec_Cur[PER_UWY_NF], Ktd_Comp[Taxe_RPP], periCond.Condition_Tax_RPP );
#endif

//  if (fabs(Ktd_Comp[Taxe_RPP]) >= 1  && (periCond.Condition_Tax_RPP <= 8) && (ctaxas_cf == '1' || taxbas_cf ='0') ) // // [11] [10] if (fabs(Ktd_Comp[Taxe_RPP]) <= 1  && (periCond.Condition_Tax_RPP <= 7) )   
  if (fabs(Ktd_Comp[Taxe_RPP]) >= 1  && (periCond.Condition_Tax_RPP <= 8) && (combas_cf == 1 || combas_cf ==0) ) // // [11] [10] if (fabs(Ktd_Comp[Taxe_RPP]) <= 1  && (periCond.Condition_Tax_RPP <= 7) ) 
  { 
	  for ( i = 0; i < Kn_GtRpp_Nbp; i++ )
		if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
		{
		  sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
		  sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
		  sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
		  sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
		  strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
		  sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
		  Gt[GT_TRNCOD_CF] = sz_Trncod ;
		  n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
		}
  }
    // Taxe sans Portefeuille
#ifdef TRACE_PERICOND    
  if ( strcmp(pbd_InRec_Cur[PER_CTR_NF], "02U036968") == 0)
  	printf(" AVANT Taxes SANS CTR_NF, SECT, UWY, Ktd_Comp[Taxe_RPP], periCond.Condition_Tax_RPP : %s, %s, %s, %f ;  %d, \n", pbd_InRec_Cur[PER_CTR_NF], pbd_InRec_Cur[PER_SEC_NF], pbd_InRec_Cur[PER_UWY_NF], Ktd_Comp[Taxe_RPP], periCond.Condition_Tax_RPP );
#endif      
    
//  if (fabs(Ktd_Comp[Taxe_RPP]) >= 1  && (periCond.Condition_Tax_RPP == 10) && (taxbas_cf == '2') ) // //[11]  [10] if (fabs(Ktd_Comp[Taxe_RPP]) > 1  && (periCond.Condition_Tax_RPP == 9) ) 
  if (fabs(Ktd_Comp[Taxe_RPP]) >= 1  && (periCond.Condition_Tax_RPP == 10) && (combas_cf == 2) ) // //[11]  [10] if (fabs(Ktd_Comp[Taxe_RPP]) > 1  && (periCond.Condition_Tax_RPP == 9) )   	
	{
		sprintf( sz_Acy, "%s", Annee_bilan ) ;
		sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
		sprintf( sz_ScoEndMth, "%s", Mois_bilan ) ;
		sprintf( sz_Amt, "%-.3f", (periCond.Tax_RPP * -1.0) ) ;
		n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
	}
		
  /**********************************/
  /* complement de courtage sur RPP */
  /**********************************/
  n_VentilationComplement2( Ktbd_GtRpp, Kn_GtRpp_Nbp, tbd_Gt2_O, Ktd_Comp[Courtage_RPP] ) ;

  Gt[GT_TRNCOD_CF] = "11313102" ;

  for ( i = 0; i < Kn_GtRpp_Nbp; i++ )
    if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  /*******************************************/
  /* complement de charges et taxes sur PPNA */
  /*******************************************/
  
  if (strcmp(pbd_InRec_Cur[PERExtend_ESTCOMTYP_CT], "3") != 0 && b_Acmtrs[0] == 1)  //[08]
  { 
    n_VentilationComplement2( Ktbd_GtPpna, Kn_GtPpna_Nbp, tbd_Gt2_O, Ktd_Comp[ChargeTaxe_PPNA] ) ;
    
    Gt[GT_TRNCOD_CF] = "99999992" ;
    
    for( i = 0; i < Kn_GtPpna_Nbp; i++ )
      if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
      {
        sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
        sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
        sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
        sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
        strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
        sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
        Gt[GT_TRNCOD_CF] = sz_Trncod ;
        n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
      }
  }

  /*****************************/
  /* DAC Fixed et DAC Variable */
  /*****************************/
  if(strcmp(pbd_InRec_Cur[PERExtend_ESTCOMTYP_CT], "3") != 0)
  {
    if (b_Acmtrs[1] == 1)
    { 
      n_VentilationComplement2( Ktbd_GtPpna, Kn_GtPpna_Nbp, tbd_Gt2_O, Kd_DACfix ) ;
    
      Gt[GT_TRNCOD_CF] = "11430002" ;
    
      for( i = 0; i < Kn_GtPpna_Nbp; i++ )
        if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
        {
          sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
          sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
          sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
          sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
          strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
          sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
          Gt[GT_TRNCOD_CF] = sz_Trncod ;
          n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
        }
    }

    if (b_Acmtrs[2] == 1)
    { 
      n_VentilationComplement2( Ktbd_GtPpna, Kn_GtPpna_Nbp, tbd_Gt2_O, Kd_DACvar ) ;
    
      Gt[GT_TRNCOD_CF] = "11430102" ;
     
      for( i = 0; i < Kn_GtPpna_Nbp; i++ )
        if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
        {
          sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
          sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
          sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
          sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
          strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
          sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
          Gt[GT_TRNCOD_CF] = sz_Trncod ;
          n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
        }
    }
  }

  /***********************************/
  /* complement de courtage sur PPNA */
  /***********************************/
  n_VentilationComplement2( Ktbd_GtPpna, Kn_GtPpna_Nbp, tbd_Gt2_O, Ktd_Comp[Courtage_PPNA] ) ;

  Gt[GT_TRNCOD_CF] = "11436002" ;

  for ( i = 0; i < Kn_GtPpna_Nbp; i++ )
    if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }
	
	
	/*******************************/
    /* DAC On Brokerage IFRS17 [14]*/
	/*******************************/

  Gt[GT_TRNCOD_CF] = "1143060I";

    if (  fabs(Kd_DACIFRS17) > 1 )
    {
      sprintf( sz_Acy, "%s", Annee_bilan ) ;
      sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
      sprintf( sz_ScoEndMth, "%s", Mois_bilan) ;
      sprintf( sz_Amt, "%-.3f", Kd_DACIFRS17 ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }
	
/*	
  n_VentilationComplement2( Ktbd_GtPpna, Kn_GtPpna_Nbp, tbd_Gt2_O, Kd_DACIFRS17 ) ;

  Gt[GT_TRNCOD_CF] = "11430602" ;

  for ( i = 0; i < Kn_GtPpna_Nbp; i++ )
{
        if ( strcmp(pbd_InRec_Cur[PER_CTR_NF], "TR0040456") == 0)
        printf ("%f,   %f\n",Kd_DACIFRS17,fabs(tbd_Gt2_O[i].AMT_M) );
    if (  fabs(tbd_Gt2_O[i].AMT_M) > 1 )
    {
      sprintf( sz_Acy, "%d", tbd_Gt2_O[i].ACY_NF ) ;
      sprintf( sz_ScoStrMth, "%d", tbd_Gt2_O[i].SCOSTRMTH_NF ) ;
      sprintf( sz_ScoEndMth, "%d", tbd_Gt2_O[i].SCOENDMTH_NF ) ;
      sprintf( sz_Amt, "%-.3f", tbd_Gt2_O[i].AMT_M ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      sz_Trncod[7] = tbd_Gt2_O[i].TRNCOD_SUFIX;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }
}
*/

  Gt[GT_TRNCOD_CF] = "11120210";

    if( fabs(Kd_RecievedMinVarCom) > 1 )
    {
      sprintf( sz_Acy, "%s", Annee_bilan ) ;
      sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
      sprintf( sz_ScoEndMth, "%s", Mois_bilan) ;
      sprintf( sz_Amt, "%-.3f", Kd_RecievedMinVarCom ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  Gt[GT_TRNCOD_CF] = "11120220";

    if( fabs(Kd_RecievedMinVarCom) > 1 )
    {
      sprintf( sz_Acy, "%s", Annee_bilan ) ;
      sprintf( sz_ScoStrMth, "%s", Mois_bilan ) ;
      sprintf( sz_ScoEndMth, "%s", Mois_bilan) ;
      sprintf( sz_Amt, "%-.3f", -Kd_RecievedMinVarCom ) ;
      strcpy(sz_Trncod, Gt[GT_TRNCOD_CF]) ;
      Gt[GT_TRNCOD_CF] = sz_Trncod ;
      n_WriteCols( Kp_OutputFilGtLoa, Gt, SEPARATEUR, 0 ) ;
    }

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre « Perimetre de souscription »
  avec l’esclave « GT des complements de primes »

retour :
  OK
==============================================================================*/
int n_InitGtPre( T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtPre" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I2", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtPre ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtPre ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtPre(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtPre" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT]   ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtPre(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  char MsgAno[300] ; /* message d'erreur */

  DEBUT_FCT( "n_ActionLigneGtPre" ) ;
  /* affectation des elements du tableau des Pc/Ac et montants de Primes, Burning cost, et reconstitution */
  Ktbd_GtPBR[Kn_GtPBR_Nbp].ACY_NF = atoi( ptb_InRecChild[GT_ACY_NF] ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].SCOSTRMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOSTRMTH_NF] ) ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].SCOENDMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].AMT_M = atof( ptb_InRecChild[GT_AMT_M] ) ;

  /* incrementation du nombre de poste du tableau */
  Kn_GtPBR_Nbp += 1 ;


  /* generation d'une anomalie si la taille du tableau "Ktbd_GtPBR" est insuffisante */
  if ( Kn_GtPBR_Nbp > NB_GT_MAX )
  {
    sprintf( MsgAno, "n_ActionLigneGtPre: The record number of the estimates premium GT, burning cost and reconstitution GT for the contract (CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program memory capacity",
             ptb_InRecOwner[PER_CTR_NF], ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF],
             ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT] ) ;

    n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMALIE */
    /* et 'plantage' du programme */
    ExitPgm( ERR_XX , "" ) ;
  }
  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « GT des montants de reconstitutions et de burning cost »

retour :
  OK
==============================================================================*/
int n_InitGtBcRec(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtBcRec" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I3", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtBcRec ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtBcRec ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtBcRec(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtBcRec" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtBcRec(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  char MsgAno[300] ; /* message d'erreur */

  DEBUT_FCT( "n_ActionLigneGtBcRec" ) ;

  /* affectation des Pc/Ac et montants de Burning cost et reconstitution dans le
  meme tableau que les montants de prime */
  Ktbd_GtPBR[Kn_GtPBR_Nbp].ACY_NF = atoi( ptb_InRecChild[GT_ACY_NF] ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].SCOSTRMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOSTRMTH_NF] ) ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].SCOENDMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) ) ;
  Ktbd_GtPBR[Kn_GtPBR_Nbp].AMT_M = atof( ptb_InRecChild[GT_AMT_M] ) ;

  /* incrementation du nombre de poste du tableau */
  Kn_GtPBR_Nbp += 1 ;

  /* generation d'une anomalie si la taille du tableau "Ktbd_GtPBR" est insuffisante */
  if ( Kn_GtPBR_Nbp > NB_GT_MAX )
  {
    sprintf( MsgAno, "n_ActionLigneGtPre: The record number of the estimates premium GT, burning cost and reconstitution GT for the contract (CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program memory capacity",
             ptb_InRecOwner[PER_CTR_NF], ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF],
             ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT] ) ;

    n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMALIE */
    /* et 'plantage' du programme */
    ExitPgm( ERR_XX , "" ) ;
  }


  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « GT des PNA »

retour :
  OK
==============================================================================*/
int n_InitGtPna(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtPna" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I4", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtPna ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtPna ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtPna(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtPna" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT ], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtPna(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  char MsgAno[300] ; /* message d'erreur */

  DEBUT_FCT( "n_ActionLigneGtPna" ) ;

  /* affectation des elements du tableau des Pc/Ac et montants de PPNA */
  Ktbd_GtPpna[Kn_GtPpna_Nbp].ACY_NF = atoi( ptb_InRecChild[GT_ACY_NF] ) ;
  Ktbd_GtPpna[Kn_GtPpna_Nbp].SCOSTRMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOSTRMTH_NF] ) ) ;
  Ktbd_GtPpna[Kn_GtPpna_Nbp].SCOENDMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) ) ;
  Ktbd_GtPpna[Kn_GtPpna_Nbp].AMT_M = atof( ptb_InRecChild[GT_AMT_M] ) ;
  Ktbd_GtPpna[Kn_GtPpna_Nbp].TRNCOD_SUFIX = ptb_InRecChild[GT_TRNCOD_CF][7] ;

  /* incrementation du nombre de poste du tableau */
  Kn_GtPpna_Nbp += 1 ;

  /* generation d'une anomalie si la taille du tableau "Ktbd_GtPpna" est insuffisante */
  if ( Kn_GtPpna_Nbp > NB_GT_MAX )
  {
    sprintf( MsgAno, "n_ActionLigneGtPna:The record number of the Unearned Premium GT for the contract (CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program memory capacity",
             ptb_InRecOwner[PER_CTR_NF], ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF],
             ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT] ) ;

    n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMALIE */
    /* et 'plantage' du programme */
    ExitPgm( ERR_XX , "" ) ;
  }



  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « Montants de primes et charges »

retour :
  OK
==============================================================================*/
int n_InitPrmLoa(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitPrmLoa" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I5", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPrmLoa ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLignePrmLoa ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncPrmLoa(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncPrmLoa" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[PRMLOA_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[PRMLOA_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[PRMLOA_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[PRMLOA_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[PRMLOA_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLignePrmLoa(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  DEBUT_FCT( "n_ActionLignePrmLoa" ) ;

  /* affectation des complements par affaire */
  switch ( atol( ptb_InRecChild[PRMLOA_ACMTRS_NT] ) )
  {
  case 10100 :
    Ktd_Comp[Charge_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[ChargeTaxe_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    b_Acmtrs[0] = 1 ;
    break ;
  case 10120 :
    Ktd_Comp[Charge_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Charge_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10300 :
    Ktd_Comp[Taxe_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Kd_RecievedMinVarCom = atof( ptb_InRecChild[PRMLOA_RESERV_M] );
    break ;
  case 10320 :
    Ktd_Comp[Taxe_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Taxe_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10400 :
    Ktd_Comp[Courtage_PRM] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Courtage_PPNA] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  case 10401 :
    Ktd_Comp[Courtage_REC] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
	Kd_DACIFRS17 = atof( ptb_InRecChild[PRMLOA_RESERV_M] );
    break ;
  case 10420 :
    Ktd_Comp[Courtage_EPP] = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Ktd_Comp[Courtage_RPP] = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    break ;
  
  /*Extractions des Calcul de REQ 9.5 sortis de ESTC1017*/

  case 12021 :
    Kd_MinVarCE = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Kd_DACfix = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    b_Acmtrs[1] = 1 ;
    break ;
  case 12030 :
    Kd_ResVarCE = atof( ptb_InRecChild[PRMLOA_ESTACC_M] ) ;
    Kd_DACvar = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    b_Acmtrs[2] = 1 ;
    break ;
  /*case 43000:
    Kd_DACfix = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    b_Acmtrs[1] = 1 ;
    break ;
  case 43010:
    Kd_DACvar = atof( ptb_InRecChild[PRMLOA_RESERV_M] ) ;
    b_Acmtrs[2] = 1 ;
    break ;*/
  }

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « GT des EPP »

retour :
  OK
==============================================================================*/
int n_InitGtEpp(T_RUPTURE_SYNC_VAR  *pbd_Rupt)

{
  DEBUT_FCT( "n_InitGtEpp" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I6", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtEpp ;

  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtEpp ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtEpp(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtEpp" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtEpp(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  char MsgAno[300] ; /* message d'erreur */

  DEBUT_FCT( "n_ActionLigneGtEpp" ) ;

  /* affectation des elements du tableau des Pc/Ac et montants d'EPP */
  Ktbd_GtEpp[Kn_GtEpp_Nbp].ACY_NF = atoi( ptb_InRecChild[GT_ACY_NF] ) ;
  Ktbd_GtEpp[Kn_GtEpp_Nbp].SCOSTRMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOSTRMTH_NF] ) ) ;
  Ktbd_GtEpp[Kn_GtEpp_Nbp].SCOENDMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) ) ;
  Ktbd_GtEpp[Kn_GtEpp_Nbp].AMT_M = atof( ptb_InRecChild[GT_AMT_M] ) ;
  Ktbd_GtEpp[Kn_GtEpp_Nbp].TRNCOD_SUFIX = ptb_InRecChild[GT_TRNCOD_CF][7] ;

  /* incrementation du nombre de poste du tableau */
  Kn_GtEpp_Nbp += 1 ;

  /* generation d'une anomalie si la taille du tableau "Ktbd_GtEpp" est insuffisante */
  if ( Kn_GtEpp_Nbp > NB_GT_MAX )
  {
    sprintf( MsgAno, "n_ActionLigneGtEpp:The record number of the PPE GT for the contract (CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program memory capacity",
             ptb_InRecOwner[PER_CTR_NF], ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF],
             ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT] ) ;

    n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMALIE */
    /* et 'plantage' du programme */
    ExitPgm( ERR_XX , "" ) ;
  }



  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « GT des RPP »

retour :
  OK
==============================================================================*/
int n_InitGtRpp(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtRpp" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I7", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtRpp ;
  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtRpp ;

  pbd_Rupt->c_Separ = '~' ;

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtRpp(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtRpp" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[GT_CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[GT_END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[GT_SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[GT_UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[GT_UW_NT] ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtRpp(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{
  char MsgAno[300] ; /* message d'erreur */
  char sz_suffixPoste[9];

  memset( sz_suffixPoste, 0, sizeof( sz_suffixPoste ) ) ;

  DEBUT_FCT( "n_ActionLigneGtRpp" ) ;

  /* affectation des elements du tableau des Pc/Ac et montants de RPP */
  Ktbd_GtRpp[Kn_GtRpp_Nbp].ACY_NF = atoi( ptb_InRecChild[GT_ACY_NF] ) ;
  Ktbd_GtRpp[Kn_GtRpp_Nbp].SCOSTRMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOSTRMTH_NF] ) ) ;
  Ktbd_GtRpp[Kn_GtRpp_Nbp].SCOENDMTH_NF = (char)( atoi( ptb_InRecChild[GT_SCOENDMTH_NF] ) ) ;
  Ktbd_GtRpp[Kn_GtRpp_Nbp].AMT_M = atof( ptb_InRecChild[GT_AMT_M] ) ;
  sprintf( sz_suffixPoste, "%s", ptb_InRecChild[GT_TRNCOD_CF] ) ;
  Ktbd_GtRpp[Kn_GtRpp_Nbp].TRNCOD_SUFIX = (char) (sz_suffixPoste[7]) ;
  /* incrementation du nombre de poste du tableau */
  Kn_GtRpp_Nbp += 1 ;

  /* generation d'une anomalie si la taille du tableau "Ktbd_GtRpp" est insuffisante */
  if ( Kn_GtRpp_Nbp > NB_GT_MAX )
  {
    sprintf( MsgAno, "The record number of the PPW GT for the contract (CTR %s /END %s /SEC %s /UWY %s /UW %s) overflows the program memory capacity",
             ptb_InRecOwner[PER_CTR_NF], ptb_InRecOwner[PER_END_NT], ptb_InRecOwner[PER_SEC_NF],
             ptb_InRecOwner[PER_UWY_NF], ptb_InRecOwner[PER_UW_NT] ) ;

    n_WriteAno ( MsgAno ) ; /* Generation d'une ANOMALIE */
    /* et 'plantage' du programme */
    ExitPgm( ERR_XX , "" ) ;
  }

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  Initialisation de la synchronisation du maitre avec
  l'esclave « GT des Conditions de com »

retour :
  OK
==============================================================================*/
int n_InitGtPeriCondition(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGtPeriCondition" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_SYNC_VAR ) ) ;

  /* ouverture du fichier esclave */
  if ( n_OpenFileAppl( "ESTC1018_I9", "rt", &( pbd_Rupt->pf_InputFil ) ) == ERR )
    return ERR ;

  /* fonction du test de synchronisation de la ligne du maitre avec l'esclave */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtPeriCond ;
  /* fonction d'action sur la ligne courante */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtPeriCond ;

  pbd_Rupt->c_Separ = '~' ;

  // initialisation de la structure pour le fichier de condition
  memset(&periCond, 0 , sizeof(periCond));

  RETURN_VAL( OK ) ;
}

/*==============================================================================
objet :
  fonction de test de synchronisation

retour :
  0 ---> pbd_InRecOwner = pbd_InRecChild ( egalité de rubrique a synchroniser)
  > 0     ---> pbd_InRecOwne> > pbd_InRecChild
  < 0     ---> pbd_InRecOwne> < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtPeriCond(
  char **pbd_InRecOwner ,  /* adresse de la ligne du maitre */
  char **pbd_InRecChild  ) /* adresse de la ligne de l'esclave */
{
  int ret ;

  DEBUT_FCT( "n_ConditionSyncGtPeriCond" ) ;

  if ( ( ret = strcmp( pbd_InRecOwner[PER_CTR_NF], pbd_InRecChild[CTR_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_SEC_NF], pbd_InRecChild[SEC_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UWY_NF], pbd_InRecChild[UWY_NF] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_END_NT], pbd_InRecChild[END_NT] ) ) != 0 ) return ret ;
  if ( ( ret = strcmp( pbd_InRecOwner[PER_UW_NT], pbd_InRecChild[UW_NT]   ) ) != 0 ) return ret ;

  RETURN_VAL( 0 ) ;
}


/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGtPeriCond(
  char **ptb_InRecOwner , /* adresse de la ligne du maitre */
  char **ptb_InRecChild ) /* adresse de la ligne de l'esclave */
{

  DEBUT_FCT( "n_ActionLigneGtPeriCond" ) ;
  memset (&periCond , 0 , sizeof(periCond));

  sprintf(periCond.Contrat, "%s" , ptb_InRecChild[CTR_NF]);
  sprintf(periCond.Devise, "%s", ptb_InRecChild[DEVISE]);
  periCond.Section = atoi(ptb_InRecChild[SEC_NF]);
  periCond.Exercice = atoi(ptb_InRecChild[UWY_NF]);
  periCond.Condition_EPP = atoi(ptb_InRecChild[COND_EPP]);
  periCond.Condition_RPP = atoi(ptb_InRecChild[COND_RPP]);
  periCond.Condition_Tax_EPP = atoi(ptb_InRecChild[COND_TAX_EPP]);
  periCond.Condition_Tax_RPP = atoi(ptb_InRecChild[COND_TAX_RPP]);
  periCond.Montant_EPP = atof(ptb_InRecChild[AMT_EPP]);
  periCond.Montant_RPP = atof(ptb_InRecChild[AMT_RPP]);
  periCond.Comm_EPP = atof(ptb_InRecChild[COM_EPP]);
  periCond.Comm_RPP = atof(ptb_InRecChild[COM_RPP]);
  periCond.Tax_EPP = atof(ptb_InRecChild[TAX_EPP]);
  periCond.Tax_RPP = atof(ptb_InRecChild[TAX_RPP]);

  RETURN_VAL( OK ) ;
}


/*==============================================================================
objet :
  fonction d'initialisation des variables de travail

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_InitVariables( void )
{

  DEBUT_FCT( "n_InitVariables" ) ;

  /* initialisateur des compteurs de postes de tableaux */
  Kn_GtEpp_Nbp = 0 ;
  Kn_GtRpp_Nbp = 0 ;
  Kn_GtPpna_Nbp = 0 ;
  Kn_GtPBR_Nbp = 0 ;

  /* initialisation des tableaux de structures du GT */
  memset( Ktbd_GtEpp, 0, ( NB_GT_MAX * sizeof( T_PCACM2 ) ) ) ;
  memset( Ktbd_GtRpp, 0, ( NB_GT_MAX * sizeof( T_PCACM2 ) ) ) ;
  memset( Ktbd_GtPpna, 0, ( NB_GT_MAX * sizeof( T_PCACM2 ) ) ) ;
  memset( Ktbd_GtPBR, 0, ( NB_GT_MAX * sizeof( T_PCACM ) ) ) ;

  /* initialisation des tableaux de structures du GT */
  memset( Ktd_Comp, 0, ( COMP_NBPOSTE * sizeof( double ) ) ) ;
  
  /*init bool Acmtrs*/
  memset (b_Acmtrs, 0, sizeof(b_Acmtrs) );

  /*init MinVarCE et ResVarCE*/
  Kd_MinVarCE = 0 ;
  Kd_ResVarCE = 0 ;
  
  //[13]
  Kd_DACfix = 0;
  Kd_DACvar = 0;
  //[15]
  Kd_DACIFRS17 = 0;
  //[17]
  Kd_RecievedMinVarCom = 0;

  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction de ventilation au detail des Pc/Ac des complements de charges,
taxes et courtage

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_VentilationComplement( T_PCACM *ptbd_Gt_I, int NbPostes_Gt_I, T_PCACM *ptbd_Gt_O, double Comp )
{
  double d_PrmTot = 0 ; /* montant de prime totale */
  int i ;

  DEBUT_FCT( "n_VentilationComplement" ) ;

  /* cumul des montants de primes */
  for ( i = 0; i < NbPostes_Gt_I; i++ )
    d_PrmTot += ptbd_Gt_I[i].AMT_M ;

  /* cumul des montants de primes */
/*  [15] for ( i = 0; i < NbPostes_Gt_I; i++ )
    d_PrmTot += ptbd_Gt_I[i].AMT_M ;
*/
  /* calcul et ventilation des complements de charges, taxes et courtage */
  for ( i = 0; i < NbPostes_Gt_I; i++ )
  {
    ptbd_Gt_O[i].ACY_NF = ptbd_Gt_I[i].ACY_NF ;
    ptbd_Gt_O[i].SCOSTRMTH_NF = ptbd_Gt_I[i].SCOSTRMTH_NF ;
    ptbd_Gt_O[i].SCOENDMTH_NF = ptbd_Gt_I[i].SCOENDMTH_NF ;
    if (fabs(d_PrmTot) > 1) {
      ptbd_Gt_O[i].AMT_M = ptbd_Gt_I[i].AMT_M * Comp / d_PrmTot ;
    }
    else {
      ptbd_Gt_O[i].AMT_M = Comp / NbPostes_Gt_I;
    }

  }
  RETURN_VAL ( OK ) ;
}


/*==============================================================================
objet :
  fonction de ventilation 2 au detail des Pc/Ac des complements de charges,
taxes et courtage
Elle est differente de la premiere par rapport au structure des tableaux passes
en argument

retour :  OK ---> traitement correctement effectue
    ERR --> probleme rencontre
==============================================================================*/
int n_VentilationComplement2( T_PCACM2 *ptbd_Gt_I, int NbPostes_Gt_I, T_PCACM2 *ptbd_Gt_O, double Comp )
{
  double d_PrmTot = 0 ; /* montant de prime totale */
  int i ;

  DEBUT_FCT( "n_VentilationComplement2" ) ;

  /* cumul des montants de primes */
  for ( i = 0; i < NbPostes_Gt_I; i++ )
    d_PrmTot += ptbd_Gt_I[i].AMT_M ;

  /* calcul et ventilation des complements de charges, taxes et courtage */
  for ( i = 0; i < NbPostes_Gt_I; i++ )
  {
    ptbd_Gt_O[i].ACY_NF = ptbd_Gt_I[i].ACY_NF ;
    ptbd_Gt_O[i].SCOSTRMTH_NF = ptbd_Gt_I[i].SCOSTRMTH_NF ;
    ptbd_Gt_O[i].SCOENDMTH_NF = ptbd_Gt_I[i].SCOENDMTH_NF ;
    ptbd_Gt_O[i].TRNCOD_SUFIX = ptbd_Gt_I[i].TRNCOD_SUFIX ;
    if (fabs(d_PrmTot) > 1) {
      ptbd_Gt_O[i].AMT_M = ptbd_Gt_I[i].AMT_M * Comp / d_PrmTot ;
    }
    else {
      ptbd_Gt_O[i].AMT_M = Comp / NbPostes_Gt_I;
    }

  }

  RETURN_VAL ( OK ) ;
}

 
