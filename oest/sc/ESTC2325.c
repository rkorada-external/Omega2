/*[XXX] 6/04/2014 JBG :spot:25773 Modify void main declaration to int main*/

/*==============================================================================
nom de l'application          :
nom du source                 : ESTC2325.c
revision                      :
date de creation              : 10/1997
auteur                        : CGI Kuhna
references des specifications : #################
squelette de base             : batch
------------------------------------------------------------------------------
description :

 Injection de l'information taux de surcommission depuis le fichier des
 placements vers le GTR

------------------------------------------------------------------------------
historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification
    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
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
#define GT_FIN         GT_RETKEY_CF + 1
/*----------------------------------*/

/*----------------------*/
/* variables de travail */
/*----------------------*/

FILE  	       *Kp_OutputFil;  /*pointeur sur le fichier de sortie */
T_RUPTURE_VAR      bd_RuptPlc;     /*variable de gestion de la rupture sur
                                     le fichier des placements*/
T_RUPTURE_SYNC_VAR bd_RuptGtr;     /*variable de gestion de la synchro sur
                                     Contrat/Avenant/Section/Exercice/Num
                                     ordre exercice RETRO
                                     Placement entre le fic des placements
                                     et le GTR*/


int n_InitGtr(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ActionLigneGtr(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ConditionSyncGtr(char **ptb_InRecOwner,char **pbd_InRecChild);
int n_ActionPereSansFilsGtr(char **ptb_InRecOwner);
int n_ActionFilsSansPereGtr(char **ptb_InRecChild);


int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt);
int n_ActionLignePlc(char **pbd_InRec_Cur);

int n_ProcessingRuptureSyncVar (
  T_RUPTURE_SYNC_VAR  *pbd_Rupt,
  char  	      **ptb_InRecOwner);

int n_ProcessingRuptureVar(
  T_RUPTURE_VAR       *pbd_Rupt);
/*==============================================================================
objet :
 Injection de l'information taux de surcommision depuis le fichier des
 placements vers le GTR : ajout d'une colonne supplementaire dans le GTR

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
  if (n_OpenFileAppl ("ESTC2325_O1","wt",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptPlc */
  if (n_InitPlc(&bd_RuptPlc) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Initialisation var bd_RuptGtr */
  if (n_InitGtr(&bd_RuptGtr) == ERR)
    ExitPgm(ERR_XX ,"");

				/* Lancement traitement fic des placements */
  if (n_ProcessingRuptureVar(&bd_RuptPlc) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fermeture des fichiers */
  if (n_CloseFileAppl("ESTC2325_I1",&(bd_RuptPlc.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2325_I2",&(bd_RuptGtr.pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_CloseFileAppl("ESTC2325_O1",&Kp_OutputFil) == ERR)
    ExitPgm(ERR_XX,"");

  if (n_EndPgm() == ERR)
    ExitPgm ( ERR_XX , "" );

  exit(OK);
}


/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture
        du fichier des placements.

retour :
	0K
==============================================================================*/
int n_InitPlc(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

				/* Ouverture du fic des placements */
  if (n_OpenFileAppl("ESTC2325_I1","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    return ERR;

  pbd_Rupt->n_NbRupture = 0;    /* Pas de rupture */

  pbd_Rupt->n_ActionLigne = n_ActionLignePlc;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}


/*==============================================================================
objet :
	fonction lancee pour chaque ligne
      A chaque ligne du fichier des placements, appel de la synchro
      avec le GTR

retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLignePlc(char **ptb_InRec_Cur)
{
  				/* Synchro du fic GTRr pour chaque ligne */
  n_ProcessingRuptureSyncVar(&bd_RuptGtr,ptb_InRec_Cur);

  return OK;
}

/*==============================================================================
objet :
     Initialisation de la synchronisation du fic maitre (fic des placements)
     avec l'esclave (fic GTR)

retour :
	OK
==============================================================================*/
int n_InitGtr(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR)) ;

				/* Ouverture du fichier esclave (GTR) */
  if (n_OpenFileAppl ("ESTC2325_I2","rt",&(pbd_Rupt->pf_InputFil)) == ERR)
    ExitPgm(ERR_XX,"");

				/* Fonction de test de la ligne du maitre
 			       	   placements avec l'esclave GTRr */
  pbd_Rupt->ConditionEndSync = n_ConditionSyncGtr;

				/* Fonction d'action sur la ligne courante
                                   du fichier esclave GTRr */
  pbd_Rupt->n_ActionLigne = n_ActionLigneGtr;


				/* Fonction d'action sur la ligne courante
                                   du fichier esclave GTR sans pere*/
  pbd_Rupt->n_FilsSansPere = n_ActionFilsSansPereGtr;

  pbd_Rupt->c_Separ = SEPARATEUR;

  return OK;
}


/*==============================================================================
objet :
	fonction de test de rupture du niveau 1

retour :
	0	---> pbd_InRecOwner = pbd_InRecChild
	> 0   	---> pbd_InRecOwner > pbd_InRecChild
	< 0   	---> pbd_InRecOwner < pbd_InRecChild
==============================================================================*/
int n_ConditionSyncGtr(
  char **pbd_InRecOwner, /* adresse de la ligne du maitre fic placements */
  char **pbd_InRecChild) /* adresse de la ligne de l'esclave GTR*/

{
  int ret ;
						/* Contrat retro */
  ret = strcmp(pbd_InRecOwner[PLA_RETCTR_NF],pbd_InRecChild[GT_RETCTR_NF]);
  if (ret != 0)
     return ret;
						/* Avenant retro */
  ret = strcmp(pbd_InRecOwner[PLA_RETEND_NT],pbd_InRecChild[GT_RETEND_NT]);
  if (ret != 0)
     return ret;
						/* Section retro */
  ret = strcmp(pbd_InRecOwner[PLA_RETSEC_NF],pbd_InRecChild[GT_RETSEC_NF]);
  if (ret != 0)
     return ret;
						/* Exercice retro */
  ret = strcmp(pbd_InRecOwner[PLA_RTY_NF],pbd_InRecChild[GT_RTY_NF]);
  if (ret != 0)
     return ret;
						/* Num ordre exercice retro */
  ret = strcmp(pbd_InRecOwner[PLA_RETUW_NT],pbd_InRecChild[GT_RETUW_NT]);
  if (ret != 0)
     return ret;
						/* Code placement */
  ret = strcmp(pbd_InRecOwner[PLA_PLC_NT],pbd_InRecChild[GT_PLC_NT]);
  if (ret != 0)
     return ret;

  return 0;
}


/*============================================================================
objet :
	fonction lancee pour chaque ligne

retour :OK ---> traitement correctement effectue
	ERR --> probleme rencontre
===========================================================================*/
int n_ActionLigneGtr(
  char **ptb_InRecOwner, /* adresse de la ligne du maitre fic placements */
  char **ptb_InRecChild) /* adresse de la ligne de l'esclave GTR */

{
                         /* Ajout du pteur sur le champ taux de surcommission
                            de fic des placements en fin de tab des pteurs sur
                            champs de GTR si commision majoree 0 sinon*/
  if (strcmp(ptb_InRecOwner[PLA_RAICOM_B],"1") == 0)
    ptb_InRecChild[GT_FIN] = ptb_InRecOwner[PLA_OVRCOM_R];
  else
    ptb_InRecChild[GT_FIN] = "0";

                         /* Delimitation champs du GTR avant ecriture */
  ptb_InRecChild[GT_FIN + 1] = 0;

                         /* Copie ds le fic en sortie*/
  n_WriteCols(Kp_OutputFil,ptb_InRecChild,SEPARATEUR,0);

  return OK;
}


/*==========================================================================
objet :
	fonction lancee quand le pere n'a pas de fils
retour :
	OK ---> traitement correctement effectue
	ERR --> probleme rencontre
==============================================================================*/
int n_ActionFilsSansPereGtr(
  char **ptb_InRecOwner)
{
  char MsgAno[200];      /* message d'anomalie */

  sprintf(MsgAno,"No row in GTR corresponding to (RETCTR/RETEND/RETSEC/RTY/RETUW/PLC) = (%s,%s,%s,%s,%s,%s)\
          from placements file\n",
          ptb_InRecOwner[GT_RETCTR_NF],
          ptb_InRecOwner[GT_RETEND_NT],
          ptb_InRecOwner[GT_RETSEC_NF],
          ptb_InRecOwner[GT_RTY_NF],
          ptb_InRecOwner[GT_RETUW_NT],
          ptb_InRecOwner[GT_PLC_NT]);

  n_WriteAno(MsgAno);

  return OK;
}
