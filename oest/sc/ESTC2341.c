/*******************************************************************************
 * Nom de l'application		: Filtre des ligne estimate des ctr non estimate   *
 * Nom du source       		: ESTC2341.c
 * Revision            		: 
 * Date de creation    		: 31/10/2019
 * Auteur              		: Belaid LAGHA.
 * 
 * --------------------------------------------------------------------------- *
 * Description : Ce programe filtre les lignes estimation des contrats 
 * non estimation.
 * --------------------------------------------------------------------------- *
 *
 * Historique des modifications : 
 * ------------+---------+--------+------------------------------------------- *
 * <jj/mm/aaaa>|<Auteur> | <spot> | <Description de la modification>
 * ------------+---------+--------+------------------------------------------- *
 *  06/12/2019 | BEL     | 80491  |  filtrer les lignes accruals et reversals 
 *             |         |        |  sur les contrats NON_ESTIMATE 
 *             |         |        |  (on laisse que la compta)
 * ------------+---------+--------+------------------------------------------- *
 *
 ******************************************************************************/

#include <estserv.h>
#include <utctlib.h>
#include <struct.h>

T_RUPTURE_SYNC_VAR    bd_RuptGT;
T_RUPTURE_VAR         bd_RuptPeri;

FILE *Kp_IncludGTOFil, *Kp_ExcludGTOFil;


int n_InitGT   (T_RUPTURE_SYNC_VAR *pbd_Rupt) ;
int n_InitPeri (T_RUPTURE_VAR      *pbd_Rupt) ;

