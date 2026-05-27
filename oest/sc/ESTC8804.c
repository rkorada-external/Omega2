/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8804.c
revision                      : $Revision: 1.2 $
date de creation              : 18/05/2000
auteur                        : S LLORENTE
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   AJOUT INFOS CORRESPONDANCE RETRO VERS ACCEPTATION DANS FTECLEDR

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
    12/09/2003     J.Ribot     passe MAX_SSDACTR  de 12500 a 20000
    27/03/2008     J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
_________________
[03] D.GATIBELZA 22/07/2008 ESTDOM15823 Echange interne  agrandissement d'un tableau en memoire pour charger les références internes
                            passage de MAX_SSDACTR 20000 à : MAX_SSDACTR 50000
[04] JF VDV      08/10/2012 [24327] Echange interne agrandissement du tableau en memoire pour charger les références internes
                             passage de MAX_SSDACTR 50 000 à : MAX_SSDACTR 500 000 + augmentation de la taille du compteur  Kn_SsdActr_Nbp
[05] 05/02/2016 Florent      :spot:29066 suite au GLT à 71 colonnes, 16 nouvelles colonnes dans les 2 tables TTCLEDA et R
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"
#include "ESTC8802.h"

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define MAX_SSDACTR 500000       // [24327] 500000  ancien = 50000  -- [003] 20000

/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_InputFilSsdActr ; /* pointeur sur le fichier des correspondances retro vers acceptation */
FILE    *Kp_InputFilFtecledr ;  /* pointeur sur le fichier FTECLEDR */
FILE            *Kp_OutputFilFtecledr ;       /* pointeur sur le fichier de sortie GT */

T_RUPTURE_VAR       bd_RuptFtecledr ;   /* variable de gestion de la rupture sur le FTECLEDR */

T_SSDACTR Ktbd_SsdActr[MAX_SSDACTR] ;   /* tableau des correspondances retro vers acceptation */
int Kn_SsdActr_Nbp ;      /* compteur du nombre de postes du tableau Ktbd_SsdActr */ // [24327] short Kn_SsdActr_Nbp

char Ksz_cloprd[7]; /* periode courante (parametre du programme) */
char Ksz_dbclo_d[9];  /* date d'arrete (parametre du programme) */
char Ksz_cre_d[9];  /* date de traitement (parametre du programme) */

int n_InitFtecledr      ( T_RUPTURE_VAR  *pbd_Rupt ) ;
int n_ActionLigneFtecledr   ( char **pbd_InRec_Cur );

int n_ChargerSSDACTR( void ) ;
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec ) ;



