/*==============================================================================
nom de l'application          : ESTIMATION
nom du source                 : ESTC8807.c
revision                      : $Revision: 1.2 $
date de creation              : 15/06/2015
auteur                        : D FILLINGER
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
   Split file FTECLEDA_MVT between FTECLEDA_MVT, FTECLEDA_MTH and FTECLEDA_REP
------------------------------------------------------------------------------
historique des modifications :
<jj/mm/aaaa>   <auteur>  <SPOT>   <description de la modification>
 18/06/2015     DFI      28947      filtre des analytiques dans la generation de l'interface 1GL
 05/02/2016     Florent  :spot:29066 suite au GLT à 71 colonnes, 16 nouvelles colonnes dans les 2 tables TTCLEDA et R
[003] 21/06/2016 Roger   :spot:30790 On ajoute les ORICOD_LS IFRSGTA, IFRS et OIGTA des ecritures de service pour les envoyer dans .MVT
[004] 10/08/2017 Roger   :spira:61508 Ajout de l'ORICOD_LS LOCAL pour prendre en compte les ecritures de service locales
[005] 04/01/2018 Roger   :spira:51764 Les 14 champs SAP (OneGL) sont remis à blanc dans tous les cas.
[006] 12/09/2023 JYP     :spira:110487 mise à blanc NEWCOLS1 / fichier REP
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>
#include <stdarg.h>
#include <utctlib.h>
#include "struct.h"
#include "estserv.h"

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC8802.h"

/*----------------------------------------*/
/* inclusion de version dans les binaires */
/*----------------------------------------*/
static char VERSION_ESTC8807_C[151] = "__version__: ESTC8807.c version [006] 12/09/2023 blank newcols1 REP" ;



/*----------------------*/
/* variables de travail */
/*----------------------*/
FILE    *Kp_InputFtecleda ;      /* pointeur sur le fichier FTECLEDA a decouper */
FILE    *Kp_InputSubtrs ;      /* pointeur sur le fichier SUBTRS */
FILE        *Kp_OutputFtecleda_mvt ; /* pointeur sur le fichier de sortie FTECLEDA_MVT */
FILE        *Kp_OutputFtecleda_mth ; /* pointeur sur le fichier de sortie FTECLEDA_MTH */
FILE        *Kp_OutputFtecleda_rep ; /* pointeur sur le fichier de sortie FTECLEDA_REP */

T_RUPTURE_VAR   Kbd_ruptFtecleda;
T_SUBTRS        pbd_SubTrsLigne;

int n_InitFtecleda(T_RUPTURE_VAR *pbd_Rupt);
int n_ActionLigneFtecleda(char **pbd_InRec_Cur);
int is_analytic(char **ptb_InRec_Cur);
char sz_message[200];

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

  sprintf(sz_message,"\nRunning with %s\n", VERSION_ESTC8807_C);
  printf(sz_message);
		
  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC8807_I1", "rt", &Kp_InputFtecleda ) == ERR )
    ExitPgm( ERR_XX , "Cannot open ESTC8807_I1 file!" ) ;

  /* ouverture du fichier binaire en entree des correspondances retro vers acceptation */
  if ( n_OpenFileAppl ( "ESTC8807_I2", "rb", &Kp_InputSubtrs ) == ERR )
    ExitPgm( ERR_XX , "Cannot open ESTC8807_I2 file!" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC8807_O1", "wt", &Kp_OutputFtecleda_mvt ) == ERR )
    ExitPgm( ERR_XX , "Cannot create ESTC8807_O1 file!" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC8807_O2", "wt", &Kp_OutputFtecleda_mth ) == ERR )
    ExitPgm( ERR_XX , "Cannot create ESTC8807_O2 file!" ) ;

  /* ouverture du fichier en sortie GT */
  if ( n_OpenFileAppl ( "ESTC8807_O3", "wt", &Kp_OutputFtecleda_rep ) == ERR )
    ExitPgm( ERR_XX , "Cannot create ESTC8807_O3 file!" ) ;

  if (n_ChargerTsubTRS(Kp_InputSubtrs) != 0)
    ExitPgm(ERR_XX, "Call of n_ChargerTsubTRS() fails");

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitFtecleda(&Kbd_ruptFtecleda))
    ExitPgm(ERR_XX, "InitFtecleda fails");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptFtecleda) == ERR)
    ExitPgm(ERR_XX, "n_ProcessingRuptureVar fails");

  if ( n_CloseFileAppl( "ESTC8807_I1", &Kp_InputFtecleda ) == ERR )
    ExitPgm( ERR_XX , "Cannot close properly ESTC8807_I1 file!" ) ;

  if ( n_CloseFileAppl( "ESTC8807_I2", &Kp_InputSubtrs ) == ERR )
    ExitPgm( ERR_XX , "Cannot close properly ESTC8807_I2 file!" ) ;

  if ( n_CloseFileAppl( "ESTC8807_O1", &Kp_OutputFtecleda_mvt ) == ERR )
    ExitPgm( ERR_XX , "Cannot close properly ESTC8807_O1 file!" ) ;

  if ( n_CloseFileAppl( "ESTC8807_O2", &Kp_OutputFtecleda_mth ) == ERR )
    ExitPgm( ERR_XX , "Cannot close properly ESTC8807_O2 file!" ) ;

  if ( n_CloseFileAppl( "ESTC8807_O3", &Kp_OutputFtecleda_rep ) == ERR )
    ExitPgm( ERR_XX , "Cannot close properly ESTC8807_O3 file!" ) ;

  /* fermeture du programme */
  if ( n_EndPgm() == ERR )
    ExitPgm( ERR_XX , "Call of n_EndPgm() fails" );

  exit( OK ) ;
}