int ConditionEndSyncGT     (char **ptb_InRec_Pere, char **ptb_InRec_Fils);
int n_ActionLigneGT        (char **ptb_InRec_Pere, char **ptb_InRec_Fils);
int n_ActionFilsSansPere   (char **ptb_InRec_Cur);
int n_ConditionRuptPerim   (char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionLigneRuptPerim (char **ptb_InRec_Cur);


int main (int argc, char *argv[])
{
  /* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm (argc, argv) == ERR) ExitPgm ( ERR_XX, "" );

  /* Allocation memoire afin de preparer les Ruptures */
  memset(&bd_RuptPeri,0,sizeof(T_RUPTURE_VAR));
  memset(&bd_RuptGT,0,sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture des fichiers */
  if (n_OpenFileAppl ("ESTC2341_I1", "rt", &(bd_RuptPeri.pf_InputFil)) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_OpenFileAppl ("ESTC2341_I2", "rt", &(bd_RuptGT.pf_InputFil)) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_OpenFileAppl ("ESTC2341_O1", "wt", &Kp_IncludGTOFil) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_OpenFileAppl ("ESTC2341_O2", "wt", &Kp_ExcludGTOFil) == ERR )
     ExitPgm ( ERR_XX, "" );

  /* Initialisation de la Rupture bd_RuptPeri */
  if (n_InitPeri(&bd_RuptPeri)) ExitPgm ( ERR_XX , "" );
  /* Initialisation de la Rupture bd_RuptPeri */
  if (n_InitGT(&bd_RuptGT)) ExitPgm ( ERR_XX , "" );

  /* Lancement du traitement du fichier perimetre */
  if (n_ProcessingRuptureVar(&bd_RuptPeri) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers */
  if (n_CloseFileAppl ("ESTC2341_I1", &(bd_RuptPeri.pf_InputFil)) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_CloseFileAppl ("ESTC2341_I2", &(bd_RuptGT.pf_InputFil)) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_CloseFileAppl ("ESTC2341_O1", &Kp_IncludGTOFil) == ERR )
     ExitPgm ( ERR_XX, "" );
  if (n_CloseFileAppl ("ESTC2341_O2", &Kp_ExcludGTOFil) == ERR )
     ExitPgm ( ERR_XX, "" );


  /* Fin du programme avec succes */
  return EXIT_SUCCESS;
}


/**********************************************************************
 * Fonction permetant de initialiser les parametres de la Rupture GT. *
 **********************************************************************/
int n_InitGT   (T_RUPTURE_SYNC_VAR *pbd_Rupt)
{
  DEBUT_FCT("n_InitGT");

  
  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = ConditionEndSyncGT;
  pbd_Rupt->n_ActionLigne    = n_ActionLigneGT;
  pbd_Rupt->n_FilsSansPere   = n_ActionFilsSansPere;
  pbd_Rupt->c_Separ          = SEPARATEUR;
 
  RETURN_VAL (0);
}

/****************************************************************************
 * Fonction permetant de verifier la condition de Rupture synchrone entre   *
 * le Perimetre et le GT.                                                   *
 ****************************************************************************/
int ConditionEndSyncGT (char **ptb_InRec_Pere, char **ptb_InRec_Fils)
{
  DEBUT_FCT("n_ConditionSyncPrev");
  int ret = 0;

  if ((ret = strcmp(ptb_InRec_Pere[PER_CTR_NF] , ptb_InRec_Fils[GT_CTR_NF])) != 0)
     RETURN_VAL(ret);
  if ((ret = strcmp(ptb_InRec_Pere[PER_END_NT],  ptb_InRec_Fils[GT_END_NT])) != 0)
     RETURN_VAL(ret);
  if ((ret = strcmp(ptb_InRec_Pere[PER_SEC_NF] , ptb_InRec_Fils[GT_SEC_NF])) != 0)
     RETURN_VAL(ret);
  if ((ret = strcmp(ptb_InRec_Pere[PER_UWY_NF] , ptb_InRec_Fils[GT_UWY_NF])) != 0)
     RETURN_VAL(ret);
  if ((ret = strcmp(ptb_InRec_Pere[PER_UW_NT],   ptb_InRec_Fils[GT_UW_NT]))  != 0)
     RETURN_VAL(ret);

  RETURN_VAL (ret);
} 


/**************************************************************************
 * Fonction lancee pour chaque ligne du GT avec une ligne Perimetre       *
 * corespondante.                                                         *
 **************************************************************************/
int n_ActionLigneGT (char **ptb_InRec_Pere, char **ptb_InRec_Fils)
{
  DEBUT_FCT("n_ActionLignePrev");

  if ( strcmp (ptb_InRec_Pere[PER_ESTCRB_CT], "V") == 0 &&
       (ptb_InRec_Fils[GT_TRNCOD_CF][7] == '2' || // Accrual  Estimate    (GAAP1). 
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == '3' || // Reversal Estimate    (GAAP1).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'A' || // Accrual  IFRS        (GAAP2).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'B' || // Reversal IFRS        (GAAP2).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'C' || // Accrual  Parent      (GAAP3).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'D' || // Reversal Parent      (GAAP3).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'E' || // Accrual  Local       (GAAP4).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'F' || // Reversal Local       (GAAP4).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'G' || // Accrual  Solvency II (GAAP5).
        ptb_InRec_Fils[GT_TRNCOD_CF][7] == 'H'    // Reversal Solvency II (GAAP5).
       )
      )
     n_WriteCols(Kp_ExcludGTOFil, ptb_InRec_Fils, SEPARATEUR, 0);
  else
     n_WriteCols(Kp_IncludGTOFil, ptb_InRec_Fils, SEPARATEUR, 0);

  RETURN_VAL (0);
}

/**************************************************************************
 * Fonction lancee pour chaque ligne du GT qui n'a pas de ligne Perimetre *
 * corespondante.                                                         *
 **************************************************************************/
int n_ActionFilsSansPere (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionFilsSansPere");

  n_WriteCols(Kp_IncludGTOFil, ptb_InRec_Cur, SEPARATEUR, 0);

  RETURN_VAL(0);
}

 
/*****************************************************************************
 * Fonction permetant de initialiser les parametres de la Rupture Perimetre. *
 *****************************************************************************/
int n_InitPeri (T_RUPTURE_VAR      *pbd_Rupt)
{
  DEBUT_FCT("n_InitPeri");

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->n_ActionLigne = n_ActionLigneRuptPerim;
  pbd_Rupt->c_Separ = SEPARATEUR;

  RETURN_VAL (0);
}


/**************************************************************
 * Fonction lancee a chaque fin de Rupture dans le Perimetre. *
 **************************************************************/
int n_ActionLigneRuptPerim (char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_ActionLastRuptPerim");

  /* Lancer le traitement de la Rupture synchrone entre le Perimetre et le GT */
  n_ProcessingRuptureSyncVar(&bd_RuptGT, ptb_InRec_Cur);

  RETURN_VAL (0);
}


