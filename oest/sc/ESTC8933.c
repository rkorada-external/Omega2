/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          : 
nom du source                 : ESTC8933.c
revision                      :
date de creation              : 8/8/1997 
auteur                        : Kuhna 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Il s'agit d'alimenter a partir des ecrirures d'inventaire les tables de
  mouvements estimations destinees a MIS
  En entree : perimetre acceptation et GTAa
  En sortie : Mouvements comptables acceptation de l'inventaire
               (format table TACCTRNE)
              avec cumul montant GTAa sur meme jour mois annee bilan, annee
              et fin de periode de compte, annee de survenance, num sinistre,
              monnaie compte et poste comptable
              

  Synchro entre les 2 fichiers en entree sur :
  Contrat/Avenant/Section/Exercice/Num ordre exercice

  fichier pere : GTAa     fichier fils : perimetre acceptation

  2 ruptures sur GTAa :
  en RTP1 sur pere  : synchro sur fils
  en RTP2 sur pere  : init cumul
  en ligne sur pere : cumul 
  en RTD2 sur pere  : Alimentation ligne finale avec ele de GTAa  
  en ligne sur fils : Alimentation ligne finale avec ele du perimetre

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
Changement du nom du prog C ( anciennement INVC8933.c ) effectue par M.Ha-Thuc
le 27/02/1998
le 18/02/99  M.LOPEZ (IBM)  remplacement de la concatenation AnneeMoisJour par CLODAT_D(en argument)
le 17/12/99  J.RIBOT        remplacement de CLODAT_D(en argument) par la concatenation AnneeMoisJour
le 16/10/00  F.GRUEL        rajout de la fonction PereSansFils pour mettre les valeurs obligatoires a defaut pour BCPIN
==============================================================================*/

/*--------------------------------------------------*/
/* inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include <struct.h>
	
/*---------------------------------------*/
/* inclusion de l'interface du composant */
/*---------------------------------------*/

/*---------------------------------------------*/
/* definition des constantes et macros privees */
/*---------------------------------------------*/
#define MV_TRN_NT       0
#define MV_SSD_CF       1
#define MV_ESB_CF       2 
#define MV_CTR_NF       4
#define MV_UWY_NF       5
#define MV_UW_NT        6
#define MV_END_NT       7
#define MV_SEC_NF       8
#define MV_SCOSTRMTH_NF 18
#define MV_SCOENDMTH_NF 19
#define MV_ACY_NF       20
#define MV_BLCSHT_D     21
#define MV_TRNSTS_CT    22
#define MV_TRNCOD_CF    23
#define MV_ORICURAMT_M  25
#define MV_CUR_CF       27
#define MV_MTH_B        31
#define MV_OCCYEA_NF    36
#define MV_LSTUPD_D     38
#define MV_LSTUPDUSR_CF 39
#define MV_LOB_CF       40 
#define MV_SOB_CF       41
#define MV_TOP_CF       42
#define MV_NAT_CF       43
#define MV_SUBNAT_CF    44
#define MV_CED_NF       49
#define MV_LSTTRN_B     50
#define MV_RSVRLSFLG_B  51
#define MV_CLM_NF       52
#define MV_RETFLG_CT    53
#define MV_EPSTATUS     56  
#define MV_FIN          57

/*----------------------------------*/


/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	           *Kp_OutputFil; /*pointeur sur le fichier de sortie: GTAaR*/

T_RUPTURE_VAR      bd_RuptGTAa;   /*variable de gestion de la rupture sur
                                    le fichier GTAaR*/
T_RUPTURE_SYNC_VAR bd_RuptPerA;   /*variable de gestion de la synchro
                                    entre le fic GTAa et le fic PerA*/
double             d_Cum;

char               *(ptb_MvtCmpA[MV_FIN+1]),
                   sz_MoisDebPer[3];

int     Kn_NumLigne;            /* Numero max de PLCSTA_NF de la table
                                   TRTOSTAE (parametre recupere du shell) */

