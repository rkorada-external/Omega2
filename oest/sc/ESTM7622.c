/*==============================================================================
 Nom de l'application          : OMEGA/R‚trocession
 Nom du source                 : ESTM7622.c
 Revision                      : $Revision:   1.1  $
 Date de creation              : 02/07/2010
 Auteur                        : Dominique Ourmiah
 References des specifications :
 Squelette de base             :
------------------------------------------------------------------------------
  Description :
   SPOT 19090 - Transformations des postes comptables des mouvements du closing
                a reverser dans le retard

MOD01 Dominique Ourmiah 04/02/2011 SPOT 21160 Modification des regles de transformation
MOD02 Odile Lefeuvre 16/09/2011 SPOT 22560 Transformation des libérations
MOD03 Lalatiana Rakotozafy 06/11/2014 SPOT 27744 
			- mise en commentaire de MOD02 poste detailles 102 ou 103 = 10120
			- passer en constitution les postes de liberation des postes reserves, 103 et 142 qui n'ont
			pas subis de transformation de provision en protefeuille
------------------------------------------------------------------------------
 Historique des modifications :
   <jj/mm/aaaa>   <auteur>    <description de la modification>
       ...           ...            ...              ...
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/

#include <util.h>
#include "struct.h"


/*---------------------------------------*/
/* Inclusion de l'interface du composant */
/*---------------------------------------*/

#include "ESTM7622.h"

/*---------------------------------------------*/
/* Definition des constantes et macros privees */
/*---------------------------------------------*/

