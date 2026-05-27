/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*=============================================================================
Nom de l'application          : 
nom du source                 : ESTC7602.c
revision                      :
date de creation              : 10/1997 
auteur                        : C.G.I. Kuhna 
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :
  Il s'agit de preparer l'edition de la balance technique
  En entree : GT simple converti trie sur 
              filiale/etablissement
              Poste comptable/ Monnaie acceptation
             
  En sortie : meme fichier auquel on a ajoute des lignes cumuls
               - Somme des montants pour 1 meme poste comptable
               - Somme des montants pour 1 meme annee bilan 
               - Somme des montants pour 1 meme etablissement 
               - Somme des montants pour 1 meme filiale 
               
  4 ruptures :
     Rupt 1 -> Poste comptable
     Rupt 2 -> Annee bilan
     Rupt 3 -> Etablissement
     Rupt 4 -> Filiale
    
------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
	   ...           ...            ...              ...
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

/* Definition du code (stockes dans le poste comptable) 
   identifiant les lignes cumuls */
#define CODE_PC_CUM_PC    "00000001"
#define CODE_PC_CUM_BIL   "00000002"
#define CODE_PC_CUM_ET    "00000003"
#define CODE_PC_CUM_FIL   "00000004"

/* Position de champs dans le GT simplifie converti */
#define GTSIMP_SSD_CF         0
#define GTSIMP_ESB_CF         1 
#define GTSIMP_BALSHEY_NF     2
#define GTSIMP_TRNCOD_CF      3
#define GTSIMP_CUR_CF         4 
#define GTSIMP_AMT_M          5
#define GTSIMP_RETAMT_M       6

/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	           *Kp_OutputFil; /*pointeur sur le fichier de sortie*/

T_RUPTURE_VAR      Kbd_Rupt;  /*variable de gestion de la rupture*/

                                   /*declaration des structures pour les cumuls 
                                     au format du GT simplifie converti */
double  	   Kd_CumPC,     /* Cumul sur 1 meme poste comptable*/
                   Kd_CumBil,    /* Cumul sur 1 meme annee bilan */
                   Kd_CumEt,     /* Cumul sur 1 meme etablissement */
                   Kd_CumFil ;   /* Cumul sur 1 meme filiale */
                          

