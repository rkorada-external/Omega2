/*==============================================================================
 Nom de l'application          : ESTIMATION
 Nom du source                 : ESTC2149.c
 Revision                      : $Revision: 1.2 $
 Date de creation              : 11/01/2001
 Auteur                        : O.Giraux
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
    Passage du format de la table des Previsions (TLIFEST) au format du fichier
    des Previsions.
    Injection de l'information type comptable (ACCADAMTYP_CT) depuis le perimetre
    vers le fichier des Previsions. On prend la valeur ACCADAMTYP_CT correspondant
    a l'exercice le plus grand.

    Le fichier PERIMETRE (esclave) a ete trie suivant la cle de synchro et l'exercice.
    Lorsqu'une ligne de maitre synchronise avec l'esclave, on parcourt toutes les lignes
    de l'esclave qui ont la meme cle; lors du dernier ActionLigneSlave sur cette cle,
  on aura la valeur de ACCADAMTYP_CT correspondant a l'exercice max.

------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>

    27/03/2008   J. Ribot    SPOT 15219  ASE15 : recompilation des programmes C
       ...           ...            ...              ...

[002] 25/11/2013 -=Dch=-  	   :spot:25773  - Omega 2B modification de colonnes pour LIFEST	 
[003] 14/10/2015 R. Cassis    :spot:29514  Ajout les x colonnes de la TLIFEST par un WriteCols de l'entrée
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include <struct.h>

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

/*
** Objet  : PREV (Maitre)
** Entree : ESTC2149_I1
** Cle    : (CTR_NF, END_NT, SEC_NF, UW_NT) (4 champs)
*/
T_RUPTURE_VAR Kbd_ruptPREV;
int n_InitPREV(T_RUPTURE_VAR *pbd_Rupt);
int n_IsR1PREV(char **pbd_InRec, char **pbd_InRec_Cur);
int n_ActionF1PREV(char **pbd_InRec_Cur);
int n_ActionLignePREV(char **pbd_InRec_Cur);

/*
** Objet  : PERIMETRE (Esclave --> PREV)
** Entree : ESTC2149_I2
** Cle    : (CTR_NF, END_NT, SEC_NF, UW_NT) (4 champs)
*/
T_RUPTURE_SYNC_VAR Kbd_ruptPERIMETRE;
int n_InitSyncPERIMETRE(T_RUPTURE_SYNC_VAR *pbd_Rupt);
int n_ConditionSyncPERIMETRE(char **ptb_InRecOwner, char **ptb_InRecChild);
int n_ActionLigneSyncPERIMETRE(char **ptb_InRecOwner, char **ptb_InRecChild);

int n_InitPERIMETRE(T_RUPTURE_SYNC_VAR  *pbd_Rupt);

/*
** Objet  : OUT
** Sortie : ESTC2149_O1
*/
FILE *Kp_OutputFileOUT;

char **Kptsz_PERIMETRE;

/*---------------------------------------------*/

