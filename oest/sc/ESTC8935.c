/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          : 
nom du source                 : ESTC8935.c
revision                      : $Revision:   1.1  $
date de creation              : 10/1997
auteur                        : KUHNA  (C.G.I.)
references des specifications : 
squelette de base             : batch
------------------------------------------------------------------------------
description :
	Multiplication des champs CED_M et CNVAMT_M du fichier
      au format de la table TACCGTE par -1

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    20/12/1999    J. Ribot     alimentation champs LIBINV avec date bilan du
                               mouvement en entree

Changement du nom du prog C ( anciennement INVC8935.c ) effectue par M.Ha-Thuc
le 27/02/1998

==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include <estserv.h>	

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define FTACCGTE_RETTRN_NT 0
#define FTACCGTE_CED_M 17
#define FTACCGTE_CNVAMT_M 19
#define FTACCGTE_LIBINV 20
#define FTACCGTE_BALSHEY_NF 29
#define FTACCGTE_BALSHRMTH_NF 30
#define FTACCGTE_BALSHRDAY_NF 31

/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

T_RUPTURE_VAR Kbd_Rupt;

FILE	*Kp_OutFil;		 /* Fichier en sortie */

int     Kn_NumLigne;            /* Numero max de RETTRN_NF de la table
                                   TACCTRTGT (parametre recupere du shell) */

/*---------------------------*/
/* Declaration des fonctions */
/*---------------------------*/

int n_InitMult(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLigneMult(char **ptb_InRec_Cur);

/*==============================================================================
objet :
   point d'entree du programme

retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc ,char *argv[])
{

  /* Alimentation du nom en clair du programme */
  Gbd_Tech.psz_PgmLabel = "Multiplication par -1";

  /* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm(argc,argv) == ERR)
    ExitPgm (ERR_XX , "");
  n_InitMult(&Kbd_Rupt);

  /* Recuperation du numero de ligne le plus eleve de la table */
  /* auquel on ajoute 1 */
  Kn_NumLigne = n_GetIntArgv(1) + 1;

  /* ouverture du fichier en sortie */
  if (n_OpenFileAppl("ESTC8935_O1","wt",&Kp_OutFil) == ERR )
  ExitPgm ( ERR_XX , "" );
  
  /* Traitement principal */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8935_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm (ERR_XX,"");

  if (n_CloseFileAppl("ESTC8935_O1",&Kp_OutFil) == ERR)
    ExitPgm (ERR_XX ,"");

  if (n_EndPgm() == ERR)
    ExitPgm (ERR_XX , "");

  exit(OK) ;
}

/*=============================================================================
 objet: Initialisation Rupture : 0 rupture 
=============================================================================*/
int n_InitMult(T_RUPTURE_VAR  *pbd_Rupt)
{
  DEBUT_FCT("n_InitMult");

  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl ("ESTC8935_I1","rt",&(pbd_Rupt->pf_InputFil)))
  RETURN_VAL (ERR);

  /* Gestion de rupture */
  pbd_Rupt->n_NbRupture = 0;

  /* Fonction executee pour chaque ligne : */
  pbd_Rupt->n_ActionLigne = n_ActionLigneMult;

  /* Separateur utilise dans le fichier en entree */
  pbd_Rupt->c_Separ = SEPARATEUR ;

  RETURN_VAL (0);
}

/*=============================================================================
 objet: Action sur chacune des lignes  : 
         - Multiplicaton du champ CNCAMT_M par -1
         - Ecriture de cette ligne dans le fichier en sortie
=============================================================================*/
int n_ActionLigneMult(char **ptb_InRec_Cur)
{
  static char sz_NumLigne[10],
              sz_MtCed[30],
              sz_MtCnvamt[30],
              sz_Balshamj[10];

  DEBUT_FCT("n_ActionLigneMult");

  sprintf(sz_NumLigne,
          "%d",
          Kn_NumLigne);
  ptb_InRec_Cur[FTACCGTE_RETTRN_NT] = sz_NumLigne;

  sprintf(sz_MtCed,
          "%-.3lf",
          atof(ptb_InRec_Cur[FTACCGTE_CED_M]) * (-1)); 
  ptb_InRec_Cur[FTACCGTE_CED_M] = sz_MtCed;

  sprintf(sz_MtCnvamt,
          "%-.3lf",
          atof(ptb_InRec_Cur[FTACCGTE_CNVAMT_M]) * (-1)); 
  ptb_InRec_Cur[FTACCGTE_CNVAMT_M] = sz_MtCnvamt;
 
/* modif J. Ribot */

  sprintf(sz_Balshamj,"%4d%02d%02d",
   atoi(ptb_InRec_Cur[FTACCGTE_BALSHEY_NF]),
   atoi(ptb_InRec_Cur[FTACCGTE_BALSHRMTH_NF]),
   atoi(ptb_InRec_Cur[FTACCGTE_BALSHRDAY_NF]));
  ptb_InRec_Cur[FTACCGTE_LIBINV] = sz_Balshamj;

/* fin modif */
  /* Ecriture dans le fichier en sortie */
  n_WriteCols(Kp_OutFil,ptb_InRec_Cur,SEPARATEUR,0);

  /* On ajoute 1 au numero de ligne */
   Kn_NumLigne ++;

  RETURN_VAL (0);
}
