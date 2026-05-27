/*==============================================================================
 Nom de l'application          : RETRO
 Nom du source                 : ESTC1052.c
 Revision                      :
 Date de creation              : 14/05/2012
 Auteur                        : Roger Cassis
 References des specifications : concu a partir du RETM0532
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
  :spot:23802 - Prog affectation retro interne
  Maj du montant de rétro interne par jointure avec le fichier contenant la part placée en interne.

  On a ds le fichier en entrée, soit des mvts 100%, soit des mvts à la part.
  On appareille sur RETCTR, RTY, RETSEC, PLC.

  Fichier I1:
  Lorsque PLC_NT = 0 :
    PLA_RETSIGSHA_TOT_R contient taux de placement global cumulé sur RETCTR, RTY, RETSEC de plc valides ou résiliés
    PLA_RETSIGSHA_INT_R contient taux de placement interne  cumulé sur RETCTR, RTY, RETSEC
    PLA_RETSIGSHA_QOT_R contient la part que représente les plcs internes / tx global :     RETSIGSHA_INT_R/RETSIGSHA_TOT_R

  Lorsque ds le fichier esclave, on appareille sur les 4 clés, on multiplie le montant 100% du maitre par le taux de plc en rétro interne
  pour obtenir le montant de rétro interne.

  Lorsque PLC_NT est renseigné: ce ne sont que les plc internes valides ou résiliés.
  Lorsqu'il y a appareillage, on met à jour le montant de rétro interne (RETINTAMT) directement avec le montant de rétro (RETAMT) déjà à la part.

  Lorsqu'il n'y a pas appareillage, cela veut dire qu'il n'y a pas du tout de rétro interne sur RETCTR,RTY, RETSEC et le montant RETINTAMT
  est mis d'office à 0.000.

------------------------------------------------------------------------------
 Historique des modifications :
[01] 18/09/2012 R. Cassis :spot:24041 Remise a zero du montant retro interne si taux de placement interne = 0
[02] 05/11/2015 Florent :spot:29615 ne pas sortir des montants inférieur à 0.01
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <util.h>

/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/
#include "ESTC1052.h"

typedef struct {
  char            RETCTR_NF[10];
  int             RETSEC_NF;
  int             RTY_NF;
  char            PLC_NT[10];
  double          RETSIGSHA_TOT_R;
  double          RETSIGSHA_INT_R;
  double          RETSIGSHA_QOT_R;
  char            RTO_NF[10];
  int             NBLIGNES;
} T_FPLATXCUM;

enum { MAX_PLATXCUM=10000 };

T_FPLATXCUM Ktb_platxcum[MAX_PLATXCUM];

int Kn_nbplatxcum=0;

int n_RecherchePlacement    (char **);
int n_IsR1FPLATXCUM         (char **, char **);
int n_ActionFirstFPLATXCUM  (char **);
int n_ActionLastFPLATXCUM   (char **);


/*==============================================================================
 Objet :    Point d'entree du programme
 Parametre(s) :
    int argc    : Nombre d'arguments sur la ligne de commande;
    char **argv : parametres
 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  // Initialisation des signaux
  InitSig ();

  if (n_BeginPgm(argc, argv) == ERR)                  ExitPgm(ERR_XX, "");

  // Initialisation des variables de gestion de ruptures
  if (n_InitFPLATXCUM(&Kbd_ruptFPLATXCUM))            ExitPgm(ERR_XX, "");
  if (n_InitFACCTRTGT(&Kbd_ruptFACCTRTGT))            ExitPgm(ERR_XX, "");

  // Ouverture des fichiers binaires et des fichiers de sortie
  if (n_OpenFileAppl("ESTC1052_O1", "wt", &Kp_OutputFileGT) == ERR)               ExitPgm(ERR_XX, "");

  // Lancement du traitement du fichier Maitre
  if (n_ProcessingRuptureVar(&Kbd_ruptFPLATXCUM) == ERR)                          ExitPgm(ERR_XX, "");

  // Fermeture des fichiers ouverts
  if (n_CloseFileAppl("ESTC1052_I1", &(Kbd_ruptFPLATXCUM.pf_InputFil)) == ERR)    ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC1052_I2", &(Kbd_ruptFACCTRTGT.pf_InputFil)) == ERR)    ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC1052_O1", &Kp_OutputFileGT))                           ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR)  ExitPgm(ERR_XX, "");

  exit(OK);
}


/*==============================================================================
 Objet :    Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_VAR
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitFPLATXCUM(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC1052_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;                                  //[001] 0;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1FPLATXCUM;          //[001]
  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstFPLATXCUM;   //[001]
  pbd_Rupt->n_ActionLigne         = n_ActionLigneFPLATXCUM;
  pbd_Rupt->n_ActionLast[0]       = n_ActionLastFPLATXCUM;    //[001]
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
objet :     fonction de test de rupture de niveau 1
retour :    0   ---> Pas de rupture
            1   ---> rupture
==============================================================================*/
int n_IsR1FPLATXCUM(char **ptb_InRec, char **ptb_InRec_Cur)
{
  DEBUT_FCT("n_IsR1Prev");

  if (strcmp(ptb_InRec[PLA_RETCTR_NF],ptb_InRec_Cur[PLA_RETCTR_NF])!=0)       RETURN_VAL(1);
  if (strcmp(ptb_InRec[PLA_RTY_NF],ptb_InRec_Cur[PLA_RTY_NF])!=0)             RETURN_VAL(1);
  if (strcmp(ptb_InRec[PLA_RETSEC_NF],ptb_InRec_Cur[PLA_RETSEC_NF])!=0)       RETURN_VAL(1);

  RETURN_VAL (0);
}