int sz_prft;
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
  if (n_InitCLORETCTR(&Kbd_ruptCLORETCTR)) ExitPgm(ERR_XX, "");
  if (n_InitCLOTRS(&Kbd_ruptCLOTRS)) ExitPgm(ERR_XX, "");

  /* Ouverture des fichiers binaires et des fichiers de sortie */
  if (n_OpenFileAppl("ESTM7622_O1", "wt", &Kp_OutputFileCLOTRS) == ERR) ExitPgm(ERR_XX ,"");

  /* Lancement du traitement du fichier Maitre */
  if (n_ProcessingRuptureVar(&Kbd_ruptCLORETCTR) == ERR) ExitPgm(ERR_XX, "");

  /* Fermeture des fichiers ouverts */
  if (n_CloseFileAppl("ESTM7622_I1", &(Kbd_ruptCLORETCTR.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");
  if (n_CloseFileAppl("ESTM7622_I2", &(Kbd_ruptCLOTRS.pf_InputFil)) == ERR) ExitPgm(ERR_XX, "");

  if (n_CloseFileAppl("ESTM7622_O1", &Kp_OutputFileCLOTRS)) ExitPgm(ERR_XX, "");

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
int n_InitCLORETCTR(T_RUPTURE_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_VAR));

  if (n_OpenFileAppl("ESTM7622_I1","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 1;
  pbd_Rupt->n_ConditionRupture[0] = n_IsR1CLORETCTR;
  pbd_Rupt->n_ActionFirst[0] = n_ActionF1CLORETCTR;
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
int n_IsR1CLORETCTR(char **pbd_InRec, char **pbd_InRec_Cur)
{
  int ret ;

  DEBUT_FCT("n_IsR1CLORETCTR");

  if ((ret = strcmp(pbd_InRec[CLORETCTR_RETCTR_NF], pbd_InRec_Cur[CLORETCTR_RETCTR_NF])) != 0 ) RETURN_VAL(ret);

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
int n_ActionF1CLORETCTR(char **ptb_InRec_Cur)
{

  /* Synchronisation du fichier maitre avec ses esclaves */
  n_ProcessingRuptureSyncVar(&Kbd_ruptCLOTRS, ptb_InRec_Cur);

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
int n_InitCLOTRS(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
  memset(pbd_Rupt,0,sizeof(T_RUPTURE_SYNC_VAR));

  if (n_OpenFileAppl("ESTM7622_I2","rt", &(pbd_Rupt->pf_InputFil)))
    return ERR;

  pbd_Rupt->n_NbRupture = 0;
  pbd_Rupt->ConditionEndSync = n_ConditionSyncCLOTRS;
  pbd_Rupt->n_ActionLigne = n_ActionLigneSyncCLOTRS;
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
int n_ConditionSyncCLOTRS(char **ptb_InRecOwner, char **ptb_InRecChild)
{
  int ret;

  if ((ret = strcmp(ptb_InRecOwner[CLORETCTR_RETCTR_NF], ptb_InRecChild[CLOTRS_RETCTR_NF])) != 0) return(ret);

  return 0;
}

/*=======================================================================================================================
 Objet :
   Fonction lancee pour chaque ligne synchronisee avec le Maitre

 Parametre(s) :
   Pointeur sur la ligne courante

 Retour :
   En cas de probleme retourne ERR
   sinon retourne OK



 Regles de transformation avec traite sans transformation de provisions en portefeuille (PRFT_CT = 0)
 Poste type : 1=1 ; 4=1
 Poste suffixe toujours egal a 0
 Postes Principaux < 49 aucune modification du poste detaille
 Postes detailles (ici caracteres 3 a 7): 49400=42000 ; 49405=42000; 49410=44000


 Regles de transformation avec traite avec transformation de provisions en portefeuille (PRFT_CT = 1)
 Poste type : 1=1 ; 4=1
 Poste suffixe toujours egal a 0
 Postes Principaux < 40 aucune modification du poste detaille
 Postes Principaux entre 40 et 49 : 40= Poste detaille 30110 ;41= Poste detaille 30110 ;42= Poste detaille 32110 ;
                                    43= Poste detaille 31030 ; 44= Poste detaille 32110 ; 45= Poste detaille 15040  ;
                                    48= Poste detaille 32110 ; 49= Poste detaille 32110
 Postes detailles : 102 = 10120
										103 = 10120
                    14100=31030 ; 14200=31030
=======================================================================================================================*/


int n_ActionLigneSyncCLOTRS(char **ptb_InRecOwner, char **ptb_InRecChild)
{

	  char sz_buf[10];
	  
    /* Enregistrement du type de transformation */
    sz_prft = atoi(ptb_InRecOwner[CLORETCTR_PRFT_CT]);

      //char val[2];
      //trncpy(val, ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, 2);
      //printf("poste principal : %s\n",val);
      //printf("Type transfo : %d\n",sz_prft);

    /* Poste suffixe toujours egal a 0 */
    strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 7, "0", 1);

    /* Traites sans transformation de provisions en portefeuille */
    if (sz_prft == 0)
    {
        /* Poste type : 1=1 ; 4=1  */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 1, "4", 1) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 1, "1", 1);

        /* Postes detailles (ici caracteres 3 a 7): 49400=42000 ; 49405=42000; 49410=44000 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "49400", 5) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "42000", 5);

        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "49405", 5) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "42000", 5);

        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "49410", 5) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "44000", 5);
    }
    /* Traites avec transformation de provisions en portefeuille */
    /*  MOD01 */
    else if (sz_prft)
    {

        /* Poste type : 1=1 ; 4=1  */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 1, "4", 1) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 1, "1", 1);

        /*Postes Principaux entre 40 et 49 */

        /* 40= Poste detaille 30110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "40", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "30110", 5);

        /* 41= Poste detaille 30110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "41", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "30110", 5);

        /* 42= Poste detaille 32110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "42", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "32110", 5);

        /* 43= Poste detaille 31030 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "43", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "31030", 5);

        /* 44= Poste detaille 32110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "44", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "32110", 5);
				
				/* MOD03 45= Poste detaille 15000 */
        /* 45= Poste detaille 15040 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "45", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "15000", 5);

        /* 48= Poste detaille 32110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "48", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "32110", 5);

        /* 49= Poste detaille 32110 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "49", 2) == 0)
                strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "32110", 5);

        /* Postes detailles (ici caracteres 3 a 7): 10200=30110 ; 10300=30110 ; 14100=31030 ; 14200=31030 */
        /* MOD03 */
        /* if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "10200", 5) == 0) */
        /*     strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "30110", 5);			 */

        /* if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "10300", 5) == 0) */
        /*     strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "30110", 5);			 */
        
        /* MOD03 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "102", 3) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "10120", 5);
				/* MOD03 */
        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "103", 3) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "10120", 5);

        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "141", 3) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "31030", 5);

        if (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "142", 3) == 0)
             strncpy(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "31030", 5);

    } 
      
	  /* mod02 transfiormation lib en const */
	  /* MOD03 */
	  /* passer en constitution les postes de liberation des postes reserves (40 -> 49) et 103 et 142 qui n'ont
			pas subis de transformation de provision en portefeuille */
		if (
				(
					(strncmp(ptb_InRecChild[CLOTRS_OSDRLS_CT],"2",1) == 0 ) /* poste de liberation */
					&&
					(sz_prft == 0) /* pas de demande de transformation de provision en portefeuille */
				) 
				&&
				(
				 (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "40", 2) == 0)
          ||
       	 (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "41", 2) == 0)
          ||
         (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "42", 2) == 0)
					||
         (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "43", 2) == 0)
 					||
         (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "44", 2) == 0)
        	||
         (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "45", 2) == 0)
        	||
         (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "48", 2) == 0)
  				||
       	 (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "49", 2) == 0)
       	  ||
       	 (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "103", 3) == 0)
       	  ||
       	 (strncmp(ptb_InRecChild[CLOTRS_TRNCOD_CF] + 2, "142", 3) == 0)
				)
			)
				
				{												 
	     	 	    sprintf(sz_buf,"%d", atoi(ptb_InRecChild[CLOTRS_TRNCOD_CF]) - 1000 );
	            ptb_InRecChild[CLOTRS_TRNCOD_CF]  = sz_buf;													 
	  		}																																										 
	   

    n_WriteCols(Kp_OutputFileCLOTRS, ptb_InRecChild, '~', 0);


    return OK;
}