int n_InitGTAa(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1GTAa(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR2GTAa(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRupt1GTAa(char **ptb_InRec_Cur);
int n_ActionFirstRupt2GTAa(char **ptb_InRec_Cur);
int n_ActionLigneGTAa(char **pbd_InRec_Cur);
int n_ActionLastRupt1GTAa(char **ptb_InRec_Cur);
int n_ActionLastRupt2GTAa(char **ptb_InRec_Cur);

int n_InitPerA(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPerA(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionLignePerA(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionPsFPerA(char **ptb_InRecCur);

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);

/*==============================================================================
objet : Pt d'entree du programme
   
retour :
   En cas de probleme, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel systeme exit()
==============================================================================*/
int main(int argc,char *argv[])
{
				/* Initialisation des signaux */
  InitSig ();

  if (n_BeginPgm (argc,argv) == ERR)
    ExitPgm(ERR_XX ,"");

  /* Recuperation du numero de ligne le plus eleve de la table */
  /* auquel on ajoute 1 */
  Kn_NumLigne = n_GetIntArgv(1) + 1;

				/* Ouverture du fichier de sortie */
  if (n_OpenFileAppl ("ESTC8933_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptGTAa */
  if (n_InitGTAa(&bd_RuptGTAa) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPerA */
  if (n_InitPerA(&bd_RuptPerA) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Lancement traitement fic des GTAa */
  if (n_ProcessingRuptureVar(&bd_RuptGTAa) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC8933_I1",&(bd_RuptGTAa.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8933_I2",&(bd_RuptPerA.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC8933_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier GTAa.

retour :
	0K
==============================================================================*/
int n_InitGTAa(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));
					/* Ouverture du fic GTAa */
  if (n_OpenFileAppl("ESTC8933_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 2; 

  pbd_Rupt->n_ConditionRupture[0] = n_IsR1GTAa;
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2GTAa;

  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1GTAa;
  pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt2GTAa;

  pbd_Rupt->n_ActionLigne         = n_ActionLigneGTAa;

  pbd_Rupt->n_ActionLast[1]       = n_ActionLastRupt2GTAa;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1 GTAa
        sur Contrat/Avenant/Section/exercie/Num ordre exercice

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR1GTAa(char **ptb_InRec,char **ptb_InRec_Cur)
{
  int ret;
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Contrat */
  ret = strcmp(ptb_InRec[GT_CTR_NF],ptb_InRec_Cur[GT_CTR_NF]);
  if (ret != 0)
     return ret;

                              			  /* Avenant */
  ret = strcmp(ptb_InRec[GT_END_NT],ptb_InRec_Cur[GT_END_NT]);
  if (ret != 0)
     return ret;

                               			 /* Num Section */
  ret = strcmp(ptb_InRec[GT_SEC_NF],ptb_InRec_Cur[GT_SEC_NF]);
  if (ret != 0)
     return ret;

                               			 /* Exercice */
  ret = strcmp(ptb_InRec[GT_UWY_NF],ptb_InRec_Cur[GT_UWY_NF]);
  if (ret != 0)
     return ret;

                               			 /* Num ordre exercice */
  ret = strcmp(ptb_InRec[GT_UW_NT],ptb_InRec_Cur[GT_UW_NT]);
  if (ret != 0)
     return ret;

  return 0;
}
/*==============================================================================
objet :
	fonction de test de rupture de niveau2 GTAa
        sur Contrat/Avenant/Section/exercie/Num ordre exercice
            Annee-Mois-Jour bilan/Annee-Fin de periode de compte/
            Anne de survenance/Num sinistre/Monnaie compte/Poste comptable
         
retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR2GTAa(char **ptb_InRec,char **ptb_InRec_Cur)
{
  int ret;
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : */ 
                                                 /* Annee de compte */
  ret = strcmp(ptb_InRec[GT_ACY_NF],ptb_InRec_Cur[GT_ACY_NF]);
  if (ret != 0)
     return ret;
                                                /* Fin de periode de compte*/ 
  ret = strcmp(ptb_InRec[GT_SCOENDMTH_NF],ptb_InRec_Cur[GT_SCOENDMTH_NF]);
  if (ret != 0)
     return ret;
                                                /* Annee de survenance */ 
  ret = strcmp(ptb_InRec[GT_OCCYEA_NF],ptb_InRec_Cur[GT_OCCYEA_NF]);
  if (ret != 0)
     return ret;
                                                 /* Num Sinistre */
  ret = strcmp(ptb_InRec[GT_CLM_NF],ptb_InRec_Cur[GT_CLM_NF]);
  if (ret != 0)
     return ret;
						/* Monnaie compte */
  ret = strcmp(ptb_InRec[GT_CUR_CF],ptb_InRec_Cur[GT_CUR_CF]);
  if (ret != 0)
     return ret;
						/* Poste comptable */
  ret = strcmp(ptb_InRec[GT_TRNCOD_CF],ptb_InRec_Cur[GT_TRNCOD_CF]);
  if (ret != 0)
     return ret;

/****** modification J.RIBOT 17/12/99 *********/
                                                 /* Date Bilan */
  ret = strcmp(ptb_InRec[GT_BALSHEY_NF],ptb_InRec_Cur[GT_BALSHEY_NF]);
  if (ret != 0)
     return ret;

  ret = strcmp(ptb_InRec[GT_BALSHRMTH_NF],ptb_InRec_Cur[GT_BALSHRMTH_NF]);
  if (ret != 0)
     return ret;

  ret = strcmp(ptb_InRec[GT_BALSHRDAY_NF],ptb_InRec_Cur[GT_BALSHRDAY_NF]);
  if (ret != 0)
     return ret;

/**********************************************/
  return 0; 
}


/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        synchronisation avec fils (perimetre acceptation)

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt1GTAa(char **ptb_InRec_Cur)
{
                                /* Synchronisation avec le PerA */
  if (n_ProcessingRuptureSyncVar(&bd_RuptPerA,ptb_InRec_Cur) == ERR)
    return ERR;

  return OK;
}

/*==========================================================================
objet :
	fonction lancee a la rupture premiere de niveau 2 
        initialisation cumul et mois de debut de periode

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt2GTAa(char **ptb_InRec_Cur)
{
  d_Cum = 0;                       /* Initialisation du cumul */
                                   /* Memorisation du premier mois de periode */
  strcpy(sz_MoisDebPer,ptb_InRec_Cur[GT_SCOSTRMTH_NF]);
  return OK;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne
        Cumul des montants

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGTAa(char **ptb_InRec_Cur)
{
					/* Cumul des montants */
  d_Cum = d_Cum + atof(ptb_InRec_Cur[GT_AMT_M]);

  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2
        Alimentation avec elements de GTAa et ecriture d'1 ligne en sortie
        (format TACCTRNE)

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt2GTAa(char **ptb_InRec_Cur)
{
  static char n_i,
              /* sz_Tmp1[30], */
              sz_Tmp2[30],
              sz_NumLigne[10], 
              sz_Balshamj[10];

                                  /* Alimentation d'1 ligne en sortie avec 
                                     les elements de GTAa */

  ptb_MvtCmpA[MV_SSD_CF] = ptb_InRec_Cur[GT_SSD_CF];
  ptb_MvtCmpA[MV_ESB_CF] = ptb_InRec_Cur[GT_ESB_CF];
  ptb_MvtCmpA[MV_CTR_NF] = ptb_InRec_Cur[GT_CTR_NF];
  ptb_MvtCmpA[MV_UWY_NF] = ptb_InRec_Cur[GT_UWY_NF];
  ptb_MvtCmpA[MV_UW_NT]  = ptb_InRec_Cur[GT_UW_NT];
  ptb_MvtCmpA[MV_END_NT] = ptb_InRec_Cur[GT_END_NT];
  ptb_MvtCmpA[MV_SEC_NF] = ptb_InRec_Cur[GT_SEC_NF];

  ptb_MvtCmpA[MV_SCOSTRMTH_NF] = sz_MoisDebPer;
  ptb_MvtCmpA[MV_SCOENDMTH_NF] = ptb_InRec_Cur[GT_SCOENDMTH_NF];
  ptb_MvtCmpA[MV_ACY_NF]       = ptb_InRec_Cur[GT_ACY_NF];
 
  ptb_MvtCmpA[MV_TRNCOD_CF] = ptb_InRec_Cur[GT_TRNCOD_CF];
  ptb_MvtCmpA[MV_CUR_CF]    = ptb_InRec_Cur[GT_CUR_CF];
  ptb_MvtCmpA[MV_OCCYEA_NF] = ptb_InRec_Cur[GT_OCCYEA_NF];
  ptb_MvtCmpA[MV_CLM_NF]    = ptb_InRec_Cur[GT_CLM_NF];

/****** modification M.LOPEZ 18/02/99 *********/

/*  ptb_MvtCmpA[MV_BLCSHT_D] = psz_GetCharArgv(3); */

/**********************************************/

/****** modification J.RIBOT 17/12/99 *********/

   sprintf(sz_Balshamj,"%4d%02d%02d",
    atoi(ptb_InRec_Cur[GT_BALSHEY_NF]),
    atoi(ptb_InRec_Cur[GT_BALSHRMTH_NF]),
    atoi(ptb_InRec_Cur[GT_BALSHRDAY_NF]));
 
    ptb_MvtCmpA[MV_BLCSHT_D] = sz_Balshamj;

/**********************************************/

  sprintf(sz_Tmp2,"%.3f",d_Cum);
  ptb_MvtCmpA[MV_ORICURAMT_M] = sz_Tmp2;

  sprintf(sz_NumLigne,
          "%d",
          Kn_NumLigne);
  ptb_MvtCmpA[MV_TRN_NT] = sz_NumLigne;

  ptb_MvtCmpA[MV_EPSTATUS] = "I";
  ptb_MvtCmpA[MV_FIN] = NULL;

                                         /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_MvtCmpA,SEPARATEUR,0);

  /* On ajoute 1 au numero de ligne */
   Kn_NumLigne ++;

  return OK;
}

/*=========================================================================
objet :
	fonction d'initialisation de la variable de gestion de synchronisation
        du fichier perimetre acceptation.

retour :
	0K
===========================================================================*/
int n_InitPerA(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));
					/* Ouverture du fic perimetre */
  if (n_OpenFileAppl("ESTC8933_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->ConditionEndSync = n_ConditionSyncPerA;
  pbd_Rupt->n_ActionLigne    = n_ActionLignePerA;

  pbd_Rupt->n_PereSansFils = n_ActionPsFPerA;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}

/*===========================================================================
objet : fonction de test de synchronisation
        entre GTAa et perimetre acceptation sur contrat/Avenant/Num section
        Exercice/Num ordre exercice
retour
   0   --> pbd_InRecOwner = pdb_InRecChild
  > 0  --> pbd_InRecOwner = pdb_InRecChild
  < 0  --> pbd_InRecOwner = pdb_InRecChild
===========================================================================*/
int n_ConditionSyncPerA(char **pdb_InRecOwner,char **pdb_InRecChild)
{
  int ret;
                                         /* Test de correspondance sur
                                                     Contrat  */
  ret = strcmp(pdb_InRecOwner[GT_CTR_NF],pdb_InRecChild[PER_CTR_NF]);
  if (ret != 0)
     return ret;

                              			  /* Avenant */
  ret = strcmp(pdb_InRecOwner[GT_END_NT],pdb_InRecChild[PER_END_NT]);
  if (ret != 0)
     return ret;

                               			 /* Num Section */
  ret = strcmp(pdb_InRecOwner[GT_SEC_NF],pdb_InRecChild[PER_SEC_NF]);
  if (ret != 0)
     return ret;

                               			 /* Exercice */
  ret = strcmp(pdb_InRecOwner[GT_UWY_NF],pdb_InRecChild[PER_UWY_NF]);
  if (ret != 0)
     return ret;

                               			 /* Num ordre exercice */
  ret = strcmp(pdb_InRecOwner[GT_UW_NT],pdb_InRecChild[PER_UW_NT]);
  if (ret != 0)
     return ret;

  return 0;
}
/*===========================================================================
objet : 
        fonction lancee pour chaque ligne du fils
        Alimentation de la ligne en sortie avec les elements du perimetre

retour OK  -> traitement correctement effectue
      ERR  -> probleme rencontre
===========================================================================*/
int n_ActionLignePerA(
  char **ptb_InRecOwner,
  char **ptb_InRecChild)
{
  static int n_k;

  for (n_k=0 ; n_k<MV_FIN ; n_k++)
    ptb_MvtCmpA[n_k] = "";

  ptb_MvtCmpA[MV_MTH_B] = "0";
  ptb_MvtCmpA[MV_LSTUPDUSR_CF] = "CloP";
  ptb_MvtCmpA[MV_TRNSTS_CT]    = "1";
  ptb_MvtCmpA[MV_LSTUPD_D] = psz_GetCharArgv(2);
  ptb_MvtCmpA[MV_LSTTRN_B] = "1";
  ptb_MvtCmpA[MV_RSVRLSFLG_B] = "0";
  ptb_MvtCmpA[MV_RETFLG_CT] = "0";

  ptb_MvtCmpA[MV_LOB_CF] = ptb_InRecChild[PER_LOB_CF];
  ptb_MvtCmpA[MV_SOB_CF] = ptb_InRecChild[PER_SOB_CF]; 
  ptb_MvtCmpA[MV_TOP_CF] = ptb_InRecChild[PER_TOP_CF]; 
  ptb_MvtCmpA[MV_NAT_CF] = ptb_InRecChild[PER_NAT_CF]; 
  ptb_MvtCmpA[MV_CED_NF] = ptb_InRecChild[PER_CED_NF]; 
  ptb_MvtCmpA[MV_SUBNAT_CF] = ptb_InRecChild[PER_SUBNAT_CF]; 

  return OK;
}


/****************************************/
/*     Modif FGL le
/*===========================================================================
objet :
 fonction lancee pour chaque ligne du Pere sans Fils
 Alimentation de la ligne en sortie avec des elements par defaut

retour OK  -> traitement correctement effectue
 ERR  -> probleme rencontre
===========================================================================*/


int n_ActionPsFPerA(char **ptb_InRecCur)
{
  int n_k;

  for (n_k=0 ; n_k<MV_FIN ; n_k++)
    ptb_MvtCmpA[n_k] = "";

  ptb_MvtCmpA[MV_MTH_B] = "0";
  ptb_MvtCmpA[MV_LSTUPDUSR_CF] = "CloP";
  ptb_MvtCmpA[MV_TRNSTS_CT]    = "1";
  ptb_MvtCmpA[MV_LSTUPD_D] = psz_GetCharArgv(2);
  ptb_MvtCmpA[MV_LSTTRN_B] = "1";
  ptb_MvtCmpA[MV_RSVRLSFLG_B] = "0";
  ptb_MvtCmpA[MV_RETFLG_CT] = "0";

  ptb_MvtCmpA[MV_LOB_CF] = " ";
  ptb_MvtCmpA[MV_SOB_CF] = " ";
  ptb_MvtCmpA[MV_TOP_CF] = " ";
  ptb_MvtCmpA[MV_NAT_CF] = " ";
  ptb_MvtCmpA[MV_CED_NF] = "0";
  ptb_MvtCmpA[MV_SUBNAT_CF] = " ";

return OK;

}