//[001]
//==============================================================================
// Objet :    A chaque rupture première sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionFirstFPLATXCUM(char **ptb_InRec_Cur)
{
  // Initialisation
  memset(Ktb_platxcum,0,MAX_PLATXCUM*sizeof(T_FPLATXCUM));
  Kn_nbplatxcum=0;
  return OK;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFPLATXCUM(char **ptb_InRec_Cur)
{
  strcpy(Ktb_platxcum[Kn_nbplatxcum].RETCTR_NF, ptb_InRec_Cur[PLA_RETCTR_NF]);
  Ktb_platxcum[Kn_nbplatxcum].RETSEC_NF = atoi(ptb_InRec_Cur[PLA_RETSEC_NF]);
  Ktb_platxcum[Kn_nbplatxcum].RTY_NF = atoi(ptb_InRec_Cur[PLA_RTY_NF]);
  strcpy(Ktb_platxcum[Kn_nbplatxcum].PLC_NT, ptb_InRec_Cur[PLA_PLC_NT]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_TOT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_TOT_R]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_INT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_INT_R]);
  Ktb_platxcum[Kn_nbplatxcum].RETSIGSHA_QOT_R = atof(ptb_InRec_Cur[PLA_RETSIGSHA_QOT_R]);
  strcpy(Ktb_platxcum[Kn_nbplatxcum].RTO_NF, ptb_InRec_Cur[PLA_RTO_NF]);
  Ktb_platxcum[Kn_nbplatxcum].NBLIGNES = atoi(ptb_InRec_Cur[PLA_NBLIGNES]);
  Kn_nbplatxcum++;

  return OK;
}

//[001]
//==============================================================================
// Objet :    En rupture Dernière sur CONTRAT/EXERCICE/SECTION   de rétro
//==============================================================================
int n_ActionLastFPLATXCUM(char **ptb_InRec_Cur)
{
  n_ProcessingRuptureSyncVar(&Kbd_ruptFACCTRTGT, ptb_InRec_Cur);
  return OK;
}