/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de rupture (Maitre)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFtecleda(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt, 0, sizeof( T_RUPTURE_VAR ));

  pbd_Rupt->pf_InputFil = Kp_InputFtecleda;
  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneFtecleda;
  pbd_Rupt->c_Separ = '~';

  return OK;
}

/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne du Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneFtecleda(char **ptb_InRec_Cur)
{
	// [005] RAB des 14 colonnes du ONEGL de SAP
	ptb_InRec_Cur[TECLEDA_BUKRS_CF] = "";
  ptb_InRec_Cur[TECLEDA_RCOMP_CF] = "";
  ptb_InRec_Cur[TECLEDA_LDGRP_CF] = "";
  ptb_InRec_Cur[TECLEDA_HKONT_CF] = "";
  ptb_InRec_Cur[TECLEDA_DBLHKONT_CF] = "";
  ptb_InRec_Cur[TECLEDA_GJAHR_NF] = "";
  ptb_InRec_Cur[TECLEDA_MONAT_NF] = "";
  ptb_InRec_Cur[TECLEDA_VBUND_CF] = "";
  ptb_InRec_Cur[TECLEDA_ZZCED_NF] = "";
  ptb_InRec_Cur[TECLEDA_SEGMENT_CF] = "";
  ptb_InRec_Cur[TECLEDA_BEWAR_CF] = "";
  ptb_InRec_Cur[TECLEDA_ZZGAAPDIF_CF] = "";
  ptb_InRec_Cur[TECLEDA_BLART_CF] = "";
  ptb_InRec_Cur[TECLEDA_ZZRECONKEY_CF] = "";

  if ((ptb_InRec_Cur[TECLEDA_ORICOD_LS] && !strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "EBSGTA")) ||
      ptb_InRec_Cur[TECLEDA_TRNCOD_CF][7] == 'G' ||
      ptb_InRec_Cur[TECLEDA_TRNCOD_CF][7] == 'H' ||
      ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'A' ||
      ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'E' ||
      ptb_InRec_Cur[TECLEDA_TRNCOD_CF][1] == 'J' ||
      is_analytic(ptb_InRec_Cur))
  {
    n_WriteCols(Kp_OutputFtecleda_mth, ptb_InRec_Cur, SEPARATEUR, 0);
  }
  else if (ptb_InRec_Cur[TECLEDA_ORICOD_LS] &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "")     != 0 &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "GTAR") != 0 &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "GTA")  != 0 &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "IFRS")  != 0 &&  //[003]
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "IFRSGTA")  != 0 &&  //[003]
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "OIGTA")  != 0 &&    //[003]
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "CURGTA")  != 0 &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "CURGTA_PO")  != 0 &&
           strcmp(ptb_InRec_Cur[TECLEDA_ORICOD_LS], "LOCAL")  != 0 &&   //[004]
           (ptb_InRec_Cur[TECLEDA_TRNCOD_CF][0] == '2' ||
            ptb_InRec_Cur[TECLEDA_TRNCOD_CF][0] == '4'))
  {
	ptb_InRec_Cur[TECLEDA_NEWCOLS1_CF] = "";	
    n_WriteCols(Kp_OutputFtecleda_rep, ptb_InRec_Cur, SEPARATEUR, 0);
  }
  else
  {
    n_WriteCols(Kp_OutputFtecleda_mvt, ptb_InRec_Cur, SEPARATEUR, 0);
  }
  return OK;
}

/*==============================================================================
 Objet :
   Teste si la ligne courante est une ligne analytique

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   Si la ligne est analytique retourne 1
   sinon retourne 0
==============================================================================*/
int is_analytic(char **ptb_InRec_Cur)
{
  char dettrncod[6];
  int i;

  for (i = 0; i < 5; i++)
    dettrncod[i] = ptb_InRec_Cur[TECLEDA_TRNCOD_CF][i + 2];
  dettrncod[5] = '\0';

  if (n_FindTsubTRS(&pbd_SubTrsLigne, dettrncod) != -1 &&
      pbd_SubTrsLigne.TRSNATURE_CT == 2)
  {
    return 1;
  }
  return 0;
}