/*==============================================================================
objet  : point d'entree du programme

retour : En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
         Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc  , char *argv[])
{
  /* Initialisation des signaux */
  InitSig () ;

  if ( n_BeginPgm ( argc, argv ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC8804_I2", "rb", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* Initialisation de la variable bd_RuptFtecledr */
  if ( n_InitFtecledr( &bd_RuptFtecledr ) )
    ExitPgm( ERR_XX , "" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC8804_O1", "wt", &Kp_OutputFilFtecledr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  /* chargement de la table TSSDACTR en memoire */
  Kn_SsdActr_Nbp = n_ChargerSSDACTR( ) ;
  if ( Kn_SsdActr_Nbp >= MAX_SSDACTR )
    ExitPgm( ERR_XX , "Taille tableau TSSDACTR insuffisante " ) ;

  /* lancement du traitement du fichier FTECLEDR */
  if ( n_ProcessingRuptureVar( &bd_RuptFtecledr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8804_I1", &( bd_RuptFtecledr.pf_InputFil ) ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8804_I2", &Kp_InputFilSsdActr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;

  if ( n_CloseFileAppl( "ESTC8804_O1", &Kp_OutputFilFtecledr ) == ERR )
    ExitPgm( ERR_XX , "" ) ;


  /* fermeture du programme */
  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "" );

  exit( OK ) ;
}


/*==============================================================================
objet  : fonction d'initialisation de la variable de gestion de rupture du fichier
   maitre.

retour : 0K
==============================================================================*/
int n_InitFtecledr(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT( "n_InitFtecledr" ) ;

  memset( pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ) ) ;

  /* ouverture du fichier maitre FTECLEDR */
  if ( n_OpenFileAppl( "ESTC8804_I1", "rt", &( pbd_Rupt->pf_InputFil ) ) )
    return ERR ;

  Kp_InputFilFtecledr  =  pbd_Rupt->pf_InputFil ;

  /* nombre de rupture a gerer */
  pbd_Rupt->n_NbRupture = 0 ;

  /* fonction d'action sur la ligne courante du fichier maitre */
  pbd_Rupt->n_ActionLigne = n_ActionLigneFtecledr ;

  pbd_Rupt->c_Separ =  '~';

  RETURN_VAL( OK ) ;
}




/*==============================================================================
objet  : fonction lancee pour chaque ligne
retour : OK ---> traitement correctement effectue
         ERR --> probleme rencontre
==============================================================================*/
int n_ActionLigneFtecledr( char **ptb_InRec_Cur )
{
  int i ;
  char  MsgAno[300] ;
  char sz_Sec[4];
  char sz_End[3];
  char sz_Uwy[5];
  char sz_Uw[5];

  DEBUT_FCT( "n_ActionLigneFtecledr" ) ;

  if ( atoi( ptb_InRec_Cur[TECLEDR_SSDRTO_B] ) == 1 )
  {
    /* recherche de la correspondance dans la table TSSDACTR */
    i = n_RechercheSSDACTR(   ptb_InRec_Cur[TECLEDR_RETCTR_NF],
                              atoi( ptb_InRec_Cur[TECLEDR_RTY_NF] ),
                              atol( ptb_InRec_Cur[TECLEDR_PLC_NT] ),
                              (unsigned char) atoi( ptb_InRec_Cur[TECLEDR_RETSEC_NF] ) ) ;


    /* si la recherche dans TSSDACTR n'aboutit pas, generation d'une anomalie et pas d'ecriture en sortie */
    if ( i == -1 )
    {
      sprintf( MsgAno,
               "the research in BRET..TSSDACTR failed for the contract ( RETCTR_NF %s - RTY_NF %s - RETSEC_NF %s - RETUW_NT %s - PLC_NT %s ) \n",
               ptb_InRec_Cur[TECLEDR_RETCTR_NF],
               ptb_InRec_Cur[TECLEDR_RTY_NF],
               ptb_InRec_Cur[TECLEDR_RETSEC_NF],
               ptb_InRec_Cur[TECLEDR_RETUW_NT],
               ptb_InRec_Cur[TECLEDR_PLC_NT] ) ;

      n_WriteAno( MsgAno ) ;
    }
    else
    {
      /*  recuperer les donnees acceptation */
      ptb_InRec_Cur[TECLEDR_CTR_NF] = Ktbd_SsdActr[i].CTR_NF;

      sprintf( sz_End , "%d", (int)Ktbd_SsdActr[i].END_NT);
      ptb_InRec_Cur[TECLEDR_END_NT] = sz_End;

      sprintf(sz_Sec , "%d", (int)Ktbd_SsdActr[i].SEC_NF);
      ptb_InRec_Cur[TECLEDR_SEC_NF] = sz_Sec;

      sprintf( sz_Uwy , "%d" , (int)Ktbd_SsdActr[i].UWY_NF);
      ptb_InRec_Cur[TECLEDR_UWY_NF] = sz_Uwy;

      sprintf( sz_Uw , "%d" , (int)Ktbd_SsdActr[i].UW_NT);
      ptb_InRec_Cur[TECLEDR_UW_NT] = sz_Uw;
    }
  }

  n_WriteCols( Kp_OutputFilFtecledr,  ptb_InRec_Cur , '~', 0);

  RETURN_VAL( OK ) ;
}



/*==============================================================================
objet : fonction de chargement du fichier binaire des correspondances
  retro vers acceptation

retour :le nombre d'enregistrements charges dans le tableau

==============================================================================*/
int n_ChargerSSDACTR( void )
{
  DEBUT_FCT( "n_ChargerSSDACTR" ) ;

  RETURN_VAL( fread( Ktbd_SsdActr, sizeof( T_SSDACTR ), MAX_SSDACTR, Kp_InputFilSsdActr ) ) ;
}



/*==============================================================================
objet : fonction de recherche des correspondances retro vers acceptation

retour :le numero de poste dans le tableau si la fonction a trouve sinon -1
==============================================================================*/
int n_RechercheSSDACTR( char *RetCtr, short Rty, long Plc, unsigned char RetSec )
{
  int i, ret1, ret2, ret3, ret4;

  for ( i = 0; i < Kn_SsdActr_Nbp; i++ )
  {
    ret1 = strcmp( RetCtr, Ktbd_SsdActr[i].RETCTR_NF ) ;
    if ( ret1 == 0 )
    {
      ret2 = Rty - Ktbd_SsdActr[i].RTY_NF ;
      if ( ret2 == 0 )
      {
        ret3 = Plc - Ktbd_SsdActr[i].PLC_NT ;
        if ( ret3 == 0 )
        {
          ret4 = RetSec - Ktbd_SsdActr[i].RETSEC_NF ;
          if ( ret4 == 0 )
            return ( i ) ;
          else if ( ret4 < 0 ) return ( -1 ) ;
        }
        else if ( ret3 < 0 ) return ( -1 ) ;
      }
      else if ( ret2 < 0 ) return ( -1 ) ;
    }
    else if ( ret1 < 0 ) return ( -1 ) ;
  }

  return ( -1 ) ;
}

