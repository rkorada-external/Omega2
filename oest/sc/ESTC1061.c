/*==============================================================================
 Nom de l'application          : Loader programs V2
 Nom du source                 : ESTC1061.c
 Revision                      : $Revision: 1.16 $
 Date de creation              : 09/01/2012
 Auteur                        : gensource v2.0 (auto)
 References des specifications : ######################
 Squelette de base             : batch
------------------------------------------------------------------------------
  Description :
   Loader programs V2
------------------------------------------------------------------------------
 Historique des modifications :
[001]  01/06/2012 	-=Dch=-  :spot:23937 SOLVENCY II
[02] Florent 27/09/2012 :spot:24041 Solvency II
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <struct.h>
#include "ESTC1061.h"

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
int main(int argc, char *argv[])
{
  pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
  pbd_Sync = malloc(sizeof(T_RUPTURE_SYNC_VAR));

	// Initialisation des signaux
	InitSig () ;

	if (n_BeginPgm(argc, argv) == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_BeginPGM.");

	// Ouverture des fichiers binaires et des fichiers de sortie
	if (n_OpenFileAppl("ESTC1061_O1", "wt", &Kp_OutputGTCumul)) ExitPgm(ERR_XX, "Problème lors de l'ouverture du 1er fichier d'output." );

  if (n_OpenFileAppl("ESTC1061_O2", "wt", &Kp_OutFileANO) == ERR) ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");

	// Initialisation des variables de gestion de ruptures
	if (n_InitRupture(pbd_Rupture)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

	if (n_InitSync(pbd_Sync)) ExitPgm(ERR_XX, "Problème lors de l'exécution de la méthode n_InitRfrBatchIN");

	if (n_ProcessingRuptureVar(pbd_Rupture) != OK) ExitPgm(ERR_XX, "Erreur lors du traitement ligne à ligne." );

	// Fermeture des fichiers ouverts
	if (n_CloseFileAppl("ESTC1061_I1", &(pbd_Rupture->pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier d'input.");

	if (n_CloseFileAppl("ESTC1061_I2", &(pbd_Sync->pf_InputFil)))  ExitPgm(ERR_XX, "Problème lors de la fermeture du fichier de cash flow.");

	if (n_CloseFileAppl("ESTC1061_O1", &Kp_OutputGTCumul)) ExitPgm(ERR_XX, "Problème lors de la fermeture du 1er fichier d'output.");

  if (n_CloseFileAppl("ESTC1061_O2", &Kp_OutFileANO) == ERR) ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");

	if (n_EndPgm() == ERR) ExitPgm(ERR_XX, "Problème lors de l'appel de la méthode n_EndPgm.");

  free(pbd_Rupture);
  free(pbd_Sync);
	exit(OK);
}

/*==============================================================================
 Objet :            Initialisation de la variable de gestion de rupture (Maitre)
 Parametre(s) :     Pointeur sur une structure T_RUPTURE_VAR
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_RuptureGTSII)
{
	memset(pbd_RuptureGTSII, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC1061_I1", "rt", &(pbd_RuptureGTSII->pf_InputFil)))
	    return ERR;
  pbd_RuptureGTSII->n_NbRupture = 1;
  pbd_RuptureGTSII->n_ConditionRupture[0] = n_ConditionRuptureGTSII;
	pbd_RuptureGTSII->n_ActionFirst[0] = n_ActionFistRuptureGTSII;
	pbd_RuptureGTSII->n_ActionLigne = n_ActionLignePereGTSII;
	pbd_RuptureGTSII->c_Separ       = '~';

	return OK;
}

/*==============================================================================
objet :
	fonction lancée à la rupture sur le fichier maître

retour :
	0 ---> pas de rupture
  1 ---> rupture
==============================================================================*/
int n_ConditionRuptureGTSII(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[])
{
  DEBUT_FCT("n_ConditionRuptureGTSII");

  if (strcmp(ptsz_LigneSuiv[GTSII_CTR_NF], ptsz_LigneCour[GTSII_CTR_NF])!=0)
		return(1);
  if (strcmp(ptsz_LigneSuiv[GTSII_SEC_NF], ptsz_LigneCour[GTSII_SEC_NF])!=0)
		return(1);
  if (strcmp(ptsz_LigneSuiv[GTSII_UWY_NF], ptsz_LigneCour[GTSII_UWY_NF])!=0)
		return(1);
  if (strcmp(ptsz_LigneSuiv[GTSII_END_NT], ptsz_LigneCour[GTSII_END_NT])!=0)
		return(1);
  if (strcmp(ptsz_LigneSuiv[GTSII_UW_NT], ptsz_LigneCour[GTSII_UW_NT])!=0)
		return(1);

	return( 0 );
}

