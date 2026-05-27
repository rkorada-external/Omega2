/*==============================================================================
nom de l'application          : ESTIMATION lot 10
nom du source                 : ESTM7010.c
révision                      : $Revision: 1.3 $
date de creation              : 08/10/2007
auteur                        : J. Ribot
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   TRAITEMENT DES TRANSFERTS  - partie GT -
    la table des sections de contient que les traites NP
    16/10/2007    J. Ribot       SPOT EST13427
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
[01] 27/06/2014 R. Cassis :spot:25036 Modifie compteur du NB_DETTRS_MAX (triplé)
[XX] 06/04/2014 JBG       :spot:25773 Modify void main declaration to int main
[XX] 09/10/2014 JBG       :spot:25773  suppress warning: unused variables
[04] 05/02/2016 Florent   :spot:29066 on utilise le struct.h
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include "struct.h"
#include "ESTM7010.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* définition des constantes et macros privées */
/*---------------------------------------------*/
#define NB_DETTRS_MAX 30000 /* Le nombre max de postes est fixe a 8000 [001] */
#define NB_TRSECT_MAX 500000  /* Le nombre max de section traités est fixe a 500000 */

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_OutputFilGt ;   /* pointeur sur le fichier de sortie GT */

FILE    *Kp_InputFilDettrs ;    /* pointeur sur le fichier en entree T_DETTRS */
FILE    *Kp_InputFilTSect ;   /* pointeur sur le fichier en entree T_TSECT */

T_RUPTURE_VAR bd_RuptGt ;     /* variable de gestion de la rupture sur le GT */

T_DETTRS        Ktbd_Dettrs[NB_DETTRS_MAX] ;
T_TSECT         Ktbd_TSect[NB_TRSECT_MAX] ;

int   Kn_NbLigDettrs = 0 ; /* nombre de lignes du tableau Ktbd_Dettrs */
int   Kn_NbLigTSect = 0 ; /* nombre de lignes du tableau Ktbd_TSect */

int n_InitGt      ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneGt   ( char **pbd_InRec_Cur ) ;

int n_InitRecond    ( T_RUPTURE_SYNC_VAR *pbd_Rupt ) ;
int n_ActionLigneRecond   ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;
int n_ConditionSyncRecond ( char **ptb_InRecOwner, char **pbd_InRecChild ) ;


int n_Processing (T_RUPTURE_VAR *);

int n_ChargerDETTRS( );
int n_ChargerTSECT( );

int n_RechTrn( char *sz_trn );
int n_RechTSect( char **ptb_InRec_Cur );


