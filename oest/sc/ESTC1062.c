/*==============================================================================
Nom de l'application          :
Nom du source                 : ESTC1062.c
Date de creation              : 11/09/2012
Auteur                        : Florent
References des specifications : :spot:24041
Squelette de base             : batch
------------------------------------------------------------------------------
Description : Reporter dans le périmètre le S/P

Fichier maitre  : IARDPERICASE trié sur SSD/SEG/UWY
Fichier esclave : EST_FSEGEST  trie sur SSD/SEG/UWY

Les traitements sont donc synchronises sur SSD/SEG

- Rupture de niveau 1 sur SSD/SEG,

prendre les ULR que sur les modes R et exercice=8888, sinon prendre exercice du périmetre, sinon zéro
sortir toutes les lignes du périmetre qui ne sont pas synchronisées (segment vide, par exe) => ANO LOG ?
------------------------------------------------------------------------------
Historique des modifications :
<jj/mm/aaaa>   <auteur>           <description de la modification>
==============================================================================*/

/*--------------------------------------------------*/
/* Inclusion des interfaces des composants importes */
/*--------------------------------------------------*/
#include <utctlib.h>
#include <stdarg.h>
#include "struct.h"
#include "estserv.h"

/*----------------------*/
/* Variables de travail */
/*----------------------*/
FILE *Kp_OutFileANO; /* Pointeur sur le fichier de sortie Périmètre pas synchronisé avec SEGEST*/
FILE *Kp_OutFilePER; /* Pointeur sur le fichier de sortie Périmètre*/
FILE *Kp_InFilePER; /* Pointeur sur le fichier de Périmètre*/
FILE *Kp_InFileSEGEST; /* Pointeur sur le fichier de sortie SEGEST*/
T_RUPTURE_VAR *pbd_Rupture; /* Pointeur sur la structure de la rupture */
T_RUPTURE_SYNC_VAR *pbd_Sync; /* Pointeur sur la structure de synchronisation */
#define NB_MAX_UWY_TSEGEST 50
typedef struct {
    char UWY[5];
    char SP_R[11];
}T_SEGEST_UWY_SP;
T_SEGEST_UWY_SP gtdb_segest[NB_MAX_UWY_TSEGEST];
int gi_cptsegest = 0; //compteur d'exercicesss pour le segment

char gsz_EXE[5] = ""; //Exercice recherché systématiquement dans TSEGEST

/*-----------------------------*/
/* Fonctions du fichier maitre */
/*-----------------------------*/
int n_InitRupture(T_RUPTURE_VAR  *pbd_Rupture);
int n_TestRupturePER(char *ptsz_LigneSuiv[], char *ptsz_LigneCour[]);
int n_ActionFistRupturePER(char **pbd_InRec_Cur);
int n_ActionLignePER(char *ptb_InRec_Cur[]);

/*--------------------------------------------------------------*/
/* Fonctions de la synchronisation entre le maitre et l'esclave */
/*--------------------------------------------------------------*/
int n_InitSync(T_RUPTURE_SYNC_VAR  *pbd_Rupture) ;
int n_ActionLigneSyncSEG(char **pbd_InRecOwner, char **pbd_InRecChild);
int n_ConditionSyncSEG(char **pbd_InRecOwner, char **pbd_InRecChild);