/*==============================================================================
 Objet :    Initialisation de la variable de gestion de synchronisation (Esclave)
 Parametre(s) : Pointeur sur une structure T_RUPTURE_SYNC_VAR
 Retour :       En cas de probleme retourne ERR
                sinon retourne OK
==============================================================================*/
int n_InitFACCTRTGT(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC1052_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncFACCTRTGT;
  pbd_Rupt->n_FilsSansPere   = n_ActionFsPFACCTRTGT;
  pbd_Rupt->n_ActionLigne    = n_ActionLigneSyncFACCTRTGT;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :    Fonction de test de synchronisation avec la Maitre
 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave
 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncFACCTRTGT(char **ptb_InRecPLATXCUM, char **ptb_InRecChild)
{
  int ret;

  if ((ret = strcmp(ptb_InRecPLATXCUM[PLA_RETCTR_NF],       ptb_InRecChild[GT_RETCTR_NF]))  != 0)  return(ret);
  if ((ret = strcmp(ptb_InRecPLATXCUM[PLA_RTY_NF],          ptb_InRecChild[GT_RETRTY_NF]))  != 0)  return(ret);
  if ((ret = (atoi(ptb_InRecPLATXCUM[PLA_RETSEC_NF]) - atoi(ptb_InRecChild[GT_RETSEC_NF]))) != 0)  return(ret);
  //[001] et Si le placement existe dans le fichier des placements
  if (( ret = n_RecherchePlacement(ptb_InRecChild) !=0)) return(ret);

  return 0;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne synchronisee avec le Maitre
 Parametre(s) :
   Pointeur sur la ligne courante
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncFACCTRTGT(char **ptb_InRecPLATXCUM, char **ptb_InRecChild)
{
  char Ksz_RETINTAMT_M[25];
  double d_RETINTAMT_M;
  double d_RETAMT_M;
  double d_AMT_M;
  char Ksz_AMT_M[25];
  int i=0;
  int j=0;

  //[001]
  if ( atoi(ptb_InRecChild[GT_PLC_NT]) == 0)
  {
    // Un seul placement interne
    if ( atoi(ptb_InRecPLATXCUM[PLA_NBLIGNES]) <= 2     &&
         atof(ptb_InRecPLATXCUM[PLA_RETSIGSHA_QOT_R]) == 1.0 )      //[001]
    {
      sprintf(Ksz_RETINTAMT_M, "%-.3lf",atof(ptb_InRecChild[GT_RETAMT_M]) * atof(ptb_InRecPLATXCUM[PLA_RETSIGSHA_QOT_R]) );
      ptb_InRecChild[GT_RETINTAMT_M]=Ksz_RETINTAMT_M;
      ptb_InRecChild[GT_PLC_NT]=Ktb_platxcum[1].PLC_NT;
      ptb_InRecChild[GT_RTO_NF]=Ktb_platxcum[1].RTO_NF;

      if ( fabs(atof(ptb_InRecChild[GT_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETINTAMT_M])) > 0.01 )
        n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
    }
    else
    {
      //memorisation montant avant écrasement.
      d_RETAMT_M=(double)atof(ptb_InRecChild[GT_RETAMT_M]);
      d_AMT_M=(double)atof(ptb_InRecChild[GT_AMT_M]);

      //[001] Ici, on va boucler sur les placements du contrat/sec/UWY et générer une ligne pour chaque
      for(i=0;i<Kn_nbplatxcum;i++)
      {
        //montant de retro interne
        d_RETINTAMT_M = d_RETAMT_M * Ktb_platxcum[i].RETSIGSHA_QOT_R;

        if(i==0)
        {
          // Ecriture  du solde pour la retro externe pure
          // Montant de retro global - montant de retro interne
          sprintf(Ksz_RETINTAMT_M, "%-.3lf", d_RETAMT_M - d_RETINTAMT_M );
          ptb_InRecChild[GT_RETAMT_M] = Ksz_RETINTAMT_M;

          sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * ( 1.00 - Ktb_platxcum[i].RETSIGSHA_QOT_R ));     //[001]
          ptb_InRecChild[GT_AMT_M] = Ksz_AMT_M;                                               //[001]

          ptb_InRecChild[GT_RETINTAMT_M] = "0.000";
          ptb_InRecChild[GT_PLC_NT] = "";     // placement vide
          ptb_InRecChild[GT_RTO_NF] = "";     // rto_nf vide

          if ( fabs(atof(ptb_InRecChild[GT_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETINTAMT_M])) > 0.01 )
            n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);

        }
        else
        {
          sprintf(Ksz_RETINTAMT_M, "%-.3lf", d_RETINTAMT_M );
          ptb_InRecChild[GT_RETINTAMT_M] = Ksz_RETINTAMT_M;
          ptb_InRecChild[GT_RETAMT_M]    = ptb_InRecChild[GT_RETINTAMT_M];

          sprintf(Ksz_AMT_M, "%-.3lf", d_AMT_M * Ktb_platxcum[i].RETSIGSHA_QOT_R);                //[001]
          ptb_InRecChild[GT_AMT_M] = Ksz_AMT_M;                                               //[001]
          ptb_InRecChild[GT_PLC_NT]=Ktb_platxcum[i].PLC_NT;
          ptb_InRecChild[GT_RTO_NF]=Ktb_platxcum[i].RTO_NF;

          if ( Ktb_platxcum[i].RETSIGSHA_INT_R == 0 ) ptb_InRecChild[GT_RETINTAMT_M] = "0.000";  // [001]
          if ( fabs(atof(ptb_InRecChild[GT_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETINTAMT_M])) > 0.01 )
            n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
        }
      }
    }
  }
  else
  {
    ptb_InRecChild[GT_RETINTAMT_M] = "0.000" ;
    ptb_InRecChild[GT_RTO_NF]=Ktb_platxcum[0].RTO_NF;                   //[001]
    for(j=0;j<Kn_nbplatxcum;j++)                                      //[002]
    {
      if ( strcmp(ptb_InRecChild[GT_PLC_NT], Ktb_platxcum[j].PLC_NT) == 0 )
      {
        ptb_InRecChild[GT_RTO_NF]=Ktb_platxcum[j].RTO_NF;
        ptb_InRecChild[GT_RETINTAMT_M] = ptb_InRecChild[GT_RETAMT_M] ;
      }
    }
    if ( Ktb_platxcum[j].RETSIGSHA_INT_R == 0 ) ptb_InRecChild[GT_RETINTAMT_M] = "0.000";  // [001]

    if ( fabs(atof(ptb_InRecChild[GT_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETINTAMT_M])) > 0.01 )
      n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);           //[001]
  }
  return OK;
}