int     n_parm_BALSHEY_NF;
char    sz_parm_BLCSHT_D[8];

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

  strcpy(sz_parm_BLCSHT_D, psz_GetCharArgv(1)) ;
  n_parm_BALSHEY_NF = atoi(psz_GetCharArgv(2)) ;

  /* ouverture du fichier en entree TDETTRS */
  if ( n_OpenFileAppl ( "ESTM7010_I2", "rb", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en entree TSECT */
  if ( n_OpenFileAppl ( "ESTM7010_I3", "rb", &Kp_InputFilTSect ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  /* ouverture du fichier de sortie des transferts */
  if ( n_OpenFileAppl ( "ESTM7010_O1", "wt", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptGt */
  if ( n_InitGt( &bd_RuptGt ) )
    ExitPgm( ERR_XX , "" ) ;

  /* Chargement des postes en memoire */
  Kn_NbLigDettrs = n_ChargerDETTRS( );
  Kn_NbLigTSect = n_ChargerTSECT( );

  /* Lancement du traitement sans rupture */
  if ( n_Processing( &bd_RuptGt ) == ERR)
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7010_I1", &( bd_RuptGt.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7010_I2", &Kp_InputFilDettrs ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7010_I3", &Kp_InputFilTSect ) == ERR )
    ExitPgm( ERR_XX , "" );

  if ( n_CloseFileAppl( "ESTM7010_O1", &Kp_OutputFilGt ) == ERR )
    ExitPgm( ERR_XX , "" );


  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit(OK) ;
}


/*==============================================================================
objet :
  fonction d'initialisation de la variable de gestion de rupture du fichier
  maitre.

retour :
  0K
==============================================================================*/
int n_InitGt(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitGt" ) ;

  memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));

  /* ouverture du fichier maitre GT */
  if ( n_OpenFileAppl( "ESTM7010_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    RETURN_VAL(  ERR ) ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneGt ;
  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL( OK ) ;
}

/*=============================================================================
objet :
  fonction d'appel a la boucle de traitement.
        lors de la sortie de la boucle impression dans fichier compte rendu.
        Ce programmme ne gere pas de rupture, un traitement sera lance a chaque
        ligne.
retour :
  ERR si on a rencontre un probleme.
=============================================================================*/
int n_Processing(T_RUPTURE_VAR *Kbd_ruptFIC_IN)
{
  int n_Resultat;

  DEBUT_FCT("n_Processing");

  n_Resultat = n_ProcessingRuptureVar (Kbd_ruptFIC_IN);

  return (n_Resultat);
}

/*==============================================================================
objet :
  fonction lancee pour chaque ligne

retour :
  OK ---> traitement correctement effectue
  ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneGt( char **ptb_InRec_Cur )
{

  int  n_indtrn, n_indtsect;
  char sz_an[5];
  char sz_mois[3];
  char sz_jour[3];
  int Non_Prop;
  int  i;

  DEBUT_FCT( "n_ActionLigneGt" ) ;


  /* exclusion postes estimations */
  if (ptb_InRec_Cur[GT_TRNCOD_CF][7] == '2'   ||
      ptb_InRec_Cur[GT_TRNCOD_CF][7] == '3' )
  {
    return (OK);
  }

  /* recherche du poste comptable */
  i = n_RechTrn(ptb_InRec_Cur[GT_TRNCOD_CF]);
  n_indtrn = i;

  if (n_indtrn < 0)
  {

    return (OK);
  }


  /* recherche section traité */
  Non_Prop = 1;
  /* exclusion des reserves, hors L0, sur le NP */
  /* recherche section traité */
  i = n_RechTSect(ptb_InRec_Cur);
  n_indtsect = i;

  if (n_indtsect < 0)       /* non trouve donc ce n'est pas un Non Prop */
  {
    Non_Prop = 0;
  }

  if ((Ktbd_Dettrs[n_indtrn].TRSTYP_CT == 3 ) &&
      Non_Prop == 1 &&
      (ptb_InRec_Cur[GT_TRNCOD_CF][6] != '1'))
  {
    return (OK);
  }
  /* modif date bilan */
  sprintf(sz_an, "%d", n_parm_BALSHEY_NF - 1);
  ptb_InRec_Cur[GT_BALSHEY_NF] = sz_an ;
  sprintf(sz_mois, "%d", 12);
  ptb_InRec_Cur[GT_BALSHRMTH_NF] = sz_mois ;
  sprintf(sz_jour, "%d", 31);
  ptb_InRec_Cur[GT_BALSHRDAY_NF] = sz_jour ;

  /* reconduction du GT en sortie */
  n_WriteCols( Kp_OutputFilGt, ptb_InRec_Cur, SEPARATEUR, 0 ) ;

  return (OK);
}

/*==============================================================================
objet:
  Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/
int n_ChargerDETTRS( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerDETTRS");

  while ( fread( &Ktbd_Dettrs[i], sizeof( T_DETTRS ), 1, Kp_InputFilDettrs ) == 1 )
  {
    i += 1 ;
    if ( i == NB_DETTRS_MAX )
    {
      printf( " max DETTRS atteint=8000 " );
      return (-1 );
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet:
  Lit le fichier binaire des postes comptable et les charge en memoire

==============================================================================*/
int n_ChargerTSECT( )
{
  int i = 0 ;

  DEBUT_FCT("n_ChargerTSECT");

  while ( fread( &Ktbd_TSect[i], sizeof( T_TSECT ), 1, Kp_InputFilTSect ) == 1 )
  {
    i += 1 ;
    if ( i == NB_TRSECT_MAX )
    {
      printf( " max TSECT atteint=500000 " );
      return (-1 );
    }
  }

  RETURN_VAL( i );
}


/*==============================================================================
objet :
  fonction de recherche du trncod
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
int n_RechTrn(char *sz_trn)
{
  int i;

  DEBUT_FCT("n_RechTrn");

  for ( i = 0; i <  Kn_NbLigDettrs ; i++ )
  {
    if ( strcmp( sz_trn, Ktbd_Dettrs[i].DETTRS_CF ) == 0) RETURN_VAL(i);
  }

  RETURN_VAL(-1);
}


/*==============================================================================
objet :
  fonction de recherche du trncod
retour :
  0   ---> Pas de rupture
  < 0     ---> On n'est pas arrive au bloc synchrone
  > 0     ---> On a depasse le bloc synchrone
==============================================================================*/
//int n_RechTSect(char *sz_tsect)
int n_RechTSect( char **ptb_InRec_Cur )
{
  int i;

  DEBUT_FCT("n_RechTSect");

  for ( i = 0; i <  Kn_NbLigTSect ; i++ )
  {
    if (strcmp(ptb_InRec_Cur[GT_CTR_NF], Ktbd_TSect[i].CTR_NF) == 0 &&
        atoi(ptb_InRec_Cur[GT_END_NT]) == Ktbd_TSect[i].END_NT &&
        atoi(ptb_InRec_Cur[GT_UWY_NF]) == Ktbd_TSect[i].UWY_NF &&
        atoi(ptb_InRec_Cur[GT_SEC_NF]) == Ktbd_TSect[i].SEC_NF )
    {
      return i ;
    }
  }
  return -1 ;
}