/*==============================================================================
objet : fonction lancée à la rupture première sur le fichier maître

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionFistRuptureGTSII(char **pbd_InRec_Cur)
{
  DEBUT_FCT("n_ActionFistRuptureGTSII");

	gsz_seglobuwy[0] = 0;
	gsz_seg_nf[0] = 0;
	n_ProcessingRuptureSyncVar(pbd_Sync,pbd_InRec_Cur);

	return OK ;
}

/*==============================================================================
objet :
	Initialisation de la synchronisation

retour :
	OK
==============================================================================*/
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Rupt)
{
	memset(pbd_Rupt, 0, sizeof(T_RUPTURE_VAR));
	if (n_OpenFileAppl("ESTC1061_I2", "rt", &(pbd_Rupt->pf_InputFil)))
	    return ERR;

	pbd_Rupt->ConditionEndSync = n_ConditionSync;
	pbd_Rupt->n_ActionLigne    = n_ActionLigneFils;
	pbd_Rupt->c_Separ       = '~';

	return OK;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Maitre
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLignePereGTSII( char **ptb_InRec)
{
	char sz_ANO_SSD[12] = "";
	char *psz_SSD_CF = 0;

	//Sauvegarde du pointeur sur la valeur en entrée de la filiale au cas où écriture d'anomalies
	psz_SSD_CF = ptb_InRec[GTSII_SSD_CF];

	if (gsz_seg_nf[0] == 0)
	{//sortir fichier ano  : pas de segment
		sprintf(sz_ANO_SSD,"NOSYNC~%s",ptb_InRec[GTSII_SSD_CF]);
	  ptb_InRec[GTSII_SSD_CF] = sz_ANO_SSD;
		n_WriteCols(Kp_OutFileANO, ptb_InRec, '~', 0);
  	//RETURN_VAL(OK);
  }

	else
		if (gsz_seg_nf[0] != ' ') //si le segment n'est pas vide
		{
	 	ptb_InRec[GTSII_SEGLOB_CF] = gsz_seglobuwy;
	 	ptb_InRec[GTSII_SEG_NF] = gsz_seg_nf;
		}
		else
		{
			if (atoi(ptb_InRec[GTSII_NAT_CF]) < 30)
			{//sortir fichier ano  : pas de segment et nature Porportionnelle
				sprintf(sz_ANO_SSD,"NOSEGNATP~%s",ptb_InRec[GTSII_SSD_CF]);
			  ptb_InRec[GTSII_SSD_CF] = sz_ANO_SSD;
				n_WriteCols(Kp_OutFileANO, ptb_InRec, '~', 0);
	    	//RETURN_VAL(OK);
	    }
		}
	//restauration du pointeur sur la valeur en entrée de la filiale au cas où écriture d'anomalies
	ptb_InRec[GTSII_SSD_CF] = psz_SSD_CF;
	n_WriteCols(Kp_OutputGTCumul, ptb_InRec, '~', 0 );
 	RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de synchro ave le Père

retour :
	0 si synchronise,
  <0 si la ligne esclave est depassee
  >0 si la ligne esclave n'est pas depassee
==============================================================================*/
int n_ConditionSync( char *ptsz_LigneMaitre[], char *ptsz_LigneEsclave[] )
{
	static short s_ret;

   	DEBUT_FCT("n_ConditionSync");

   if ((s_ret = strcmp(ptsz_LigneMaitre[GTSII_CTR_NF], ptsz_LigneEsclave[PER_CTR_NF])))
      return s_ret;

   if ((s_ret = strcmp(ptsz_LigneMaitre[GTSII_SEC_NF], ptsz_LigneEsclave[PER_SEC_NF])))
      return s_ret;

   if ((s_ret = strcmp(ptsz_LigneMaitre[GTSII_UWY_NF], ptsz_LigneEsclave[PER_UWY_NF])))
      return s_ret;

   if ((s_ret = strcmp(ptsz_LigneMaitre[GTSII_END_NT], ptsz_LigneEsclave[PER_END_NT])))
      return s_ret;

   RETURN_VAL(strcmp(ptsz_LigneMaitre[GTSII_UW_NT], ptsz_LigneEsclave[PER_UW_NT])) ;
}

/*==============================================================================
 Objet :            Fonction lancee pour chaque ligne du Fils
 Parametre(s) :     Pointeur sur la ligne courante
 Retour :           En cas de probleme retourne ERR
                    sinon retourne OK
==============================================================================*/
int n_ActionLigneFils (char **pbd_InRecOwner, char **pbd_InRecChild)
{
 	sprintf(gsz_seglobuwy,"%s%s",pbd_InRecChild[PER_SEG_NF],pbd_InRecOwner[GTSII_RTY_NF]);
	strcpy(gsz_seg_nf,pbd_InRecChild[PER_SEG_NF]);

  return OK;
}