//[001]
int n_RecherchePlacement(char **ptb_InRecChild)
{
  int trouve = -1;
  int i=0;

  for(i=0;i<Kn_nbplatxcum;i++)
  {
      if ( strcmp(ptb_InRecChild[GT_RETCTR_NF] , Ktb_platxcum[i].RETCTR_NF)==0   &&
           atoi(ptb_InRecChild[GT_RETRTY_NF]) == Ktb_platxcum[i].RTY_NF          &&
           atoi(ptb_InRecChild[GT_RETSEC_NF]) == Ktb_platxcum[i].RETSEC_NF       &&
           atoi(ptb_InRecChild[GT_PLC_NT])    == atoi(Ktb_platxcum[i].PLC_NT)    )
      {
        trouve=0;
        break;
    }
  }
//  return trouve;
  return 0;
}

/*==============================================================================
 Objet :    Fonction lancee pour chaque ligne du fils non synchronisee avec le pere
 Parametre(s) :
   Pointeur sur la ligne courante (Esclave)
 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionFsPFACCTRTGT(char **ptb_InRecChild)
{
  ptb_InRecChild[GT_RETINTAMT_M]= "0.000";
  if ( fabs(atof(ptb_InRecChild[GT_AMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETAMT_M])) > 0.01 || fabs(atof(ptb_InRecChild[GT_RETINTAMT_M])) > 0.01 )
    n_WriteCols(Kp_OutputFileGT, ptb_InRecChild, '~', 0);
  return OK;
}