int n_InitGTSimp(T_RUPTURE_VAR  *pbd_Rupt);
int n_IsR1Fil(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR2Et(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR3Bil(char **ptb_InRec,char **ptb_InRec_Cur);
int n_IsR4PC(char **ptb_InRec,char **ptb_InRec_Cur);
int n_ActionFirstRupt1Fil(char **ptb_InRec_Cur);
int n_ActionFirstRupt2Et(char **ptb_InRec_Cur);
int n_ActionFirstRupt3Bil(char **ptb_InRec_Cur);
int n_ActionFirstRupt4PC(char **ptb_InRec_Cur);
int n_ActionLigneGTSimp(char **pbd_InRec_Cur);
int n_ActionLastRupt1Fil(char **ptb_InRec_Cur);
int n_ActionLastRupt2Et(char **ptb_InRec_Cur);
int n_ActionLastRupt3Bil(char **ptb_InRec_Cur);
int n_ActionLastRupt4PC(char **ptb_InRec_Cur);
int n_ProcessingRuptureVar(T_RUPTURE_VAR *pbd_Rupt);

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

				/* Ouverture du fichier de sortie */
  if (n_OpenFileAppl ("ESTC7602_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var Kbd_Rupt */
  if (n_InitGTSimp(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Lancement traitement */
  if (n_ProcessingRuptureVar(&Kbd_Rupt) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC7602_I1",&(Kbd_Rupt.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC7602_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier GT simplifie converti
retour :
	0K
==============================================================================*/
int n_InitGTSimp(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));
				/* Ouverture du fic GT Simplifie converti */
  if (n_OpenFileAppl("ESTC7602_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 4; 

  pbd_Rupt->n_ConditionRupture[0] = n_IsR1Fil;
  pbd_Rupt->n_ConditionRupture[1] = n_IsR2Et;
  pbd_Rupt->n_ConditionRupture[2] = n_IsR3Bil;
  pbd_Rupt->n_ConditionRupture[3] = n_IsR4PC;


  pbd_Rupt->n_ActionFirst[0]      = n_ActionFirstRupt1Fil;
  pbd_Rupt->n_ActionFirst[1]      = n_ActionFirstRupt2Et;
  pbd_Rupt->n_ActionFirst[2]      = n_ActionFirstRupt3Bil;
  pbd_Rupt->n_ActionFirst[3]      = n_ActionFirstRupt4PC;

  pbd_Rupt->n_ActionLigne         = n_ActionLigneGTSimp;

  pbd_Rupt->n_ActionLast[0]      = n_ActionLastRupt1Fil;
  pbd_Rupt->n_ActionLast[1]      = n_ActionLastRupt2Et;
  pbd_Rupt->n_ActionLast[2]      = n_ActionLastRupt3Bil;
  pbd_Rupt->n_ActionLast[3]      = n_ActionLastRupt4PC;


  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1
        sur Filiale

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR1Fil(char **ptb_InRec,char **ptb_InRec_Cur)
{
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Filiale */
  return strcmp(ptb_InRec[GTSIMP_SSD_CF],ptb_InRec_Cur[GTSIMP_SSD_CF]);
}
/*==============================================================================
objet :
	fonction de test de rupture de niveau 1
        sur Etablissement

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR2Et(char **ptb_InRec,char **ptb_InRec_Cur)
{
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Etablissement */
  return strcmp(ptb_InRec[GTSIMP_ESB_CF],ptb_InRec_Cur[GTSIMP_ESB_CF]);
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1
        sur Annee bilan

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR3Bil(char **ptb_InRec,char **ptb_InRec_Cur)
{
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Annee bilan */
  return strcmp(ptb_InRec[GTSIMP_BALSHEY_NF],ptb_InRec_Cur[GTSIMP_BALSHEY_NF]);
}

/*==============================================================================
objet :
	fonction de test de rupture de niveau 1
        sur poste comptable

retour :
	0 ---> pas de rupture
	dif de 0 ---> rupture
===========================================================================*/
int n_IsR4PC(char **ptb_InRec,char **ptb_InRec_Cur)
{
				/* Test de correspondance entre ligne courante
                                   et ligne suivante sur : 
                              		  	    Poste comptable */
  return strcmp(ptb_InRec[GTSIMP_TRNCOD_CF],ptb_InRec_Cur[GTSIMP_TRNCOD_CF]);
}

/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul Filiale
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt1Fil(char **ptb_InRec_Cur)
{
  Kd_CumFil = 0;
  return OK;
}
/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul Etablissement
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt2Et(char **ptb_InRec_Cur)
{
  Kd_CumEt = 0;
  return OK;
}
/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul Bilan
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt3Bil(char **ptb_InRec_Cur)
{
  Kd_CumBil = 0;
  return OK;
}

/*==============================================================================
objet :
	fonction lancee a la rupture premiere de niveau 1
        Initialisation cumul poste comptable
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionFirstRupt4PC(char **ptb_InRec_Cur)
{
  Kd_CumPC = 0;
  return OK;
}

/*==============================================================================
objet :
	fonction lancee pour chaque ligne
        - cumuls
        - ecriture des lignes en sortie

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGTSimp(char **ptb_InRec_Cur)
{
  double d_MtConvert;

  /* Conversion de type du montants monnaie convertie */
  d_MtConvert = atof(ptb_InRec_Cur[GTSIMP_RETAMT_M]);

  /* Cumuls */
  Kd_CumFil += d_MtConvert;
  Kd_CumEt  += d_MtConvert;
  Kd_CumBil += d_MtConvert;
  Kd_CumPC  += d_MtConvert;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_InRec_Cur,SEPARATEUR,0);
  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul filiale
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt1Fil(char **ptb_InRec_Cur)
{
  char sz_CumFil[30];

  /* Dans le Montant converti, on met le cumul filiale */
  sprintf(sz_CumFil,"%-.3lf",Kd_CumFil);
  ptb_InRec_Cur[GTSIMP_RETAMT_M] = sz_CumFil;

  /* Dans le poste comptable, on met le code ligne cumul filiale */
  ptb_InRec_Cur[GTSIMP_TRNCOD_CF] = CODE_PC_CUM_FIL;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_InRec_Cur,SEPARATEUR,0);

  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul etablissement
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt2Et(char **ptb_InRec_Cur)
{
  char sz_CumEt[30];

  /* Dans le Montant converti, on met le cumul etablissement */
  sprintf(sz_CumEt,"%-.3lf",Kd_CumEt);
  ptb_InRec_Cur[GTSIMP_RETAMT_M] = sz_CumEt;

  /* Dans le poste comptable, on met le code ligne cumul etablissement */
  ptb_InRec_Cur[GTSIMP_TRNCOD_CF] = CODE_PC_CUM_ET;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_InRec_Cur,SEPARATEUR,0);

  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 1
        Ecriture sur le fic en sortie de la ligne cumul annee bilan
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt3Bil(char **ptb_InRec_Cur)
{
  char sz_CumBil[30];

  /* Dans le Montant converti, on met le cumul annee bilan */
  sprintf(sz_CumBil,"%-.3lf",Kd_CumBil);
  ptb_InRec_Cur[GTSIMP_RETAMT_M] = sz_CumBil;

  /* Dans le poste comptable, on met le code ligne cumul annee bilan */
  ptb_InRec_Cur[GTSIMP_TRNCOD_CF] = CODE_PC_CUM_BIL;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_InRec_Cur,SEPARATEUR,0);

  return OK;
}

/*==============================================================================
objet :
	fonction lancee en rupture derniere de niveau 2
        Ecriture sur le fic en sortie de la ligne cumul poste comptable
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLastRupt4PC(char **ptb_InRec_Cur)
{
  char sz_CumPc[30];

  /* Dans le Montant converti, on met le cumul poste comptable */
  sprintf(sz_CumPc,"%-.3lf",Kd_CumPC);
  ptb_InRec_Cur[GTSIMP_RETAMT_M] = sz_CumPc;

  /* Dans le poste comptable, on met le code ligne cumul poste comptable */
  ptb_InRec_Cur[GTSIMP_TRNCOD_CF] = CODE_PC_CUM_PC;

  /* Ecriture de la ligne */
  n_WriteCols(Kp_OutputFil,ptb_InRec_Cur,SEPARATEUR,0);

  return OK;
}