/*==============================================================================
objet :
   point d'entrée du programme

retour :
   En cas de problème, la sortie s'effectue par la fonction ExitPgm().
   Sinon, par l'appel système exit()
==============================================================================*/
int main(int argc, char *argv[])
{
  pbd_Rupture = malloc(sizeof(T_RUPTURE_VAR));
  pbd_Sync = malloc(sizeof(T_RUPTURE_SYNC_VAR));

  /* Initialisation des signaux */
  InitSig();

  if (n_BeginPgm(argc, argv) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_BeginPgm");
  }

	/* stockage des parametres du programme */
	sprintf(gsz_EXE,"%s",psz_GetCharArgv(1));

  /* Ouverture fichiers de sortie */
  if (n_OpenFileAppl("ESTC1062_O1", "wt", &Kp_OutFilePER) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
  }

  if (n_OpenFileAppl("ESTC1062_O2", "wt", &Kp_OutFileANO) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_OpenFileAppl");
  }

  /* Initialisation de la structure de rupture */
  if (n_InitRupture(pbd_Rupture) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_InitRupture");
  }

  /* Initialisation de la structure de synchronisation */
  if (n_InitSync(pbd_Sync) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_InitSync");
  }

  /* Lancement du traitement du fichier maitre */
  if (n_ProcessingRuptureVar(pbd_Rupture) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_ProcessingRuptureVar");
  }

  if (n_CloseFileAppl("ESTC1062_I1", &(pbd_Rupture->pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC1062_I2", &(pbd_Sync->pf_InputFil)) == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC1062_O1", &Kp_OutFilePER) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_CloseFileAppl("ESTC1062_O2", &Kp_OutFileANO) == ERR) {
    ExitPgm(ERR_XX , "Erreur appel fonction n_CloseFileAppl");
  }

  if (n_EndPgm() == ERR) {
    ExitPgm(ERR_XX, "Erreur appel fonction n_EndPgm");
  }

  free(pbd_Rupture);
  free(pbd_Sync);
  exit(OK);
}

/*==============================================================================
objet :
	fonction d'initialisation de la variable de gestion de rupture du fichier
	maitre.

retour :
	0K
==============================================================================*/
int n_InitRupture(
   T_RUPTURE_VAR *pbd_Rupture
)
{
  DEBUT_FCT("n_InitRupture");
  memset(pbd_Rupture, 0, sizeof(T_RUPTURE_VAR));

  /* Ouverture du fichier maitre */
  if (n_OpenFileAppl("ESTC1062_I1", "rt", &(pbd_Rupture->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Rupture->n_NbRupture=1;
  pbd_Rupture->n_ConditionRupture[0]=n_TestRupturePER;
	pbd_Rupture->n_ActionFirst[0]=n_ActionFistRupturePER;
  pbd_Rupture->n_ActionLigne=n_ActionLignePER;
  pbd_Rupture->c_Separ= '~';

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
	Initialisation de la synchronisation

retour :
	OK
==============================================================================*/
int n_InitSync(
   T_RUPTURE_SYNC_VAR  *pbd_Sync
)
{
  DEBUT_FCT("n_InitSync");
	n_WriteLog('A',"n_InitSync");
  memset(pbd_Sync, 0, sizeof(T_RUPTURE_SYNC_VAR));

  /* Ouverture du fichier esclave */
  if (n_OpenFileAppl("ESTC1062_I2", "rt", &(pbd_Sync->pf_InputFil)) == ERR) {
    RETURN_VAL(ERR);
  }
  pbd_Sync->ConditionEndSync=n_ConditionSyncSEG;
  pbd_Sync->n_ActionLigne=n_ActionLigneSyncSEG;
  pbd_Sync->c_Separ='~';

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction lancée à la rupture sur le fichier maître

retour :
	0 ---> pas de rupture
  1 ---> rupture
==============================================================================*/
int n_TestRupturePER(
   char *ptsz_LigneSuiv[],
   char *ptsz_LigneCour[]
)
{
  DEBUT_FCT("n_TestRupturePER");

  if (strcmp(ptsz_LigneSuiv[PIV_SSD_CF], ptsz_LigneCour[PIV_SSD_CF])!=0)
		return(1);
  if (strcmp(ptsz_LigneSuiv[PIV_SEGLOB_CF], ptsz_LigneCour[PIV_SEGLOB_CF])!=0)
		return(1);

	return( 0 );
}

/*==============================================================================
objet : fonction lancée à la rupture première sur le fichier maître

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionFistRupturePER(char **pbd_InRec_Cur)
{
  DEBUT_FCT("n_ActionFistRupturePER");

  memset(gtdb_segest,0,sizeof(gtdb_segest));
  gi_cptsegest = 0;
	n_ProcessingRuptureSyncVar(pbd_Sync,pbd_InRec_Cur);

	return OK ;
}

/*==============================================================================
objet : fonction lancee pour chaque ligne du fichier maitre

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionLignePER(char *ptb_InRec_Cur[])
{
	int n_seg_sp = -1;
	int n_premier_seg_sp = -1;
	char sz_ANO_SSD[9] = "";
	char *psz_SSD_CF = 0;
	int i = 0;/* Added for Phase1b Migration */

  DEBUT_FCT("n_ActionLigneRupture");

	//Sauvegarde du pointeur sur la valeur en entrée de la filiale au cas où écriture d'anomalies
	psz_SSD_CF = ptb_InRec_Cur[PIV_SSD_CF];

	//Ligne du périmètre sans lien avec segest
	if (!gi_cptsegest)
	{ //dans la ligne de l'ano, on mets la nature de l'ano avant la filiale
		sprintf(sz_ANO_SSD,"NOSEG~%s",ptb_InRec_Cur[PIV_SSD_CF]);
	  ptb_InRec_Cur[PIV_SSD_CF] = sz_ANO_SSD;
		n_WriteCols(Kp_OutFileANO, ptb_InRec_Cur, '~', 0);
	}
	else
	{
		//recherche du SP pour la ligne du périmètre
		for(i=0; i < gi_cptsegest ;i++) /* Updated for Phase1b Migration */
		{                                //exe du pivot inférieure à l'exe du segment
			if ( n_premier_seg_sp == -1 && strcmp(ptb_InRec_Cur[PIV_UWY_NF],gtdb_segest[i].UWY) < 0 )
			{
	    	n_premier_seg_sp = i;
			}
			if (strcmp(ptb_InRec_Cur[PIV_UWY_NF],gtdb_segest[i].UWY)==0 || strcmp(gtdb_segest[i].UWY,gsz_EXE)==0 )
	    	n_seg_sp = i;
		}
		if ( n_seg_sp < 0 )
			 n_seg_sp = n_premier_seg_sp;

		if ( n_seg_sp < 0 ) // pas de S/P pour l'exe du périmètre et pas d'exe comme dans gsz_EXE, dans segest, donc taux vide
		{  //dans la ligne de l'ano, on mets la nature de l'ano avant la filiale
			sprintf(sz_ANO_SSD,"NOSP~%s",ptb_InRec_Cur[PIV_SSD_CF]);
		  ptb_InRec_Cur[PIV_SSD_CF] = sz_ANO_SSD;
			n_WriteCols(Kp_OutFileANO, ptb_InRec_Cur, '~', 0);
		}
		else
		{
			//On mets à jour le tableau de pointeur de l'enr sur les nouvelles valeurs du S/P
			ptb_InRec_Cur[PIV_ULR_R] = gtdb_segest[n_seg_sp].SP_R;
			ptb_InRec_Cur[PIV_ULRY_NF] = gtdb_segest[n_seg_sp].UWY;
		}
	}

	//restauration du pointeur sur la valeur en entrée de la filiale au cas où écriture d'anomalies
	ptb_InRec_Cur[PIV_SSD_CF] = psz_SSD_CF;
  /* Ecriture du fichier en sortie */
  n_WriteCols(Kp_OutFilePER, ptb_InRec_Cur, '~',0);

  RETURN_VAL(OK);
}

/*==============================================================================
objet :
	fonction de test de rupture

retour :
	0 si synchronise,
  <0 si la ligne esclave est depassee
  >0 si la ligne esclave n'est pas depassee
==============================================================================*/
int n_ConditionSyncSEG(char **pbd_InRecOwner, char **pbd_InRecChild)
{
	int ret ;

  DEBUT_FCT("n_ConditionSyncSEG");

	ret = strcmp(pbd_InRecOwner[PIV_SSD_CF],pbd_InRecChild[SEGEST1_SSD_CF]);
	if( ret != 0 )
		return ret ;
	ret = strcmp(pbd_InRecOwner[PIV_SEGLOB_CF],pbd_InRecChild[SEGEST1_SEG_NF]);
	if( ret != 0 )
		return ret ;

	return( 0 ) ;
}

/*==============================================================================
objet :
	fonction lancée pour chaque ligne synchronisée avec le Père sur le fichier fils

retour :
	OK ---> traitement correctement effectué
	ERR --> problème rencontré
==============================================================================*/
int n_ActionLigneSyncSEG(char **pbd_InRecOwner, char **pbd_InRecChild)
{
  DEBUT_FCT("n_ActionLigneSyncSEG");

  if (pbd_InRecChild[SEGEST1_SP_CT][0] == 'R')
  {
    strcpy(gtdb_segest[gi_cptsegest].UWY,pbd_InRecChild[SEGEST1_UWY_NF]);
    strcpy(gtdb_segest[gi_cptsegest].SP_R,pbd_InRecChild[SEGEST1_SP_R]);
  	++gi_cptsegest;
  }
  RETURN_VAL(OK);
}