/*==============================================================================
 Objet :
   Point d'entree du programme

 Parametre(s) :
   int argc    : Nombre d'arguments sur la ligne de commande;
   char **argv : parametres

 Retour :
   En cas de probleme, sortie par ExitPgm(ERRCODE)
   sinon appel systeme exit(OK)
==============================================================================*/
int main(int argc, char **argv)
{
  /* Initialisation des signaux */
  InitSig () ;

  if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "");

  /* Initialisation des variables de gestion de ruptures */
  if (n_InitPREV(&Kbd_ruptPREV)) ExitPgm(ERR_XX, "");
  if (n_InitPERIMETRE(&Kbd_ruptPERIMETRE)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTC2149_O1", "wt", &Kp_OutputFileOUT) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptPREV) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTC2149_I1", &(Kbd_ruptPREV.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTC2149_I2", &(Kbd_ruptPERIMETRE.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTC2149_O1", &Kp_OutputFileOUT)) ExitPgm(ERR_XX, "");

  if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "");

  exit(OK);
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
int n_InitPREV(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTC2149_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1PREV;
  pbd_Rupt->n_ActionFirst[0] = n_ActionF1PREV;
  pbd_Rupt->n_ActionLigne = n_ActionLignePREV;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction de test de rupture de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante
   Pointeur sur la ligne suivante

 Retour :
   0 --> Pas de rupture
   1--> Situation de rupture
==============================================================================*/
int n_IsR1PREV(char **pbd_InRec, char **pbd_InRec_Cur)
{
  int ret ;

  DEBUT_FCT("n_IsR1PREV");

  /*
  ** Modele de test de rupture :
  ** =========================
  **
  **  if ((ret = strcmp(pbd_InRec[idx], pbd_InRec_Cur[idx])) != 0 ) RETURN_VAL(ret);
  **
  */

  if ((ret = strcmp(pbd_InRec[PRE_CTR_NF], pbd_InRec_Cur[PRE_CTR_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[PRE_END_NT], pbd_InRec_Cur[PRE_END_NT])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[PRE_SEC_NF], pbd_InRec_Cur[PRE_SEC_NF])) != 0 ) RETURN_VAL(ret);
  if ((ret = strcmp(pbd_InRec[PRE_UW_NT], pbd_InRec_Cur[PRE_UW_NT])) != 0 ) RETURN_VAL(ret);

  RETURN_VAL(0);
}


/*==============================================================================
 Objet :
   Fonction lancee en rupture premiere de niveau 1 (Maitre)

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionF1PREV(char **ptb_InRec_Cur)
{
  Kptsz_PERIMETRE = NULL;

   /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptPERIMETRE, ptb_InRec_Cur);

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
int n_ActionLignePREV(char **ptb_InRec_Cur)
{
	char MsgAno[200];      /* message d'anomalie */

	char *ptb_LignePrev[PRE_NBCOL + 1];
	//int  n_i;

  	if ( Kptsz_PERIMETRE == NULL )
  	{
		/* Il n'y a pas eu synchro sur la cle CTR, END, SEC et UW avec le perimetre */
	    sprintf(MsgAno,"No row in IARVPERICASE corresponding to (CTR/END/SEC/UW_NT)\
	    		= (%s,%s,%s,%s) from placements file\n",
	            ptb_InRec_Cur[PRE_CTR_NF],
	            ptb_InRec_Cur[PRE_END_NT],
	            ptb_InRec_Cur[PRE_SEC_NF],
	            ptb_InRec_Cur[PRE_UW_NT]);

  		n_WriteAno(MsgAno);
  		/* return ERR;   Supprimée par M.NAJI MAIL Andre 29/01/2001 09:01 */
	}
	else
	{
/*
		  for (n_i = 0 ; n_i < PRE_NBCOL ; n_i ++)
		    ptb_LignePrev[n_i] = "";

		  ptb_LignePrev[PRE_SSD_CF] = ptb_InRec_Cur[PRE_SSD_CF];
		  ptb_LignePrev[PRE_CTR_NF] = ptb_InRec_Cur[PRE_CTR_NF];
		  ptb_LignePrev[PRE_END_NT] = ptb_InRec_Cur[PRE_END_NT];
		  ptb_LignePrev[PRE_SEC_NF] = ptb_InRec_Cur[PRE_SEC_NF];
		  ptb_LignePrev[PRE_UWY_NF] = ptb_InRec_Cur[PRE_UWY_NF];
		  ptb_LignePrev[PRE_UW_NT] = ptb_InRec_Cur[PRE_UW_NT];
		  ptb_LignePrev[PRE_ACY_NF] = ptb_InRec_Cur[PRE_ACY_NF];
		  ptb_LignePrev[PRE_CRE_D] = ptb_InRec_Cur[PRE_CRE_D];
		  ptb_LignePrev[PRE_PRS_CF] = ptb_InRec_Cur[PRE_PRS_CF];
		  ptb_LignePrev[PRE_GAAP_NF] = ptb_InRec_Cur[PRE_GAAP_NF];  // [003]
		  ptb_LignePrev[PRE_DETTRNCOD_CF] = ptb_InRec_Cur[PRE_DETTRNCOD_CF];  // [003]
		  ptb_LignePrev[PRE_ESTMTH_NF] = ptb_InRec_Cur[PRE_ESTMTH_NF];  // [003]
		  ptb_LignePrev[PRE_ACMTRS_NT] = ptb_InRec_Cur[PRE_ACMTRS_NT];
		  ptb_LignePrev[PRE_BALSHEY_NF] = ptb_InRec_Cur[PRE_BALSHEY_NF];
		  ptb_LignePrev[PRE_BALSHTMTH_NF] = ptb_InRec_Cur[PRE_BALSHTMTH_NF];
		  ptb_LignePrev[PRE_CUR_CF] = ptb_InRec_Cur[PRE_CUR_CF];
		  ptb_LignePrev[PRE_ESTMNT_M] = ptb_InRec_Cur[PRE_ESTMNT_M];
		  ptb_LignePrev[PRE_INDSUP_B] = ptb_InRec_Cur[PRE_INDSUP_B];
		  ptb_LignePrev[PRE_ORICOD_LS] = ptb_InRec_Cur[PRE_ORICOD_LS];
		  ptb_LignePrev[PRE_CREUSR_CF] = ptb_InRec_Cur[PRE_CREUSR_CF];
		  ptb_LignePrev[PRE_LSTUPD_D] = ptb_InRec_Cur[PRE_LSTUPD_D];
		  ptb_LignePrev[PRE_LSTUPDUSR_CF] = ptb_InRec_Cur[PRE_LSTUPDUSR_CF];

		  ptb_LignePrev[PRE_ACCADMTYP_CT] = Kptsz_PERIMETRE[PER_ACCADMTYP_CT];

*/
		ptb_InRec_Cur[PRE_ACCADMTYP_CT] = Kptsz_PERIMETRE[PER_ACCADMTYP_CT];
		
		/* Delimitation champs avant ecriture */
		ptb_LignePrev[PRE_NBCOL] = 0;

		/* Copie ds le fic en sortie*/
		//n_WriteCols(Kp_OutputFileOUT,ptb_LignePrev,SEPARATEUR,0);
		n_WriteCols(Kp_OutputFileOUT,ptb_InRec_Cur,SEPARATEUR,0);
	}

	return OK;
}


/*==============================================================================
 Objet :
   Initialisation de la variable de gestion de synchronisation (Esclave)

 Parametre(s) :
   Pointeur sur une structure T_RUPTURE_SYNC_VAR

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_InitPERIMETRE(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTC2149_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncPERIMETRE;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncPERIMETRE;
  pbd_Rupt->c_Separ = '~';

  return OK;
}


/*==============================================================================
 Objet :
   Fonction de test de synchronisation avec la Maitre

 Parametre(s) :
   Pointeur sur la ligne du maitre
   Pointeur sur la ligne de l'esclave

 Retour :
   0 --> Pas de synchro
   1--> Situation de synchro
==============================================================================*/
int n_ConditionSyncPERIMETRE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  /*
  ** Modele de test de synchronisation :
  ** =================================
  **
  **  if ((ret = strcmp(ptb_InRecOwner[idx_pere], ptb_InRecChild[idx_fils])) != 0) return(ret);
  **
  */

  if ((ret = strcmp(ptb_InRecOwner[PRE_CTR_NF], ptb_InRecChild[PER_CTR_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PRE_END_NT], ptb_InRecChild[PER_END_NT])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PRE_SEC_NF], ptb_InRecChild[PER_SEC_NF])) != 0) return(ret);
  if ((ret = strcmp(ptb_InRecOwner[PRE_UW_NT], ptb_InRecChild[PER_UW_NT])) != 0) return(ret);

  return 0;
}


/*==============================================================================
 Objet :
   Fonction lancee pour chaque ligne synchronisee avec le Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK
==============================================================================*/
int n_ActionLigneSyncPERIMETRE(char **ptb_InRecOwner, char **ptb_InRecChild)
{
	/* On memorise le pointeur pointant sur la ligne courante du perimetre
	   Comme ce fichier est trié suivant la cle et l'exercice, on aura lors du dernier
	   passage ds cette fction la ligne correspondant a l'exercice max */

  Kptsz_PERIMETRE = ptb_InRecChild;
  return OK;
}


